# Camera Permission Screen – Protly App

## Purpose
Ask for camera access in a natural and reassuring way, right after the user has experienced the fake scan demo (page 2).  
Goal: maximize permission acceptance while keeping the flow calm and continuous.

---

## Visual Layout (Vertical Screen)

**Background:** pure white `#FFFFFF` to ensure continuity from previous pages.

### Top (0–15%)
- Minimal camera icon (outline style, Protly green `#4ADE80`)
- Soft pulsing animation (opacity `0.8 → 1.0 → 0.8`, loop)

### Middle (30–40%)
**Title text centered:**

> “We need your camera to scan your meals 📸”  
> Font: *Poppins Semibold*, dark gray `#1E1E1E`, 22–24 px, slightly rounded line spacing.

### Below Title (45–65%)
3 bullet points in calm gray tone `#3A3A3A`:
- No manual imports  
- Instant results  
- Your data stays private  

Each bullet appears with a short staggered fade-in (0.1 s delay between each).

### Bottom (70–85%)
**Main CTA button:**

> “Enable Camera”  

- Background: Protly green `#4ADE80`  
- Text: white `#FFFFFF`  
- Corners fully rounded (radius = 24 px)  
- Press feedback: scale `0.97 → 1.0` + short haptic vibration  

### Footer (85–92%)
Small reassurance text:

> “Protly only uses your camera to scan your meals.”  
> Font: *Inter Regular* 14 px, color `#7C7C7C`

---

## User Interaction Flow and Cases

### Case 1 – Permission Granted
- System permission prompt accepted.  
- Immediately play a success haptic and a light fade-out transition.  
- Display a short success message (optional overlay):  
  > “Perfect 🎯 Let’s set your daily goal.”  
- Then transition to **Page 4 (Set-Up Goal).**

---

### Case 2 – Permission Denied (User Presses “Don’t Allow”)
- Stay on the same screen but show a reassurance modal overlaying the center.

**Modal Content:**
- **Title:** “Without the camera, you won’t be able to scan your meals.”  
- **Text:** “You can enable it later in your settings.”  

**Buttons:**
- “Try Again” (green button → re-trigger permission prompt)  
- “Continue without camera” (gray outline → go to Page 4)  

Use a gentle fade for modal appearance (no harsh alert).

---

### Case 3 – Permission Previously Granted (Returning User)
- Skip this screen entirely.  
- Auto-transition directly to **Page 4** with no flicker.

---

### Case 4 – Permission Blocked at OS Level (“Don’t Ask Again”)
Display a specific modal:

**Modal Content:**
- **Title:** “Camera access is blocked.”  
- **Text:** “Protly needs access to your camera to work properly. You can enable it in your device settings.”  

**Buttons:**
- “Open Settings” (deep link to OS settings)  
- “Maybe later” (close modal, go to Page 4)

---

## Micro-Interactions
- Every button tap triggers a subtle vibration (haptic feedback).  
- The main camera icon gently pulses every 2 s to maintain visual life.  
- No loading spinners or progress bars — this screen must feel instant.  
- Transitions are fade-based, not sliding.  

---

## Tone
Calm, confident, minimal, human — it should feel like the app is asking for permission naturally, not forcing it.
