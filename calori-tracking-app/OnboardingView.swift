import SwiftUI
import SwiftData
struct OnboardingView: View {
    var isEditingExisting: Bool = false

    @AppStorage("userHeight") private var storedHeight: Double = 0
    @AppStorage("userWeight") private var storedWeight: Double = 0
    @AppStorage("userAge") private var storedAge: Int = 0
    @AppStorage("userGender") private var storedGender: String = "male"
    @AppStorage("userActivity") private var storedActivity: String = "sedentary"
    @AppStorage("userGoal") private var storedGoal: String = "maintain"
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var step: Int = 0
    @State private var heightText: String = ""
    @State private var weightText: String = ""
    @State private var ageText: String = ""
    @State private var gender: String = "male"
    @State private var activity: String = "sedentary"
    @State private var goal: String = "maintain"

    private let activityOptions: [(key: String, title: String, subtitle: String, factor: Double)] = [
        ("sedentary", "Hareketsiz", "Masa başı iş, egzersiz yok", 1.2),
        ("light", "Az Hareketli", "Haftada 1-3 gün hafif egzersiz", 1.375),
        ("moderate", "Orta Hareketli", "Haftada 3-5 gün egzersiz", 1.55),
        ("active", "Hareketli", "Haftada 6-7 gün egzersiz", 1.725),
        ("very_active", "Çok Hareketli", "Fiziksel iş + günlük yoğun egzersiz", 1.9)
    ]

    private let goalOptions: [(key: String, title: String, subtitle: String)] = [
        ("lose", "Kilo Vermek", "Günlük ~500 kcal açık uygulanır"),
        ("maintain", "Kiloyu Korumak", "Harcamana eşit kalori hedeflenir"),
        ("gain", "Kilo Almak", "Günlük ~500 kcal fazla uygulanır")
    ]

    private var height: Double { Double(heightText.replacingOccurrences(of: ",", with: ".")) ?? 0 }
    private var weight: Double { Double(weightText.replacingOccurrences(of: ",", with: ".")) ?? 0 }
    private var age: Int { Int(ageText) ?? 0 }

    private var bmr: Double {
        let base = 10 * weight + 6.25 * height - 5 * Double(age)
        return gender == "male" ? base + 5 : base - 161
    }

    private var activityFactor: Double {
        activityOptions.first(where: { $0.key == activity })?.factor ?? 1.2
    }

    private var tdee: Double {
        bmr * activityFactor
    }

    private var recommendedCalorie: Int {
        let adjusted: Double
        switch goal {
        case "lose": adjusted = tdee - 500
        case "gain": adjusted = tdee + 500
        default: adjusted = tdee
        }
        return max(1200, Int(adjusted.rounded()))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ProgressView(value: Double(step + 1), total: 4)
                    .padding(.horizontal)
                    .padding(.top, 8)

                TabView(selection: $step) {
                    bodyInfoStep.tag(0)
                    activityStep.tag(1)
                    goalStep.tag(2)
                    resultStep.tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .navigationTitle(stepTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if isEditingExisting {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("İptal") { dismiss() }
                    }
                }
            }
            .onAppear(perform: loadExistingValues)
        }
        .interactiveDismissDisabled(!isEditingExisting)
    }

    private var stepTitle: String {
        switch step {
        case 0: return "Bilgilerin"
        case 1: return "Hareket Durumun"
        case 2: return "Hedefin"
        default: return "Sonuç"
        }
    }

    private var bodyInfoStep: some View {
        Form {
            Section("Boy, Kilo, Yaş") {
                HStack {
                    Text("Boy (cm)")
                    Spacer()
                    TextField("170", text: $heightText)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                }
                HStack {
                    Text("Kilo (kg)")
                    Spacer()
                    TextField("70", text: $weightText)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                }
                HStack {
                    Text("Yaş")
                    Spacer()
                    TextField("25", text: $ageText)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                }
            }
            Section("Cinsiyet") {
                Picker("Cinsiyet", selection: $gender) {
                    Text("Erkek").tag("male")
                    Text("Kadın").tag("female")
                }
                .pickerStyle(.segmented)
            }
            Section {
                Button("Devam Et") { step = 1 }
                    .disabled(height <= 0 || weight <= 0 || age <= 0)
            }
        }
    }

    private var activityStep: some View {
        Form {
            Section("Ne kadar hareketlisin?") {
                ForEach(activityOptions, id: \.key) { option in
                    Button {
                        activity = option.key
                    } label: {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(option.title)
                                    .foregroundStyle(.primary)
                                    .fontWeight(.semibold)
                                Text(option.subtitle)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            if activity == option.key {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.blue)
                            }
                        }
                    }
                }
            }
            Section {
                Button("Devam Et") { step = 2 }
                Button("Geri") { step = 0 }
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var goalStep: some View {
        Form {
            Section("Hedefin ne?") {
                ForEach(goalOptions, id: \.key) { option in
                    Button {
                        goal = option.key
                    } label: {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(option.title)
                                    .foregroundStyle(.primary)
                                    .fontWeight(.semibold)
                                Text(option.subtitle)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            if goal == option.key {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.blue)
                            }
                        }
                    }
                }
            }
            Section {
                Button("Hesapla") { step = 3 }
                Button("Geri") { step = 1 }
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var resultStep: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "flame.fill")
                .font(.system(size: 50))
                .foregroundStyle(.orange)
            Text("Günlük Kalori İhtiyacın")
                .font(.headline)
                .foregroundStyle(.secondary)
            Text("\(recommendedCalorie) kcal")
                .font(.system(size: 44, weight: .bold))

            VStack(alignment: .leading, spacing: 6) {
                Text("Bazal metabolizma hızın (BMR): \(Int(bmr)) kcal")
                Text("Hareketle birlikte günlük harcaman (TDEE): \(Int(tdee)) kcal")
                Text(goalNote)
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 24)

            Spacer()

            Button {
                finish()
            } label: {
                Text(isEditingExisting ? "Güncelle" : "Başla")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)

            Button("Geri") { step = 2 }
                .foregroundStyle(.secondary)
        }
        .padding(.bottom, 30)
    }

    private var goalNote: String {
        switch goal {
        case "lose": return "Kilo vermek için günlük 500 kcal açık uygulandı."
        case "gain": return "Kilo almak için günlük 500 kcal fazla uygulandı."
        default: return "Kiloyu korumak için harcamana eşit kalori hedeflendi."
        }
    }

    private func loadExistingValues() {
        heightText = storedHeight > 0 ? String(format: "%g", storedHeight) : ""
        weightText = storedWeight > 0 ? String(format: "%g", storedWeight) : ""
        ageText = storedAge > 0 ? "\(storedAge)" : ""
        gender = storedGender
        activity = storedActivity
        goal = storedGoal
    }

    private func finish() {
        storedHeight = height
        storedWeight = weight
        storedAge = age
        storedGender = gender
        storedActivity = activity
        storedGoal = goal

        let newGoal = DailyGoal(date: Date(), value: recommendedCalorie)
        modelContext.insert(newGoal)

        hasCompletedOnboarding = true
        dismiss()
    }
}
