# Tray

A Flutter project following clean architecture and feature-first principles.

## Project Structure

This project follows the **Flutter Development Rules & Scalable Project Structure (v1)** defined in `flutter.mdc`.

```
lib/
├── core/              # Cross-cutting concerns (config, routing, theme, utils)
├── features/          # Feature modules (feature-first architecture)
├── app.dart           # Root widget
└── main.dart          # Entry point
```

## Documentation

- **`flutter.mdc`** - Complete development rules and guidelines
- **`ARCHITECTURE.md`** - Architecture overview and current state
- **`lib/core/README.md`** - Core layer guidelines
- **`lib/features/README.md`** - Feature development guidelines

## Getting Started

1. **Install dependencies:**
   ```bash
   flutter pub get
   ```

2. **Run the app:**
   ```bash
   flutter run
   ```

3. **Check for issues:**
   ```bash
   flutter analyze
   ```

## Development Guidelines

This project follows strict guidelines to ensure scalability, maintainability, and testability:

- ✅ **Feature-first** structure
- ✅ **Clean architecture** with clear layer separation
- ✅ **Type safety** and null-safe Dart
- ✅ **Utility & Minimality Gate** - only add what's necessary

See `flutter.mdc` for complete guidelines.

## Tech Stack

Current dependencies:
- Flutter SDK
- Dart (null-safe)

**Planned dependencies** (add only when needed):
- Riverpod (state management)
- GoRouter (routing)
- Freezed (immutable models)
- Dio (HTTP client)

## Next Steps

1. Add your first feature in `lib/features/`
2. Set up routing in `core/routing/`
3. Configure theme in `core/theme/`
4. Add environment config in `core/config/`

Refer to `flutter.mdc` for detailed instructions on each step.
