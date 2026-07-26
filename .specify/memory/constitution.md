# Thanaweya Online Constitution

## Core Principles

### I. Multi-Tenant Data Isolation (NON-NEGOTIABLE)
Every teacher's data MUST be completely isolated from other teachers. Students MUST only access content from teachers they are subscribed to. Row Level Security (RLS) MUST enforce data boundaries at the database level. No teacher should ever be able to view, modify, or access another teacher's data, courses, students, or analytics.

### II. Arabic-First RTL Interface
The entire application interface MUST support Arabic as the primary language with right-to-left (RTL) layout. All screens, navigation, forms, and content MUST render correctly in RTL. English or any other language support is optional and must not compromise the Arabic-first experience.

### III. Phased Incremental Delivery
The project MUST be delivered in ordered phases where each phase produces a complete, runnable increment. No phase may begin until all blocking dependencies from prior phases are verified complete. Each phase MUST be independently testable and demonstrable.

### IV. Offline-Resilient User Experience
The application MUST gracefully handle network disconnection. Users MUST see a clear offline state screen. Data entered offline MUST be preserved locally where feasible. The app MUST NOT crash or show unhandled errors during connectivity loss.

### V. Role-Based Access Control (RBAC)
Three distinct roles exist: Super Admin, Teacher (Tenant), and Student. Every screen, action, and data access MUST be gated by the user's role. Role transitions (e.g., teacher approval by Super Admin) MUST be enforced server-side. Students MUST NOT access teacher dashboard features and vice versa.

### VI. Simplicity Over Premature Optimization
Start with the simplest correct implementation. No premature performance optimization, caching layers, or complex abstractions unless a specific, measurable need justifies them. The tech stack is Flutter + Supabase — leverage their built-in capabilities before adding third-party solutions.

### VII. Content Protection First
Free preview content MUST be clearly distinguishable from paid content. Video access MUST be gated by subscription status. Teachers MUST have control over which content is free vs. paid. The system MUST prevent unauthorized access to premium content through proper authorization checks.

## Security & Data Protection

- Never store payment card data directly — delegate to certified payment gateways
- Supabase RLS policies MUST be tested for every new table
- Teacher approval workflow MUST require Super Admin intervention
- Student-teacher subscription MUST require activation (code or payment)
- All API keys and secrets MUST be stored in environment variables, never in code

## Development Workflow

- Code follows the Flutter project structure defined in the comprehensive platform document
- State management via Riverpod or Bloc (consistent choice across all features)
- All database migrations MUST be versioned and reversible
- UI follows the design system: Primary blue (#1D4ED8) for teachers, Secondary turquoise (#0FA37F) for students
- Dark mode support is deferred but the architecture MUST accommodate it from the start

## Governance

This constitution supersedes all other development practices. Any requirement, plan, or task that conflicts with these principles MUST be adjusted to comply. Amendments require documentation of the change, rationale, and impact on existing artifacts.

**Version**: 1.0.0 | **Ratified**: 2026-07-21 | **Last Amended**: 2026-07-21
