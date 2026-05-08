# JeepneyWaze — Claude Design Prompt Guide
## UI/UX Recreation: Uber Design Language → JeepneyWaze

> **How to use this file:** Paste any section (or the entire file) into Claude Design as your starting prompt. Each section is self-contained and copy-paste ready. For full fidelity, start with Section 1 (System Foundation) before designing individual screens.

---

## SECTION 1 — SYSTEM FOUNDATION (Always include this)

You are designing **JeepneyWaze**, a civic-tech mobile transit app for Filipino commuters. It provides real-time jeepney tracking powered by the **Virtual Beacon engine** — GPS clustering from commuter phones, requiring zero hardware.

Adopt the visual language of Uber's design system with targeted Filipino adaptations. The result should feel like Uber's confident minimalism meets the kinetic energy of Philippine street culture — bold, functional, built for the chaotic beauty of Metro Manila commuting.

### Brand Identity
- **App Name:** JeepneyWaze
- **Tagline:** "Alam mo na. Sumakay na." *(You know now. Ride now.)*
- **Audience:** Filipino urban commuters aged 18–45, daily jeepney riders in Metro Manila and Cebu
- **Tone:** Confident, civic, street-smart. Not corporate. Not playful. Authoritative transit infrastructure.
- **Platform:** Flutter mobile app (Android primary, iOS secondary). All screens are **375×812px** (iPhone 14 reference) unless specified.

### Design Philosophy
The interface is built on Uber's core principle — **confident minimalism** — with one deliberate deviation: a **Jeepney Yellow** accent that pays homage to the iconic painted jeepney. This is the only color allowed to break the black/white universe, and it does so with purpose: to signal live vehicle activity, active states, and moments of delight.

---

## SECTION 2 — COLOR PALETTE

### Primary (Uber-Inherited)
| Name | Hex | Role |
|------|-----|------|
| **JW Black** | `#000000` | Primary buttons, headlines, navigation, headers |
| **Pure White** | `#FFFFFF` | Page background, card surfaces, text on dark |
| **Body Gray** | `#4B4B4B` | Secondary text, descriptions, metadata |
| **Muted Gray** | `#AFAFAF` | Tertiary text, placeholders, disabled states |
| **Chip Gray** | `#EFEFEF` | Filter chips, secondary nav tabs, input backgrounds |
| **Hover Gray** | `#E2E2E2` | Hover/pressed states on white buttons |

### Accent (JeepneyWaze-Specific)
| Name | Hex | Role |
|------|-----|------|
| **Jeepney Yellow** | `#F5C400` | Live beacon markers, active route indicators, gamification rewards, success states |
| **Yellow Dark** | `#C49A00` | Yellow hover state, pressed yellow buttons |
| **Yellow Glow** | `rgba(245, 196, 0, 0.20)` | Beacon pulse animation, active map highlights |

### Semantic (Status Colors)
| Name | Hex | Role |
|------|-----|------|
| **Siksikan Red** | `#E53935` | Crowded jeepney status (Siksikan = packed) |
| **Malwag Green** | `#2E7D32` | Spacious jeepney status (Malwag = roomy) |
| **Warning Orange** | `#F57C00` | Moderate crowding, ETA warnings |

### Shadows & Depth
| Name | Value | Role |
|------|-------|------|
| Shadow Light | `rgba(0,0,0,0.12) 0px 4px 16px` | Standard cards, bottom sheets |
| Shadow Medium | `rgba(0,0,0,0.16) 0px 4px 16px` | Elevated overlays, FABs |
| Shadow Beacon | `rgba(245,196,0,0.30) 0px 0px 12px` | Glowing beacon map marker |

### Rules
- **No gradients anywhere** — all surfaces are flat, solid colors.
- **No mid-tone grays** in UI chrome — only `#EFEFEF`, `#4B4B4B`, `#AFAFAF` are permitted.
- Jeepney Yellow appears **only** on: beacon markers, active route pills, Guardian Points badges, success toasts, and the app logo mark.
- Never use yellow on body text or primary buttons — it is a signal color, not a UI chrome color.

---

## SECTION 3 — TYPOGRAPHY

### Font Family
Since UberMove is proprietary, JeepneyWaze uses **Inter** as its primary typeface (closest geometric sans-serif match, free and available on Google Fonts).

