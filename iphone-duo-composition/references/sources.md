# Sources and verification

Checked 2026-11-09. Prefer current primary documentation and the installed SDK over remembered symbol names or device rumors.

| Source | Use |
| --- | --- |
| [Prepare for iPhone Duo](https://developer.apple.com/iphone-duo/prepare/) | Build-SDK behavior, resizing, safe areas and simulator workflow |
| [Designing for iPhone Duo](https://developer.apple.com/design/human-interface-guidelines/designing-for-iphone-duo) | Product and layout design guidance |
| [Prepare your app for iPhone Duo](https://developer.apple.com/videos/play/tech-talks/111461/) | Native containers, asymmetric insets and adaptation |
| [Strike a pose with adaptive layouts](https://developer.apple.com/videos/play/tech-talks/111463/) | Arrangements, displacement, active/inactive regions |
| [Multiple displays and scenes](https://developer.apple.com/videos/play/tech-talks/111464/) | Hinge interaction, scene creation and camera accessories |

SDK verification: Xcode 27.2, build 27B52. Inspected SwiftUI/SwiftUICore public Swift interfaces and UIKit public headers. Confirmed iOS 27.1 availability for `ArrangementView`, its styles, `ReservedRegion`, `GeometryProxy.reservedRegions`, `onHingeChange`, `UIArrangementViewController`, `UIViewReservedRegion` `UIHingeInteraction` and `CameraCaptureAccessory`.

References summarize decision-relevant behavior; they are not copies of Apple documentation. Composition recommendations and lessons from a workout app are author guidance, not platform requirements. Simulator screenshots demonstrate a layout, not physical-device ergonomics or correctness across all runtime configurations.
