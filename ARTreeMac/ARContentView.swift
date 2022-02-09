//
//  ARContentView.swift
//  ARTreeMac
//
//  Created by Joseph Heck on 1/5/22.
//

import SwiftUI
import RealityKit
import Combine

struct ARContentView : View {
    @StateObject var arview: CameraControlARView = {
        let arView = CameraControlARView(frame: .zero)
        
        // Set ARView debug options
        arView.debugOptions = [
            //            .showPhysics,
            .showStatistics,
            //            .none
        ]
        
        // Load the "Box" scene from the "Experience" Reality File
        let boxAnchor = try! Experience.loadBox()
        
        // Add the box anchor to the scene
        arView.scene.anchors.append(boxAnchor)
        return arView
    }()
        
    var body: some View {
        ARViewContainer(cameraARView: arview)
    }
}


struct ARContentView_Previews: PreviewProvider {
    static var previews: some View {
        ARContentView()
    }
}
