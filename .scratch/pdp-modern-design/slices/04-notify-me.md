# Slice 4 — Notify me when back in stock

**Epic:** ALFMOB-427 · **Blocked by:** no backend service

## Why separate

Slice 1 draws the bell on out-of-stock size chips as **decorative and non-tappable** (`.allowsHitTesting(false)`, no accessibility action). This slice makes it real.

## Scope

- Make the bell an interactive control with proper accessibility.
- Capture and persist the customer's interest in a specific out-of-stock variant.
- Confirmation feedback, and presumably a notification when stock returns.

## Blockers

- **No notify-me service exists.** Needs backend and, if it notifies, push infrastructure and a customer-preference story.

## Open questions (`.scratch/pdp-modern-design/to-questionnaire-pdp-control-behaviour.md`)

- On the out-of-stock size chips, what should the bell do when tapped? *If it is purely a status indicator meaning "unavailable", this slice can be closed as not-needed and Slice 1's decorative treatment is final.*
