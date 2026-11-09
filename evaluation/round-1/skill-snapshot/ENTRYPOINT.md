---
name: iphone-duo-composition
description: Design and implement useful iPhone Duo layouts and folding interactions while preserving ordinary iPhone screens. Use when adding Duo support, composing complementary panes, adapting to the fold, or planning inner/outer display experiences in an iOS app.
---

# iPhone Duo Composition

Make the additional space shorten a task, reveal useful context, or make a hands-free activity easier. Preserve the app's identity and its complete phone experience.

## Choose the experience

Inspect the existing screen, navigation, state ownership, deployment target and design conventions. Identify the user's primary task and what they repeatedly switch away to consult or control. For a new app, establish that task before choosing panes.

Consider a few plausible compositions; implement the one with the clearest benefit. Explain the benefit in one sentence. A second pane earns its space through a relationship to the current task, not through extra dashboard cards. Read [composition patterns](references/composition.md) when choosing that relationship.

Distinguish these capabilities:

- **One inner display, multiple regions:** coordinate content around available space and the fold.
- **Inner/outer continuity:** keep the same task when the app moves between displays.
- **Simultaneous physical displays:** use supported scene accessories only when their availability and the product scenario permit it. Two columns do not imply two display scenes.

Keep ordinary iPhone screens familiar. Do not identify Duo from a large width, an aspect ratio, an idiom, or a model-name string. Space determines what fits; supported region/capability APIs determine what special treatment is possible. Do not require an unfolded device to complete an essential action.

## Implement the composition

Read the relevant sections of [platform guidance](references/platform.md) before using Duo APIs. It covers SwiftUI, UIKit, regions, version availability and scene accessories. Prefer standard containers unless the task needs a different relationship or measured layout behavior requires customization.

Keep task state outside transient layout branches: selected item, navigation, draft, timer and media position should survive rearrangement. Changing the fold must not implicitly submit, cancel, restart, or save the task. Retain identity for stateful child views; moving persistent data to a model does not by itself preserve focus or local form state.

Derive layout from current container geometry. Give content room to breathe without treating all empty space as a defect. Respect the physical fold, camera regions and each safe-area edge. Keep controls and the content they act on together. A continuous article or feed may remain one scrolling surface.

When space contracts, prioritize the current task and provide an obvious route to its context. Preserve existing sheets and navigation semantics unless changing them serves the requested experience. Do not introduce a custom two-stack shell merely because another app needed one.

## Verify within the requested scope

Use the project's available build and simulator tools; this skill requires no particular agent or tool integration. Confirm new API signatures against the installed SDK and preserve the existing deployment target with availability checks.

For a visual task, inspect the ordinary phone, Duo outer display, open inner display and a relevant partial-fold pose. Compare readable content, controls, empty space and the fold boundary. Report what was actually observed. If a real pose cannot be exercised, label geometry-only previews honestly. Do not expand a visual-only request into a test suite or an accessibility audit.

For deeper implementation work, check continuity through resizing and existing project checks as appropriate to the user's scope. Keep runtime/device limitations explicit. Sources and their verification date are in [sources](references/sources.md).
