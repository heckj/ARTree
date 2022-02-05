//
//  ContentView.swift
//  ARTree
//
//  Created by Joseph Heck on 1/5/22.
//

// reading material: https://www.ralfebert.com/ios/realitykit-dice-tutorial/

import SwiftUI
import ARKit
import RealityKit
import FocusEntity
import MeshGenerator

struct ContentView : View {
    var body: some View {
        VStack {
            RealityKitView()
                .edgesIgnoringSafeArea(.all)
        }
    }
}

class Coordinator: NSObject, ARSessionDelegate {
    weak var view: ARView?
    var focusEntity: FocusEntity?

    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        guard let view = self.view else { return }
        debugPrint("Anchors added to the scene: ", anchors)
        self.focusEntity = FocusEntity(on: view, style: .classic(color: .yellow))
    }
    
    @objc func handleTap() {
        guard let view = self.view, let focusEntity = self.focusEntity else { return }

        // Create a new anchor to add content to
        let anchor = AnchorEntity()
        view.scene.anchors.append(anchor)

        //        // Load the "Box" scene from the "Experience" Reality File
        //        let boxAnchor = try! Experience.loadBox()
        //
        //        // Add the box anchor to the scene
        //        arView.scene.anchors.append(boxAnchor)
        //        print("Anchors: \(arView.scene.anchors.count)")

//        // Add a Box entity with a blue material
//        let box = MeshResource.generateBox(size: 0.1, cornerRadius: 0.025)
//        let material = SimpleMaterial(color: .blue, isMetallic: true)
//        let diceEntity = ModelEntity(mesh: box, materials: [material])
//        diceEntity.position = focusEntity.position
        
        let positions: [Vector] = [
            Vector(x: 0.5, y: -0.4330127, z: -0.4330127), // 0
            Vector(x: -0.5, y: -0.4330127, z: -0.4330127), // /// 1
            Vector(x: 0, y: 0.4330127, z: 0), // 2  (peak)
            Vector(x: 0, y: -0.4330127, z: 0.4330127), // 3
        ]
        
        let back = Triangle(positions[0], positions[1], positions[2], material: ColorRepresentation.red)
        let bottom = Triangle(positions[0], positions[3], positions[1], material: ColorRepresentation.white)
        let left = Triangle(positions[0], positions[2], positions[3], material: ColorRepresentation.blue)
        let right = Triangle(positions[2], positions[1], positions[3], material: ColorRepresentation.green)
        let mesh = Mesh([back, bottom, left, right])
        let tetra = try! MeshResource.generate(mesh: mesh)
        let materials = [
            SimpleMaterial(color: .blue, isMetallic: false),
            SimpleMaterial(color: .red, isMetallic: false),
            SimpleMaterial(color: .green, isMetallic: false),
            SimpleMaterial(color: .white, isMetallic: false)
        ]
        let tetraEntity = ModelEntity(mesh: tetra, materials: materials)
        tetraEntity.position = focusEntity.position
        tetraEntity.scale = [0.1, 0.1, 0.1]
        anchor.addChild(tetraEntity)

//        // Add a dice entity
//        let diceEntity = try! ModelEntity.loadModel(named: "Dice")
//        diceEntity.scale = [0.1, 0.1, 0.1]
//        diceEntity.position = focusEntity.position
//
//        // This need to be the unscaled size, that's why relativeTo: diceEntity is used
//        let size = diceEntity.visualBounds(relativeTo: diceEntity).extents
//        let boxShape = ShapeResource.generateBox(size: size)
//        diceEntity.collision = CollisionComponent(shapes: [boxShape])
//        diceEntity.physicsBody = PhysicsBodyComponent(
//            massProperties: .init(shape: boxShape, mass: 50),
//            material: nil,
//            mode: .dynamic
//        )
//        anchor.addChild(diceEntity)
//
//        // Create a plane below the dice
//        let planeMesh = MeshResource.generatePlane(width: 2, depth: 2)
//        let material = SimpleMaterial(color: .init(white: 1.0, alpha: 0.1), isMetallic: false)
//        let planeEntity = ModelEntity(mesh: planeMesh, materials: [material])
//        planeEntity.position = focusEntity.position
//        planeEntity.physicsBody = PhysicsBodyComponent(massProperties: .default, material: nil, mode: .static)
//        planeEntity.collision = CollisionComponent(shapes: [.generateBox(width: 2, height: 0.001, depth: 2)])
//        planeEntity.position = focusEntity.position
//        anchor.addChild(planeEntity)
//
//        diceEntity.addForce([0, 2, 0], relativeTo: nil)
//        diceEntity.addTorque([Float.random(in: 0 ... 0.4), Float.random(in: 0 ... 0.4), Float.random(in: 0 ... 0.4)], relativeTo: nil)
    }
}

struct RealityKitView: UIViewRepresentable {
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)

        // Start AR session
        let session = arView.session
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        session.run(config)
        
        // Add coaching overlay
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        coachingOverlay.session = session
        coachingOverlay.goal = .horizontalPlane
        arView.addSubview(coachingOverlay)
                
        // Set debug options
        #if DEBUG
        arView.debugOptions = [
//            .showFeaturePoints,
            .showAnchorOrigins,
            .showPhysics,
//            .showAnchorGeometry
        ]
        #endif
        
        // Handle ARSession events via delegate
        context.coordinator.view = arView
        session.delegate = context.coordinator
        
        // Handle taps
        arView.addGestureRecognizer(
            UITapGestureRecognizer(
                target: context.coordinator,
                action: #selector(Coordinator.handleTap)
            )
        )
        
        return arView
        
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
