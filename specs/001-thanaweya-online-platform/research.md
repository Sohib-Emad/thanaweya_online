# Research: Thanaweya Online Platform

**Date**: 2026-07-21

## Technology Decisions

### State Management: Riverpod

- **Decision**: Use flutter_riverpod for state management
- **Rationale**: Riverpod is the recommended state management for new Flutter projects. It provides compile-safe providers, easy dependency injection, and works well with Supabase. It's more modern than Provider and simpler than Bloc for this scale.
- **Alternatives considered**: Bloc (more boilerplate), Provider (older, less type-safe), GetX (opinionated, less community trust)

### Navigation: GoRouter

- **Decision**: Use go_router for declarative routing
- **Rationale**: GoRouter supports deep linking, nested navigation, redirect guards for role-based access, and is the officially recommended router for Flutter. Essential for the multi-role navigation structure.
- **Alternatives considered**: AutoRoute (code generation overhead), Navigator 2.0 (too verbose)

### Video Playback: youtube_player_flutter

- **Decision**: Use youtube_player_flutter for YouTube video embedding
- **Rationale**: Renders YouTube videos in-app without launching external app. Supports custom controls. The simplified interface (no related videos) is achievable through configuration.
- **Alternatives considered**: webview_flutter (heavier, less native feel), launching external YouTube app (breaks UX)

### Supabase as Backend

- **Decision**: Supabase for auth, database, storage, and realtime
- **Rationale**: Provides PostgreSQL with Row Level Security (critical for multi-tenant isolation), built-in auth with role support, file storage for video/images, and realtime subscriptions. Eliminates need for custom backend server.
- **Alternatives considered**: Firebase (less control over RLS, vendor lock-in), custom backend (too much overhead for MVP)

### Payment Gateway: Paymob

- **Decision**: Paymob for electronic payments
- **Rationale**: Most widely used in Egyptian startups. Supports credit/debit cards, Vodafone Cash, Fawry, and mobile wallets. Has a Flutter SDK. Single integration covers multiple payment methods.
- **Alternatives considered**: Fawry (limited to their network), Kashier (newer, less proven)

### Video Hosting: YouTube (Phase 2) + Bunny.net (Phase 3+)

- **Decision**: YouTube for initial launch, Bunny.net Stream for premium content
- **Rationale**: YouTube is free, instantly available, and requires no setup. Bunny.net provides DRM-like protection for paid content. Phased approach allows launching faster.
- **Alternatives considered**: Cloudflare Stream (similar to Bunny.net, less Egyptian market presence), self-hosted (prohibitive cost)

## Arabic RTL Implementation

- Flutter natively supports RTL through the `Directionality` widget
- Set `locale` and `supportedLocales` in MaterialApp
- Use `textDirection: TextDirection.rtl` in relevant widgets
- Arabic fonts: Cairo or Tajawal (Google Fonts) for clean Arabic typography
- All padding/mirroring should use `EdgeInsetsDirectional` instead of `EdgeInsets`

## Offline Handling

- Use `connectivity_plus` package to detect network state
- Show `OfflineScreen` widget when no connection detected
- Supabase client automatically queues writes when offline (with caveats)
- Video playback requires internet — show appropriate message when offline

## Content Protection Strategy

- YouTube videos: Use unlisted links only, simplified player (no related videos)
- Uploaded videos: Host on Bunny.net Stream with signed URLs and DRM
- Free preview lessons: Marked with `is_free_preview` flag, accessible without subscription
- Paid content: Gated by RLS policy checking active subscription
