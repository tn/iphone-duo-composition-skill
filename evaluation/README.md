# Visual evaluation

Model: **Astra Light** (the model label supplied for these runs). Both arms used the same inherited model and reasoning configuration, with no model override.

Date: 2026-11-09. Xcode 27.2 (27B52), iOS 27.2 simulator, minimum deployment target iOS 26.0.

## Method

Each arm began with an identical [starter](starter/) and the same [product brief](prompt.md), in a separate temporary directory. Agents had no parent conversation history and were instructed not to inspect other projects or another run. They could consult public Apple documentation and the installed SDK. The baseline received no skills; the treatment received only `iphone-duo-composition` and its references. Each agent was given the same ceiling of 25 tool invocations and 15 minutes, not an equal token-count guarantee. No special visual direction was supplied beyond the brief.

Agents built their projects and could correct compilation failures. The evaluator did not edit generated application source. Screenshots use the lemon pasta recipe, step 2, ingredients unchecked, timer paused at 08:00, initial scroll position, and light appearance. Both arms use the same simulator devices and matching display configurations. Device Hub selected real simulated poses; PNGs are original `simctl` framebuffer captures, without a composited device frame or painted hinge. The folded framebuffer is flat even though the simulator pose is partially open.

This is an illustrative comparison of generated interfaces, not a controlled statistical study. One sample per arm in each round cannot establish general superiority. Only final visuals were evaluated. No automated tests, VoiceOver checks, large-font checks, behavior suite, or physical-device validation were performed.

## Two rounds, all outputs retained

Round 1 revealed a specific problem in the treatment: in the horizontal-fold pose, introductory content consumed the short upper region and the active instruction needed scrolling. The baseline's folded layout exposed the instruction more directly. The skill was refined to prioritize active content within each region's actual height; the app itself was not patched.

Both arms were then generated again from clean starters with the original brief and the same limits. This avoids comparing a hand-polished treatment with an untouched baseline. The final round uses the published skill. Round 1 remains available as [source and screenshots](round-1/) with the [original skill entrypoint](round-1/skill-snapshot/ENTRYPOINT.md); its name is changed only to keep installers from discovering a second skill.

## Reproduce a build

From `evaluation/baseline` or `evaluation/with-skill`:

```sh
xcodebuild -project Saffron.xcodeproj -scheme Saffron \
  -configuration Debug -sdk iphonesimulator \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath /tmp/saffron-build CODE_SIGNING_ALLOWED=NO build
```

Use separate derived-data directories when building both variants. Install one variant at a time; both intentionally use the same bundle identifier, `dev.duocomposition.saffron`. The checked-in Xcode projects require no dependency download. `project.yml` is included for optional regeneration with XcodeGen.

Capture iPhone 18 Pro in portrait, Duo outer display in portrait, Duo fully open with the wider dimension horizontal, then rotate right once and choose Partially Open for a horizontal fold. Do not scroll or change the recipe between captures. Use `simctl io <device> enumerate` to identify displays; on the capture device the outer screen was ID 1 and the inner screen ID 3. Screen IDs are not a portable device-detection API.

Final comparison images and observations are presented in the repository README.

## Build results

All four runs completed their simulator build successfully (exit code 0). The treatment builds required normal compiler access outside the execution sandbox for Swift macro plugins. No source-level visual correction was applied by the evaluator. Build products and host-specific logs are not distributed; the generated source and Xcode projects are.

The final skill entrypoint and composition reference are identical to those supplied to the second treatment. The first snapshot preserves the earlier instructions. Model labels, image dimensions and content hashes are recorded in `manifest.json` for artifact identification; they are not quality scores.
