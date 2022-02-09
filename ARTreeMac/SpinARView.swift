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
import UniformTypeIdentifiers

struct SpinARView : View {
    @StateObject private var arView: CameraControlARView = {
        let arView = CameraControlARView(frame: .zero)
        
        // Load the "Box" scene from the "Experience" Reality File
        let boxAnchor = try! Experience.loadBox()
        
        // Add the box anchor to the scene
        arView.scene.anchors.append(boxAnchor)
        arView.radius = 1.2
        return arView
    }()
    @State var debugEnabled = false

    @State var cancellables: Set<AnyCancellable> = []
    @State var snapshots: [NSImage] = []
    @State var name_for_file: String = ""
    @State var frames_per_second: Int = 20
    
    func animatedGifFromImages(images: [NSImage], filename: String, frameDelay: Double) -> Bool {
        let directory_url = FileManager.default.urls(for: .documentDirectory,
                                            in: .userDomainMask)[0]
            
        let url = directory_url.appendingPathComponent("/\(filename).gif") as CFURL
        
//        // NSSerachPathForDirectories results in app-specific document container
//        guard let path = NSSearchPathForDirectoriesInDomains(
//            .documentDirectory,
//            .userDomainMask, true).last?.appending() else {
//                return false
//            }
        //        let url = URL(fileURLWithPath: path) as CFURL

        let prep = [kCGImagePropertyGIFDictionary as String :
               [kCGImagePropertyGIFDelayTime as String : frameDelay]] as CFDictionary

        let fileProperties = [ kCGImagePropertyGIFDictionary as String :
                               [kCGImagePropertyGIFLoopCount as String : 0] ,
                               kCGImageMetadataShouldExcludeGPS as String: true]
                               as CFDictionary

        guard let destination = CGImageDestinationCreateWithURL(
            url,
            UTType.gif.identifier as CFString, // aka `kUTTypeGIF`
            images.count,
            nil) else {
            return false
        }

        CGImageDestinationSetProperties(destination, fileProperties)

        for image in images {
            if let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) {
                CGImageDestinationAddImage(destination, cgImage, prep)
            }
        }

        if CGImageDestinationFinalize(destination) {
            NSWorkspace.shared.open(directory_url)
            return true
        }
        return false
    }

    let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    
    @State var rotation: Float = 0
    @State var timer_connected: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    if debugEnabled {
                        debugEnabled = false
                        arView.debugOptions = [.none]
                    } else {
                        debugEnabled = true
                        arView.debugOptions = [.showStatistics]
                    }
                } label: {
                    Label {
                        Text("AR stats")
                    } icon: {
                        Image(systemName: "info.circle")
                    }
                }
                Button {
//                    print(".")
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
                            arView.snapshot(saveToHDR: false) { image in
                                guard let image = image else {
                                    return
                                }
                                // print("image size: \(image.size)")
                                // print("arview size: \(arView.frame.size)")
                                // image size: (809.0, 643.0) <- same size as frame
                                snapshots.append(image)
                            }
                        }
                        .store(in: &cancellables)
                } label: {
                    Image(systemName: "play")
                }
                Button {
//                    print("x")
                    for thing_to_cancel in cancellables {
                        thing_to_cancel.cancel()
                    }
                    arView.rotationAngle = 0
                } label: {
                    Image(systemName: "stop")
                }
                Button {
                    snapshots = []
                    arView.rotationAngle = 0
                } label: {
                    Image(systemName: "clear")
                }
                Text("Images captured: \(snapshots.count)")
                TextField("name for the animated gif", text: $name_for_file)
                HStack {
                    Text("at \(frames_per_second) fps")
                    VStack {
                        Button {
                            if frames_per_second < 30 {
                            frames_per_second += 1
                            }
                        } label: {
                            Image(systemName: "chevron.up")
                        }
                        Button {
                            if frames_per_second > 0 {
                                frames_per_second -= 1
                            }
                        } label: {
                            Image(systemName: "chevron.down")
                        }

                    }
                }
                Button {
                    if name_for_file.count > 0 && snapshots.count > 0 {
                        print("Saving to \(name_for_file)")
                        for thing_to_cancel in cancellables {
                            thing_to_cancel.cancel()
                        }
                        let result = animatedGifFromImages(
                            images: snapshots,
                            filename: name_for_file,
                            frameDelay: 1.0/Double(frames_per_second))
                        print("Save result: \(result)")
                    }
                } label: {
                    Image(systemName: "square.and.arrow.down")
                }
            }
            .padding([.horizontal, .top])
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
