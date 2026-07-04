//
//  calori_tracking_appApp.swift
//  calori-tracking-app
//
//  Created by Fırat İlhan on 3.07.2026.
//

import SwiftUI
import SwiftData

@main
struct calori_tracking_appApp: App {
    var body: some Scene {
        WindowGroup {
            ListView()
        }
        .modelContainer(for: [FoodEntry.self, FoodItem.self, DailyGoal.self])
    }
}
