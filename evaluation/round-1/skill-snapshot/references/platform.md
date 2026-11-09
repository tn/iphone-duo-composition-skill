# Platform implementation

Verified against the Xcode 27.2 SDK on 2026-11-09. The Duo-specific symbols below are available from iOS 27.1; recheck the SDK when using a newer release. Build SDK and minimum deployment target are different decisions.

## SwiftUI

Use `NavigationSplitView` for selection/detail navigation and `TabView` for sections. Use `ArrangementView` when the relationship is between two pieces of task content rather than navigation columns. Avoid replacing working native navigation solely to adopt the newer API.

This small composition example intentionally leaves compact presentation to its caller:

```swift
import SwiftUI

@available(iOS 27.1, *)
struct TaskPair<Primary: View, Context: View>: View {
    let primary: Primary
    let context: Context

    var body: some View {
        ArrangementView {
            primary
        } secondary: {
            context
        }
        .arrangementViewStyle(.split)
    }
}
```

`.split` and `.overlay` are arrangement styles; `.axes(...)` can constrain their axes. Choose a style for the content relationship, then inspect its actual behavior in the poses the app needs. Do not assume `.split` guarantees that every secondary action remains visible in every compact configuration. Supply an explicit compact route where needed.

For custom layouts, `GeometryProxy.reservedRegions(kind:options:layoutDirectionBehavior:)` returns `ReservedRegion` values with `frame`, `margins`, `isActive`, `kind` and `id`. Query `.division` for a fold and `.occlusion` for obstructed areas. The default query returns active regions; `.includeInactive` also exposes inactive ones. An inactive division is not an active obstruction. A missing region in the current window is not proof of an ordinary physical phone.

Use frames in the querying view's coordinate space and apply margins on their respective edges. Do not substitute a fixed center line or hinge width. Account for horizontal and vertical divisions, and convert coordinates if the layout uses another space. Preserve the default directional behavior unless the content has an explicit physical-coordinate requirement.

A custom `ArrangementViewStyle` receives `configuration.primary` and `configuration.secondary`. Preserve these children while changing placement. Do not rebuild forms under unrelated `if` branches or change `.id` with pose. If a view is retained but hidden, it must not intercept interaction. Keep shared task state above the arrangement; preserve each pane's navigation path separately when the product needs independent navigation.

## UIKit

Use `UISplitViewController`, `UINavigationController` and `UITabBarController` for their established navigation roles. `UIArrangementViewController` is the task-content counterpart of `ArrangementView`; `UIViewReservedRegion` provides region information, and `UIHingeInteraction` observes hinge updates.

Recalculate using the current view/window bounds and layout lifecycle. Respect `safeAreaLayoutGuide` and directional margins. Keep child controllers and their models alive across placement changes; use correct view-controller containment rather than constructing new editors on every resize. Check the installed Swift interface for imported UIKit method labels instead of translating Objective-C names by guesswork.

## Resizing and compatibility

Read size from the current container, not a cached `UIScreen.main.bounds`. A wide iPhone window is possible; `.regular` is not an iPad identity. Use independent safe-area edges because navigation bars can move to a side. Let decorative backgrounds extend while foreground content remains usable.

Use `if #available(iOS 27.1, *)` around Duo-specific implementation and retain the existing compact path on older systems. Build with iOS 27.1 or later for the full Duo display behavior; this does not require raising the app's deployment target to 27.1. A large-window adaptation can be useful on other platforms, but must not accidentally replace a deliberately preserved ordinary-phone screen.

## Hinge interaction and physical displays

`onHingeChange(isEnabled:_:)` supplies old and new `DeviceHingeContext` values. `context.hinge` is optional; handle its absence and reset transient effects. `UIHingeInteraction` serves the equivalent UIKit role. These APIs are appropriate for a purposeful interaction or effect; arrangements and reserved regions supply layout geometry.

`CameraCaptureAccessory` can provide supplementary UI on the outer display during a supported camera experience. It requires an active camera session and a full-screen inner-display app. Observe accessory availability; it can change. Do not treat it as general permission to place any app's second pane on the outer screen, and do not add camera capture just to unlock another display.

Multiwindow support is another distinct capability. Scene creation can become unavailable when the device closes; handle failure and preserve the current scene. Add scenes only when the requested workflow benefits from them.
