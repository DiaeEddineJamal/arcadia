# Arcadia Style Guide

This guide documents the refined visual system for the premium ambient sounds experience.

## Color System
- Core surfaces: `primaryDark #0A0A0F`, `surfaceDark #1A1A2E`, `surfaceVariantDark #16213E`
- Light surfaces: `primaryLight #F8F9FA`, `surfaceLight #FFFFFF`, `surfaceVariantLight #F5F5F5`
- Accents: Aqua `#64FFDA`, Coral `#FF6B9D`, Lavender `#B39DDB`, Mint `#81C784`, Peach `#FFAB91`
- Semantic: Success `#4CAF50`, Warning `#FF9800`, Error `#F44336`, Info `#2196F3`

## Glassmorphism
- Base: semi-transparent layer (`alpha 0.15–0.30`), blur radius `12–18`
- Inner border: subtle (`1–1.5px`) with `alpha 0.10–0.20`
- Inner gradient: diagonal linear gradient with 3 stops, low opacity
- Shadow: soft drop shadow (`blur 16–24`, `offset 0,8`) tuned per brightness

## Typography
- Display: Poppins or system SF Text; tight tracking on headings
- Hierarchy:
  - `headlineSmall`: 24–28, `w600–w700`, spacing `0.2–0.4`
  - `titleMedium`: 16–18, `w600`
  - `titleSmall`: 13–14, `w600`
  - `bodyMedium`: 14–16, `w400`, opacity adjustments for secondary text

## Micro-Interactions
- Press: scale to `0.985` with ease-out `120–160ms`, shadow slightly increases
- Hover (desktop): subtle elevation (no glow)
- Selection: inner highlight ring at `alpha 0.20`

## Motion & Transitions
- Content entrance: `Slide + Fade` `400–600ms`
- State transitions: `200–300ms` ease-in-out
- Visualizer: slow pulse `1.6s` loop; avoid high-frequency updates

## Layout & Spacing
- Grid columns: 2; spacing: `12–16`
- Rhythm: section spacing `24–32`; internal padding `16–24`
- Touch targets: minimum `48x48`

## Accessibility
- Contrast: maintain at least AA for text vs background
- Haptics: optional; micro-interactions must not obscure content