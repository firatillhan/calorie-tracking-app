//
//  FoodQuantityView.swift
//  calori-tracking-app
//
//  Created by Fırat İlhan on 3.07.2026.
//


import SwiftUI
import SwiftData

struct FoodQuantityView: View {
    let foodItem: FoodItem
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var quantityText: String = "1"

    private var quantity: Double {
        Double(quantityText.replacingOccurrences(of: ",", with: ".")) ?? 1
    }

    private var totalCalorie: Int {
        Int((quantity * foodItem.unitCalorie).rounded())
    }

    var body: some View {
        Form {
            Section {
                HStack {
                    if let data = foodItem.imageData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    } else {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.systemGray5))
                            .frame(width: 60, height: 60)
                            .overlay(Image(systemName: "fork.knife").foregroundStyle(.secondary))
                    }
                    VStack(alignment: .leading) {
                        Text(foodItem.name)
                            .font(.headline)
                        Text("\(formatted(foodItem.unitCalorie)) kcal / \(foodItem.unitLabel)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section("Miktar") {
                HStack {
                    Text(foodItem.unitLabel.capitalized)
                    Spacer()
                    TextField("1", text: $quantityText)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                }
                HStack {
                    Text("Toplam")
                        .fontWeight(.semibold)
                    Spacer()
                    Text("\(totalCalorie) kcal")
                        .fontWeight(.semibold)
                }
            }
        }
        .navigationTitle(foodItem.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Kaydet") {
                    save()
                }
                .disabled(totalCalorie <= 0)
            }
        }
    }

    private func save() {
        let entry = FoodEntry(
            date: Date(),
            calorie: totalCalorie,
            content: foodItem.name,
            imageData: foodItem.imageData,
            quantity: quantity,
            unitCalorie: foodItem.unitCalorie
        )
        modelContext.insert(entry)
        dismiss()
    }

    private func formatted(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", value)
            : String(format: "%.1f", value)
    }
}