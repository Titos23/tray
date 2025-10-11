# Protly Onboarding Implementation

## Overview
This is the complete onboarding sequence for the Protly app, implementing all 9 screens as specified in the markdown documentation files.

## Screen Sequence

### 1. Splash Screen (`00_splash_screen.md`)
- **Duration**: ~1.8s
- **Features**:
  - Logo fade-in with scale animation (0.85x → 1.0x)
  - "Protly" text slides up 0.3s after logo
  - Subtle pulse effect on logo
  - Auto-transition to Welcome screen

### 2. Welcome Screen (`01_welcome_value_prop.md`)
- **Features**:
  - Logo at top-left with slide-in animation
  - Center animation demonstrating app concept (looping)
  - "Essayer maintenant" CTA with bounce animation
  - Sign-in bottom sheet with Apple/Google/Email options
  - Sequential fade-in animations (logo → animation → CTA → secondary text)

### 3. Try Demo Screen (`02_try_it_demo.md`)
- **Features**:
  - Interactive plate with breathing animation
  - Tap triggers: glow → scan beam → protein result → progress bar fill
  - "+28 g" result appears with pop-in effect
  - Feedback text: "Simple, non ? 📈"
  - "Activer la caméra" CTA appears after interaction

### 4. Camera Permission Screen (`03_camera_permission.md`)
- **Features**:
  - Pulsing camera icon
  - Three reassurance bullet points (staggered fade-in)
  - "Enable Camera" CTA
  - Handles 4 cases:
    - Permission granted → success message + navigate
    - Permission denied → modal with "Try Again" / "Continue without"
    - Previously granted → skip screen
    - Blocked → modal with "Open Settings" / "Maybe later"

### 5. Goal Weight Screen (`04.1_goal_weight.md`)
- **Features**:
  - Sex selection chips (Male/Female) with bounce animation
  - Weight slider with real-time display (40-130 kg)
  - kg/lb toggle switch
  - Optional height slider (140-200 cm)
  - "I don't know" option for height (defaults to 170 cm)
  - Haptic feedback on all interactions

### 6. Goal Activity Screen (`04.2_goal_activity.md`)
- **Features**:
  - 3 goal cards: Maintain 🧘 / Gain muscle 🏋️ / Lose fat 🔥
  - 4 activity chips: Sedentary 🪑 / Active 🚶 / Regular 🏋️ / Intense 🏃
  - Selected cards glow with green outline
  - "See my goal" CTA computes protein target
  - Formula: `weight × goalFactor × activityMultiplier × sexAdjustment`

### 7. Goal Summary Screen (`04_goal_setup.md`)
- **Features**:
  - Progress indicator "Step 2 of 2"
  - Calculated protein goal with fade+scale animation
  - Large number display (e.g., "150 g of protein per day")
  - Empty progress ring at 0%
  - Ring pulse animation
  - Motivational text: "You're all set 💪"
  - Haptic feedback on number reveal

### 8. Notification Permission Screen (`05_notification_permission.md`)
- **Features**:
  - Pulsing bell icon
  - 3 selectable reminder modes:
    - 🌿 Light (1 reminder/day)
    - ⚡ Standard (3 reminders/day)
    - 💤 Silent (no sound)
  - Cards fade-in sequentially
  - "Enable my reminders" CTA
  - Handles permission granted/denied cases
  - Shows appropriate toast messages

### 9. Privacy Consent Screen (`06_privacy_consent.md`)
- **Features**:
  - Pulsing shield icon
  - "You stay in control" headline
  - 3 bullet points with slide-up animation:
    - Edit or correct any scan
    - Delete data anytime
    - No calories, only proteins
  - "Learn more" link opens info bottom sheet
  - "Continue" CTA marks onboarding complete
  - Navigates to main app (home screen)

## Design System

### Colors (ProtlyTheme)
- **Vitality Green**: `#4ADE80` - Primary brand color
- **Pure White**: `#FFFFFF` - Background
- **Dark Gray**: `#3A3A3A` - Body text
- **Dark Text**: `#1E1E1E` - Headings
- **Medium Gray**: `#7C7C7C` - Secondary text
- **Light Gray**: `#E8E8E8` - Borders
- **Light Green Tint**: `#E6F9ED` - Selected state backgrounds

### Typography
- **Display**: Poppins SemiBold (22-28px) - Headlines
- **Body**: Inter Regular/Medium (14-16px) - Body text
- **CTA**: Poppins SemiBold (18px) - Buttons

### Animation Durations
- **Short**: 200ms - Quick interactions
- **Medium**: 400ms - Standard transitions
- **Long**: 600ms - Elaborate animations

### Animation Curves
- **Default**: easeInOut - Most transitions
- **Bounce**: elasticOut - CTA buttons
- **Scale**: easeOut - Fade-ins

## Navigation Flow

