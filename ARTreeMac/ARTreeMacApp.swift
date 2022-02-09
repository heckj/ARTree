//
//  ARTreeMacApp.swift
//  ARTreeMac
//
//  Created by Joseph Heck on 1/5/22.
//

import SwiftUI

@main
struct ARTreeMacApp: App {
    
    //@NSApplicationDelegateAdaptor(ARTreeAppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            // use min wi & he to make the start screen 800 & 1000 and make max wi & he to infinity to make screen expandable when user stretch the screen
            ContentView()
                .frame(minWidth: 400, maxWidth: .infinity, minHeight: 400, maxHeight: .infinity, alignment: .center)
        }
    }
}

