# Core

This directory contains cross-cutting concerns shared across all features.

## Structure

- **config/** - Environment configuration, flavors, constants
- **routing/** - Router provider, route definitions, navigation guards
- **theme/** - Design system, theme extensions, colors, typography
- **utils/** - Cross-cutting utility functions (date formatters, validators, etc.)

## Guidelines

- Keep this layer minimal and focused on truly shared concerns
- Avoid feature-specific logic here
- All code in `core/` should be reusable across multiple features

