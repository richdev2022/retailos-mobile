# RetailOS — Mobile

Offline-first Flutter mobile app for retail store management (POS, inventory, sales, expenses, customers, suppliers, branches, staff, reports, subscriptions). Targets Android first (APK + AAB); iOS-ready structure.

> Backend: https://github.com/richdev2022/retailos-backend — serves `/api/v1/*`.

## Prerequisites

- **Flutter** 3.24.x (stable)
- **Dart** ≥ 3.4.0 (bundled with Flutter)
- **Java** 17 (Temurin recommended) — required by Android Gradle
- **Android SDK** 34, with Build Tools matching `compileSdk 34`
- An Android device or emulator (API 21+)

## Getting started

```bash
# 1. Install dependencies
flutter pub get

# 2. Generate code (Drift, Freezed, JSON serializable, Riverpod)
dart run build_runner build --delete-conflicting-outputs

# 3. Run (dev flavor — hits the local emulator backend at http://10.0.2.2:4000)
flutter run --flavor dev -t lib/main.dart
```

> Re-run `build_runner` whenever you change a model annotated with `@freezed` / `@JsonSerializable`, a Drift table, or a `@riverpod`-annotated provider. During active development use `dart run build_runner watch --delete-conflicting-outputs`.

## Configuration

### Backend URL

The API base URL defaults to `http://10.0.2.2:4000/api/v1` (Android emulator → host loopback) for the `dev` flavor and `https://api.retailos.com/api/v1` for `prod`. Override at runtime:

```bash
flutter run --flavor dev -t lib/main.dart \
  --dart-define=API_BASE_URL=http://192.168.1.10:4000/api/v1
```

Or edit the default in `lib/core/network/api_client.dart`.

### Android flavors

| Flavor | Application ID          | Suffix | Backend                         |
|--------|-------------------------|--------|---------------------------------|
| `dev`  | `com.retailos.mobile.dev` | `.dev` | local (`10.0.2.2:4000`)         |
| `prod` | `com.retailos.mobile`     | —      | production (`api.retailos.com`) |

Always pass `--flavor`:

```bash
flutter run              --flavor dev  -t lib/main.dart
flutter build apk        --flavor prod -t lib/main.dart
flutter build appbundle  --flavor prod -t lib/main.dart
```

## Signing

### Local signing

1. Generate a keystore (once):
   ```bash
   keytool -genkey -v -keystore android/app/retailos.jks \
     -keyalg RSA -keysize 2048 -validity 10000 \
     -alias retailos
   ```
2. Copy the template and fill in your passwords:
   ```bash
   cp android/key.properties.example android/key.properties
   ```
   Then edit `android/key.properties`:
   ```properties
   storePassword=<keystore password>
   keyPassword=<key password>
   keyAlias=retailos
   storeFile=app/retailos.jks
   ```
3. Build signed release:
   ```bash
   flutter build apk       --flavor prod -t lib/main.dart
   flutter build appbundle --flavor prod -t lib/main.dart
   ```

> `android/key.properties`, `*.jks` and `*.keystore` are gitignored — never commit them.

### CI signing (GitHub Actions)

The workflow `.github/workflows/build-mobile.yml` builds signed APK + AAB on every push to `develop` and on PRs to `develop`. Configure these **repository secrets** (Settings → Secrets and variables → Actions):

| Secret                      | Description                                              |
|-----------------------------|----------------------------------------------------------|
| `ANDROID_KEYSTORE_BASE64`   | `base64 -w 0` of your `retailos.jks`                    |
| `ANDROID_KEYSTORE_PASSWORD` | Keystore password                                        |
| `ANDROID_KEY_ALIAS`         | Key alias inside the keystore (e.g. `retailos`)         |
| `ANDROID_KEY_PASSWORD`      | Key password                                             |

Encode your keystore:
```bash
cat android/app/retailos.jks | base64 -w 0
```

If any secret is missing the workflow still produces **unsigned** artifacts (useful for testing branches). To cut a release, dispatch the workflow manually and provide a `version` input (e.g. `1.2.3`) — a GitHub Release is created with both APK and AAB attached.

Artifacts are retained for 90 days.

## Architecture

```
lib/
├── main.dart                  # entry point — ProviderScope + bootstrap
├── app.dart                   # MaterialApp.router (GoRouter) + theme + locale
└── core/
    ├── theme/                 # light + dark Material 3 themes
    ├── router/                # GoRouter config + StatefulShellRoute (bottom nav)
    ├── network/               # Dio ApiClient, endpoints, ApiError mapping
    ├── storage/               # SecureStorage + Drift LocalDatabase + SyncQueue
    ├── sync/                  # sync engine (push/pull, connectivity-aware)
    ├── state/                 # auth + business Riverpod notifiers, bootstrap
    ├── models/                # freezed models (User, Business, Product, Sale, …)
    ├── utils/                 # money (kobo) + date/relative formatters
    └── widgets/               # buttons, fields, cards, stat cards, empty/error states
└── features/
    ├── auth/screens/          # welcome, login, register, forgot/reset password
    ├── onboarding/screens/   # create business
    ├── home/screens/         # dashboard (bottom-nav shell)
    ├── products/screens/    # product list
    ├── sales/screens/       # POS / sales
    ├── reports/screens/    # reports
    └── settings/screens/   # settings
```

### Conventions

- **Money** is stored and computed as `int` minor units (kobo for NGN). Use `MoneyUtils.formatMinor`, `toMinor`, `toMajor`. Never use `double` for money.
- **Dates** are UTC over the wire; formatted to the user's local timezone for display via `Formatters`.
- **Navigation** uses `go_router` (`context.go` / `context.push`) — never `Navigator.push`.
- **State** uses Riverpod 2 with `@riverpod` code generation where practical.
- **Offline-first**: every write enqueues a `SyncQueue` row; the sync engine drains it when online. Reads hit the local Drift DB and fall back to the network.

## Testing

```bash
flutter test
flutter analyze
```

## Project structure notes

- All Google Fonts are loaded at runtime via the `google_fonts` package (no bundled font files).
- Asset folders: `assets/images/`, `assets/icons/`.
