//
//  CameraControlARView.swift
//  ARTreeMac
//
//  Created by Joseph Heck on 2/7/22.
//

import RealityKit
import Cocoa

@objc public class CameraControlARView: ARView, ObservableObject {

    public enum MotionMode: Int {
        case arcball
        case firstperson
    }
    
    // arcball:
    //
    // At its heart, arcball is all about looking at a singular location (or object). It needs to have a
    // radius as well.
    //
    // - vertical delta motion (drag) interpreted as changing the inclination angle. Which I think
    // would make sense to clamp at +90° and -90° (+.pi/2, -.pi/2) to keep from getting really confusing.
    // - horizontal delta motion (drag) interpreted as changing rotation angle. No need to clamp this.
    // - keydown left-arrow, right-arrow get mapped to explicit increments of horizontal delta and change rotation
    // - keydown up-arrow, down-arrow get mapped to explicit increments of vertical delta, and respect the clamping.
    // - maginification (increase = zoom in) interpretted as shortening the radius to the target location, and
    // zoom out does the reverse. Definitely clamp to a minimum of zero radius, and potentially want to have a
    // lower set limit not to come earlier based on a collision boundary for any target object and maybe some padding.
    
    /// The mode in which the camera is controlled by keypresses and/or mouse and gesture movements.
    var motionMode: MotionMode
    /// The target for the camera when in arcball mode.
    var arcballTarget: simd_float3
    /// The angle of inclination of the camera when in arcball mode.
    var inclinationAngle: Float
    /// The angle of rotation of the camera when in arcball mode.
    var rotationAngle: Float
    /// The camera's orbital distance from the target when in arcball mode.
    var radius: Float
    /// The speed at which keypresses change the angles of inclination or rotation.
    ///
    /// This view doubles the speed valuewhen the key is held-down.
    var keyspeed: Float
    /// A reference to the camera anchor entity for moving, or reading the location values, for the camera.
    var cameraAnchor: AnchorEntity
    
    required init(frame frameRect: NSRect) {
        motionMode = .arcball
        arcballTarget = simd_float3(0,0,0)
        inclinationAngle = 0
        rotationAngle = 0
        radius = 2
        cameraAnchor = AnchorEntity(world: .zero)
        keyspeed = 0.01
        super.init(frame: frameRect)
        
        let cameraEntity = PerspectiveCamera()
        cameraEntity.camera.fieldOfViewInDegrees = 60
        cameraAnchor.addChild(cameraEntity)
        scene.addAnchor(cameraAnchor)
        updateCamera()
    }
    
    @MainActor func updateCamera() {
        let translationTransform = Transform(scale: .one,
                                        rotation: simd_quatf(),
                                        translation: SIMD3<Float>(0, 0, radius))
        
//        let rotationQuaternion: simd_quatf = simd_quatf(angle: rotationAngle, axis: simd_float3(0,1,0))
//        let rotationTransform = simd_float4x4(rotationQuaternion)
//
//        let inclinationQuaternion: simd_quatf = simd_quatf(angle: inclinationAngle, axis: simd_float3(0,0,1))
//        let inclinationTransform = simd_float4x4(inclinationQuaternion)
        
        let combinedRotationTransform: Transform = Transform(pitch: inclinationAngle, yaw: rotationAngle, roll: 0)
        
//        var computedMatrix = matrix_multiply(matrix_identity_float4x4, rotationTransform)
//        var computedMatrix = matrix_identity_float4x4 * rotationTransform
//        computedMatrix = computedMatrix * inclinationTransform

        // ORDER of operations is critical here to getting the correct transform:
        // - identity -> rotation -> translation
        let computed_transform = matrix_identity_float4x4 * combinedRotationTransform.matrix * translationTransform.matrix
        
        // This moves the camera to the right location
        cameraAnchor.transform = Transform(matrix: computed_transform)
        // This spins the camera AT its current location to look at a specific target location
        cameraAnchor.look(at: arcballTarget, from: cameraAnchor.transform.translation, relativeTo: nil)
    }
        
    @MainActor required dynamic init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    override dynamic open func layout()
//
//    override dynamic open func viewDidChangeBackingProperties()
//
//    override dynamic open func viewDidMoveToSuperview()
//
//    override dynamic open var frame: NSRect

    override dynamic open func mouseDown(with event: NSEvent) {
        print("mouseDown EVENT: \(event)")
        print(" at \(event.locationInWindow) of \(self.frame)")
//        print(" converted local: \(self.convert(event.locationInWindow, from: self))")
        // no difference in conversion, apparently because we're getting this from inside the view
        // itself.
        // Oh - and the coordinate frame (x,y) has the 0,0 location in the lower left corner.
//        print(" associated event mask: \(event.associatedEventsMask)")
    }
    