- **Headlines / Display:** `Inter, system-ui, -apple-system, sans-serif` — Weight 700 (Bold)
- **Body / UI:** `Inter, system-ui, -apple-system, sans-serif` — Weight 400–500

### Type Scale (Mobile)
| Role | Size | Weight | Line Height | Use |
|------|------|--------|-------------|-----|
| Display | 36px | 700 | 1.20 | Hero headlines, splash screen |
| Heading 1 | 28px | 700 | 1.25 | Screen titles, major headers |
| Heading 2 | 22px | 700 | 1.27 | Card titles, section headers |
| Heading 3 | 18px | 700 | 1.33 | Sub-section headers, modal titles |
| Body Large | 16px | 400 | 1.50 | Primary body text, route names |
| Body Regular | 14px | 400 | 1.43 | Descriptions, stop names, metadata |
| Label | 14px | 500 | 1.14 | Button labels, chip text, nav labels |
| Caption | 12px | 400 | 1.50 | Timestamps, ETA values, footnotes |
| Micro | 10px | 500 | 1.60 | Badge counts, map pin labels |

### Principles
- All headlines: Inter Bold (700) only. Never use regular weight for headings.
- No letter-spacing modifications. No text-transform (no ALL CAPS in UI).
- Filipino route and stop names render in the same typeface — no special handling needed.
- ETA numbers (e.g., "4 min") use Inter Bold at Heading 2 size for immediate scannability.

---

## SECTION 4 — COMPONENT LIBRARY

### Buttons

**Primary Black CTA**
```
Background: #000000
Text: #FFFFFF, Inter 500, 14px
Padding: 14px 24px
Border Radius: 999px (full pill)
Min Height: 48px (touch target)
Pressed: background #1A1A1A
Example: "See Routes", "Confirm Ride", "Report Crowd"
```

**Secondary White**
```
Background: #FFFFFF
Text: #000000, Inter 500, 14px
Border: 1px solid #000000
Padding: 14px 24px
Border Radius: 999px
Pressed: background #EFEFEF
Example: "Cancel", "View Details"
```

**Jeepney Yellow CTA (Accent — Use Sparingly)**
```
Background: #F5C400
Text: #000000, Inter 700, 14px
Padding: 14px 24px
Border Radius: 999px
Pressed: background #C49A00
Use ONLY for: "I'm On Board" confirm, Guardian Points claim, beacon formation success
```

**Filter / Nav Chip**
```
Background: #EFEFEF
Text: #000000, Inter 500, 13px
Padding: 10px 16px
Border Radius: 999px
Active: Background #000000, Text #FFFFFF
Example: "All Routes", "EDSA Line", "Colon-SM"
```

**Floating Action Button (FAB)**
```
Background: #FFFFFF
Icon: black SVG, 20px
Padding: 14px (square, becomes circle)
Border Radius: 999px
Shadow: rgba(0,0,0,0.16) 0px 2px 8px
Use for: Locate Me, Zoom controls, Layer toggle on map
```

### Cards

**Standard Content Card**
```
Background: #FFFFFF
Border Radius: 12px
Shadow: rgba(0,0,0,0.12) 0px 4px 16px
Padding: 16px
Content: Title (Heading 3, black), Body (14px, Body Gray #4B4B4B), optional CTA button
```

**Jeepney Status Card (Live Vehicle)**
```
Background: #FFFFFF
Border Radius: 12px
Shadow: rgba(0,0,0,0.12) 0px 4px 16px
Left accent bar: 4px wide — Malwag Green (#2E7D32) or Siksikan Red (#E53935)
Contains: Route code pill, ETA in Inter Bold 28px, crowding badge, stop count
```

**Bottom Sheet (Drawer)**
```
Background: #FFFFFF
Border Radius: 20px 20px 0px 0px (top corners only)
Shadow: rgba(0,0,0,0.16) 0px -4px 24px
Drag handle: 4px × 36px rounded pill, #EFEFEF, centered at top
Max height: 70% of screen
```

### Map Components

**Virtual Beacon Marker (Live Jeepney)**
```
Shape: Rounded square, 44×44px
Background: #F5C400 (Jeepney Yellow)
Icon: Jeepney silhouette SVG, black, 24px
Border: 2px solid #000000
Shadow: rgba(245,196,0,0.30) 0px 0px 12px (yellow glow)
Pulse animation: scale 1.0→1.3→1.0 at 2s intervals, opacity 1→0
Stale marker: background #AFAFAF, no glow
```

