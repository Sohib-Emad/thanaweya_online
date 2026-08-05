# Product

<!-- impeccable:product-schema 1 -->

## Platform

android

## Users

Primary users are Egyptian Thanaweya Amma (الثانوية العامة) high-school students, primarily on Android phones, in their final/prep study years. Their job: find, buy, and follow structured courses, lessons, and mock exams per subject and stage to prepare for the national exam. Secondary audiences (confirmed in the codebase but out of scope for the student home surface): teachers who author and sell courses, and admins who manage the platform.

## Product Purpose

Thanaweya Online is the all-in-one study hub for Thanaweya Amma: one app where students discover courses for every subject and stage (أول/ثاني/ثالث ثانوي), buy or activate them, watch lessons, take mock exams, and track progress. Success means a student can move from "which teacher/subject?" to "watching a lesson with progress tracked" without leaving the app.

## Positioning

The all-in-one Thanaweya Amma study hub: courses, lessons, mock exams, and progress for every subject and stage in one place, with real teacher profiles rather than faceless video aggregators. A neighboring app that only streams videos or only sells one teacher's courses cannot truthfully claim the full curriculum span.

## Operating Context

- Arabic-first, RTL interface; the student speaks and reads Arabic (Egyptian context), price and content strings are Egyptian.
- Primary device: Android phone, portrait; app is built for mobile (bottom-nav tabs), with Flutter desktop/web targets secondary.
- Student workflow: browse home (subjects, popular courses, top teachers) → course detail → subscribe/activate via codes or payment → lessons with progress → mock exams.
- Real data flows through Supabase via Repo → Cubit → Screen; students are authenticated with roles in `user_metadata`.
- Teachers sell access via subscription/activation codes; some lessons are free previews (`is_free_preview`).

## Capabilities and Constraints

- Confirmed features (student app): home dashboard with subject chips, search + filter, promo banner, popular courses, top teachers; my-courses list with real filters (subject + stage, stored in `CourseFilters`); course detail; lessons; mock exams; transactions; bookmarks; profile. Bottom nav: home, my courses, transactions, exams, profile.
- Architecture is feature-first + repository pattern (Screen ← Cubit ← Repo ← Supabase). State via flutter_bloc cubits; `ApiResult<T>` for success/failure; Arabic error strings.
- All screen text is hardcoded Arabic in the codebase today (not yet moved into `AppStrings`); RTL must hold everywhere.
- Typefaces: Cairo (Google Fonts) for Arabic. Responsive via `flutter_screenutil` (`.w`/`.h`/`.sp`).
- App supports light and dark modes; the student home surface is currently light-mode rendered.
- Tech constraints: Flutter, Supabase (Postgres + RLS + Auth). No image assets beyond icons in the current surface.
- Undecided: no confirmed marketing tagline; no app-store presence data; no confirmed student analytics.

## Brand Commitments

- Name: Thanaweya Online (ثانوية أونلاين).
- Mint/teal green identity is binding (student primary `#0FA37F`, light `#E6F7F2`, dark `#0B7B60`) — confirmed by the user to survive the redesign.
- Warm, encouraging Arabic voice for students (the greeting "مرحباً بك" tone); formal enough to stay credible for exam prep.
- The redesign replaces the visual world, not these commitments.

## Evidence on Hand

- Codebase evidence: real subject data and real teacher profiles load from Supabase (`subjects`, `teachers`, `courses`, `lesson_progress`); the enrolled-courses repo returns real title, teacher name, subject, and stage. No price, rating, or review data is currently queried for home cards — do not fabricate prices, ratings, testimonials, benchmarks, or marketing claims.
- No design documentation exists (no PRODUCT.md/DESIGN.md prior to this file) — the previous look is evidence of what the product is, not authority over what it becomes.

## Product Principles

1. A student must always know their place in the study journey: subject, stage, and progress are never ambiguous.
2. Real content beats decoration: every card, chip, and row represents live data, never a hardcoded mock.
3. One mental model per screen: the home tab is a launchpad into courses and teachers, not a wall of promotions.
4. Pressure is real (national exam); the surface should feel like a calm, structured study companion, not a noisy marketplace.
5. Speed and clarity over flourish: an Android-first, Arabic RTL surface must stay legible on a phone in one hand.

## Accessibility & Inclusion

- RTL text direction and Cairo typeface must be preserved (Arabic legibility).
- Dark mode is supported by the app's theme system and should not regress.
- All interactive elements must remain tappable at phone sizes; no text-overflow on small screens.
