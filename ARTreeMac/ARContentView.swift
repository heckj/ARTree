//
//  ContentView.swift
//  ARTreeMac
//
//  Created by Joseph Heck on 1/5/22.
//

import SwiftUI
import RealityKit
import Combine

struct ARContentView : View {
    @StateObject var arview: CameraControlARView = CameraControlARView(frame: .zero)
    var body: some View {
        ARViewContainer(cameraARView: arview)
    }
}

struct ARViewContainer: NSViewRepresentable {
    
    var cameraARView: CameraControlARView
    
    class ARViewCoordinator: NSObject {
        /*
         When you want your view controller to coordinate with other SwiftUI views,
         you must provide a Coordinator object to facilitate those interactions.
         For example, you use a coordinator to forward target-action and
         delegate messages from your view controller to any SwiftUI views.
         */
        var representableContainer: ARViewContainer
        
        init(_ representableContainer: ARViewContainer) {
            self.representableContainer = representableContainer
        }
    }
    
    func makeCoordinator() -> ARViewContainer.ARViewCoordinator {
        ARViewCoordinator(self)
    }
    
    func makeNSView(context: Context) -> ARView {
        // Creates the view object and configures its initial state.
        //
        // Context includes:
        // - coordinator
        // - transaction
        // - environment
        
        let arView = cameraARView
        
        // Set debug options
#if DEBUG
        arView.debugOptions = [
            //            .showPhysics,
            .showStatistics,
            //            .none
        ]
#endif
        
        // Switch to first-person movement mode
//        arView.motionMode = .firstperson
                
        // Load the "Box" scene from the "Experience" Reality File
        let boxAnchor = try! Experience.loadBox()
        
        // Add the box anchor to the scene
        arView.scene.anchors.append(boxAnchor)
        
        return arView
    }
    
