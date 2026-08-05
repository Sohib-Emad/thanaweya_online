---
version: 1
slug: "ures-student-ui-dashboard-student-home-screen-dart"
primary_target: "lib/features/student/ui/dashboard/student_home_screen.dart"
related_targets: []
---

# Surface brief: student home dashboard

## Scope and visitor mode
Student home tab (mobile, Android-first, Arabic RTL). Operate mode: a launchpad for finding courses and teachers by subject and stage.

## Audience
Egyptian Thanaweya Amma students on a phone, one hand, in their study years. Task: know their place in the journey (stage + subject), find and open a course or teacher quickly, filter by subject/stage.

## Job, action, proof
Primary action: pick a subject → see matching courses/teachers → open a course. Proof: real subjects, real enrolled courses, real approved teachers from Supabase; every card/chip/row is live data.

## Constraints
Keep all sections (greeting, search+filter, promo, subjects, courses, top teachers), bottom nav, routing, and green identity (#0FA37F). Real data via cubits. RTL + Cairo. Dark mode must not regress. Remove ~1400 lines of dead code.

## Chosen direction
الدفتر (ruled school notebook) — dealt by concept roll. Cream ruled-paper ground, signature red margin down every screen, headings written like notebook titles, teacher star-grades in the margin, green as highlighter ink. Home = notebook cover + first page: greeting/stage like the class line, subjects as margin tabs, courses as summary pages, promo as a stamped خصم seal.

## Memorable moment
The red margin line carrying the subject index; pulling a margin tab filters the day's courses; a course card reads like a ruled summary page with the teacher's name signed at the top.

## Unresolved
Exact ruled-line weight and paper tone in dark mode; whether the red margin persists onto course-detail/exam screens (cross-surface reach is desired but out of this build's scope).
