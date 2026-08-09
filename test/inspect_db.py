import os
import urllib.request
import json

def get_supabase_data(url, key, table):
    headers = {
        'apikey': key,
        'Authorization': f'Bearer {key}'
    }
    req = urllib.request.Request(f"{url}/rest/v1/{table}?select=*", headers=headers)
    try:
        with urllib.request.urlopen(req) as response:
            return json.loads(response.read().decode())
    except Exception as e:
        print(f"Error reading {table}: {e}")
        return []

def main():
    # Load .env manually
    env = {}
    if os.path.exists('.env'):
        with open('.env') as f:
            for line in f:
                if '=' in line:
                    k, v = line.strip().split('=', 1)
                    env[k] = v

    url = env.get('SUPABASE_URL', '')
    key = env.get('SUPABASE_ANON_KEY', '')

    if not url or not key:
        print("Missing SUPABASE_URL or SUPABASE_ANON_KEY")
        return

    print("--- USERS ---")
    users = get_supabase_data(url, key, 'users')
    for u in users:
        print(f"ID: {u.get('id')} | Email: {u.get('email')} | Role: {u.get('role')} | Name: {u.get('full_name')}")

    print("\n--- STUDENTS ---")
    students = get_supabase_data(url, key, 'students')
    for s in students:
        print(f"ID: {s.get('id')} | Grade: {s.get('grade_level')} | Parent Phone: {s.get('parent_phone')}")

    print("\n--- SUBSCRIPTIONS ---")
    subs = get_supabase_data(url, key, 'subscriptions')
    for sub in subs:
        print(f"ID: {sub.get('id')} | Student: {sub.get('student_id')} | Teacher: {sub.get('teacher_id')} | Status: {sub.get('status')}")

    print("\n--- PAYMENTS ---")
    payments = get_supabase_data(url, key, 'payments')
    for p in payments:
        print(f"ID: {p.get('id')} | Payer: {p.get('payer_id')} | Course: {p.get('course_id')} | Amount: {p.get('amount')} | Gateway: {p.get('payment_gateway')} | Status: {p.get('status')}")

    print("\n--- EXAMS ---")
    exams = get_supabase_data(url, key, 'exams')
    for ex in exams:
        print(f"ID: {ex.get('id')} | Title: {ex.get('title')} | Teacher: {ex.get('teacher_id')} | Published: {ex.get('is_published')} | Start: {ex.get('start_at')} | End: {ex.get('end_at')}")

if __name__ == '__main__':
    main()
