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
    @GestureState var magnifyBy = 1.0
    var magnification: some Gesture {
            MagnificationGesture()
                .updating($magnifyBy) { currentState, gestureState, transaction in
                    gestureState = currentState
                    print("Current magnification: \(currentState)")
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
            }
            ARViewContainer()
                .edgesIgnoringSafeArea(.all)
                .gesture(magnification)

        }
    }
}

// some setup courtesy of example code in https://rozengain.medium.com/quick-realitykit-tutorial-programmatic-non-ar-setup-cafaf61e9884

struct ARViewContainer: NSViewRepresentable {
    
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

        let arView = ARView(frame: .zero)
        
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
        let cameraRotationSpeed: Float = 0.01

        arView.scene.subscribe(to: SceneEvents.Update.self) { _ in
            let x = sin(currentCameraRotation) * cameraDistance
            let z = cos(currentCameraRotation) * cameraDistance

            let cameraTranslation = SIMD3<Float>(x, 1, z)
            let cameraTransform = Transform(scale: .one,
                                            rotation: simd_quatf(),
                                            translation: cameraTranslation)

            cameraEntity.transform = cameraTransform
            cameraEntity.look(at: .zero, from: cameraTranslation, relativeTo: nil)

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
                
        // Context includes:
        // - coordinator
        // - transaction
        // - environment
        print("updateNSView invoked")
        print("- transaction: \(context.transaction))")
        print("- environment: \(context.environment))")
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
