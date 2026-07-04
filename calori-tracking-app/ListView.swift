import SwiftUI
import SwiftData

struct ListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FoodEntry.date, order: .reverse) private var allEntries: [FoodEntry]
    @Query(sort: \DailyGoal.date, order: .forward) private var allGoals: [DailyGoal]
    @StateObject private var healthKitManager = HealthKitManager.shared

    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @State private var showingAddSheet = false
    @State private var showingLibrarySheet = false
    @State private var showingGoalAlert = false
    @State private var goalInput = ""
    @State private var showOnboarding = false
    @State private var showingProfileEdit = false

    @State private var selectedDate: Date = Date()
    @State private var isCalendarExpanded = false

    private var selectedDayEntries: [FoodEntry] {
        allEntries.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
    }

    private var selectedDayTotal: Int {
        selectedDayEntries.reduce(0) { $0 + $1.calorie }
    }

    private var selectedDayGoal: Int {
        DailyGoal.effectiveGoal(for: selectedDate, goals: allGoals)
    }

    private var adjustedGoal: Int {
        selectedDayGoal + healthKitManager.burnedCalories(for: selectedDate)
    }

    private var remaining: Int {
        adjustedGoal - selectedDayTotal
    }

    private var isToday: Bool {
        Calendar.current.isDateInToday(selectedDate)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                calendarHeader

                if isCalendarExpanded {
                    CalendarMonthView(selectedDate: $selectedDate, dayStatus: dayStatus)
                        .padding(.horizontal)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }

                Divider()

                summaryCard

                List {
                    ForEach(selectedDayEntries) { entry in
                        NavigationLink(destination: DetailView(entry: entry)) {
                            entryRow(entry)
                        }
                    }
                    .onDelete(perform: deleteEntries)
                }
                .listStyle(.plain)
            }
            .navigationTitle(isToday ? "Bugün" : selectedDate.formatted(date: .abbreviated, time: .omitted))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingProfileEdit = true
                    } label: {
                        Image(systemName: "person.circle")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            showingAddSheet = true
                        } label: {
                            Label("Manuel Ekle", systemImage: "square.and.pencil")
                        }
                        Button {
                            showingLibrarySheet = true
                        } label: {
                            Label("Listeden Seç", systemImage: "list.bullet")
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddEntryView()
            }
            .sheet(isPresented: $showingLibrarySheet) {
                FoodLibraryView()
            }
            .sheet(isPresented: $showingProfileEdit) {
                OnboardingView(isEditingExisting: true)
            }
            .fullScreenCover(isPresented: $showOnboarding) {
                OnboardingView(isEditingExisting: false)
            }
            .onAppear {
                if !hasCompletedOnboarding {
                    showOnboarding = true
                }
                healthKitManager.requestAuthorization()
                healthKitManager.fetchBurnedCaloriesRange()
            }
        }
    }

    private var calendarHeader: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.25)) {
                isCalendarExpanded.toggle()
            }
        } label: {
            HStack {
                Image(systemName: "calendar")
                    .foregroundStyle(.secondary)
                Text(headerDateText)
                    .font(.subheadline.bold())
                    .foregroundStyle(.primary)
                Spacer()
                Image(systemName: "chevron.down")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .rotationEffect(.degrees(isCalendarExpanded ? 180 : 0))
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
        }
        .buttonStyle(.plain)
    }

    private var headerDateText: String {
        if isToday {
            return "Bugün, " + selectedDate.formatted(.dateTime.day().month(.wide).locale(Locale(identifier: "tr_TR")))
        } else {
            return selectedDate.formatted(.dateTime.day().month(.wide).year().weekday(.wide).locale(Locale(identifier: "tr_TR")))
        }
    }

    private var summaryCard: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Alınan")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(selectedDayTotal) kcal")
                        .font(.title2.bold())
                }
                Spacer()
                if healthKitManager.isAuthorized {
                    VStack {
                        Text("Yakılan")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("+\(healthKitManager.burnedCalories(for: selectedDate)) kcal")
                            .font(.title3.bold())
                            .foregroundStyle(.orange)
                    }
                    Spacer()
                }
                VStack(alignment: .trailing) {
                    Text("Hedef")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Button {
                        goalInput = "\(selectedDayGoal)"
                        showingGoalAlert = true
                    } label: {
                        Text("\(adjustedGoal) kcal")
                            .font(.title2.bold())
                    }
                    .buttonStyle(.plain)
                    .alert("Kalori Hedefi", isPresented: $showingGoalAlert) {
                        TextField("Kalori hedefi", text: $goalInput)
                            .keyboardType(.numberPad)
                        Button("İptal", role: .cancel) {}
                        Button("Kaydet") {
                            if let value = Int(goalInput) {
                                let goal = DailyGoal(date: selectedDate, value: value)
                                modelContext.insert(goal)
                            }
                        }
                    } message: {
                        Text(isToday
                             ? "Bugünden itibaren geçerli olacak temel hedefi gir (yaktığın kalori bunun üstüne otomatik eklenir)"
                             : "\(selectedDate.formatted(date: .abbreviated, time: .omitted)) tarihinden itibaren geçerli olacak temel hedefi gir")
                    }
                }
            }

            ProgressView(value: min(Double(selectedDayTotal), Double(adjustedGoal)), total: Double(max(adjustedGoal, 1)))
                .tint(remaining >= 0 ? .green : .red)

            Text(remaining >= 0 ? "\(remaining) kcal hakkın kaldı" : "\(-remaining) kcal aştın")
                .font(.headline)
                .foregroundStyle(remaining >= 0 ? .green : .red)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
    }

    private func entryRow(_ entry: FoodEntry) -> some View {
        HStack {
            if let data = entry.imageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray5))
                    .frame(width: 50, height: 50)
                    .overlay(Image(systemName: "fork.knife").foregroundStyle(.secondary))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(entry.content.isEmpty ? "İsimsiz" : entry.content)
                    .font(.subheadline.bold())
                Text(entry.date.formatted(date: .omitted, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text("\(entry.calorie) kcal")
                .font(.subheadline.bold())
        }
        .padding(.vertical, 4)
    }

    private func deleteEntries(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(selectedDayEntries[index])
        }
    }

    private func dayStatus(for day: Date) -> CalendarMonthView.DayStatus {
        let entries = allEntries.filter { Calendar.current.isDate($0.date, inSameDayAs: day) }
        guard !entries.isEmpty else { return .noData }
        let total = entries.reduce(0) { $0 + $1.calorie }
        let goalForDay = DailyGoal.effectiveGoal(for: day, goals: allGoals)
        let adjustedGoalForDay = goalForDay + healthKitManager.burnedCalories(for: day)
        return total > adjustedGoalForDay ? .exceeded : .ok
    }
}
