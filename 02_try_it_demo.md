Create the second onboarding page of the Protly mobile app.

Objective:
Simulate the “scan-to-protein” experience in an interactive way before requesting camera access. 
The goal is to give the user a short, satisfying “aha” moment that demonstrates the core mechanic without real camera use.

General layout (vertical mobile screen):

1. **Background**
   - Pure white (#FFFFFF).
   - Keep the same minimal visual identity as Page 1.
   - Ensure smooth visual continuity (fade-in transition from Page 1).

2. **Top section (≈ 10–15 % from top)**
   - Display a short line of text centered:  
     **“Essaie 👇”**
   - Font: Poppins Medium 18 px, color #3A3A3A.
   - Appear with fade-in 0.4 s after page load.

3. **Center area (≈ 35–60 % height zone)**
   - Place a large stylized **assiette (plate icon)** or minimal vector meal illustration.
   - Below it, include a **thin progress bar placeholder** (empty, 0 % filled, same green #4ADE80).
   - The user interaction:
       • When the user taps the plate, trigger the following sequence:
         1. Plate glows softly with a green halo (0.2 s).
         2. Short “scan beam” animation sweeps over it (left-to-right).
         3. Text appears above the plate: **“+28 g”**, pop-in effect with slight upward motion.
         4. The progress bar fills smoothly to ~30 %.
         5. Subtle vibration + soft pop sound (if available).
         6. After 0.8 s, display text feedback: **“Simple, non ? 📈”** below the plate.
   - Each feedback step should feel quick, rewarding, and natural — total duration ≈ 1.5–2 s.
   - If the user taps again, the animation can replay identically (loop behavior).

4. **CTA section (≈ 75–85 % height zone)**
   - After the interaction finishes (or after 2 s timeout if no tap):
       • Show a green primary button labeled **“Activer la caméra”**.
       • Full-width minus 10 % horizontal padding.
       • Color: #4ADE80 (background) / #FFFFFF (text).
       • Font: Poppins Semibold 18 px.
       • Corner radius = 24 px; light drop shadow.
       • Press animation = scale 0.97 → 1.0 + haptic feedback.
       • On tap: fade-out screen (0.4 s) → transition to Page 3 (real camera permission).

5. **Micro-interactions and timing**
   - Page fade-in = 0.4 s.
   - “Essaie 👇” appears = +0.3 s.
   - Plate slightly floats (idle breathing animation: scale 1.0 ↔ 1.02 every 2 s).
   - When plate is tapped:
       • Halo pulse → scan sweep → text +28 g → progress bar fill → “Simple, non ?” → CTA fade-in.
   - Total sequence length ≈ 3 s max.
   - All easing curves = ease-in-out for natural motion.

6. **Visual identity**
   - Maintain color palette from Page 1:  
     Primary #4ADE80, neutrals #3A3A3A / #7C7C7C, background #FFFFFF.
   - Typography: Poppins / Inter.
   - No extra decorative elements, only clean motion and space.

User perception goal:
- Understand by doing: “I tap, it scans, it adds protein.”
- Feel a short burst of satisfaction (visual + haptic feedback).
- Be ready to accept camera access naturally on the next page.

End state:
After the CTA “Activer la caméra” is pressed, fade out to transition directly to the real permission screen (Page 3).
