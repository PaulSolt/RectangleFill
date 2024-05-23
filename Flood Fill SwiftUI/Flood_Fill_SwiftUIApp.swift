//
//  Flood_Fill_SwiftUIApp.swift
//  Flood Fill SwiftUI
//
//  Created by Paul Solt on 5/23/24.
//

import SwiftUI

@main
struct Flood_Fill_SwiftUIApp: App {
    var body: some Scene {
        WindowGroup {
            FloodFill(grid: Grid(9))
        }
    }
}
