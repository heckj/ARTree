//
//  ContentView.swift
//  ARTreeMac
//
//  Created by Joseph Heck on 1/5/22.
//

import SwiftUI
import RealityKit
import Combine

struct ContentView : View {
    @State var count = 0
    @State var magValue = 1.0
    @State var rotation = 0.0
    @State var inclination = 0.0
    
    @State var isDragging = false
    
    @State var aTransform: Transform = Transform()
    // I think I want something that SwiftUI "owns" memory wise - so @State or such, but I want to use that
    // to update a reference to the camera, which doesn't exist when this all starts...
    // So do I pass down a binding? Or create an instance of something and pass that down into
    // ARViewContainer through its initializer?
    
    var magnification: some Gesture {
        MagnificationGesture()
            .onEnded { finalValue in
                magValue = magValue * finalValue
                print("Set mag value to \(magValue)")
            }
    }
    
    var drag: some Gesture {
        DragGesture()
            .onChanged { dragval in
                self.isDragging = true
                print("draggin: \(dragval.location), \(dragval.translation)")
            }
            .onEnded { dragval in
                self.isDragging = false
                print("drag fininshed at: \(dragval.location), \(dragval.translation)")
            }
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("My AR View on macOS: \(count)")
                Button {
                    count += 1
                } label: {
                    Image(systemName: "plus")
                }
                Text("\(String(describing: aTransform.translation))")
            }
            ARViewContainer(cameraTransform: $aTransform)
                .edgesIgnoringSafeArea(.all)
//                .highPriorityGesture(drag)
                .simultaneousGesture(magnification)
//                .highPriorityGesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
//                    .onChanged({ value in
//                        print("drag onChanged: \(value)")
//                    })
//                    .onEnded({ value in
//                        print("drag onEnded: \(value)")
//                    })
//                )
//                .onTapGesture {
//                    print("TAPPED IN VIEW")
//                }
        }
    }
}

struct ARViewContainer: NSViewRepresentable {
    
    var cameraTransform: Binding<Transform>
    
    class ARViewCoordinator: NSObject {
        /*
         When you want your view controller to coordinate with other SwiftUI views,
         you must provide a Coordinator object to facilitate those interactions.
         For example, you use a coordinator to forward target-action and
         delegate messages from your view controller to any SwiftUI views.
         */
        var parent: ARViewContainer
        weak var view: ARView?
        var cancellables: Set<AnyCancellable> = []
        
        init(_ parent: ARViewContainer) {
            self.parent = parent
            view = nil
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
        
        let arView = CameraControlARView(frame: .zero)
        
        // NOTE(heckj): I think in order to sort the event handling, I'm going to have to consider subclassing
        // ARView from RealityKit and adding my own mouse/event handling mechanisms. While some gesture capture appears
        // to be working from above this view (in SwiftUI land), taps, drags, etc aren't being reflected. I don't know
        // if I'm screwing up the gesture in SwiftUI, or if the ARView is consuming, and disposing, of the views before they get
        // "up" to SwiftUI.
        
        context.coordinator.view = arView
        // Set debug options
#if DEBUG
        arView.debugOptions = [
            //            .showPhysics,
            .showStatistics,
            //            .none
        ]
#endif
        
        //        print("camera transform with default camera: \(arView.cameraTransform)")
        //        camera transform with default camera:
        //        Transform(
        //              scale: SIMD3<Float>(1.0, 1.0, 1.0),
        //              rotation: simd_quatf(real: 1.0, imag: SIMD3<Float>(0.0, 0.0, 0.0)),
        //              translation: SIMD3<Float>(0.0, 0.0, 2.0)
        //        )
        
        let cameraEntity = PerspectiveCamera()
        cameraEntity.camera.fieldOfViewInDegrees = 60
        
        let cameraAnchor = AnchorEntity(world: .zero)
        cameraAnchor.addChild(cameraEntity)
        arView.scene.addAnchor(cameraAnchor)
        
        //        print("initial camera transform: \(arView.cameraTransform)")
        //        initial camera transform: Transform(
        //            scale: SIMD3<Float>(1.0, 1.0, 1.0),
        //            rotation: simd_quatf(real: 1.0, imag: SIMD3<Float>(0.0, 0.0, 0.0)),
        //            translation: SIMD3<Float>(0.0, 0.0, 0.0))
        
        let cameraDistance: Float = 3
        var currentCameraRotation: Float = 0
        let cameraRotationSpeed: Float = 0.01 // radians per frame
        
        arView.scene.subscribe(to: SceneEvents.Update.self) { _ in
            let x = sin(currentCameraRotation) * cameraDistance
            let z = cos(currentCameraRotation) * cameraDistance
            
            let cameraTranslation = SIMD3<Float>(x, 1, z)
            
            let localcameraTransform = Transform(scale: .one,
                                            rotation: simd_quatf(),
                                            translation: cameraTranslation)
            
            cameraEntity.transform = localcameraTransform
            cameraEntity.look(at: .zero, from: cameraTranslation, relativeTo: nil)
            // pushes the value "up" to the SwiftUI layer
            // -- this in turn will trigger SwiftUI to invoke updateNSView() below
            // with the context updated with context.coordinator
            cameraTransform.wrappedValue = localcameraTransform
            
            currentCameraRotation += cameraRotationSpeed
        }.store(in: &context.coordinator.cancellables)
        
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
