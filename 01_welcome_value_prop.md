Create the first onboarding page of the Protly mobile app.

Objective:
Visually express the app’s concept — "Take a photo of your meal → Instantly see your protein result" — in less than 3 seconds, before any user input.

Structure (vertical mobile layout):

1. **Background**
   - Full screen pure white (#FFFFFF).
   - No gradients, no decorative patterns.
   - Maintain generous vertical spacing for a minimalist, breathable layout.

2. **Logo placement**
   - Position the Protly logo at the top-left (5% margin from top and left edges).
   - Logo fades in from left to right over 0.5 seconds.
   - No shadow or container background.
   - Dimensions proportional: about 15% of screen width.

3. **Main animation block (center area, ~40–55% height zone)**
   - Insert a 16:9 container centered on the screen.
   - Inside the container, play a short looping animation (1.5 – 2 s loop) that illustrates how the app works:
       • A smartphone camera points toward a plate of food.
       • A green outline flash indicates a photo being taken.
       • The photo transitions to a stylized analyzed image.
       • A value appears: “+28 g”.
       • A green progress bar (#4ADE80) fills smoothly to one-third.
       • The scene resets smoothly and loops.
   - Animation must be subtle, silent, and continuous — no hard cuts.
   - The goal is comprehension through imagery, not reading.

4. **Primary Call-to-Action (below animation, ~70% height zone)**
   - One centered button: **“Essayer maintenant”**.
   - Full width minus 10% horizontal padding.
   - Background color: Vitality Green #4ADE80.
   - Text: white (#FFFFFF), font: Poppins Semibold, size ≈ 18 px.
   - Corner radius: 24 px; slight shadow for elevation.
   - On tap: scale 0.97 → 1.0 with 20 ms haptic feedback.
   - Fade-up + slight bounce animation on appearance (duration 0.6 s).

5. **Secondary action (bottom area, ~90% height zone)**
   - Centered text link:  
     **“As-tu déjà un compte ? Se connecter”**
   - Font: Inter Medium 14 px; color #7C7C7C.
   - “Se connecter” is tappable with underline on press.
   - No borders, dividers, or additional icons.

6. **Page-load sequence**
   - 0.0 s → Logo fades in.
   - 0.5 s → Animation starts automatically (loop).
   - 1.0 s → CTA fades up.
   - 1.5 s → Secondary text appears.

7. **Exit behavior**
   - When user taps “Essayer maintenant”: short vibration, fade-out of the entire screen (0.4 s) and transition to Page 2 (Try-it Demo).

Visual identity:
- Primary color = #4ADE80 (Vitality Green).
- Neutral text = #3A3A3A.
- Typeface = Poppins / Inter (sans-serif, geometric).
- No taglines, paragraphs, or carousels.
- Emotion = freshness, confidence, simplicity.

User goal:
Within 3 seconds, the user should intuitively understand:
“Protly lets me scan my meal and instantly see my protein count.”


8. **Contextual Sign-in Expansion (same page interaction)**

   - When the user taps **“As-tu déjà un compte ? Se connecter”**, do not redirect to another page.  
   - Instead, display a **non-modal contextual bottom sheet** that slides up from the bottom (occupying around 40–45% of screen height).

   **Behavior and appearance**
   - Background behind remains visible, slightly dimmed at 5–8% opacity (no blur).
   - Bottom sheet background: pure white (#FFFFFF).
   - Top corners rounded (24 px radius).
   - Entrance animation: smooth slide-up + fade (250–300 ms).
   - Dismissal: swipe down or tap outside the sheet.
   - The Welcome page remains visible and paused in its current state (animation does not restart).

   **Content inside the sheet**
   1. **Title**
      - Centered at the top: **“Se connecter”**
      - Font: Poppins Semibold, size ≈ 18 px
      - Color: #1E1E1E

   2. **Buttons (stacked vertically, 12 px spacing)**
      - **Apple Sign-in**
        - Background: #000000
        - Text: white (#FFFFFF)
      - **Google Sign-in**
        - Background: white (#FFFFFF)
        - Border: light gray (#E8E8E8)
        - Text: dark gray (#3A3A3A)
      - **Email Sign-in**
        - Transparent background
        - Border: light gray (#E8E8E8)
        - Text: gray (#3A3A3A)
      - All buttons have corner radius 24 px and uniform height ≈ 52 px.

   3. **Legal disclaimer**
      - Centered small text at the bottom:
        - Color: #7C7C7C
        - Font size: 12 px
        - Content:  
          “En continuant, tu acceptes les Conditions générales et la Politique de confidentialité.”
        - “Conditions générales” and “Politique de confidentialité” are tappable links.

   **Functional rules**
   - The sheet does not trigger a new page or reload.
   - Closes instantly after authentication success or on dismissal.
   - Returning to the Welcome page keeps its animation state intact (no restart).
