# PDP redesign — what should these controls actually do?

**Purpose:** the new Product Details design draws three controls whose *behaviour* isn't specified anywhere. We can build them to look right, but we don't know what should happen when a customer taps them — and two of them currently have nothing behind them at all. These answers go straight into the ALFMOB-441 implementation spec.

**From:** Khoi (iOS) — **To:** the design owner for the PDP Figma, and the wider team — **How your answers will be used:** written into the ALFMOB-441 spec and the follow-up tickets under ALFMOB-427. Where you tell us something needs backend or content work, it becomes its own ticket rather than blocking the visual rollout.

## Context

We're rolling the modern Figma design onto the iOS Product Details screen ([ALFMOB-441](https://mindera.atlassian.net/browse/ALFMOB-441), Figma [PDP canvas](https://www.figma.com/design/axx7Bz1fpQurtU6DHwVaJX/Alfie---Designs--Mobile-?node-id=1-10080)). The visual side is well specified — spacing, colour and type all map cleanly onto our design tokens. What isn't specified is interaction: the Figma shows static frames, so for a few elements we can see exactly what they look like but not what they do. We'd rather ask than guess and ship something that behaves wrongly.

Worth knowing: the app today has **no notify-me feature and no size-guide content**, so two of these controls have no destination. We plan to draw them exactly as designed but make them non-interactive for now, with follow-up tickets to make them work. Question 3 checks whether that's acceptable to you.

## How to answer

Roughly 10 minutes. Please reply by **end of this week** so it lands before implementation starts. Partial answers and "I don't know" are genuinely useful — flag anything you're unsure of rather than skipping it, and say if a question should go to someone else.

## Control behaviour

### On the out-of-stock size chips, what should the bell icon do when tapped?

_Why this matters: we have no notify-me service. If the bell is meant to be interactive we need to raise that as backend work now; if it's purely a status indicator meaning "unavailable", we can ship it as-is this sprint._

>

### The "Size Guide" link next to "Select a Size" — where should it go?

_Why this matters: there is no size-guide content in the app today. We need to know whether it opens a web page (and which URL), a native screen, or a modal — and who owns producing that content._

>

### The three accordion rows ("Size & Fit", "Materials & Care Guide", "Shippings and Returns") — should they expand in place, or navigate away?

The Figma shows them expanding in place with rich content — imagery and structured copy like "Outer Shell / 100% Cotton". Today in the app these three rows are a chevron that **navigates to a web page**, and we have no data source for the in-place content (it would need a backend contract we don't have yet).

So for this release we can either (a) keep the "+" that expands, revealing a link that opens the existing web page — honest affordance, but two taps to reach content that currently takes one; or (b) keep today's one-tap navigation with a chevron, which deviates from the design until the real content exists.

_Why this matters: this is the one place where matching the design makes the customer journey slightly worse in the short term, so we'd like your call rather than ours._

>

### For the accordion content itself — is it per product category, and who writes it?

The Figma has twelve content variants (Cloth / Cosmetics / Home / Food, three accordions each) with different labels — "Materials", "Care Guide", "Ingredients", "Shipping & Payments". We want to confirm that's the real model rather than illustrative mock-up, and understand where the copy and images would come from.

>

## Colour and size selection

### When a product has several colours, which of the three colour UIs should appear?

The design shows three: a small swatch with "+3" in the info block, an inline "Select a Colour" card grid, and a bottom-sheet list. It doesn't say when each is used. We've assumed the summary is always visible and tappable, the inline grid shows for a few colours, and the sheet takes over for many — mirroring how sizes work. Please confirm or correct.

_Why this matters: this is currently our guess, not your instruction, and it changes what a customer sees on most products._

>

### Same question for sizes: grid or vertical list, and at what threshold?

The design has a chip grid (XS/S/M/L/XL) and a vertical list (shoe sizes 2.5–6.5). We've assumed short size runs get the grid and long ones get the list. Is there a specific cut-off you have in mind?

>

### On the vertical size list, when should "Only 1 item left!" versus "Last units" appear?

We have live stock numbers per size, so we can render either — we just need the rule. Our placeholder assumption is exactly 1 remaining shows "Only 1 item left!" and some small number N shows "Last units". What should N be?

>

## Scope and sequencing

### The recommendations grid ("You might also like") is roughly the bottom third of the design. Is it required for the first release?

_Why this matters: it needs backend work — we can get related-product IDs but not the products themselves in one call — plus a "Best Seller" badge whose data source we haven't identified. Treating it as a separate release lets the rest of the redesign ship now._

>

### Where does the "Best Seller" badge come from?

Is it a merchandising flag, a computed ranking, or something a category manager sets per product? We can't find a field for it.

>

### Is it acceptable that the first release visually matches the design everywhere except the deferred items?

To be explicit: after ALFMOB-441 the screen will have the new gallery, info block, buttons, size and colour selectors, description and accordion rows — but no recommendations grid, no working bell, no size-guide destination, and no rich accordion content.

>

## Anything else?

Is there anything about this screen we haven't asked about that we should know — interactions, states, edge cases, or upcoming design changes that would affect what we build now?

>
