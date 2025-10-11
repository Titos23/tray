# Protly App – Splash Screen Specification

## Background
- Color: Pure white `#FFFFFF`

## Logo
- Position: Center of the screen  
- Asset: Protly logo (provided image asset)  
- Size: ~35–40% of screen width  
- Animation:
  - Fade-in with slight scale-in (`0.85x → 1.0x`)  
  - Duration: ~0.5s  

## Text (“Protly”)
- Position: Just below the logo  
- Content: **Protly**  
- Color: `#3A3A3A`  
- Font: Clean sans-serif (Inter Medium / Poppins Semibold)  
- Size: Visually balanced with the logo  
- Animation:
  - Appears **0.3s after logo**  
  - Fade-in upward from bottom  

## Pulse Effect
- Trigger: After both logo and text appear  
- Animation: Logo performs subtle pulse (`1.0 → 1.03 → 1.0`)  
- Duration: ~0.3s  
- Effect: Creates a sense of life and freshness  

## Sequence Duration
- Total splash sequence: ~1.8s  
- End: Smooth fade-out transition to **Welcome page**  

## Constraints
- No loading bar  
- No shadows  
- No extra text  
- Design must remain **absolutely minimal, bright, and clean**
