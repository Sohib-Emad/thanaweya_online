// Supabase Edge Function: notify-user
//
// Reads a notification row (by id), looks up the user's FCM device tokens and
// sends a Firebase Cloud Messaging HTTP v1 message to each of them.
//
// Secrets required:
//   FIREBASE_SERVICE_ACCOUNT  base64-encoded Firebase service-account JSON
//                             (Firebase Console -> Project settings ->
//                              Service accounts -> Generate new private key)
//   SUPABASE_SERVICE_ROLE_KEY (provided automatically by Supabase)
//
// Deploy:
//   supabase secrets set FIREBASE_SERVICE_ACCOUNT="$(base64 -i fb-sa.json)"
//   supabase functions deploy notify-user

import { createClient } from "jsr:@supabase/supabase-js@2";
import { SignJWT, importPKCS8 } from "npm:jose@^5.9.6";

const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const serviceAccountB64 = Deno.env.get("FIREBASE_SERVICE_ACCOUNT");

const supabase = createClient(supabaseUrl, serviceRoleKey, {
  auth: { persistSession: false },
});

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

// Exchanges the Firebase service-account credentials for a short-lived OAuth2
// access token that authorizes FCM HTTP v1 calls.
async function getFcmAccessToken(sa: Record<string, string>): Promise<string> {
  const now = Math.floor(Date.now() / 1000);
  const jwt = await new SignJWT({
    scope: "https://www.googleapis.com/auth/firebase.messaging",
  })
    .setProtectedHeader({ alg: "RS256", typ: "JWT" })
    .setIssuer(sa.client_email)
    .setSubject(sa.client_email)
    .setAudience(sa.token_uri)
    .setIssuedAt(now)
    .setExpirationTime(now + 3600)
    .sign(await importPKCS8(sa.private_key, "RS256"));

  const res = await fetch(sa.token_uri, {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: jwt,
    }),
  });

  if (!res.ok) {
    throw new Error(`token exchange failed: ${res.status} ${await res.text()}`);
  }
  const data = await res.json();
  return data.access_token as string;
}

// Sends one FCM HTTP v1 message. Returns the raw response so the caller can
// detect invalid (unregistered) tokens.
async function sendFcmMessage(
  accessToken: string,
  projectId: string,
  token: string,
  notification: { id: string; title: string; body: string; category: string },
): Promise<Response> {
  return fetch(
    `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${accessToken}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        message: {
          token,
          notification: {
            title: notification.title,
            body: notification.body || notification.category || "",
          },
          data: {
            notificationId: notification.id,
            category: notification.category || "system",
            click_action: "FLUTTER_NOTIFICATION_CLICK",
          },
          android: { priority: "HIGH" },
          apns: {
            headers: { "apns-priority": "10", "apns-push-type": "alert" },
          },
        },
      }),
    },
  );
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return json({ error: "method_not_allowed" }, 405);

  let body: { notification_id?: string };
  try {
    body = await req.json();
  } catch {
    return json({ error: "invalid_json" }, 400);
  }

  const notificationId = body.notification_id;
  if (!notificationId) return json({ error: "notification_id_required" }, 400);

  const { data: notification, error: nErr } = await supabase
    .from("notifications")
    .select("id, user_id, title, body, category")
    .eq("id", notificationId)
    .single();

  if (nErr || !notification) {
    return json({ error: "notification_not_found" }, 404);
  }

  const { data: tokens, error: tErr } = await supabase
    .from("device_tokens")
    .select("id, token")
    .eq("user_id", notification.user_id);

  if (tErr) return json({ error: tErr.message }, 500);

  if (!tokens || tokens.length === 0) {
    return json({ ok: true, skipped: "no_device_tokens" });
  }

  if (!serviceAccountB64) {
    return json({ error: "FIREBASE_SERVICE_ACCOUNT secret not set" }, 500);
  }

  let sa: Record<string, string>;
  try {
    sa = JSON.parse(atob(serviceAccountB64));
  } catch {
    return json({ error: "FIREBASE_SERVICE_ACCOUNT is not valid base64 JSON" }, 500);
  }

  let accessToken: string;
  try {
    accessToken = await getFcmAccessToken(sa);
  } catch (e) {
    console.error("token exchange error:", e);
    return json({ error: "fcm_auth_failed" }, 502);
  }

  const results: Array<{ token: string; status: number }> = [];
  for (const { id, token } of tokens) {
    try {
      const res = await sendFcmMessage(accessToken, sa.project_id, token, {
        id: notification.id as string,
        title: notification.title as string,
        body: (notification.body as string) || "",
        category: (notification.category as string) || "system",
      });
      // 404 = token is valid but the app instance was deleted;
      // 410 = token is no longer valid (uninstalled / refreshed).
      if (res.status === 404 || res.status === 410) {
        await supabase.from("device_tokens").delete().eq("id", id);
      }
      results.push({ token: token.slice(0, 8) + "…", status: res.status });
    } catch (e) {
      console.error("send error:", e);
      results.push({ token: token.slice(0, 8) + "…", status: -1 });
    }
  }

  return json({ ok: true, results });
});