    func updateNSView(_ uiView: ARView, context: Context) {
        // Updates the state of the specified view with new information from SwiftUI.
        
        // called every time something updates that would impact this view - in our case,
        // every time the binding is triggered with an update.
/*
 Here's an example of what's included within context.environment:
 
- environment: [
    EnvironmentPropertyKey<PreferenceBridgeKey> = Value(value: Optional(SwiftUI.PreferenceBridge)),
    EnvironmentPropertyKey<WindowRoleKey> = Optional(SwiftUI.AppWindowsController.WindowRole.main),
    EnvironmentPropertyKey<StateRestorationContextIDKey> = Optional("SwiftUI.ModifiedContent<ARTreeMac.ContentView, SwiftUI._FlexFrameLayout>-1-AppWindow-1"),
    EnvironmentPropertyKey<PresentedWindowToolbarStyleKey> = AnyWindowToolbarStyle(storage: SwiftUI.AnyWindowToolbarStyleStorage<SwiftUI.DefaultWindowToolbarStyle>),
    EnvironmentPropertyKey<PresentedWindowStyleKey> = AnyWindowStyle(storage: SwiftUI.AnyWindowStyleStorage<SwiftUI.DefaultWindowStyle>),
    EnvironmentPropertyKey<AppNavigationAuthorityKey> = Optional(SwiftUI.WeakBox<SwiftUI.AppNavigationAuthority>(base: Optional(SwiftUI.AppNavigationAuthority))),
    EnvironmentPropertyKey<WindowsControllerKey> = Value(value: Optional(<SwiftUI.AppWindowsController: 0x6000023ac1e0>)),
    EnvironmentPropertyKey<SceneStorageValuesKey> = Optional(SwiftUI.WeakBox<SwiftUI.SceneStorageValues>(base: Optional(SwiftUI.SceneStorageValues))),
    EnvironmentPropertyKey<StoreKey<SceneBridge>> = Optional(SceneBridge: window = Optional(<SwiftUI.SwiftUIWindow: 0x12983ed80>)),
    EnvironmentPropertyKey<FocusScopesKey> = [SwiftUI.Namespace.ID(id: 744)],
    EnvironmentPropertyKey<AccessibilityRequestFocusKey> = AccessibilityRequestFocusAction(onAccessibilityFocus: nil),
    EnvironmentPropertyKey<FocusSystemKey> = _FocusSystem(onResetToDefault: Optional((Function))),
    EnvironmentPropertyKey<ResetFocusKey> = ResetFocusAction(onReset: Optional((Function))),
    EnvironmentPropertyKey<FocusBridgeKey> = WeakBox<FocusBridge>(base: Optional(SwiftUI.FocusBridge)),
    EnvironmentPropertyKey<PresentationModeKey> = Binding<PresentationMode>(transaction: SwiftUI.Transaction(plist: []), location: SwiftUI.LocationBox<SwiftUI.FunctionalLocation<SwiftUI.PresentationMode>>, _value: SwiftUI.PresentationMode(isPresented: true)),
    EnvironmentPropertyKey<EmphasizedKey> = false, EnvironmentPropertyKey<UndoManagerKey> = Optional(<NSUndoManager: 0x6000023debc0>),
    EnvironmentPropertyKey<AccentColorKey> = Optional(sRGB IEC61966-2.1 colorspace 0 0.478431 1 1),
    EnvironmentPropertyKey<BackgroundMaterialKey> = nil,
    EnvironmentPropertyKey<ColorSchemeContrastKey> = standard,
    EnvironmentPropertyKey<ColorSchemeKey> = light,
    EnvironmentPropertyKey<InTouchBarKey> = false,
    EnvironmentPropertyKey<LayoutDirectionKey> = leftToRight,
    EnvironmentPropertyKey<AllControlsNavigableKey> = false,
    EnvironmentPropertyKey<ControlActiveKey> = key,
    EnvironmentPropertyKey<DisplayScaleKey> = 2.0,
    EnvironmentPropertyKey<DisplayGamutKey> = displayP3,
    EnvironmentPropertyKey<AccessibilityLargeContentViewerKey> = false,
    EnvironmentPropertyKey<EnabledTechnologiesKey> = AccessibilityTechnologies(technologySet: SwiftUI.(unknown context at $1e96bad58).AccessibilityTechnologySet(rawValue: 0)),
    EnvironmentPropertyKey<AccessibilityButtonShapesKey> = false,
    EnvironmentPropertyKey<AccessibilityPrefersCrossFadeTransitionsKey> = false,
    EnvironmentPropertyKey<AccessibilityInvertColorsKey> = false,
    EnvironmentPropertyKey<AccessibilityReduceMotionKey> = false,
    EnvironmentPropertyKey<AccessibilityReduceTransparencyKey> = false,
    EnvironmentPropertyKey<AccessibilityDifferentiateWithoutColorKey> = false,
    EnvironmentPropertyKey<ReduceDesktopTintingKey> = false,
    EnvironmentPropertyKey<SystemAccentValueKey> = multicolor,
    EnvironmentPropertyKey<TimeZoneKey> = America/Los_Angeles (fixed (equal to current)),
    EnvironmentPropertyKey<CalendarKey> = gregorian (current),
    EnvironmentPropertyKey<LocaleKey> = en_US (current),
    EnvironmentPropertyKey<ScenePhaseKey> = active,
    EnvironmentPropertyKey<TimeZoneKey> = America/Los_Angeles (fixed (equal to current)),
    EnvironmentPropertyKey<CalendarKey> = gregorian (current), EnvironmentPropertyKey<LocaleKey> = en_US (current)])
*/
        // Context includes:
        // - coordinator
        // - transaction
        // - environment
//        print("updateNSView invoked")
//                print("- transaction: \(context.transaction))")
//        print("- environment: \(context.environment))")
//        print("")
    }
    
}

struct ARContentView_Previews: PreviewProvider {
    static var previews: some View {
        ARContentView()
    }
}
