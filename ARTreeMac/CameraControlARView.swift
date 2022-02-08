//
//  CameraControlARView.swift
//
//  Created by Joseph Heck on 2/7/22.
//

import RealityKit
import Cocoa

/// An augmented reality view for macOS that provides keyboard and mouse movement controls for the camera within the view.
@objc public class CameraControlARView: ARView, ObservableObject {
    
    /// The mode of camera motion within the augmented reality scene.
    public enum MotionMode: Int {
        /// Rotate around a target location, effectively orbiting and keeping the camera trained on it.
        ///
        /// Drag motions:
        /// - The view converts vertical drag distance into an inclination above, or below, the target location, clamped to directly above and below it.
        /// - The view converts horizontal drag distance into a rotational angle, orbiting the target location.
        ///
        /// Keyboard motions:
        /// - The right-arrow and `d` keys rotate the camera to the right around the location.
        /// - The left-arrow and `a` keys rotate the camera to the left around the location.
        /// - the up-arrow and `w` keys rotate the camera upward around the location, clamped to a maximum of directly above the location.
        /// - the down-arrow and `s` keys rotate the camera downward around the location, clamped to a minimum of directly below the location.
        case arcball
        /// Free motion within the AR scene, not locked to a location.
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
    ///
    /// The default option is ``MotionMode-swift.enum/arcball``:
    /// - ``MotionMode-swift.enum/arcball`` rotates around a specific target location, effectively orbiting and keeping the camera trained on that location.
    /// - ``MotionMode-swift.enum/firstperson`` moves freely in all axis within the world space, not locked to any location.
    ///
    var motionMode: MotionMode
    
    // TODO: consider encapsulating all these values into a single struct to allow for assigning consolidated values.
    
    /// The target for the camera when in arcball mode.
    var arcballTarget: simd_float3
    /// The angle of inclination of the camera when in arcball mode.
    var inclinationAngle: Float
    /// The angle of rotation of the camera when in arcball mode.
    var rotationAngle: Float
    /// The camera's orbital distance from the target when in arcball mode.
    var radius: Float
    
    /// The speed at which drag operations map percentage of movement within the view to rotational or positional updates.
    var dragspeed: Float
    
    /// The speed at which keypresses change the angles of inclination or rotation.
    ///
    /// This view doubles the speed valuewhen the key is held-down.
    var keyspeed: Float
    /// A reference to the camera anchor entity for moving, or reading the location values, for the camera.
    var cameraAnchor: AnchorEntity
    
    private var dragstart: NSPoint
    private var dragstart_rotation: Float
    private var dragstart_inclination: Float
    private var magnify_start: Float
    /// A copy of the basic transform applied ot the camera, and updated in parallel to reflect "upward" to SwiftUI.
    @Published var macOSCameraTransform: Transform
    
    required init(frame frameRect: NSRect) {
        motionMode = .arcball
        arcballTarget = simd_float3(0,0,0)
        inclinationAngle = 0
        rotationAngle = 0
        radius = 2
        cameraAnchor = AnchorEntity(world: .zero)
        keyspeed = 0.01
        dragspeed = 0.01
        dragstart = NSPoint.zero
        dragstart_rotation = 0
        dragstart_inclination = 0
        magnify_start = radius
        // reflect the camera's transform as an observed object
        macOSCameraTransform = cameraAnchor.transform
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
        // reflect the camera's transform as an observed object
        macOSCameraTransform = cameraAnchor.transform
    }
    
    @MainActor required dynamic init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override dynamic open func mouseDown(with event: NSEvent) {
                print("mouseDown EVENT: \(event)")
        //        print(" at \(event.locationInWindow) of \(self.frame)")
        dragstart = event.locationInWindow
        dragstart_rotation = rotationAngle
        dragstart_inclination = inclinationAngle
        //        print(" converted local: \(self.convert(event.locationInWindow, from: self))")
        // no difference in conversion, apparently because we're getting this from inside the view
        // itself.
        // Oh - and the coordinate frame (x,y) has the 0,0 location in the lower left corner.
        //        print(" associated event mask: \(event.associatedEventsMask)")
    }
    
    override dynamic open func mouseDragged(with event: NSEvent) {
        //        print("mouseDragged EVENT: \(event)")
        //        print(" at \(event.locationInWindow) of \(self.frame)")
        
        let deltaX = Float(event.locationInWindow.x - dragstart.x)
        let deltaY = Float(event.locationInWindow.y - dragstart.y)
        switch motionMode {
        case .arcball:
            rotationAngle = dragstart_rotation - deltaX * dragspeed
            inclinationAngle = dragstart_inclination + deltaY * dragspeed
            if inclinationAngle > Float.pi/2 {
                inclinationAngle = Float.pi/2
            }
            if inclinationAngle < -Float.pi/2 {
                inclinationAngle = -Float.pi/2
            }
            updateCamera()
        case .firstperson:
            break
        }
        //        print(" converted local: \(self.convert(event.locationInWindow, from: self))")
        //        print(" associated event mask: \(event.associatedEventsMask)")
    }
    
    //    override dynamic open func mouseMoved(with event: NSEvent) {
    //        // looks like I'd need to create a relevant NSTrackingArea to capture random mouse movements here
    //        // https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/EventOverview/TrackingAreaObjects/TrackingAreaObjects.html
    //        // https://swiftui-lab.com/a-powerful-combo/
    //        print("mouseMoved EVENT: \(event)")
    //    }
    
    override dynamic open func keyDown(with event: NSEvent) {
        //        print("keyDown: \(event)")
        //        print("key value: \(event.keyCode)")
        switch motionMode {
        case .arcball:
            switch event.keyCode {
            case 123, 0:
                // 123 = left arrow
                // 0 = a
                if event.isARepeat {
                    rotationAngle -= keyspeed * 2
                } else {
                    rotationAngle -= keyspeed
                }
                updateCamera()
            case 124, 2:
                // 124 = right arrow
                // 2 = d
                if event.isARepeat {
                    rotationAngle += keyspeed * 2
                } else {
                    rotationAngle += keyspeed
                }
                updateCamera()
            case 126, 13:
                // 126 = up arrow
                // 13 = w
                if inclinationAngle > -Float.pi/2 {
                    if event.isARepeat {
                        inclinationAngle -= keyspeed * 2
                    } else {
                        inclinationAngle -= keyspeed
                    }
                    updateCamera()
                }
            case 125, 1:
                // 125 = down arrow
                // 1 = s
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
        case .firstperson:
            break
        }
        
    }
    
    override dynamic open func keyUp(with event: NSEvent) {
        //print("keyUp: \(event)")
    }
    
    override dynamic open func magnify(with event: NSEvent) {
        if event.phase == NSEvent.Phase.ended {
            print("magnify: \(event)")
        }
//        print("magnify: \(event)")
        switch motionMode {
        case .arcball:
            if event.phase == NSEvent.Phase.began {
                magnify_start = Float(event.magnification)
                print("magnify: \(event)")
            }
            let multiplier = Float(event.magnification) / magnify_start
            print("Multiplier is \(multiplier)")
            radius = 2 * multiplier
            print("radius updated to \(radius)")
            updateCamera()
        case .firstperson:
            break
        }
    }
    
    //    override dynamic open func rotate(with event: NSEvent) {
    //        print("rotate: \(event)")
    //    }
    
}
