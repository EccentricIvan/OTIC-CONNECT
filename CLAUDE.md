# Africa AI Connect

## Project Overview
Africa AI Connect is an offline-first, AI-powered digital empowerment ecosystem for women in Sub-Saharan Africa. Built with Flutter, it supports Android, Windows, and Web. It evolved from Otic Studio v3, under the working name "Otic Connect" — some internal identifiers (Dart package name `otic_connect`, Android `applicationId com.oticgroup.otic_connect`, local SQLite filename) intentionally still use the old name to avoid breaking app updates/signing continuity for existing installs. User-facing text, the app icon, and all display names use the new branding.

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
- `lib/db/` — Drift database. `tables/users_table.dart`, `daos/user_dao.dart`,
  `database.dart` (the `AppDatabase` class), `providers/database_provider.dart`
  (Riverpod wiring) — see **Data layer** below. Only `users` exists so far;
  everything else (marketplace, mentorship, jobs, courses, etc.) is still
  hardcoded mock data in the widgets — follow this same table → DAO →
  provider pattern when building those out.
- `lib/safety/` — emotional safety engine from Otic Studio (scaffolded, not yet implemented)
- `AI_BACKEND/` — a standalone Python/FastAPI service (chat + translation,
  calls Groq itself) merged from a collaborator PR. **Not wired into the
  Flutter app** — nothing in `lib/` calls it, and it has no deployment
  config. Treat as an unintegrated prototype, not live infrastructure.

## Roadmap — mock data & non-functional buttons to replace
Full audit as of 2026-07-08. Follow the `users`/`UserDao`/`currentUserProvider`
pattern (see **Data layer**) for each: a table, a DAO, a provider, then wire
the screen to it. Ordered by rough priority.

- **Wellbeing "Get Help" button** (`thrive/wellbeing/wellbeing_screen.dart`)
  — a no-op crisis-support CTA. Small scope (helpline directory + `url_launcher`
  tel: links, no DB needed), but high-stakes to leave broken. Do this one
  first regardless of what else is picked.
- **Learn** (`learn/learn_hub_screen.dart`) — `_Cat` category cards and
  featured-course cards are `onTap: () {}`; hero stats (course count,
  points, milestone progress) are hardcoded. Needs `courses` +
  `user_course_progress` tables.
- **Skills** (`grow/skills/skills_screen.dart`) — all 4 `FeatureCard`s are
  no-op, no backing model at all. Same `courses`-style table as Learn.
- **Marketplace** (`earn/marketplace/marketplace_screen.dart`) — search
  icon, "List a Product", "See all", and category grid cells are all
  no-op; `_Listing` is a hardcoded 3-item list. Needs a
  `marketplace_listings` table (seller, title, price, category, location,
  created_at) — reasonable next vertical slice.
- **Mentorship** (`grow/mentorship/mentorship_screen.dart`) — "Connect" and
  "Apply to Mentor" buttons are no-op; `_Mentor` list is hardcoded. Needs
  `mentors` + `mentor_connections` tables.
- **Jobs** (`grow/jobs/jobs_screen.dart`) — search and "Create CV" are
  no-op; job list items have **no `onTap` at all** (not even a stub — tapping
  does literally nothing). `_Job` list is hardcoded. Needs a `jobs` table.
- **Community** (`thrive/community/community_screen.dart`) — "group_add"
  icon, "Create a Group", "Join", and Like/Comment/Share (×3 per post) are
  all no-op. Needs `groups` + `group_members` + `community_posts` tables.
- **Health** (`thrive/health/health_screen.dart`) — resource cards and the
  "directions" button are no-op; `_Facility` list has **hardcoded distance**
  (`distKm`) instead of real geolocation math. Needs `health_facilities` +
  `health_resources` tables.
- **Financial Hub** (`earn/financial/financial_hub_screen.dart`) — Savings
  Tracker, Budget Planner, SACCO Directory, and Mobile Money Guide all go
  nowhere; **zero data model exists** for this pillar at all (greenfield —
  needs `savings_goals`, `budget_entries`, `sacco_directory` tables).
- **AI Chat** (`ai_chat/ai_chat_screen.dart`) — messages are in-memory
  only (`List<_ChatMessage>` in State), lost on screen dispose/app
  restart. Needs `chat_sessions` + `chat_messages` tables.
- **Profile** (`profile/profile_screen.dart`) — edit icon is no-op; the
  "Achievements" badge grid shows 5 badges as if all earned (`_badges`
  static list, no real unlock tracking). Needs `achievements` +
  `user_achievements` tables.
- **Home** (`home/home_screen.dart`) — search and notifications icons are
  no-op.
