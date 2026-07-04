import Foundation
import SwiftData

@Model
final class FoodEntry {
    var date: Date
    var calorie: Int
    var content: String
    var imageData: Data?
    var quantity: Double?
    var unitCalorie: Double?

    init(date: Date = Date(), calorie: Int, content: String = "", imageData: Data? = nil, quantity: Double? = nil, unitCalorie: Double? = nil) {
        self.date = date
        self.calorie = calorie
        self.content = content
        self.imageData = imageData
        self.quantity = quantity
        self.unitCalorie = unitCalorie
    }
}
