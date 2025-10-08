# Features

This directory contains all feature modules following a clean architecture approach.

## Feature Structure

Each feature should follow this 4-layer structure:

```
feature_name/
  domain/          # Pure Dart - Entities, Repository interfaces, Use cases
  data/            # DTOs, Mappers, Data sources (API/local), Repository implementations
  application/     # Riverpod providers/notifiers (business logic)
  presentation/    # Screens, Widgets (pure UI)
  README.md        # Feature-specific documentation
```

## Guidelines

- **domain/** - No Flutter dependencies, pure business logic
- **data/** - Only layer that performs I/O operations (network, database)
- **application/** - State management with Riverpod
- **presentation/** - UI components, no business logic

## Adding a New Feature

1. Create a new directory with the feature name
2. Add the 4-layer structure
3. Create a README.md explaining the feature
4. Follow the separation of concerns strictly

