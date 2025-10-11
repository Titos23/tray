Design the "Notification Pre-Permission" screen for the Protly app.

## Goal
Encourage the user to enable gentle reminders that help them complete their daily protein goal — not spam.  
The flow must feel friendly, calm, and consistent with previous onboarding pages (white background, green accent #4ADE80, minimalist layout).

---

## Layout (vertical mobile layout)

### Top (0–10%)
- Small green bell icon (#4ADE80), line style.
- Appears with a soft fade-in + pulse animation (opacity 0.8→1.0→0.8).

### Middle (30–45%)
- Title text (centered):
  **"Gentle reminders to complete your bar 🟩"**
  Font: Poppins Semibold 22 px, color #1E1E1E.
  Function: explain benefit, not the permission itself.

### Middle-Lower (50–70%)
- Three selectable cards (equal width, rounded 24 px, light gray border #E8E8E8).
  Each card has an emoji, name, and short description:
  1. 🌿 **Light** — one reminder per day  
  2. ⚡ **Standard** — three reminders per day  
  3. 💤 **Silent** — reminders without sound  
- When tapped:
  - Card background animates to #E6F9ED (light green tint).
  - Small haptic feedback.
  - Selected card keeps subtle green border #4ADE80.

### Bottom (75–85%)
- Primary CTA button:
  Text: **"Enable my reminders"**  
  Background #4ADE80, text #FFFFFF, corner radius 28 px.  
  On tap: quick vibration + ripple effect.

### Bottom (85–90%)
- Secondary reassurance text (centered, gray #7C7C7C, Inter 14 px):  
  “You can change this anytime.”

---

## Animation / Interaction Flow

1. Cards fade-in sequentially (100 ms offset).
2. When user selects a card → enable button becomes active.
3. Tap **Enable my reminders** → short bell chime sound + confetti animation (light, minimal).
4. Immediately after animation → system notification permission prompt appears (OS-level).

---

## Edge-Case Behaviors

### ✅ Case 1 – Permission Accepted
- Transition with quick fade-out (0.4 s) to next onboarding page ("Privacy & Consent").
- Optional confirmation toast:  
  “Great! We’ll keep you on track 💪”

### ❌ Case 2 – Permission Denied
- Show small reassurance overlay for 2 s:  
  “No worries — you can enable notifications later 😉”
- Then automatically continue to next onboarding page.

### ⚙️ Case 3 – Already Granted
- Skip this screen entirely and go directly to "Privacy & Consent" page.

---

## Visual & Motion Guidelines
- Background: pure white #FFFFFF  
- Accent color: green #4ADE80  
- Font pairing: Poppins / Inter  
- Motion: soft, 200–300 ms ease-in-out transitions  
- Tone: calm, friendly, reassuring  
- No hard shadows, no dense text blocks, no pop-ups except OS prompt.

---

## Success Criteria
- User perceives control (choice among 3 modes).  
- Screen duration < 6 s average.  
- > 70 % expected acceptance rate.  
- Seamless transition to Privacy & Consent page.
