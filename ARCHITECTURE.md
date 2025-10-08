# Project Architecture

This project follows the **Flutter Development Rules & Scalable Project Structure (v1)** defined in `flutter.mdc`.

## Current Structure

```
lib/
├── core/
│   ├── config/        # Environment configuration, flavors, constants
│   ├── routing/       # Router provider, route definitions, guards
│   ├── theme/         # Design system, theme extensions
│   └── utils/         # Cross-cutting utility functions
│
├── features/          # Feature modules (empty, ready for features)
│   └── README.md      # Documentation for adding features
│
├── app.dart           # Root widget
└── main.dart          # Entry point
```

## Architecture Principles

This project is structured following these core principles from `flutter.mdc`:

1. **Feature-first modularity** - Scale by adding features, not folders at root
2. **Clean architecture** - Separation of concerns: UI ↔ state ↔ domain ↔ data
3. **Type & null safety** - Avoid `dynamic`, embrace null-safe Dart
4. **Immutability** - Use Freezed for data models
5. **Utility & Minimality Gate** - Only add what's necessary and valuable

## Adding a New Feature

Each feature should follow a 4-layer structure inside `lib/features/<feature_name>/`:

```
feature_name/
├── domain/          # Pure Dart - Entities, Repository interfaces, Use cases
├── data/            # DTOs, Mappers, Data sources (API/local), Repository impls
├── application/     # Riverpod providers/notifiers (business logic)
├── presentation/    # Screens, Widgets (pure UI)
└── README.md        # Feature documentation
```

### Layer Responsibilities

- **domain/** - No Flutter/external dependencies, pure business logic
- **data/** - Only layer performing I/O (network, database, storage)
- **application/** - State management with Riverpod providers
- **presentation/** - UI components only, no business logic

## Tech Stack (Planned)

The following tech stack is defined in `flutter.mdc` and should be added **only when needed**:

- **State:** Riverpod (+ `riverpod_generator`, `riverpod_lint`)
- **Routing:** GoRouter
- **Models:** Freezed + `json_serializable`
- **HTTP:** Dio (+ interceptors)
- **Persistence:** `shared_preferences`, `flutter_secure_storage`
- **Images:** `cached_network_image`
- **Logging:** `logger`

⚠️ **Important:** Follow the **Utility & Minimality Gate** - only add dependencies when they solve a real user story or requirement.

## Current State

✅ Basic project structure created
✅ Core directories established (config, routing, theme, utils)
✅ Features directory ready for new features
✅ Documentation in place

## Next Steps

When starting development:

1. Add dependencies as needed (follow section 17 in `flutter.mdc`)
2. Create your first feature in `lib/features/`
3. Set up routing in `core/routing/`
4. Configure theme in `core/theme/`
5. Add environment config in `core/config/`

## References

- See `flutter.mdc` for complete guidelines
- See `lib/core/README.md` for core layer guidelines
- See `lib/features/README.md` for feature development guidelines