- **Settings** (`settings/settings_screen.dart`) — sync/notification
  toggles are hardcoded `value: true` with no-op `onChanged`; "Storage
  usage" and "Terms/Privacy" links go nowhere.

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

## Data layer
`lib/db/` uses Drift (SQLite). Pattern per feature: a `Table` class under
`tables/`, a `@DriftAccessor` DAO under `daos/` (registered on
`AppDatabase` in `database.dart`), and Riverpod providers in
`providers/database_provider.dart` exposing it to widgets — see `Users` /
`UserDao` / `currentUserProvider` as the reference implementation. Screens
consume a `StreamProvider` so writes update the UI reactively with no
manual reload plumbing.

After adding/changing any table or DAO, regenerate code:
```
dart run build_runner build --delete-conflicting-outputs
```
This produces `.g.dart` files that are gitignored (correctly — generated
code shouldn't be committed). **CI must run this same command before
building the APK** (`.github/workflows/build.yml` has a "Generate code"
step) — without it, the build fails with "Error when reading
'lib/db/database.g.dart': No such file or directory" since the source
files reference a generated `part` file that was never created.

**Windows storage path gotcha**: `drift_flutter`'s `driftDatabase()` helper
puts the SQLite file in the user's **Documents** folder
(`Documents\otic_connect.sqlite`), while `shared_preferences` on Windows
uses a different Roaming AppData folder
(`AppData\Roaming\com.oticgroup\otic_connect\shared_preferences.json`).
Useful to know if you're debugging persistence and checking the wrong file.

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
(`sqlite3_flutter_libs`'s native Windows build has not shown this issue —
it ships prebuilt binaries rather than compiling from source.)

## Design Principles
- Offline-first: works without internet, syncs when connected
- Women-centered: tailored onboarding, relevant content
- Accessible: low-bandwidth, low-spec device friendly
- Localised: support for Luganda, Swahili, and local context

## Localization status
`lib/core/l10n/app_strings.dart` defines `AppLocale` and the `_strings`
lookup table (`S.tr`, with safe fallback: `locale → English → raw key`).
- **Supported**: English (`en`), Luganda (`lg`), Kiswahili (`sw`) — the only
  three with real translations and Groq AI-chat language instructions
  (`lib/services/gemini_service.dart`'s `getAiLanguageInstruction`)
- An earlier PR briefly added 17 more Ugandan-language enum entries with no
  translations behind them; a follow-up PR deliberately reverted that back
  to these 3, since untranslated entries just silently rendered English —
  confusing, not actually multilingual. If more languages come back, add
  real `_strings` entries in the same PR, not just the enum case.
- No flag emojis in the language picker (removed deliberately) — just
  language name + code.

## APK distribution (manual release flow)
CI (`.github/workflows/build.yml`) builds split-per-abi release APKs on
every push/PR to `main` via `flutter build apk --release --split-per-abi`,
using the `GROQ_API_KEY` repo secret. Artifacts land as run artifacts
(`africa-ai-connect-v<run>-arm64` / `-arm32`), not automatically published.
To hand someone a phone-installable build:
1. `gh run download <run-id> -n africa-ai-connect-v<run>-arm64 -D <dir>`
2. Zip the APK before distributing — Android Chrome silently kills direct
   `.apk` browser downloads (flagged as a risky file type); a `.zip`
   wrapper avoids this and gets extracted + installed manually
3. Upload both the raw `.apk` and the `.zip` to the standing GitHub
   Release tag **`africa-ai-connect-v1`** (repo was renamed from
   `OTIC-CONNECT` to `AFRICA-AI-CONNECT`; the old `otic-connect-v6` tag
   still exists with legacy download links, GitHub auto-redirects the old
   repo URL, but use the new tag for anything going forward).

**Use a unique, version-stamped filename every time** (e.g.
`AfricaAiConnect-arm64-v23.apk`), not a fixed name overwritten via `--clobber`.
A collaborator once got a stale build after a key rotation because their
browser/GitHub's CDN cached the old file at the same unchanging URL — the
underlying asset had changed but the URL hadn't, so there was no reliable
way to force a fresh fetch. A new filename sidesteps this entirely since
it's a genuinely new URL. If you need to confirm a specific value (like an
API key) actually made it into a given build, don't assume — extract and
grep the compiled binary directly:
```
unzip -q app.apk lib/arm64-v8a/libapp.so
grep -a -o "gsk_[A-Za-z0-9]\{20,60\}" lib/arm64-v8a/libapp.so
```

**Windows local build note**: `E:\dev\flutter\bin` is not on default PATH
on this machine; prepend it before running `flutter` commands.