**Stop Marker**
```
Shape: Circle, 12px diameter
Background: #000000
Border: 2px solid #FFFFFF
Selected: diameter 18px with inner yellow dot #F5C400
```

**Route Polyline**
```
Active route: #000000, 4px stroke, opacity 1.0
Inactive route: #AFAFAF, 2px stroke, opacity 0.5
```

**ETA Bubble (on map)**
```
Background: #000000
Text: #FFFFFF, Inter Bold, 12px, format: "4 min"
Padding: 4px 8px
Border Radius: 999px
Anchor: bottom-center of beacon marker
```

### Inputs & Forms

**Search / Destination Input**
```
Background: #FFFFFF
Border: 1px solid #000000
Border Radius: 12px
Padding: 14px 16px
Text: Inter 400, 16px, #000000
Placeholder: Inter 400, 16px, #AFAFAF
Focus: border 2px solid #000000, shadow rgba(0,0,0,0.08) 0px 2px 8px
Leading icon: search or location pin SVG, black, 18px
```

**Phone Number Input (OTP Auth)**
```
Same as Search Input
Prefix: Philippine flag emoji + "+63" label in Body Gray
Keyboard type: numeric
```

**OTP Code Boxes**
```
6 individual boxes, each 48×56px
Background: #EFEFEF
Active: border 2px solid #000000, background #FFFFFF
Filled: background #000000, text #FFFFFF, Inter Bold 24px
Border Radius: 8px
Gap between boxes: 8px
```

### Navigation

**Bottom Navigation Bar**
```
Background: #FFFFFF
Border Top: 1px solid #EFEFEF
Height: 72px (including safe area)
Tabs: 4 items — Map (home), Routes, Alerts, Profile
Active tab icon: #000000, filled; label: Inter 500 12px #000000
Inactive tab icon: #AFAFAF, outline; label: Inter 400 12px #AFAFAF
Active indicator: 3px × 20px rounded pill above icon, #F5C400
```

**Top App Bar**
```
Background: #FFFFFF
Height: 56px
Title: Inter 700, 18px, #000000, centered
Back button: left-aligned, black chevron icon, 44×44px touch target
Action button: right-aligned, icon only, 44×44px
Border Bottom: none — use shadow rgba(0,0,0,0.08) 0px 2px 8px on scroll
```

### Crowding Badges

**Siksikan (Packed)**
```
Background: #E53935
Text: #FFFFFF, Inter 700, 11px, "SIKSIKAN"
Padding: 4px 8px, Border Radius: 999px
```

**Malwag (Spacious)**
```
Background: #2E7D32
Text: #FFFFFF, Inter 700, 11px, "MALWAG"
Padding: 4px 8px, Border Radius: 999px
```

**Moderate**
```
Background: #F57C00
Text: #FFFFFF, Inter 700, 11px, "KATAMTAMAN"
Padding: 4px 8px, Border Radius: 999px
```

### Guardian Points Badge
```
Shape: Circle, 32px diameter
Background: #F5C400
Text: Inter Bold, 12px, #000000
Icon: Shield SVG, 16px, black (for rank display)
Shadow: rgba(245,196,0,0.30) 0px 2px 8px
```

---

## SECTION 5 — SPACING & LAYOUT SYSTEM

```
Base Unit: 4px
Scale: 4, 8, 12, 16, 20, 24, 32, 40, 48, 64px

Screen Edge Margin: 20px (left/right)
Card Gap: 12px between cards
Section Gap: 32px between major sections
Bottom Sheet Internal Padding: 24px
Safe Area Bottom: 34px (iOS) / 0px (Android — handled by system)
```

### Border Radius Scale
| Value | Use |
|-------|-----|
| 0px | None — never used on interactive elements |
| 8px | Input fields, content chips, small thumbnails |
| 12px | Standard cards, modal containers, list items |
| 20px | Bottom sheet top corners |
| 999px | All buttons, all filter chips, all pill badges, beacon ETA bubbles |

---

## SECTION 6 — SCREEN-BY-SCREEN DESIGN INSTRUCTIONS

---

### SCREEN 1: Splash Screen

**Purpose:** App launch / loading state. Establish brand.

