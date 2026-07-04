import Foundation
import HealthKit
import Combine

@MainActor
final class HealthKitManager: ObservableObject {
    static let shared = HealthKitManager()

    private let healthStore = HKHealthStore()

    /// Gün başlangıcına göre (startOfDay) yakılan aktif kalori değerleri
    @Published var burnedCaloriesByDay: [Date: Int] = [:]
    @Published var isAuthorized: Bool = false

    private init() {}

    var isHealthDataAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    func burnedCalories(for date: Date) -> Int {
        let day = Calendar.current.startOfDay(for: date)
        return burnedCaloriesByDay[day] ?? 0
    }

    func requestAuthorization() {
        guard isHealthDataAvailable,
              let activeEnergyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
            return
        }

        let readTypes: Set<HKObjectType> = [activeEnergyType]

        healthStore.requestAuthorization(toShare: nil, read: readTypes) { [weak self] success, _ in
            Task { @MainActor in
                self?.isAuthorized = success
                if success {
                    self?.fetchBurnedCaloriesRange()
                }
            }
        }
    }

    /// Son `daysBack` gün için (bugün dahil) günlük yakılan kaloriyi tek sorguda çeker.
    func fetchBurnedCaloriesRange(daysBack: Int = 120) {
        guard isHealthDataAvailable,
              let activeEnergyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
            return
        }

        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: Date())
        guard let rangeStart = calendar.date(byAdding: .day, value: -daysBack, to: todayStart),
              let rangeEnd = calendar.date(byAdding: .day, value: 1, to: todayStart) else { return }

        var interval = DateComponents()
        interval.day = 1

        let query = HKStatisticsCollectionQuery(
            quantityType: activeEnergyType,
            quantitySamplePredicate: nil,
            options: .cumulativeSum,
            anchorDate: todayStart,
            intervalComponents: interval
        )

        query.initialResultsHandler = { [weak self] _, results, _ in
            guard let results else { return }
            var newValues: [Date: Int] = [:]
            results.enumerateStatistics(from: rangeStart, to: rangeEnd) { statistics, _ in
                let day = calendar.startOfDay(for: statistics.startDate)
                let sum = statistics.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0
                newValues[day] = Int(sum.rounded())
            }
            Task { @MainActor in
                self?.burnedCaloriesByDay.merge(newValues) { _, new in new }
            }
        }

        healthStore.execute(query)
    }
}
