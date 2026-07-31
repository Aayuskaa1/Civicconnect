# civic_connect (Flutter)

See the root [README.md](../README.md) for full setup, API list, and demo steps.

## Testing (mocktail)

```bash
cd frontend
flutter test test/features
```

- **Unit tests (20+):** usecases + entities + Ask AI assistant (`test/features/**/usecases`, `entities_and_assistant_test.dart`)
- **Widget tests (20):** Login, Signup, Onboarding, Reports list (`test/features/**/pages`)
- Mocks: `test/helpers/mocktail_mocks.dart` (mocktail)

Quick start:

```bash
flutter pub get
bash scripts/setup_ios_build_dir.sh
flutter run --dart-define=USE_LAN=false
```
