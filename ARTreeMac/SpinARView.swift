//
//  SpingARView.swift
//
//
//  Created by Joseph Heck on 2/9/22.
//

import Foundation
import SwiftUI
import RealityKit
import Combine

struct SpinARView : View {
    @StateObject private var arView: CameraControlARView = {
        let arView = CameraControlARView(frame: .zero)
        
        // Set ARView debug options
        arView.debugOptions = [
            //            .showPhysics,
            .showStatistics,
            //                        .none
        ]
        
        // Load the "Box" scene from the "Experience" Reality File
        let boxAnchor = try! Experience.loadBox()
        
        // Add the box anchor to the scene
        arView.scene.anchors.append(boxAnchor)
        return arView
    }()
    //    @State private var rotation: Float = 0
    //    @State private var inclination: Float = 0
    
    //    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    //    let x = stride(from: 0.0, through: (Float.pi*2), by: 0.05).publisher
    
    //    let rotation = PassthroughSubject<Float, Never>()
    @State var cancellables: Set<AnyCancellable> = []
    
    let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    
    @State var rotation: Float = 0
    @State var timer_connected: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    print(".")
                    let rotation_publisher = stride(from: 0.0, through: (Float.pi*2), by: 0.05).publisher
                    rotation_publisher
                        .zip(timer)
                        .map { (floatval, timerval) in
                            return floatval
                        }
                        .removeDuplicates()
                        .sink { rot in
                            print("setting rotation to: \(rot)")
                            arView.rotationAngle = rot
                        }
                        .store(in: &cancellables)
                } label: {
                    Image(systemName: "play")
                }
                Button {
                    print("x")
                    for thing_to_cancel in cancellables {
                        thing_to_cancel.cancel()
                    }
                    arView.rotationAngle = 0
                } label: {
                    Image(systemName: "stop")
                }
            }
            ARViewContainer(cameraARView: arView)
                .onAppear() {
                    arView.inclinationAngle = -Float.pi/6 // 30°
                }
        }
    }
}

struct SpinARView_Previews: PreviewProvider {
    static var previews: some View {
        SpinARView()
    }
}
