---
name: High-Performance Athleticism
colors:
  surface: '#131313'
  surface-dim: '#131313'
  surface-bright: '#393939'
  surface-container-lowest: '#0e0e0e'
  surface-container-low: '#1c1b1b'
  surface-container: '#201f1f'
  surface-container-high: '#2a2a2a'
  surface-container-highest: '#353534'
  on-surface: '#e5e2e1'
  on-surface-variant: '#e2bdc7'
  inverse-surface: '#e5e2e1'
  inverse-on-surface: '#313030'
  outline: '#a98891'
  outline-variant: '#5a3f48'
  surface-tint: '#ffb0c9'
  primary: '#ffb0c9'
  on-primary: '#640034'
  primary-container: '#ff4799'
  on-primary-container: '#58002d'
  inverse-primary: '#b90066'
  secondary: '#c8c6c5'
  on-secondary: '#303030'
  secondary-container: '#474746'
  on-secondary-container: '#b7b5b4'
  tertiary: '#78dc77'
  on-tertiary: '#00390a'
  tertiary-container: '#41a447'
  on-tertiary-container: '#003208'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#ffd9e3'
  primary-fixed-dim: '#ffb0c9'
  on-primary-fixed: '#3e001e'
  on-primary-fixed-variant: '#8e004c'
  secondary-fixed: '#e5e2e1'
  secondary-fixed-dim: '#c8c6c5'
  on-secondary-fixed: '#1b1b1c'
  on-secondary-fixed-variant: '#474746'
  tertiary-fixed: '#94f990'
  tertiary-fixed-dim: '#78dc77'
  on-tertiary-fixed: '#002204'
  on-tertiary-fixed-variant: '#005313'
  background: '#131313'
  on-background: '#e5e2e1'
  surface-variant: '#353534'
typography:
  headline-xl:
    fontFamily: Anybody
    fontSize: 48px
    fontWeight: '800'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Anybody
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Anybody
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
  session-time:
    fontFamily: Anybody
    fontSize: 24px
    fontWeight: '800'
    lineHeight: 32px
    letterSpacing: 0.05em
  body-lg:
    fontFamily: Lexend
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Lexend
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-sm:
    fontFamily: Lexend
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 8px
  xs: 4px
  sm: 12px
  md: 24px
  lg: 40px
  xl: 64px
  container-margin-mobile: 20px
  container-margin-desktop: 48px
  gutter: 16px
---

## Brand & Style

The visual identity of the design system is anchored in high-performance energy and precision. It targets professional athletes and coaches who require a focused, distraction-free environment to monitor progress and optimize training. 

The aesthetic is a fusion of **Modern Minimalism** and **High-Contrast Boldness**. By utilizing a strict dark-mode foundation, we reduce eye strain during early morning or late-night coaching sessions while allowing vibrant accent colors to guide the user's attention to critical performance metrics. The style is sleek, technical, and unapologetically professional, evoking the feeling of elite sports equipment and telemetry dashboards.

## Colors

This design system operates exclusively in a dark-mode palette to maintain a premium, high-contrast feel.

- **Primary (#FF2E93):** An electric hot pink used for primary actions, active states, and highlighting key performance peaks. It is designed to vibrate against the dark background to ensure instant recognition.
- **Surface (#1E1E1E):** A matte charcoal used for cards, containers, and secondary navigation elements to provide subtle depth against the primary background.
- **Success (#4CAF50) & Danger (#F44336):** High-chroma green and red used strictly for status indicators, completion targets, and rejected entries.
- **Primary Background (#121212):** A deep, neutral base that provides the foundation for all other layers.

## Typography

The typography strategy leverages two distinct sans-serif families to balance character with readability.

- **Anybody** is utilized for headlines and session times. Its variable width and bold weights provide an aggressive, athletic aesthetic that commands attention and mirrors the urgency of competitive sports.
- **Lexend** is the workhorse for body copy and data labels. Chosen for its exceptional legibility and "athletic" clarity, it ensures that complex training data and coaching notes remain readable at a glance.

Session times and primary metrics should always use the `session-time` token with heavy weights and slight tracking to emphasize numerical data.

## Layout & Spacing

The design system employs a **fluid grid** model based on an 8px square-unit system. This ensures mathematical harmony across all components.

- **Mobile:** A 4-column layout with 20px side margins and 16px gutters.
- **Desktop:** A 12-column layout with a maximum content width of 1440px, utilizing 48px side margins for a centered, cinematic feel.

Vertical rhythm is strictly maintained using the `md` (24px) spacing unit between major sections and the `sm` (12px) unit between related items within a card or list.

## Elevation & Depth

In this dark-mode environment, depth is established through **Tonal Layering** and **Low-Contrast Outlines** rather than heavy shadows.

- **Level 0 (Base):** #121212. The lowest visual plane.
- **Level 1 (Cards/Surfaces):** #1E1E1E. Elevated surfaces that house content.
- **Outlines:** All elevated containers feature a 1px solid border (#2C2C2C) to define edges without breaking the minimalist aesthetic.
- **Focus States:** High-intensity Primary (#FF2E93) inner glows are used sparingly for active inputs or selected states, providing a "lit from within" effect.

## Shapes

The shape language is refined and modern, using **Rounded** (Level 2) geometry to soften the technical edge of the dark interface.

- **Standard Components:** Buttons and inputs use a 0.5rem (8px) radius.
- **Cards:** Main content containers use a 1rem (16px) radius to create a sleek, "object-like" feel.
- **Status Indicators:** Small chips and avatars use a fully circular "pill" shape to contrast against the more structured rectangular grid.

## Components

- **Buttons:** Primary buttons are solid #FF2E93 with white or black text (check contrast). Secondary buttons use a ghost style with a #FF2E93 border. All buttons must maintain a minimum height of 48px to exceed the 44px touch-target requirement.
- **Cards:** Built on #1E1E1E with 1px #2C2C2C borders. Padding should be a consistent 24px (md).
- **Session Timers:** High-visibility text using the `session-time` token. Usually paired with a Primary-colored linear progress bar.
- **Inputs:** Dark backgrounds (#121212) with 1px borders. On focus, the border transitions to #FF2E93.
- **Chips:** Small, rounded-pill elements used for tagging muscle groups or workout types, using subtle #2C2C2C backgrounds with Lexend Bold labels.
- **Lists:** Clean, divider-less lists using 16px vertical spacing between items, relying on the 8px grid for alignment.