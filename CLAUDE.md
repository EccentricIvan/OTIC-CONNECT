# Otic Connect

## Project Overview
Otic Connect is an offline-first, AI-powered digital empowerment ecosystem for women in Sub-Saharan Africa. Built with Flutter, it supports Android, Windows, and Web. It evolved from Otic Studio v3.

## Tech Stack
- **Framework**: Flutter 3.44+ / Dart 3.12+
- **State**: flutter_riverpod
- **Navigation**: go_router with ShellRoute
- **Database**: Drift (SQLite)
- **Theme**: Material Design 3 with custom PlusJakartaSans font

## Architecture
- `lib/core/` — theme, router, app-level config
- `lib/shared/widgets/` — reusable UI components
- `lib/features/` — feature screens organized by pillar (learn, earn, grow, thrive)
- `lib/db/` — Drift database, tables, DAOs
- `lib/safety/` — emotional safety engine (from Otic Studio)

## Key Pillars
- **Learn** — courses, digital skills, financial literacy
- **Earn** — marketplace, financial hub, business tools
- **Grow** — mentorship, jobs, skills training
- **Thrive** — health, community, wellbeing

## Build Commands
```
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run -d windows
flutter run -d android
flutter build apk --release
```

## Design Principles
- Offline-first: works without internet, syncs when connected
- Women-centered: tailored onboarding, relevant content
- Accessible: low-bandwidth, low-spec device friendly
- Localised: support for Luganda, Swahili, and local context
