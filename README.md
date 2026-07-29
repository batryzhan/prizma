# Prizma

Prizma is now a **Flutter Web** learning workspace. It combines a public landing page with a responsive, local-first dashboard for peer help, learning focus, progress, and community.

The visual language takes inspiration from Horizon UI's clear dashboard hierarchy, but this project contains no Chakra UI or React code.

## Included screens

- Landing page with product overview and call to action
- Dashboard with learning metrics, daily plan, level progress, SOS preview, and guild pulse
- SOS requests: search, filters, creation, helping, and safe deletion of your own request
- Subjects catalogue with focused study cards
- Guild with members, invite flow, and local chat
- Leaderboard, progress, profile, and settings screens
- Responsive sidebar / drawer navigation and light or dark mode

## Run locally

Use Flutter 3.44+ (Dart 3.12+):

```bash
cd prizma
flutter pub get
flutter analyze
flutter test
flutter run -d web-server --web-port=8080
```

Open the URL printed by Flutter. For a production bundle:

```bash
flutter build web
```

The deployable output is created in `build/web`.

## Routes

Flutter Web uses hash routes, so direct links work on static hosts:

| URL | Screen |
| --- | --- |
| `#/` | Landing |
| `#/dashboard` | Dashboard |
| `#/sos` | SOS requests |
| `#/subjects` | Subjects |
| `#/guild` | Guild and chat |
| `#/leaderboard` | Leaderboard |
| `#/progress` | Progress |
| `#/profile` | Profile |
| `#/settings` | Settings |

## Flutter architecture

```text
lib/
├── app/                    # MaterialApp, routes, theme, responsive app shell
├── core/
│   ├── models/             # immutable domain models and configuration
│   ├── persistence/        # SharedPreferences and one-time legacy import
│   └── state/              # PrizmaStore: SOS, XP, energy, preferences
├── features/               # landing, dashboard, SOS, subjects, community, personal
└── shared/widgets/         # reusable Prizma UI primitives
test/                       # deterministic PrizmaStore coverage
web/                        # Flutter Web bootstrap and manifest
```

`PrizmaStore` is the single local source of truth. It persists the Flutter state through `SharedPreferences`, keeps XP/energy/SOS rules typed and validated, and can import a prior browser prototype snapshot (`prizma:v2` or `guildlearn_state`) once when both apps run on the same web origin.

## Migration note

`lib/main.dart` and `web/index.html` are the active application entry points. The former Vanilla HTML/CSS/JS files remain in the repository as migration reference material and are not used by the Flutter build; this preserves existing work without mixing it into the deployed Flutter app.

## Scope

This is a local-first product demo. It does not include sign-in, server synchronization, real-time messaging, moderation, or a production backend. Do not store sensitive personal information in local demo data.

## License

MIT License.
