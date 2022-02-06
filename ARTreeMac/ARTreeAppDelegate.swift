////
////  ARTreeAppDelegate.swift
////  ARTreeMac
////
////  Created by Joseph Heck on 2/5/22.
////
//
//import Cocoa
//import SwiftUI
//
//class ARTreeAppDelegate: NSObject, NSApplicationDelegate {
//
//    var window: NSWindow!
//
//    func applicationDidFinishLaunching(_ aNotification: Notification) {
//        // Insert code here to initialize your application
//        window = NSWindow(
//            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
//            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
//            backing: .buffered, defer: false)
//        window.center()
//        window.setFrameAutosaveName("Main Window")
//        window.contentView = NSHostingView(rootView: ContentView())
//        window.makeKeyAndOrderFront(nil)
//    }
//}
