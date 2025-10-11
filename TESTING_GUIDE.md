# Protly Onboarding - Testing Guide

## 🧪 Complete Testing Checklist

### Pre-Test Setup
- [ ] `flutter clean && flutter pub get`
- [ ] Device/emulator with camera capability
- [ ] Test on both Android and iOS
- [ ] Test on different screen sizes (phone, tablet)
- [ ] Clear app data before each full test

---

## Screen-by-Screen Testing

### 1️⃣ Splash Screen (00)

**Visual Tests**
- [ ] Logo appears centered on screen
- [ ] Logo fades in smoothly (0.5s)
- [ ] Logo scales from 0.85x to 1.0x
- [ ] "Protly" text appears 0.3s after logo
- [ ] Text slides up from bottom
- [ ] Pulse effect occurs after both elements appear
- [ ] Pulse animation: 1.0 → 1.03 → 1.0 scale
- [ ] Background is pure white (#FFFFFF)
- [ ] No loading indicators or extra elements

**Timing Tests**
- [ ] Total duration is approximately 1.8s
- [ ] Auto-transition to Welcome screen occurs
- [ ] No flicker or blank frames during transition

**Edge Cases**
- [ ] App doesn't crash on slow devices
- [ ] Animation completes even if user taps screen
- [ ] Works on both portrait and landscape

---

### 2️⃣ Welcome Screen (01)

**Visual Tests**
- [ ] Logo appears at top-left (5% margin)
- [ ] Logo slides in from left (0.5s)
- [ ] Center animation block is visible
- [ ] Animation loops smoothly every 2s
- [ ] "Essayer maintenant" button appears with bounce
- [ ] Button has green background (#4ADE80)
- [ ] "Se connecter" link visible at bottom
- [ ] All elements fade in sequentially

**Interaction Tests**
- [ ] Tap "Essayer maintenant" → haptic feedback
- [ ] Button scales 0.97 → 1.0 on tap
- [ ] Navigation to Try Demo screen works
- [ ] Tap "Se connecter" → bottom sheet appears
- [ ] Bottom sheet slides up smoothly (250-300ms)
- [ ] Sheet has Apple/Google/Email options
- [ ] Tap outside sheet → sheet dismisses
- [ ] Swipe down on sheet → sheet dismisses

**Sign-In Sheet Tests**
- [ ] Sheet background is white with rounded corners
- [ ] Apple button is black with white text
- [ ] Google button is white with gray border
- [ ] Email button is transparent with border
- [ ] All buttons have 52px height
- [ ] All buttons have 24px border radius
- [ ] Tap any button → haptic feedback

**Edge Cases**
- [ ] Sheet doesn't open multiple times
- [ ] Background slightly dimmed (5-8% opacity)
- [ ] Welcome page animation continues behind sheet
- [ ] Sheet closes cleanly without lag

---

### 3️⃣ Try Demo Screen (02)

**Visual Tests**
- [ ] "Essaie 👇" header appears after 0.4s
- [ ] Plate icon is centered
- [ ] Plate has breathing animation (1.0 ↔ 1.02)
- [ ] Progress bar placeholder is visible below plate
- [ ] Progress bar is empty (0%) initially
- [ ] Background is pure white

**Interaction Tests - First Tap**
- [ ] Tap plate → haptic feedback
- [ ] Green glow halo appears (0.2s)
- [ ] Scan beam sweeps left-to-right (0.8s)
- [ ] "+28 g" text pops in above plate
- [ ] Progress bar fills to ~30% smoothly (1.0s)
- [ ] "Simple, non ? 📈" appears below plate
- [ ] "Activer la caméra" button fades in
- [ ] Total sequence takes ~2-3s

**Interaction Tests - Multiple Taps**
- [ ] Can tap plate multiple times
- [ ] Animation replays identically each time
- [ ] No performance degradation after multiple taps
- [ ] CTA button stays visible after first interaction

**Timing Tests**
- [ ] If no tap after 2s → CTA appears automatically
- [ ] Each animation phase has correct duration
- [ ] No jumpy or stuttering animations

**Edge Cases**
- [ ] Tapping during animation doesn't break it
- [ ] CTA button only appears once
- [ ] Animations don't overlap incorrectly

---

### 4️⃣ Camera Permission Screen (03)

**Visual Tests**
- [ ] Camera icon pulses (opacity 0.8 → 1.0)
- [ ] Icon has green border (#4ADE80)
- [ ] Title text is centered and readable
- [ ] Three bullets appear with staggered timing
- [ ] Each bullet has green check icon
- [ ] "Enable Camera" button is visible
- [ ] Reassurance text at bottom

**Case 1: Permission Granted**
- [ ] Tap "Enable Camera" → OS prompt appears
- [ ] Grant permission → success message shows
- [ ] Message: "Perfect 🎯 Let's set your daily goal."
- [ ] Message is green background
- [ ] Haptic feedback on success
- [ ] Auto-navigate to Goal Weight (after 0.8s)

**Case 2: Permission Denied**
- [ ] Tap "Enable Camera" → OS prompt appears
- [ ] Deny permission → modal appears
- [ ] Modal has "Try Again" and "Continue without" buttons
- [ ] Modal fades in smoothly
- [ ] Tap "Try Again" → prompt reappears
- [ ] Tap "Continue without" → navigate to Goal Weight

**Case 3: Previously Granted**
- [ ] If permission already granted → screen skips
- [ ] Auto-navigate to Goal Weight immediately
- [ ] No flicker or visible screen

**Case 4: Permission Blocked**
- [ ] If permission permanently denied → different modal
- [ ] Modal: "Camera access is blocked"
- [ ] Modal has "Open Settings" and "Maybe later" buttons
- [ ] Tap "Open Settings" → system settings open
- [ ] Tap "Maybe later" → continue to next screen

**Edge Cases**
- [ ] Modal dismisses cleanly
- [ ] No double-navigation issues
- [ ] Works correctly on both Android and iOS

---

### 5️⃣ Goal Weight Screen (04.1)

**Visual Tests**
- [ ] "Let's start simple 👇" header visible
- [ ] Sex chips (Male/Female) horizontally aligned
- [ ] Weight slider visible with label
- [ ] Weight display shows current value
- [ ] kg/lb toggle visible below slider
- [ ] Height slider visible (or "I don't know" option)
- [ ] "Continue" button at bottom

**Sex Selection Tests**
- [ ] Tap "Male" → chip fills with green
- [ ] Tap "Female" → chip fills with green
- [ ] Only one chip selected at a time
- [ ] Haptic feedback on selection
- [ ] Selected chip has white text
- [ ] Unselected chip has gray text
- [ ] Smooth color transition (200ms)

**Weight Slider Tests**
- [ ] Slider range: 40-130 kg
- [ ] Real-time display updates while sliding
- [ ] Display format: "XX.X kg" or "XXX.X lb"
- [ ] Haptic feedback while sliding
- [ ] Slider thumb is green (#4ADE80)
- [ ] Track fills with green behind thumb

**Unit Toggle Tests**
- [ ] Switch shows kg/lb labels
- [ ] Tap switch → unit changes
- [ ] Weight value converts correctly
- [ ] Formula: kg × 2.20462 = lb
- [ ] Active unit is bold and green
- [ ] Haptic feedback on toggle

**Height Slider Tests**
- [ ] Slider range: 140-200 cm
- [ ] Display format: "XXX cm"
- [ ] Tap "I don't know" → slider hides
- [ ] Tap "Add height" → slider reappears
- [ ] Default height: 170 cm if skipped

**Navigation Tests**
- [ ] Tap "Continue" → haptic feedback
- [ ] Data passed to next screen: sex, weight, height
- [ ] Navigate to Goal Activity screen

**Edge Cases**
- [ ] Works with minimum weight (40 kg)
- [ ] Works with maximum weight (130 kg)
- [ ] Height optional → defaults correctly
- [ ] No keyboard appears (slider-only input)

---

### 6️⃣ Goal Activity Screen (04.2)

**Visual Tests**
- [ ] "Tell me your goal 🎯" header visible
- [ ] Three goal cards displayed vertically
- [ ] Each card has emoji, title, description
- [ ] Four activity chips below goals
- [ ] "See my goal" button at bottom

**Goal Card Tests**
- [ ] Cards: Maintain 🧘, Gain 🏋️, Lose 🔥
- [ ] Tap card → green outline appears (3px)
- [ ] Selected card has green glow shadow
- [ ] Card scales up slightly when selected
- [ ] Only one card selected at a time
- [ ] Haptic feedback on selection
- [ ] Smooth transition (400ms)

**Activity Chip Tests**
- [ ] Chips: Sedentary 🪑, Active 🚶, Regular 🏋️, Intense 🏃
- [ ] Tap chip → fills with green background
- [ ] Selected chip has white text
- [ ] Unselected chip has gray text and border
- [ ] Only one chip selected at a time
- [ ] Haptic feedback on selection

**Validation Tests**
- [ ] Tap "See my goal" with no goal → error message
- [ ] Tap "See my goal" with no activity → error message
- [ ] Error shows toast/snackbar notification
- [ ] Error message: "Please select both..."

**Calculation Tests**
- [ ] Test case: 70kg male, gain, regular
  - Expected: 70 × 2.0 × 1.1 × 1.05 = ~162g
- [ ] Test case: 60kg female, maintain, active
  - Expected: 60 × 1.5 × 1.0 × 0.95 = ~86g
- [ ] Test case: 80kg male, lose, intense
  - Expected: 80 × 1.8 × 1.2 × 1.05 = ~181g

**Navigation Tests**
- [ ] After valid selection → navigate to Summary
- [ ] All previous data + calculation passed forward
- [ ] proteinGoal is an integer (rounded)

**Edge Cases**
- [ ] Reselection works smoothly
- [ ] No calculation errors with edge values
- [ ] High protein goals (>180g) handled

---

### 7️⃣ Goal Summary Screen (04_goal_setup)

**Visual Tests**
- [ ] Progress indicator shows "Step 2 of 2"
- [ ] Progress bar filled with green (2/2)
- [ ] "Here's your daily goal 🎯" title visible
- [ ] Large protein number displayed
- [ ] Format: "XXX g of protein per day"
- [ ] Subtext shows lb conversion
- [ ] Empty progress ring at 0%
- [ ] Motivational text below ring
- [ ] "Continue" button at bottom

**Animation Tests**
- [ ] Number fades in with scale animation (0.8s)
- [ ] Scale: 0.85 → 1.0 (elastic easing)
- [ ] Haptic feedback when number appears
- [ ] Ring pulses after number appears (0.6s)
- [ ] Ring scale: 0.9 → 1.05 → 1.0
- [ ] Motivation text fades in last (0.4s)
- [ ] Total sequence: ~1.5s

**Data Display Tests**
- [ ] Protein goal matches calculation
- [ ] Number is correctly rounded to integer
- [ ] Subtext calculation: goal / 2.2
- [ ] Format is clear and readable

**Special Cases**
- [ ] Very high goal (>180g) → no special handling
- [ ] Low goal (<80g) → displays normally
- [ ] Decimal values rounded correctly

**Navigation Tests**
- [ ] Tap "Continue" → haptic feedback
- [ ] Navigate to Notification Permission

---

### 8️⃣ Notification Permission Screen (05)

**Visual Tests**
- [ ] Bell icon pulses (opacity animation)
- [ ] Title: "Gentle reminders..."
- [ ] Three reminder cards displayed
- [ ] Cards: Light 🌿, Standard ⚡, Silent 💤
- [ ] Each card has emoji, title, description
- [ ] Cards fade in sequentially (100ms offset)
- [ ] "Enable my reminders" button
- [ ] "You can change this anytime" text

**Card Selection Tests**
- [ ] Tap card → background changes to light green tint
- [ ] Selected card has green border (2px)
- [ ] Check icon appears on selected card
- [ ] Only one card selected at a time
- [ ] Haptic feedback on selection
- [ ] Smooth transition (400ms)

**Validation Tests**
- [ ] Tap button with no selection → validation message
- [ ] Message: "Please select a reminder mode"

**Case 1: Permission Granted**
- [ ] Select mode + tap button → OS prompt
- [ ] Grant permission → success toast appears
- [ ] Toast: "Great! We'll keep you on track 💪"
- [ ] Toast has green background
- [ ] Auto-navigate after 1.5s

**Case 2: Permission Denied**
- [ ] Select mode + tap button → OS prompt
- [ ] Deny permission → reassurance toast
- [ ] Toast: "No worries — you can enable later 😉"
- [ ] Toast has gray background
- [ ] Auto-navigate after 2s

**Case 3: Already Granted**
- [ ] If permission already granted → screen skips
- [ ] Auto-navigate to Privacy Consent

**Edge Cases**
- [ ] Works on both Android (API 33+) and iOS
- [ ] Graceful fallback on older Android versions
- [ ] Toast doesn't block navigation

---

### 9️⃣ Privacy Consent Screen (06)

**Visual Tests**
- [ ] Shield icon pulses (scale animation)
- [ ] Icon in green circle background
- [ ] "You stay in control." headline
- [ ] Three bullet points with check icons
- [ ] Bullets slide up with staggered timing
- [ ] "Learn more" link underlined
- [ ] "Continue" button at bottom

**Bullet Animation Tests**
- [ ] Each bullet fades in + slides up
- [ ] Delay between bullets: 0ms, 200ms, 400ms
- [ ] Smooth easing (easeOut curve)
- [ ] Total animation: ~1.2s

**Info Sheet Tests**
- [ ] Tap "Learn more" → bottom sheet opens
- [ ] Sheet height: ~60% of screen
- [ ] Sheet has drag handle at top
- [ ] Content: 4 sections (Local Storage, Privacy, etc.)
- [ ] Sheet scrolls smoothly
- [ ] Tap "Got it" → sheet closes
- [ ] Swipe down → sheet closes
- [ ] Tap outside → sheet closes

**Content Tests**
- [ ] All three bullets visible:
  - Edit or correct any scan
  - Delete data anytime
  - No calories, only proteins
- [ ] Text is readable and clear
- [ ] Check icons are green

**Navigation Tests**
- [ ] Tap "Continue" → haptic feedback (medium)
- [ ] SharedPreferences saves: onboarding_completed = true
- [ ] Navigate to Home screen
- [ ] Navigation removes onboarding stack (can't go back)

**Edge Cases**
- [ ] Info sheet doesn't interfere with navigation
- [ ] Persistence works correctly
- [ ] Second launch skips onboarding (future feature)

---

## Integration Tests

### Full Flow Test
- [ ] Complete onboarding from splash to home
- [ ] All screens appear in correct order
- [ ] No crashes or errors
- [ ] Total time: 2-5 minutes (depending on user)

### Data Persistence Test
- [ ] Complete onboarding
- [ ] Check SharedPreferences for flag
- [ ] Close and reopen app
- [ ] Verify data persists

### Navigation Stack Test
- [ ] Complete onboarding
- [ ] Reach home screen
- [ ] Press back button → doesn't go to onboarding
- [ ] Navigation stack properly cleared

### Permission Flow Test
- [ ] Test all camera permission states
- [ ] Test all notification permission states
- [ ] Verify modals appear correctly
- [ ] Verify navigation continues properly

---

## Performance Tests

### Animation Performance
- [ ] All animations run at 60 FPS
- [ ] No dropped frames during transitions
- [ ] Smooth on both high and low-end devices

### Memory Usage
- [ ] App uses < 150 MB RAM
- [ ] No memory leaks in animations
- [ ] AnimationControllers disposed properly

### App Size
- [ ] APK size < 30 MB (Android)
- [ ] IPA size < 40 MB (iOS)

### Load Times
- [ ] Splash loads instantly (< 100ms)
- [ ] Screen transitions < 400ms
- [ ] No loading spinners needed

---

## Cross-Platform Tests

### Android
- [ ] Test on Android 5.0 (API 21)
- [ ] Test on Android 13+ (notifications)
- [ ] Test on different screen sizes
- [ ] Test on different manufacturers (Samsung, Pixel, etc.)

### iOS
- [ ] Test on iOS 12.0+
- [ ] Test on different iPhone models
- [ ] Test on iPad (if supported)
- [ ] Test on different screen sizes (SE, Pro Max)

---

## Accessibility Tests (Future)

- [ ] Screen reader support
- [ ] High contrast mode
- [ ] Large text support
- [ ] Color blind friendly
- [ ] Keyboard navigation (if applicable)

---

## Edge Case Tests

### Network
- [ ] Test in airplane mode (should work)
- [ ] Test with slow connection

### Device States
- [ ] Test with low battery
- [ ] Test with power saving mode
- [ ] Test with reduced motion enabled
- [ ] Test with dark mode (future)

### User Behavior
- [ ] Rapid tapping doesn't break navigation
- [ ] Rotating device doesn't break state
- [ ] Backgrounding app preserves progress
- [ ] Killing app mid-flow restarts cleanly

---

## Regression Tests

### After Each Change
- [ ] Run full flow test
- [ ] Check all animations still smooth
- [ ] Verify no new lint errors
- [ ] Test on both platforms

### Before Release
- [ ] Complete all checklist items
- [ ] Test on multiple devices
- [ ] Verify no known bugs
- [ ] Performance profiling

---

## Bug Report Template

```
**Screen**: [Which onboarding screen]
**Issue**: [Brief description]
**Steps to Reproduce**:
1. [Step 1]
2. [Step 2]
3. [Step 3]

**Expected**: [What should happen]
**Actual**: [What actually happens]
**Device**: [Model, OS version]
**Frequency**: [Always / Sometimes / Rare]
**Screenshots**: [If applicable]
```

---

## Testing Tools

### Manual Testing
- Real Android device
- Real iOS device
- Multiple screen sizes

### Automated Testing (Future)
```dart
// Example test structure
testWidgets('Splash screen animations', (tester) async {
  await tester.pumpWidget(MyApp());
  await tester.pumpAndSettle(Duration(seconds: 2));
  expect(find.byType(WelcomeScreen), findsOneWidget);
});
```

### Performance Profiling
- Flutter DevTools
- Performance overlay
- Timeline view
- Memory profiler

---

**Testing Status**: Ready for QA  
**Critical Path**: All 9 screens + navigation  
**Estimated Test Time**: 30-45 minutes full manual test