```
Splash (1.8s)
  ↓
Welcome
  ↓
Try Demo
  ↓
Camera Permission
  ↓
Goal Weight (04.1)
  ↓
Goal Activity (04.2)
  ↓
Goal Summary (04_goal_setup)
  ↓
Notification Permission
  ↓
Privacy Consent
  ↓
Home (Main App)
```

## State Management

### Data Flow
- User data (sex, weight, height, goal, activity) passed via route arguments
- Protein calculation performed in Goal Activity screen
- Onboarding completion stored in SharedPreferences
- Permission states managed per screen

### Persistence
- `onboarding_completed`: Boolean flag in SharedPreferences
- Future: User profile data should be persisted to local database

## Micro-Interactions

### Haptic Feedback
- **Light Impact**: Button taps, chip selections
- **Medium Impact**: Success states, goal reveal
- **Selection Click**: Slider movements

### Visual Feedback
- All buttons have scale animation (0.97 → 1.0)
- Selected states use green outline + fill
- Breathing animations on idle elements (plates, icons)
- Pulse effects for attention-grabbing elements

## Edge Cases Handled

### Camera Permission
- ✅ Permission granted
- ✅ Permission denied
- ✅ Previously granted (skip)
- ✅ Permanently denied (blocked)

### Goal Setup
- ✅ Complete data provided
- ✅ Height skipped (default: 170cm)
- ✅ Very high protein target (>180g)
- ✅ Missing inputs (fallback: 130g)

### Notification Permission
- ✅ Permission accepted
- ✅ Permission denied
- ✅ Already granted (skip)

## Dependencies

```yaml
dependencies:
  permission_handler: ^11.3.1  # Camera & notification permissions
  shared_preferences: ^2.2.2   # Onboarding completion state
  flutter_svg: ^2.0.10         # Future: SVG assets
  google_fonts: ^6.2.1         # Poppins & Inter fonts
```

## Running the App

1. Install dependencies:
   ```bash
   flutter pub get
   ```

2. Run the app:
   ```bash
   flutter run
   ```

3. The onboarding sequence will start automatically on first launch.

## Platform Configuration

### Android
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

### iOS
Add to `ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access to scan your meals and calculate protein content.</string>
<key>NSNotificationAlwaysAlwaysAllowUsageDescription</key>
<string>We'd like to send you gentle reminders to help you reach your daily protein goal.</string>
```

## Design Principles

1. **Sequential Flow**: Never skip or reorder screens
2. **Visual Continuity**: Consistent colors, fonts, spacing
3. **Timing Precision**: Follow exact durations from specs
4. **Psychological Design**: Every animation has purpose
5. **Graceful Degradation**: Handle all permission states
6. **Zero Friction**: No keyboard input in goal setup
7. **Immediate Feedback**: Haptics + visual confirmation
8. **Trust Building**: Progressive disclosure of permissions

## Future Enhancements

- [ ] Add actual logo asset (replace placeholder icon)
- [ ] Implement sign-in functionality (Apple/Google/Email)
- [ ] Add confetti animation on notification acceptance
- [ ] Create animated illustration for welcome screen
- [ ] Add onboarding skip functionality
- [ ] Implement actual protein calculation API
- [ ] Add analytics tracking for onboarding funnel
- [ ] Support dark mode
- [ ] Add localization (i18n)
- [ ] Implement onboarding reset (for testing)

## Testing Checklist

- [ ] Complete flow from splash to home
- [ ] All animations timing correct
- [ ] Haptic feedback on all interactions
- [ ] Camera permission all 4 cases
- [ ] Notification permission all 3 cases
- [ ] Weight slider kg/lb conversion
- [ ] Height "I don't know" default
- [ ] Protein calculation accuracy
- [ ] Sign-in bottom sheet dismiss
- [ ] Privacy info sheet open/close
- [ ] Navigation back button disabled
- [ ] System UI overlay colors correct
- [ ] Landscape orientation (if supported)
- [ ] Tablet layout (if supported)

## Architecture

```
lib/
├── app.dart                    # Main app with routing
├── main.dart                   # Entry point
├── core/
│   └── theme/
│       └── protly_theme.dart  # Colors, typography, animations
└── features/
    ├── onboarding/
    │   ├── splash_screen.dart
    │   ├── welcome_screen.dart
    │   ├── try_demo_screen.dart
    │   ├── camera_permission_screen.dart
    │   ├── goal_weight_screen.dart
    │   ├── goal_activity_screen.dart
    │   ├── goal_summary_screen.dart
    │   ├── notification_permission_screen.dart
    │   └── privacy_consent_screen.dart
    └── home/
        └── home_screen.dart   # Main app entry
```

## Credits

Built following exact specifications from markdown design files:
- `00_splash_screen.md`
- `01_welcome_value_prop.md`
- `02_try_it_demo.md`
- `03_camera_permission.md`
- `04.1_goal_weight.md`
- `04.2_goal_activity.md`
- `04_goal_setup.md`
- `05_notification_permission.md`
- `06_privacy_consent.md`

---

**Status**: ✅ Complete onboarding sequence implemented  
**Last Updated**: October 11, 2025
