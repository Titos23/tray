**Design the Page 4C: “Protein Goal Result” screen for the Protly app.**

**Purpose:**  
Display the personalized daily protein target in a rewarding, emotionally satisfying way.  
It must feel like a mini “achievement moment.”

---

### 🎨 Layout & Elements (vertical order)

1️⃣ **Progress indicator (top 0–10%)**
- Thin bar labeled “Step 2 of 2”.
- Animate left → right with vitality green (#4ADE80).

2️⃣ **Main title (35–45%)**
- Text: “Here’s your daily goal 🎯”
- Font: Poppins SemiBold 26 px, color #1E1E1E, centered.

3️⃣ **Dynamic result block (45–65%)**
- Large number: **“150 g of protein per day”**
- Subtext: “≈ 1 g per lb of body weight.”
- Appear with fade + scale-in animation (0.85x → 1.0x).
- Haptic vibration on appear.

4️⃣ **Progress visual (65–80%)**
- Empty progress bar or circular ring at 0%.
- Light pulse animation (scale 0.9 → 1.05 → 1.0).

5️⃣ **Motivational line (80–88%)**
- Text: “You’re all set 💪 We’ll help you get there.”
- Fade-in 0.3 s after the main number appears.

6️⃣ **Primary CTA (88–95%)**
- Button: **“Continue”**
- Background: #4ADE80, text white (#FFFFFF), radius 24 px.
- Tap → fade or slide-up transition to Page 5 (Notification Preferences).

---

### ⚙️ Behavior Cases

**Case 1 – Complete data:**  
- Show exact computed value (e.g. “148 g”).  
- Normal message: “🎯 Your goal is 148 g per day.”

**Case 2 – Partial data (“I don’t know” for weight/height):**  
- Show average estimate: “≈ 120 g of protein per day.”  
- Subtext: “You can adjust this later in your profile ⚙️.”

**Case 3 – Very high target (>180 g):**  
- Add small note: “That’s a strong goal 💪 You can tweak it anytime.”

**Case 4 – Error / missing inputs:**  
- Fallback to 130 g.  
- Message: “We’ll start with an average goal (130 g). You can edit it later.”

---

### 💡 Design Principles
- 1 main focus per screen (the result).
- Immediate visual feedback (Norman: visibility of system status).
- Positive reinforcement tone.
- White background, vitality green accent, clean typography.
