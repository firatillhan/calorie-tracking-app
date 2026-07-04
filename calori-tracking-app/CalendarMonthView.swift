//
//  CalendarMonthView.swift
//  calori-tracking-app
//
//  Created by Fırat İlhan on 3.07.2026.
//


import SwiftUI

struct CalendarMonthView: View {
    enum DayStatus {
        case noData, ok, exceeded
    }

    @Binding var selectedDate: Date
    let dayStatus: (Date) -> DayStatus

    @State private var displayedMonth: Date = Date()

    private let calendar = Calendar.current
    private let daySymbols = ["Pt", "Sa", "Ça", "Pe", "Cu", "Ct", "Pz"]

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Button { changeMonth(-1) } label: {
                    Image(systemName: "chevron.left")
                }
                Spacer()
                Text(monthTitle)
                    .font(.headline)
                Spacer()
                Button { changeMonth(1) } label: {
                    Image(systemName: "chevron.right")
                }
            }

            HStack {
                ForEach(daySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }

            let columns = Array(repeating: GridItem(.flexible()), count: 7)
            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(Array(generateDays().enumerated()), id: \.offset) { _, day in
                    if let day {
                        dayCell(day)
                    } else {
                        Color.clear.frame(height: 40)
                    }
                }
            }
        }
        .padding(.vertical, 8)
        .onAppear {
            displayedMonth = selectedDate
        }
        .onChange(of: selectedDate) { _, newValue in
            if !calendar.isDate(newValue, equalTo: displayedMonth, toGranularity: .month) {
                displayedMonth = newValue
            }
        }
    }

    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: displayedMonth).capitalized
    }

    private func changeMonth(_ delta: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: delta, to: displayedMonth) {
            displayedMonth = newMonth
        }
    }

    private func generateDays() -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: displayedMonth),
              let firstWeekday = calendar.dateComponents([.weekday], from: monthInterval.start).weekday else {
            return []
        }
        let mondayFirstIndex = (firstWeekday + 5) % 7
        var days: [Date?] = Array(repeating: nil, count: mondayFirstIndex)

        var current = monthInterval.start
        while current < monthInterval.end {
            days.append(current)
            guard let next = calendar.date(byAdding: .day, value: 1, to: current) else { break }
            current = next
        }
        return days
    }

    @ViewBuilder
    private func dayCell(_ day: Date) -> some View {
        let status = dayStatus(day)
        let isSelected = calendar.isDate(day, inSameDayAs: selectedDate)
        let isToday = calendar.isDateInToday(day)

        Button {
            selectedDate = day
        } label: {
            VStack(spacing: 4) {
                Text("\(calendar.component(.day, from: day))")
                    .font(.subheadline)
                    .fontWeight(isToday ? .bold : .regular)
                    .foregroundStyle(isSelected ? .white : .primary)

                Circle()
                    .fill(dotColor(status))
                    .frame(width: 6, height: 6)
                    .opacity(status == .noData ? 0 : 1)
            }
            .frame(maxWidth: .infinity, minHeight: 40)
            .background(
                Circle()
                    .fill(isSelected ? Color.accentColor : Color.clear)
                    .padding(3)
            )
        }
        .buttonStyle(.plain)
    }

    private func dotColor(_ status: DayStatus) -> Color {
        switch status {
        case .noData: return .clear
        case .ok: return .green
        case .exceeded: return .red
        }
    }
}