    override dynamic open func rightMouseDown(with event: NSEvent) {
        print("rightMouseDown EVENT: \(event)")
        print(" at \(event.locationInWindow) of \(self.frame)")
//        print(" converted local: \(self.convert(event.locationInWindow, from: self))")
//        print(" associated event mask: \(event.associatedEventsMask)")

    }

    override dynamic open func otherMouseDown(with event: NSEvent) {
        print("otherMouseDown EVENT: \(event)")
        print(" at \(event.locationInWindow) of \(self.frame)")
//        print(" converted local: \(self.convert(event.locationInWindow, from: self))")
//        print(" associated event mask: \(event.associatedEventsMask)")

    }

    override dynamic open func mouseUp(with event: NSEvent) {
        print("mouseUp EVENT: \(event)")
        print(" at \(event.locationInWindow) of \(self.frame)")
//        print(" converted local: \(self.convert(event.locationInWindow, from: self))")
//        print(" associated event mask: \(event.associatedEventsMask)")
    }

    override dynamic open func rightMouseUp(with event: NSEvent) {
        print("rightMouseUp EVENT: \(event)")
        print(" at \(event.locationInWindow) of \(self.frame)")
//        print(" converted local: \(self.convert(event.locationInWindow, from: self))")
//        print(" associated event mask: \(event.associatedEventsMask)")
    }

    override dynamic open func otherMouseUp(with event: NSEvent) {
        print("otherMouseUp EVENT: \(event)")
        print(" at \(event.locationInWindow) of \(self.frame)")
//        print(" converted local: \(self.convert(event.locationInWindow, from: self))")
//        print(" associated event mask: \(event.associatedEventsMask)")
    }

    override dynamic open func mouseDragged(with event: NSEvent) {
        print("mouseDragged EVENT: \(event)")
        print(" at \(event.locationInWindow) of \(self.frame)")
//        print(" converted local: \(self.convert(event.locationInWindow, from: self))")
//        print(" associated event mask: \(event.associatedEventsMask)")
    }

    override dynamic open func rightMouseDragged(with event: NSEvent) {
        print("rightMouseDragged EVENT: \(event)")
        print(" at \(event.locationInWindow) of \(self.frame)")
//        print(" converted local: \(self.convert(event.locationInWindow, from: self))")
//        print(" associated event mask: \(event.associatedEventsMask)")
    }

    override dynamic open func otherMouseDragged(with event: NSEvent) {
        print("otherMouseDragged EVENT: \(event)")
        print(" at \(event.locationInWindow) of \(self.frame)")
//        print(" converted local: \(self.convert(event.locationInWindow, from: self))")
//        print(" associated event mask: \(event.associatedEventsMask)")

    }

    override dynamic open func mouseMoved(with event: NSEvent) {
        // looks like I'd need to create a relevant NSTrackingArea to capture random mouse movements here
        // https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/EventOverview/TrackingAreaObjects/TrackingAreaObjects.html
        // https://swiftui-lab.com/a-powerful-combo/
        print("mouseMoved EVENT: \(event)")
    }

//    override dynamic open func scrollWheel(with event: NSEvent)
//
//    override dynamic open func makeBackingLayer() -> CALayer

//    override dynamic open var acceptsFirstResponder: Bool {
//        get {
//            print("checking 'acceptsFirstResponder', saying : 'YEP!'")
//            return true
//        }
//    }

    override dynamic open func keyDown(with event: NSEvent) {
        print("keyDown: \(event)")
        print("key value: \(event.keyCode)")
        switch event.keyCode {
            // 123 = left arrow
            // 124 = right arrow
            // 126 = up arrow
            // 125 = down arrow
            // 0 = a
            // 1 = s
            // 2 = d
            // 13 = w
            case 123, 0:
            if event.isARepeat {
                rotationAngle -= keyspeed * 2
            } else {
                rotationAngle -= keyspeed
            }
            updateCamera()
            case 124, 2:
            if event.isARepeat {
                rotationAngle += keyspeed * 2
            } else {
                rotationAngle += keyspeed
            }
            updateCamera()
            case 126, 13:
            if inclinationAngle > -Float.pi/2 {
                if event.isARepeat {
                    inclinationAngle -= keyspeed * 2
                } else {
                    inclinationAngle -= keyspeed
                }
                updateCamera()
            }
            case 125, 1:
            if inclinationAngle < Float.pi/2 {
                if event.isARepeat {
                    inclinationAngle += keyspeed * 2
                } else {
                    inclinationAngle += keyspeed
                }
                updateCamera()
            }
            default:
                break
        }
    }

    override dynamic open func keyUp(with event: NSEvent) {
        //print("keyUp: \(event)")
    }
    
    override dynamic open func magnify(with event: NSEvent) {
        print("magnify: \(event)")
    }
    
//    override dynamic open func rotate(with event: NSEvent) {
//        print("rotate: \(event)")
//    }

}
