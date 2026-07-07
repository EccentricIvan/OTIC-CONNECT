# Otic Connect

## Project Overview
Otic Connect is an offline-first, AI-powered digital empowerment ecosystem for women in Sub-Saharan Africa. Built with Flutter, it supports Android, Windows, and Web. It evolved from Otic Studio v3.

## Tech Stack
- **Framework**: Flutter 3.44+ / Dart 3.12+
- **State**: flutter_riverpod
- **Navigation**: go_router with ShellRoute
- **Database**: Drift (SQLite)
- **Theme**: Material Design 3, "Terracotta Blush" design tokens (see below)

## Design System — "Terracotta Blush"
All colors and fonts are tokens in `lib/core/theme/app_colors.dart` and
`app_theme.dart` — feature screens should reference these, not hardcode hex.
- **Background**: warm blush cream (`bgTop`/`bgBottom`, `#FAF1EC`)
- **Surfaces**: white cards (`surface`) with a soft `#F0E2DA` border (`border`)
- **Brand**: terracotta (`primary`/`accent`, `#C96F4A`) drives buttons, active
  nav, and links; `secondary` is a muted teal
- **Reward color**: `gold` (`#D4A24E`) — used only for points/streak/milestone
  UI, kept distinct from the terracotta brand color
- **Text tiers**: three solid (non-alpha) colors so contrast is guaranteed
  regardless of background — `textPrimary` (headings, `#3A2E29`),
  `textSecondary` (body, `#4A403B`), `textHint` (captions/secondary — the
  floor, `#6E5F57`, never go lighter)
- **Category colors**: each Learn topic / pillar has a fixed color
  (`skillsColor` violet, `financeColor` teal, `marketplaceColor` terracotta,
  `agricultureColor` leaf green, `healthColor`/`thriveColor` rose, etc.) used
  for card left-bars, tinted icon backgrounds, and lesson-count pills
- **Typography**: two-font pairing — `Saira` (variable font,
  `assets/fonts/Saira-Variable.ttf`) for headings/display text, contrasted
  with `PlusJakartaSans` for body copy, optimized for legibility on cheap,
  dim, low-DPI screens
- **Tap affordance**: `lib/shared/widgets/tap_scale.dart` wraps tappable
  cards with ripple + a subtle 0.98 press-down scale

## Architecture
- `lib/core/` — theme (colors/fonts), router, l10n, app-level config
- `lib/shared/widgets/` — reusable UI components (cards, nav shell, tap_scale)
- `lib/features/` — feature screens organized by pillar (learn, earn, grow, thrive)
- `lib/db/` — Drift database, tables, DAOs (scaffolded, not yet implemented)
- `lib/safety/` — emotional safety engine from Otic Studio (scaffolded, not yet implemented)

## Key Pillars
- **Learn** — courses, digital skills, financial literacy
- **Earn** — marketplace, financial hub, business tools
- **Grow** — mentorship, jobs, skills training
- **Thrive** — health, community, wellbeing

## Navigation
`lib/shared/widgets/app_shell.dart` renders the wide side-nav and the mobile
drawer from one grouped destination list (`AppShell._sections`): **Learn &
Earn** (Home, Learn, Market, Finance), **Grow** (Mentors, Jobs, Skills),
**Thrive** (Health, Community, Wellbeing), **Account** (AI Chat, Profile,
Settings). The mobile bottom nav bar (`_destinations`) is a separate,
shorter 5-item list. The active item gets a terracotta tint + icon/label
color + a 3px left indicator bar.

## Build Commands
```
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run -d windows
flutter run -d android
flutter build apk --release
```

**Windows + split-drive gotcha**: if the Flutter SDK and this project live on
different drive letters (e.g. SDK on `E:`, project on `C:`), the Kotlin
incremental compiler crashes trying to compute a relative path across drive
roots. `android/gradle.properties` sets `kotlin.incremental=false` to work
around this — don't remove it without verifying a same-drive build first.

## Design Principles
- Offline-first: works without internet, syncs when connected
- Women-centered: tailored onboarding, relevant content
- Accessible: low-bandwidth, low-spec device friendly
- Localised: support for Luganda, Swahili, and local context

## Localization status
`lib/core/l10n/app_strings.dart` defines `AppLocale` and the `_strings`
lookup table (`S.tr`, with safe fallback: `locale → English → raw key`).
- **Fully translated**: English (`en`), Luganda (`lg`), Kiswahili (`sw`)
- **Enum entries added, not yet translated** (merged via PR #1 from
  `esianaemmah-dev`, 2026-07-06): Acholi, Alur, Rukiga, Ateso, Lusoga,
  Lugbara, Lumasaba, Runyankole, Runyoro, Rutooro, Lango, Karamojong,
  Kumam, Jopadhola, Ma'di, Samia, Kupsabiny — these currently render in
  English until someone fills in their `_strings` entries

## Open collaborator PRs (as of 2026-07-07, not yet merged)
From `esianaemmah-dev`, both CI-green, pick up here next session:
- **PR #2** "Keep AI chat responses in selected language" — touches
  `lib/features/ai_chat/ai_chat_screen.dart`, `lib/services/gemini_service.dart`
  (the Groq client), `.github/workflows/build.yml`, and adds
  `docs/PHASE1_LOCAL_LANGUAGE_TRANSLATION_MATRIX.md`
- **PR #3** "Add Groq-powered local language AI backend" — adds a new
  standalone Python/FastAPI service under `AI_BACKEND/` (routes, services,
  translation schema) as a separate microservice, not yet wired into the
  Flutter app. This is a significant architectural addition — review scope
  and integration plan before merging.

## APK distribution (manual release flow)
CI (`.github/workflows/build.yml`) builds split-per-abi release APKs on
every push/PR to `main` via `flutter build apk --release --split-per-abi`,
using the `GROQ_API_KEY` repo secret. Artifacts land as run artifacts
(`otic-connect-v<run>-arm64` / `-arm32`), not automatically published.
To hand someone a phone-installable build:
1. `gh run download <run-id> -n otic-connect-v<run>-arm64 -D <dir>`
2. Zip the APK before distributing — Android Chrome silently kills direct
   `.apk` browser downloads (flagged as a risky file type); a `.zip`
   wrapper avoids this and gets extracted + installed manually
3. Upload both the raw `.apk` and the `.zip` to the standing GitHub
   Release tag **`otic-connect-v6`** with `gh release upload ... --clobber`
   so the download links stay stable across rebuilds:
   - `https://github.com/EccentricIvan/OTIC-CONNECT/releases/download/otic-connect-v6/OticConnect-arm64.zip`
   - `https://github.com/EccentricIvan/OTIC-CONNECT/releases/download/otic-connect-v6/OticConnect-arm64.apk`

**Windows local build note**: `E:\dev\flutter\bin` is not on default PATH
on this machine; prepend it before running `flutter` commands.
