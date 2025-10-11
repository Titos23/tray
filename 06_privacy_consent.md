### TASK
Design **Page 6 – Privacy & Consent** for the mobile app **Protly**.

---

### CONTEXT
This is the **final screen** of the pre-onboarding flow, right after notification permission (Page 5).  
Goal: **build user trust** and create a sense of transparency and control before the user enters the main app (camera scan or dashboard).  
Tone: calm, confident, simple, human.

---

### VISUAL STYLE
- Background: pure white `#FFFFFF`
- Primary color: Vitality Green `#4ADE80`
- Font: Poppins / Inter
- Layout: centered vertical flow, generous white space
- Minimalist icons (flat, outline, soft shadows)
- No long paragraphs, only short bullet chunks
- Smooth fade-in animation for each element (0.3s staggered)

---

### STRUCTURE (VERTICAL ORDER)

1. **Icon (Top 0–10%)**
   - Display a small shield or open hand icon in green (#4ADE80).
   - Subtle pulse animation to convey safety.
   - Cognitive purpose: *affective priming of trust*.

2. **Main Title (Mid 25–35%)**
   - Text: **“You stay in control.”**
   - Font size ≈ 24–28 px, bold, dark gray `#1E1E1E`.
   - Function: reduce anxiety, emphasize ownership.

3. **Three Bullet Points (Mid 40–65%)**
   - Each with a small green check icon and a short, plain statement:
     - “You can edit or correct any scan.”
     - “You can delete your data anytime.”
     - “We never display calories — only proteins.”
   - Justification: *Chunking principle* (Cognitive Load Theory).
   - Animation: appear one by one (0.2 s delay each).

4. **Optional Link (Mid-low 70%)**
   - Text: “Learn more about how we protect your data.”
   - Gray text `#7C7C7C`, underlined.
   - Opens a separate info sheet (optional).
   - Heuristic: *User control & freedom*.

5. **Primary CTA (Bottom 85–90%)**
   - Text: **“Continue”**
   - Button color: #4ADE80 (white text)
   - Rounded corners (radius = 24 px)
   - Light scale-in animation on appearance.
   - On tap → gentle vibration feedback.

---

### MICRO-INTERACTIONS
- When bullets appear, slight slide-up + fade effect.
- When pressing “Continue”, perform a small pulse (1.0 → 1.05 → 1.0 scale).
- Fade transition to **the main app home screen**.

---

### CONDITIONAL CASES / EDGE STATES

#### 🟢 Case 1 – All permissions accepted (camera + notifications)
- Show the normal flow above.
- After tapping **Continue**, go straight to the **Main Dashboard** (Page Home).
- Transition text (optional): “Let’s go 👇”.

#### 🟡 Case 2 – Camera accepted but notifications denied
- Add a small info line above the CTA:
  - “Notifications are off. You can enable them later in Settings ⚙️.”
- Keep CTA text the same: **“Continue”**.

#### 🔴 Case 3 – Camera denied
- Replace title with: **“We’ll need your camera later.”**
- Replace bullets with:
  - “Protly works best when you can scan your meals.”
  - “You can allow camera access anytime in Settings.”
- CTA: **“Continue without camera”**
- Add a small link below CTA: “Open Settings”.

#### ⚪ Case 4 – Offline mode (no connection)
- Add banner on top: “You’re offline. Some features may be limited.”
- CTA disabled (gray) until connection restored.
- Animation: banner slides from top with a soft bounce.

---

### TRANSITION
After “Continue”:
- Fade-out (0.5 s)
- Navigate to **Main App Home / Dashboard / Camera screen** (depending on design logic)
- Haptic feedback “success” pattern.

---

### UX PRINCIPLES
- **Norman:** Visibility of purpose → title and icons clearly communicate safety.
- **Nielsen:** Minimalist design, clear user control, error tolerance.
- **Kahneman:** Use System 1 cues (icon, short text, green color) to trigger intuitive trust.
- **Cognitive load:** ≤ 4 information chunks total.
