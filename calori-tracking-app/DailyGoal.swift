import Foundation
import SwiftData

@Model
final class DailyGoal {
    var date: Date // bu tarihten itibaren geçerli
    var value: Int

    init(date: Date, value: Int) {
        self.date = Calendar.current.startOfDay(for: date)
        self.value = value
    }
}

extension DailyGoal {
    /// Belirli bir gün için geçerli olan hedefi döner: o günden önce veya
    /// o gün başlayan en son hedefi bulur. Hiç hedef yoksa varsayılanı döner.
    static func effectiveGoal(for date: Date, goals: [DailyGoal], defaultValue: Int = 2000) -> Int {
        let day = Calendar.current.startOfDay(for: date)
        let applicable = goals.filter { $0.date <= day }.sorted { $0.date < $1.date }
        return applicable.last?.value ?? defaultValue
    }
}