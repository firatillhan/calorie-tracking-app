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