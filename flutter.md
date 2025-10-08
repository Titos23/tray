# Flutter Development Rules & Scalable Project Structure (v1)

> **Goal:** A concise, enforceable set of rules so any engineer can ship features fast **without** sacrificing scalability, readability, or testability.

---

## 0) Tech Stack (opinionated)
- **Framework:** Flutter (stable channel)
- **Language:** Dart (null-safe)
- **State:** **Riverpod** (+ `riverpod_generator`, `riverpod_lint`)
- **Routing:** **GoRouter**
- **Models:** **Freezed** + `json_serializable`
- **HTTP:** **Dio** (+ interceptors)
- **Persistence:** `shared_preferences` (non‑sensitive), `flutter_secure_storage` (tokens), optional DB (Drift/Isar) if needed
- **Images:** `cached_network_image`
- **Logging:** `logger` (+ custom printer)
- **Lints & Build:** `flutter_lints`, `custom_lint`, `build_runner`
- **Testing:** `flutter_test`, `mocktail`, `integration_test`, optional `golden_toolkit`

---

## 1) Core Principles
1. **Clean, maintainable, testable** code.
2. **Type & null safety** first; avoid `dynamic`.
3. **Immutability** for data models (Freezed).
4. **Separation of concerns**: UI ↔ state ↔ domain ↔ data.
5. **Feature-first modularity** (scale by adding features, not folders at root).
6. **Least power principle**: pick the simplest abstraction that works.
7. **Docs-as-code**: keep README per feature; update when behavior changes.

---

## 2) Project Structure (feature‑first, clean-ish)

> Prefer **feature-first** with a lean clean-architecture split *inside* each feature.

```
lib/
  core/
    config/            # env, flavors, constants
    routing/           # routerProvider, route defs, guards
    theme/             # design system, ThemeExtensions
    utils/             # cross-cutting helpers (date, formatters, etc.)
    network/           # Dio client, interceptors, retry policy
    error/             # AppException sealed classes, error mapping
    storage/           # shared_prefs, secure_storage wrappers
    analytics/         # analytics/telemetry adapters (optional)
  features/
    auth/
      domain/          # entities, repositories (abstract), usecases
      data/            # DTOs, mappers, data sources (api/local), repo impl
      application/     # riverpod providers/notifiers (business logic)
      presentation/    # screens, widgets, controllers (pure UI)
    profile/
      ... (same 4 layers)
    home/
      ...
  services/
    ...
  app.dart             # root widget, ProviderScope, MaterialApp.router
  main_dev.dart        # dev entry (flavor)
  main_stg.dart        # staging entry
  main_prod.dart       # prod entry
```

