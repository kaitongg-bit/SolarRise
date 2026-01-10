//
//  SolarRiseApp.swift
//  SolarRise
//
//  Created by gktnbjl on 2026/1/10.
//

import SwiftUI
import SwiftData

@main
struct SolarRiseApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [DailyRecord.self, UserStats.self])
    }
}