**Layout:**
- Full black background `#000000`
- Center vertically and horizontally
- App logo mark: stylized jeepney silhouette in Jeepney Yellow `#F5C400`, 80×80px
- App name "JeepneyWaze" below logo: Inter Bold 28px, Pure White `#FFFFFF`, letter-spacing 0
- Tagline "Alam mo na. Sumakay na." below name: Inter 400 14px, Muted Gray `#AFAFAF`
- Gap between logo and name: 16px
- Gap between name and tagline: 8px
- Loading indicator at bottom: 3 dots pulsing in Jeepney Yellow, 8px each, 32px from screen bottom

**Tone:** Silent, confident. The black + yellow against dark reads like a transit sign at night.

---

### SCREEN 2: Onboarding — Slide 1 of 3

**Purpose:** Explain the Virtual Beacon concept in plain Filipino terms.

**Layout:**
- White background
- Top 55% of screen: full-bleed illustration
  - Style: warm, slightly flat illustration (not photographic)
  - Scene: Birds-eye view of EDSA with clustered commuter phone icons glowing yellow, forming a virtual jeepney beacon. People with phones, jeepney in motion.
  - Illustration palette: warm neutrals, black, and yellow highlights — no other colors
- Bottom 45%: text content area, 20px horizontal margin
  - Chip label at top: "HOW IT WORKS" in black pill chip, 10px uppercase, 8px padding
  - Headline: "Nakikita namin ang jeepney kahit walang driver app." Inter Bold 26px, #000000, tight line-height 1.25
  - Body: "Ang iyong GPS ang nagpapakita kung nasaan ang jeepney. Walang hardware. Libre." Inter 400 14px, Body Gray #4B4B4B, line-height 1.57
  - Gap: 24px
  - Progress dots: 3 dots — active dot is a 24px pill `#000000`, inactive are 8px circles `#EFEFEF`
  - "Next" pill button: black, full width, pinned to bottom with 20px margin

---

### SCREEN 3: Onboarding — Slide 2 of 3

**Purpose:** Explain crowding reports (Siksikan/Malwag).

**Layout (same structure as Slide 1):**
- Illustration: Commuter inside a jeepney tapping their phone. Jeepney interior, warm illustration tones. Other passengers visible. Crowding badge floats above.
- Chip label: "SIKSIKAN O MALWAG"
- Headline: "Sabihin sa iba kung puno o may puwang." Inter Bold 26px
- Body: "Isang tap lang para mag-report ng crowding. Lahat ay nakikinabang kapag nagbahagi tayo." Inter 400 14px, Body Gray
- Crowding badge demo: Show Siksikan (red) and Malwag (green) badges inline in body text as visual examples
- Progress dots: dot 2 active
- "Next" button: black pill, full width

---

### SCREEN 4: Onboarding — Slide 3 of 3

**Purpose:** Introduce Route Guardian gamification.

