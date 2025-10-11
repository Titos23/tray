# Protly Onboarding Flow Diagram

## Complete User Journey

```
┌─────────────────────────────────────────────────────────────────────┐
│                        APP LAUNCH                                    │
└───────────────────────────────┬─────────────────────────────────────┘
                                │
                                ▼
                    ┌───────────────────────┐
                    │   00. SPLASH SCREEN   │
                    │                       │
                    │  🎯 Logo fade-in      │
                    │  📱 "Protly" text     │
                    │  ✨ Pulse animation   │
                    │  ⏱️  Duration: 1.8s   │
                    └───────────┬───────────┘
                                │ Auto-transition
                                ▼
                    ┌───────────────────────┐
                    │  01. WELCOME SCREEN   │
                    │                       │
                    │  📹 Animation demo    │
                    │  🟢 "Essayer..."     │
                    │  🔗 Sign-in option   │
                    └───────────┬───────────┘
                                │ User taps CTA
                                ▼
                    ┌───────────────────────┐
                    │  02. TRY DEMO         │
                    │                       │
                    │  🍽️  Interactive plate│
                    │  📸 Scan animation    │
                    │  +28g Result          │
                    │  📊 Progress bar      │
                    └───────────┬───────────┘
                                │ "Activer la caméra"
                                ▼
            ┌───────────────────────────────────────┐
            │   03. CAMERA PERMISSION               │
            │                                       │
            │   📷 Pulsing icon                     │
            │   ✓ Reassurance bullets               │
            │   🟢 "Enable Camera"                  │
            └───────────┬───────────────────────────┘
                        │
        ┌───────────────┼───────────────────────┐
        │               │                       │
    Granted         Denied                  Blocked
        │               │                       │
        ▼               ▼                       ▼
    Navigate    Show Modal              Show Modal
      to         ┌─────────┐           ┌─────────┐
    Goal Weight  │Try Again│           │Settings │
                 │  Skip   │           │  Skip   │
                 └────┬────┘           └────┬────┘
                      │                     │
                      └──────────┬──────────┘
                                 ▼
                    ┌───────────────────────┐
                    │  04.1 GOAL WEIGHT     │
                    │                       │
                    │  👤 Sex selector      │
                    │  ⚖️  Weight slider    │
                    │  📏 Height (optional) │
                    └───────────┬───────────┘
                                │ Collects: sex, weight, height
                                ▼
                    ┌───────────────────────┐
                    │  04.2 GOAL ACTIVITY   │
                    │                       │
                    │  🎯 Goal cards        │
                    │     (Maintain/Gain/   │
                    │      Lose)            │
                    │  🏃 Activity chips    │
                    │     (Sedentary/Active/│
                    │      Regular/Intense) │
                    └───────────┬───────────┘
                                │ Calculates protein goal
                                ▼
                    ┌───────────────────────┐
                    │  04. GOAL SUMMARY     │
                    │                       │
                    │  🎯 "150g protein"    │
                    │  📊 Progress ring 0%  │
                    │  💪 "You're all set"  │
                    └───────────┬───────────┘
                                │ "Continue"
                                ▼
            ┌───────────────────────────────────────┐
            │   05. NOTIFICATION PERMISSION         │
            │                                       │
            │   🔔 Pulsing bell                     │
            │   🌿 Light / ⚡ Standard / 💤 Silent │
            │   🟢 "Enable reminders"               │
            └───────────┬───────────────────────────┘
                        │
        ┌───────────────┼───────────────┐
        │               │               │
    Granted         Denied          Already Granted
        │               │               │
        ▼               ▼               ▼
    "Great! 💪"   "No worries 😉"   Skip Screen
        │               │               │
        └───────────────┼───────────────┘
                        ▼
                    ┌───────────────────────┐
                    │  06. PRIVACY CONSENT  │
                    │                       │
                    │  🛡️  Shield icon      │
                    │  ✓ Control bullets    │
                    │  🔗 Learn more        │
                    │  🟢 "Continue"        │
                    └───────────┬───────────┘
                                │ Marks onboarding complete
                                ▼
                    ┌───────────────────────┐
                    │   🏠 HOME SCREEN      │
                    │                       │
                    │   Main App Begins     │
                    └───────────────────────┘
```

## State Flow & Data Collection

```
Screen Flow                    Data Collected              Persistence
────────────────────────────────────────────────────────────────────────
Splash (1.8s)                  -                           -
Welcome                        -                           -
Try Demo                       -                           -
Camera Permission              camera_granted: bool        Permission state
                               ↓
Goal Weight                    sex: String                 Route args →
                               weight: double              
                               height: double              
                               ↓
Goal Activity                  goal: String                Route args →
                               activity: String            
                               ↓
                               [CALCULATION]
                               proteinGoal: int            
                               ↓
Goal Summary                   proteinGoal: int (display)  Route args →
                               ↓
Notification Permission        notification_granted: bool  Permission state
                               reminderMode: String
                               ↓
Privacy Consent                onboarding_completed: true  SharedPreferences
                               ↓
Home Screen                    [All data ready]            Local DB (future)
```

