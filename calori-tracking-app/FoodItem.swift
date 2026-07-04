//
//  FoodItem.swift
//  calori-tracking-app
//
//  Created by Fırat İlhan on 3.07.2026.
//


import Foundation
import SwiftData

@Model
final class FoodItem {
    var name: String
    var imageData: Data?
    var unitCalorie: Double
    var unitLabel: String // örn: "adet", "dilim", "porsiyon"

    init(name: String, imageData: Data? = nil, unitCalorie: Double, unitLabel: String = "adet") {
        self.name = name
        self.imageData = imageData
        self.unitCalorie = unitCalorie
        self.unitLabel = unitLabel
    }
}