**Layout (same structure):**
- Illustration: Hand holding phone with Guardian Points badge glowing gold. Leaderboard visible in background. Urban Metro Manila skyline at dusk silhouette.
- Chip label: "ROUTE GUARDIAN"
- Headline: "Mag-earn ng Guardian Points para sa tuwing nakakatulong ka." Inter Bold 26px
- Body: "Ang pinaka-aktibong commuters ang nagiging Route Guardians ng kanilang linya." Inter 400 14px, Body Gray
- Guardian Points badge demo: Show the yellow circular badge with a shield icon
- Progress dots: dot 3 active
- CTA: "Magsimula na" (Let's begin) — yellow pill button `#F5C400`, Inter Bold 14px, black text, full width

---

### SCREEN 5: Phone OTP Authentication

**Purpose:** Login / Sign-up via Philippine mobile number.

**Layout:**
- White background
- Top App Bar: "Mag-sign in" (Sign in), Inter Bold 18px, centered. No back button on this screen.
- Content area with 20px horizontal margin:
  - Gap from top bar: 40px
  - Headline: "Ano ang iyong numero?" Inter Bold 28px, #000000
  - Sub: "Padadalhan ka namin ng verification code." Inter 400 14px, Body Gray
  - Gap: 32px
  - Phone input field: full width, flag + "+63" prefix, numeric keyboard
  - Gap: 16px
  - "Humingi ng Code" pill button (Request Code): black, full width, 48px height
  - Gap: 24px
  - Divider line with "o" (or) centered: 1px `#EFEFEF` on both sides, "o" in Body Gray 14px
  - Gap: 24px
  - Legal text: "Sa pag-sign in, sumasang-ayon ka sa aming Terms at Privacy Policy." Inter 400 12px, Muted Gray, centered, with underlined links in black

**OTP Verification sub-screen (pushed on top):**
- Headline: "I-enter ang code" Inter Bold 28px
- Sub: "Ipinadala sa +63 9XX XXX XXXX" Inter 400 14px, Body Gray — with "Baguhin" (Change) link in black
- 6 OTP boxes, centered, as described in components
- "Resend code" text link: Muted Gray, "Muling humingi ng code (00:45)"
- Auto-submit on 6th digit entry
- Loading state: button shows spinner instead of label

---

### SCREEN 6: Home — Map Screen (PRIMARY SCREEN)

**Purpose:** Core product screen. Real-time jeepney map with Virtual Beacon markers.

**Layout:**
- Full-bleed map (OpenStreetMap/MapLibre tile, light gray style — not dark map)
- Map style: de-saturated light gray, roads in white/light gray, labels in Body Gray `#4B4B4B`
- Virtual Beacon markers scattered across routes (see marker specs in Section 4)
- Route polylines visible on map

**Overlaid UI (NOT part of the map tile):**

*Top layer:*
- Floating search bar (not a top app bar):
  - Position: 20px from top of safe area, 20px horizontal margin
  - Background: #FFFFFF, border-radius 12px, shadow rgba(0,0,0,0.12)
  - Height: 52px
  - Leading: search icon 18px black
  - Placeholder: "Saan ka pupunta?" (Where are you going?)
  - Trailing: profile avatar circle, 32px diameter, black background

*Filter chips row (horizontal scroll):*
- Position: 12px below search bar
- Chips: "Lahat" (All), "EDSA Cubao–Quiapo", "Colon–SM", "+ Dagdag" (+Add)
- Active chip: black background, white text
- Scroll: horizontal, no scrollbar visible

*Bottom sheet (default collapsed state):*
- Peek height: 160px from bottom
- Drag handle at top
- Content in peek state:
  - Section title: "Mga Malapit na Jeepney" (Nearby Jeepneys), Inter Bold 16px
  - 2 horizontal route cards in a scroll: show route code, ETA, crowding badge
- Expanded: full route list

*Floating Action Buttons (bottom right, stacked):*
- "Locate Me" FAB: compass/location icon
- Above it: "Layers" FAB: map layers icon
- 16px gap between FABs
- 20px from right edge, 180px from bottom (above peek sheet)

*Bottom Navigation Bar:*
- Pinned to bottom, above safe area
- 4 tabs: Map (active), Routes, Alerts, Profile

---

### SCREEN 7: Route Detail — Bottom Sheet (Expanded)

**Purpose:** User tapped a route or a beacon. Show live vehicles on that route.

**Layout (Bottom Sheet expanded to 80% screen):**
- Drag handle
- Route header row:
  - Left: Route code pill (black pill, white text, Inter Bold 14px, e.g., "EDSA C-Q")
  - Center: Route name, Inter Bold 18px
  - Right: Favorite heart icon, outline → filled yellow when active
- Separator line `#EFEFEF`, 1px
- "Live Jeepneys" section label: Inter 700 12px, Muted Gray, uppercase
- Vertical list of Jeepney Status Cards (see component spec):
  - Each card: route badge, ETA, crowding indicator, "X stops away", Malwag/Siksikan badge
  - Tap a card → expands into Stop Detail sheet
- "May problema sa data?" (Issue with data?) text link in Muted Gray at bottom of list
- Pinned at sheet bottom: "Nandito na ako" (I'm on board) button — Jeepney Yellow pill, full width, Inter Bold 14px, black text

---

### SCREEN 8: Stop Detail Sheet

**Purpose:** User tapped a specific stop marker on the map.

**Layout (Bottom Sheet, mid-height ~50%):**
- Drag handle
- Stop name: Inter Bold 22px, #000000 (e.g., "Guadalupe MRT Station")
- Stop sub-label: Inter 400 14px, Body Gray — "Kanto sa EDSA Southbound"
- Separator
- "Susunod na Jeepney" (Next Jeepney) label: Muted Gray uppercase 12px Inter 700
- Large ETA display: "3 min" — Inter Bold 48px, #000000, left-aligned
- Sub: "2 jeepney ang papalapit" (2 jeepneys approaching), Inter 400 14px, Body Gray
- Crowding badge: inline, Malwag or Siksikan
- Separator
- "Mag-report ng Crowd" (Report Crowd) section — icon + label, tappable row
- Black pill CTA: "I-notify ako" (Notify me when jeepney is close) — full width

---

### SCREEN 9: Crowding Report (Siksikan / Malwag)

**Purpose:** 1-tap crowding report. Keep it fast — commuter is standing at the kanto.

**Layout (Modal bottom sheet, 45% height):**
- Drag handle
- Title: "Kamusta ang sasakyan?" (How's the vehicle?) Inter Bold 20px, centered
- Sub: "Para sa ibang commuters na naghihintay." Inter 400 14px, Body Gray, centered
- Gap: 24px
- 3 large pill option buttons, stacked, full width, 56px each:
  - **SIKSIKAN**: Red background `#E53935`, white Inter Bold 16px text, jeepney icon + "Puno na!" (Full!)
  - **KATAMTAMAN**: Orange `#F57C00`, white text, "Pwede pa." (Still OK.)
  - **MALWAG**: Green `#2E7D32`, white text, jeepney icon + "May puwang pa!" (Still room!)
- Gap: 16px
- "Hindi na ako makapag-report" (I can't report right now) — text link, Muted Gray, centered
- Note: No X close button. Drag down to dismiss, or tap an option (auto-dismisses).

---

### SCREEN 10: Route Guardian — Points & Leaderboard

**Purpose:** Gamification screen. Show user's Guardian Points and rank on their routes.

**Layout:**
- Top App Bar: "Route Guardian" Inter Bold 18px centered
- Black hero section (full width, 180px tall):
  - User's total points: "1,240 pts" Inter Bold 36px, Jeepney Yellow `#F5C400`
  - Rank label: "Silver Guardian" Inter 500 14px, Pure White
  - Guardian Points badge (shield + star), 48px, yellow
  - Subtle background: faint jeepney silhouette pattern at 5% white opacity
- White content area, 20px margin:
  - Section: "Iyong mga Ruta" (Your Routes), Inter Bold 16px
  - Route cards showing user's contribution per route:
    - Route code pill, route name, "X reports this week", progress bar toward next rank
    - Progress bar: track `#EFEFEF`, fill `#F5C400`, height 6px, border-radius 999px
  - Section: "Leaderboard — EDSA Cubao–Quiapo"
  - Leaderboard list: rank number, username (anonymized), points
    - Rank 1: yellow left border accent on row
    - Current user row: `#EFEFEF` background highlight
  - "Kumita ng mas marami" (Earn more) section: tips in card format

---

### SCREEN 11: Profile & Settings

**Layout:**
- Top App Bar: "Profile" Inter Bold 18px
- White background
- Profile header card (20px margin, 12px radius card):
  - Avatar: black circle, 56px, white initials Inter Bold 20px
  - Name: Inter Bold 18px (or "Anonymous Commuter" if not set)
  - Phone: `+63 9XX XXX XXXX`, Body Gray 14px
  - Guardian rank badge inline: yellow shield + "Silver Guardian"
- Settings list below (standard iOS/Android list items):
  - Each row: 56px height, 20px padding, 1px `#EFEFEF` divider
  - Label: Inter 400 16px, #000000
  - Trailing: chevron icon `#AFAFAF` for navigable items; toggle switch for boolean items
  - Toggle active: black track with white thumb (no color)
- List sections:
  - **App:** Notifications, GPS Accuracy Mode, Language (Filipino/English)
  - **Account:** Saved Routes, Privacy, Terms of Service
  - **About:** App Version, Report a Bug, Rate the App
- "Mag-sign out" (Sign out) — black outlined pill button, full width, at bottom

---

## SECTION 7 — ILLUSTRATION STYLE GUIDE

All illustrations in JeepneyWaze follow these rules:

- **Style:** Warm, slightly flat (not fully flat — soft shadows on objects), contemporary Filipino urban scene
- **Color palette within illustrations:** Black outlines at 40% opacity, warm skin tones, muted urban colors, and strategic Jeepney Yellow highlights (on phone screens, jeepney body, beacon signals)
- **People:** Diverse Filipino faces, casual everyday clothing, age 18–45. Not stylized to the point of cartoon — more editorial illustration than emoji style.
- **Vehicles:** Jeepneys rendered with iconic silhouette — elongated body, decorative top rails, front-facing. Yellow body with black chrome details.
- **Setting:** Metro Manila streets — EDSA overpasses, LRT pillars, jeepney terminals, sidewalk crowds. Or Cebu's Colon Street with heritage architecture.
- **No western-context imagery.** No American-style pickup trucks, no European architecture, no generic Uber-style illustrations with anonymous cities.
- **Warmth check:** Every illustration should feel like it was made by a Filipino artist who commutes daily. It should feel familiar, not generic.

---

## SECTION 8 — INTERACTION & ANIMATION PATTERNS

### Beacon Pulse Animation
- Virtual Beacon marker emits a pulsing ring every 2 seconds
- Ring: starts at marker edge (44px), expands to 70px, opacity 1→0
- Color: Jeepney Yellow `rgba(245,196,0,0.40)`
- CSS equivalent: `scale(1)→scale(1.6)` + `opacity(1)→opacity(0)` over 1.5s, infinite

### Screen Transitions
- Push navigation: standard right-to-left slide (iOS), bottom-to-top for bottom sheets
- Modal bottom sheets: spring physics — overshoot slightly then settle (natural feel)
- Tab switches: crossfade, no slide

### Loading States
- Skeleton loader: `#EFEFEF` placeholder blocks, same shape as content, animated shimmer
- Shimmer: left-to-right gradient `rgba(255,255,255,0.6)`, 1.2s cycle
- Map loading: tiles fade in from white at 300ms

### Micro-interactions
- Crowding report submission: button flashes briefly to selected color, then checkmark → auto-dismiss
- OTP box fill: box turns black with white text on each digit entry — instant, no animation delay
- Beacon marker tap: brief scale 1.0→1.15→1.0 at 150ms, then bottom sheet slides up
- Guardian Points earned: yellow badge bounces (scale 1.0→1.3→1.0) with a +points toast

### Toast Notifications
- Bottom of screen, above navigation bar
- Background: #000000 (success/info) or `#E53935` (error)
- Text: Pure White, Inter 500, 14px
- Icon: left-aligned, white SVG
- Auto-dismiss: 3 seconds
- Example: "✓ Na-report ang crowding. +5 Guardian Points" — black background with yellow "+5" text

---

## SECTION 9 — DO'S AND DON'TS FOR CLAUDE DESIGN

### Do
- Use Inter Bold 700 for every headline — size and weight convey authority.
- Apply 999px border-radius to all buttons and pills — non-negotiable core identity.
- Use `#000000` and `#FFFFFF` as the primary palette for all UI chrome.
- Reserve Jeepney Yellow `#F5C400` exclusively for live/active/success states — do not decorate with it.
- Use Filipino language for all UI labels (English in parentheses in this doc for reference).
- Keep layouts information-dense — commuters are scanning at the kanto, not leisurely browsing.
- Design for one-handed phone use — all critical actions within thumb reach (bottom third of screen).
- Add the Siksikan/Malwag color coding consistently on all crowding indicators.
- Use full-bleed illustrations in onboarding only — keep map and functional screens clean.

### Don't
- Don't use color in the UI chrome — only the 3 status colors (red/orange/green) and yellow accent.
- Don't use rounded corners less than 999px on any button, chip, or pill element.
- Don't create airy, spacious layouts — Filipino transit context is dense, fast, and direct.
- Don't use gradients, shadows with >0.16 opacity, or glow effects on non-beacon elements.
- Don't mix languages randomly — commit to Filipino-first with English fallback only for technical terms.
- Don't design for desktop or tablet — this is a mobile-native app.
- Don't add decorative borders — borders are functional (inputs) or absent.
- Don't use yellow text on white backgrounds — insufficient contrast, reserve for dark/black surfaces.
- Don't replicate Uber's "ride-hailing" UX patterns — JeepneyWaze is transit tracking, not dispatch.

---

## SECTION 10 — EXAMPLE COMPONENT PROMPTS FOR CLAUDE DESIGN

Copy-paste any of these directly into Claude Design as a prompt:

**Home Map Screen:**
> "Design a mobile home screen for JeepneyWaze, a Filipino jeepney tracking app. Full-bleed de-saturated light gray map background (OpenStreetMap style). Overlaid: floating white pill search bar at top ('Saan ka pupunta?'), horizontal filter chips ('Lahat', 'EDSA Cubao–Quiapo', 'Colon–SM') below it. Jeepney markers on map: 44×44px rounded squares in Jeepney Yellow (#F5C400) with black jeepney silhouette icon and a glowing yellow pulse ring. Black pill ETA bubbles anchored below each marker. Bottom sheet peeking 160px with drag handle, showing 'Mga Malapit na Jeepney' section title and 2 horizontal route cards. Bottom nav bar (Map active, Routes, Alerts, Profile) with Jeepney Yellow 3px active indicator pill. All typography: Inter. Buttons: 999px border-radius."

**Crowding Report Sheet:**
> "Design a mobile bottom sheet for JeepneyWaze crowding report. Title 'Kamusta ang sasakyan?' in Inter Bold 20px centered. Three large pill buttons stacked (full width, 56px height, 999px radius): SIKSIKAN in red (#E53935) white text 'Puno na!', KATAMTAMAN in orange (#F57C00) 'Pwede pa.', MALWAG in green (#2E7D32) 'May puwang pa!'. Drag handle at top. Bottom: 'Hindi na ako makapag-report' text link in muted gray. No close button. White background, 20px 20px 0 0 border radius."

**Splash Screen:**
> "Design a splash screen for JeepneyWaze. Full black background (#000000). Center: stylized jeepney silhouette icon in Jeepney Yellow (#F5C400), 80×80px. Below: 'JeepneyWaze' in Inter Bold 28px Pure White. Below that: 'Alam mo na. Sumakay na.' in Inter Regular 14px Muted Gray (#AFAFAF). At bottom 32px from edge: three pulsing yellow dots loading indicator. Total vertical stack centered on screen."

**Guardian Points Screen:**
> "Design a Route Guardian screen for JeepneyWaze. Black hero section 180px tall: '1,240 pts' in Inter Bold 36px Jeepney Yellow (#F5C400), 'Silver Guardian' in Inter 500 14px Pure White, shield badge icon. White content below with 20px margin: section 'Iyong mga Ruta' Inter Bold 16px, route cards with route pill (black, 999px radius, white text), route name, weekly report count, and Jeepney Yellow progress bar (6px height, 999px radius). Leaderboard section below with rank numbers, anonymized usernames, and yellow left border on rank 1 row."

---

## SECTION 11 — SCREEN INVENTORY (Full Design Scope)

| # | Screen | Priority | Section Ref |
|---|--------|----------|-------------|
| 1 | Splash Screen | P0 | Section 6.1 |
| 2 | Onboarding Slide 1 — Virtual Beacon | P0 | Section 6.2 |
| 3 | Onboarding Slide 2 — Crowding Reports | P0 | Section 6.3 |
| 4 | Onboarding Slide 3 — Route Guardian | P0 | Section 6.4 |
| 5 | Phone OTP — Number Entry | P0 | Section 6.5 |
| 6 | Phone OTP — Code Verification | P0 | Section 6.5 |
| 7 | Home — Map Screen (default) | P0 | Section 6.6 |
| 8 | Home — Map with Beacon Selected | P0 | Section 6.6 |
| 9 | Route Detail — Bottom Sheet | P0 | Section 6.7 |
| 10 | Stop Detail — Bottom Sheet | P0 | Section 6.8 |
| 11 | Crowding Report Modal | P0 | Section 6.9 |
| 12 | Route Guardian — Points & Leaderboard | P1 | Section 6.10 |
| 13 | Profile & Settings | P1 | Section 6.11 |
| 14 | Route Search / Browse | P1 | — |
| 15 | Saved Routes | P2 | — |
| 16 | Notification Alerts | P2 | — |
| 17 | Error / Offline State | P1 | — |
| 18 | Empty State — No Beacons Detected | P1 | — |

---

*This document is the canonical design specification for JeepneyWaze Phase 1. When Claude Design generates screens, reference the exact hex values, border-radius rules, typography specs, and Filipino copy from this guide. The Uber design system is the structural template; Filipino transit context and Jeepney Yellow are what make it JeepneyWaze.*