## Animation Timeline

```
Screen: Splash (1.8s total)
──────────────────────────────────────────────────────────────────
0.0s  ├─ Logo fade-in starts (0.5s)
      │  Opacity: 0 → 1
      │  Scale: 0.85 → 1.0
      │
0.3s  ├─ Text appears (0.4s)
      │  Slide up from bottom
      │  Fade in
      │
0.8s  ├─ Pulse effect (0.3s)
      │  Scale: 1.0 → 1.03 → 1.0
      │
1.8s  └─ Auto-navigate to Welcome


Screen: Try Demo (3s max)
──────────────────────────────────────────────────────────────────
User Taps Plate
      │
0.0s  ├─ Glow halo (0.2s)
      │  Green aura appears
      │
0.2s  ├─ Scan beam (0.8s)
      │  Circular sweep animation
      │
1.0s  ├─ "+28 g" pops in (0.5s)
      │  Fade + slide up
      │  Haptic: medium
      │
1.5s  ├─ Progress bar fills (1.0s)
      │  0% → 30%
      │  Smooth easing
      │
2.5s  ├─ Feedback text appears
      │  "Simple, non ? 📈"
      │
3.0s  └─ CTA button fades in (0.6s)
            "Activer la caméra"


Screen: Goal Summary (Result Animation)
──────────────────────────────────────────────────────────────────
0.0s  ├─ Screen loads
      │
0.3s  ├─ Number appears (0.8s)
      │  Scale: 0.85 → 1.0 (elastic)
      │  Fade in
      │  Haptic: medium impact
      │
0.8s  ├─ Ring pulse (0.6s)
      │  Scale: 0.9 → 1.05 → 1.0
      │
1.1s  └─ Motivation text fades in (0.4s)
            "You're all set 💪"
```

## User Decision Points

```
┌─────────────────────────────────────────────────────────────┐
│ Critical Decision Points Where User Can Take Different Paths │
└─────────────────────────────────────────────────────────────┘

1. WELCOME SCREEN
   ┌─ "Essayer maintenant" → Continue to demo
   └─ "Se connecter" → Open sign-in sheet (stay on page)

2. CAMERA PERMISSION
   ┌─ Granted → Continue to goals ✓
   ├─ Denied → Try again OR Skip
   └─ Blocked → Open settings OR Skip

3. GOAL WEIGHT
   ┌─ Provide height → Use actual height
   └─ "I don't know" → Default to 170cm

4. NOTIFICATION PERMISSION
   ┌─ Select mode + Grant → Continue with reminders ✓
   ├─ Select mode + Deny → Continue without reminders
   └─ Already granted → Auto-skip

5. PRIVACY CONSENT
   ┌─ "Learn more" → View info sheet (stay on page)
   └─ "Continue" → Complete onboarding → Home
```

## Error Handling & Edge Cases

```
┌────────────────────────────────────────────────────────────┐
│ Edge Case                │ Handling Strategy              │
├──────────────────────────┼────────────────────────────────┤
│ Permission denied        │ Show friendly modal with retry │
│ Permission blocked       │ Direct to system settings      │
│ Camera unavailable       │ Allow skip, continue without   │
│ Height not provided      │ Default to 170cm               │
│ No goal selected         │ Show validation message        │
│ No activity selected     │ Show validation message        │
│ Protein goal > 180g      │ Show "strong goal" message     │
│ Navigation interrupted   │ Data persists in route args    │
│ App closed mid-flow      │ Restart from splash next time  │
│ Onboarding completed     │ Go directly to home (future)   │
└────────────────────────────────────────────────────────────┘
```

## Performance Optimization

```
┌─────────────────────────────────────────────────────────────┐
│ Optimization Strategy                                        │
├─────────────────────────────────────────────────────────────┤
│ ✓ AnimationControllers disposed properly                    │
│ ✓ Minimal setState() calls, targeted rebuilds               │
│ ✓ Image assets preloaded (future)                           │
│ ✓ Heavy calculations on background isolates (future)        │
│ ✓ Lazy loading of routes                                    │
│ ✓ No unnecessary network calls                              │
│ ✓ Smooth 60 FPS animations throughout                       │
└─────────────────────────────────────────────────────────────┘
```

---

**Legend:**
- 🎯 = Animation/Visual element
- 📱 = User interaction required
- ⏱️ = Timing constraint
- 🟢 = Primary CTA
- ✓ = Success state
- ▼ = Flow continues
- ├─ = Alternative path
- └─ = End of path

