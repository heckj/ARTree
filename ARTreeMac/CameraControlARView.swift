//
//  CameraControlARView.swift
//  ARTreeMac
//
//  Created by Joseph Heck on 2/7/22.
//

import RealityKit
import Cocoa

@objc public class CameraControlARView: ARView {

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

    var motionMode: MotionMode
    
    required init(frame frameRect: NSRect) {
        motionMode = .arcball
        super.init(frame: frameRect)
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
    }

    override dynamic open func keyUp(with event: NSEvent) {
        print("keyUp: \(event)")
    }
    
    override dynamic open func magnify(with event: NSEvent) {
        print("magnify: \(event)")
    }
    
    override dynamic open func rotate(with event: NSEvent) {
        print("rotate: \(event)")
    }
//    override dynamic open func swipe(with event: NSEvent) {
//        print("swipe: \(event)")
//    }

}