**Why this layout?**
- Keeps **UI small & composable**.
- Business rules live in **application/** (Riverpod notifiers) and **domain/** (pure Dart) — easy to test.
- **data/** is the only layer touching I/O (Dio, local DB). Mappers isolate external schema changes.
- You can split features into separate packages later (Melos) without rewrites.

> **Optional monorepo** (for large apps):
```
packages/
  design_system/   # shared UI components & tokens
  api_client/      # generated clients, models (if OpenAPI)
  analytics/       # analytics abstraction + impls
```

---

## 3) Environments & Config
- Use **flavors**: `dev`, `stg`, `prod` with separate entry points.
- Pass secrets/config via `--dart-define` or a `dart-define-from-file` step. **Never** commit secrets.
- Create `core/config/app_config.dart` and expose through a provider:
```dart
@riverpod
AppConfig appConfig(AppConfigRef ref) => const AppConfig(
  name: 'Dev', apiBaseUrl: String.fromEnvironment('API_BASE_URL'),
);
```

---

## 4) State Management — Riverpod Rules
- Use **`@riverpod`** codegen over manual providers.
- **`ref.watch()`** in build, **`ref.read()`** in callbacks.
- **`autoDispose`** for short-lived/route‑scoped state; use `keepAlive()` sparingly.
- Prefer:
  - `Notifier`/`AsyncNotifier` for business logic
  - `FutureProvider` for simple async reads
  - `StreamProvider` for real‑time
  - `StateProvider` for trivial local state
- Use **family providers** for parameterized state (`userProvider(id)`)
- Avoid circular dependencies; isolate cross-feature deps in **core/** providers.
- **Dispose** streams/controllers in providers.

**Example**
```dart
@riverpod
class Counter extends _$Counter {
  @override int build() => 0;
  void increment() => state++;
}
```

---

## 5) Routing — GoRouter
- Centralize router in `core/routing/router.dart` and expose with a provider.
- Use **named routes**, typed helpers, and **route guards** (auth, onboarding).
- **Nested navigation** via `ShellRoute` for persistent tabs.
- Support **deep links**; handle unknown routes with `errorBuilder`.

```dart
final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authStateProvider);
  return GoRouter(
    initialLocation: '/home',
    redirect: (ctx, state) {
      final needsAuth = state.matchedLocation.startsWith('/secure');
      if (needsAuth && !auth.isAuthenticated) return '/login';
      return null;
    },
    routes: [
      GoRoute(path: '/home', name: 'home', builder: (_, __) => const HomeScreen()),
      // ...
    ],
    errorBuilder: (_, st) => ErrorScreen(st.error),
  );
});
```

---

## 6) Networking — Dio
- Single **configured client** (base URL, headers, timeouts) exposed via provider.
- Interceptors: auth token attach/refresh, logging (strip in prod), retry (exponential backoff).
- Map transport errors → `AppException` early (data layer).

```dart
@riverpod
Dio dio(DioRef ref) {
  final base = ref.watch(appConfigProvider).apiBaseUrl;
  final dio = Dio(BaseOptions(baseUrl: base, connectTimeout: const Duration(seconds: 10)));
  dio.interceptors.addAll([AuthInterceptor(ref), LogInterceptor()]);
  return dio;
}
```

---

## 7) Data & Domain
- **Domain**: pure Dart — `Entity` (Freezed), `Repository` (abstract), `UseCase` (if helpful).
- **Data**: DTOs (Freezed+JSON), mappers, datasource (remote/local), repository **impl**.
- Never return `Response` or raw JSON above `data/` — map to domain models.

```dart
// domain
@freezed
class User with _$User { const factory User({required String id, required String name, String? email}) = _User; }
abstract interface class UserRepo { Future<User> getMe(); }

// data
@freezed
class UserDto with _$UserDto { factory UserDto({required String id, required String name, String? email}) = _UserDto; factory UserDto.fromJson(Map<String, dynamic> json) => _$UserDtoFromJson(json); }

extension UserMapper on UserDto { User toDomain() => User(id: id, name: name, email: email); }
```

---

## 8) Error Handling
- Use **`AsyncValue`** in UI; never throw through the widget tree.
- Centralize **`AppException`** types (network, auth, validation, unknown) in `core/error/`.
- Convert exceptions in data layer → domain/app exceptions; show **user‑friendly** messages in UI.

```dart
Widget build(BuildContext context, WidgetRef ref) {
  final users = ref.watch(usersProvider);
  return users.when(
    data: (d) => ListView.builder(itemCount: d.length, itemBuilder: (_, i) => Text(d[i].name)),
    loading: () => const Center(child: CircularProgressIndicator()),
    error: (e, _) => ErrorView(message: toFriendly(e)),
  );
}
```

---

## 9) UI, Theming & Design System
- Build a **design system**: colors, typography, spacing, radii, icons.
- Use **ThemeExtensions** for tokens; favor composition.
- Break down large widgets; use `const` constructors.
- Avoid logic in widgets — delegate to providers.
- Responsive layouts: `LayoutBuilder`/`MediaQuery` and size breakpoints.
- Accessibility: semantics, contrast, scalable text.

---

## 10) Performance
- `const` widgets, memoize heavy calcs, `select()` to watch slices of state.
- Use `ListView.builder`/`SliverList` for long lists; paginate/infinite scroll.
- Cache images (CachedNetworkImage) and data (repository cache if needed).
- Avoid rebuild storms (don’t watch whole objects when a field is enough).

---

## 11) Security
- No secrets in repo; store in CI or `--dart-define`.
- Use `flutter_secure_storage` for tokens; wipe on logout.
- Validate user input; sanitize before network.
- Optional: **certificate pinning** with Dio if required.

---

## 12) Testing Strategy
- **Unit tests**: domain & application providers (business logic highest coverage).
- **Widget tests**: screens with mocked providers via `ProviderScope(overrides: [...])`.
- **Integration tests**: happy paths for key flows (login → home → detail).
- **Golden tests** (optional): critical components across themes/sizes.

```dart
test('counter increments', () {
  final c = ProviderContainer();
  addTearDown(c.dispose);
  final notifier = c.read(counterProvider.notifier);
  expect(c.read(counterProvider), 0);
  notifier.increment();
  expect(c.read(counterProvider), 1);
});
```

---

## 13) Tooling & Automation
- **Scripts** (Makefile or `melos.yaml`) for: format, analyze, build_runner, tests.
- **CI** (GitHub Actions/GitLab): format → analyze → tests → build; block merge on failure.
- **Codegen:** `dart run build_runner watch --delete-conflicting-outputs` during dev.
- **Linting:** enable `riverpod_lint`, `custom_lint`, `flutter_lints`.

**analysis_options.yaml (snippet)**
```yaml
include: package:flutter_lints/flutter.yaml
linter:
  rules:
    - prefer_const_constructors
    - prefer_final_locals
    - always_use_package_imports
    - avoid_print
    - public_member_api_docs
analyzer:
  plugins:
    - custom_lint
```

**Melos (optional monorepo)**
```yaml
name: my_app
packages:
  - .
  - packages/*
scripts:
  format: dart format .
  analyze: flutter analyze
  gen: dart run build_runner build --delete-conflicting-outputs
  test: flutter test
```

---

## 14) Git & Reviews
- **Conventional Commits** (`feat:`, `fix:`, `refactor:`, ...). Keep commits atomic.
- **Feature branches** → PR → review checklist.
- Pre-push hook: `format` + `analyze` + `test`.

**PR checklist (minimum):**
- [ ] Unit tests updated/added
- [ ] UI states covered (loading/error/empty)
- [ ] Strings extracted (localization-ready)
- [ ] No TODOs left unresolved
- [ ] Screenshots for UI changes

---

## 15) Naming & Conventions
- **camelCase** for vars/functions; **PascalCase** for types.
- Private members prefix `_`.
- Suffix: `*Provider`, `*Screen`, DTOs as `*Dto`, entities as bare nouns.
- Files: `snake_case.dart`. Feature files prefixed with feature if shared.

---

## 16) Localization & Copy
- Plan for i18n early (`flutter_localizations`, `intl`).
- Keep strings in ARB; no hardcoded user-facing text.

---

## 17) Example `pubspec.yaml` (key deps)
```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^
  riverpod_annotation: ^
  go_router: ^
  freezed_annotation: ^
  json_annotation: ^
  dio: ^
  shared_preferences: ^
  flutter_secure_storage: ^
  cached_network_image: ^
  logger: ^

dev_dependencies:
  build_runner: ^
  riverpod_generator: ^
  freezed: ^
  json_serializable: ^
  flutter_test:
    sdk: flutter
  mocktail: ^
  custom_lint: ^
  riverpod_lint: ^
```

---

## 18) Definition of Done (per feature)
1. Providers + tests for business logic
2. Screens cover **loading/error/empty/success** states
3. Strings extracted; accessibility labels present
4. Analytics events added (if applicable)
5. Docs (README in feature) updated

---

## 19) Minimum Code Templates

**Feature README (template)**
```
# <Feature Name>
- User story:
- Routes:
- Providers:
- Entities/DTOs:
- Edge cases:
- Telemetry:
```

**Provider (Async) template**
```dart
@riverpod
class Items extends _$Items {
  @override
  FutureOr<List<Item>> build() => _load();
  Future<List<Item>> _load() => ref.read(itemRepoProvider).fetch();
  Future<void> refresh() async => state = const AsyncLoading();
}
```

**Repository template**
```dart
abstract interface class ItemRepo { Future<List<Item>> fetch(); }

class ItemRepoImpl implements ItemRepo {
  ItemRepoImpl(this._dio);
  final Dio _dio;
  @override
  Future<List<Item>> fetch() async {
    try {
      final res = await _dio.get('/items');
      return (res.data as List).map((j) => ItemDto.fromJson(j).toDomain()).toList();
    } on DioException catch (e) {
      throw mapDioError(e); // -> AppException
    }
  }
}
```

---

## 20) What NOT to do
- Don’t put network calls in widgets.
- Don’t expose DTOs above data layer.
- Don’t keep long‑lived state without reason; prefer `autoDispose`.
- Don’t add dependencies lightly; prefer native Dart/Flutter first.
- Don’t block UI thread with heavy sync work; offload/`compute` if necessary.

---

### TL;DR
- **Feature-first** structure with **clean boundaries**.
- **Riverpod + GoRouter + Freezed + Dio** as core.
- Enforce quality with **lints, tests, CI**, and **PR checklist**.
- Keep it **simple, typed, documented, and immutable**.

