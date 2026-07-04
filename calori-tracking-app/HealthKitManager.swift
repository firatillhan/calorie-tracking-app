import Foundation
import HealthKit

@MainActor
final class HealthKitManager: ObservableObject {
    static let shared = HealthKitManager()

    private let healthStore = HKHealthStore()

    @Published var burnedCalories: Int = 0
    @Published var isAuthorized: Bool = false

    private init() {}

    var isHealthDataAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
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
                    self?.fetchBurnedCalories(for: Date())
                }
            }
        }
    }

    func fetchBurnedCalories(for date: Date) {
        guard isHealthDataAvailable,
              let activeEnergyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
            return
        }

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return }

        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)

        let query = HKStatisticsQuery(
            quantityType: activeEnergyType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { [weak self] _, statistics, _ in
            let sum = statistics?.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0
            Task { @MainActor in
                self?.burnedCalories = Int(sum.rounded())
            }
        }

        healthStore.execute(query)
    }
}