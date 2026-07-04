import SwiftUI
import SwiftData
import PhotosUI

struct AddFoodItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var selectedPhoto: PhotosPickerItem?
    @State private var imageData: Data?
    @State private var name: String = ""
    @State private var unitCalorieText: String = ""
    @State private var unitLabel: String = "adet"

    private var unitCalorie: Double {
        Double(unitCalorieText.replacingOccurrences(of: ",", with: ".")) ?? 0
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        if let imageData, let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 160)
                                .frame(maxWidth: .infinity)
                        } else {
                            HStack {
                                Spacer()
                                VStack(spacing: 8) {
                                    Image(systemName: "camera.fill")
                                        .font(.largeTitle)
                                    Text("Fotoğraf Seç")
                                }
                                .foregroundStyle(.secondary)
                                .padding(.vertical, 24)
                                Spacer()
                            }
                        }
                    }
                    .onChange(of: selectedPhoto) { _, newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                imageData = data
                            }
                        }
                    }
                }

                Section("Bilgiler") {
                    TextField("Yiyecek adı (Örn: Karpuz)", text: $name)
                    HStack {
                        Text("Birim")
                        Spacer()
                        TextField("adet / dilim / porsiyon", text: $unitLabel)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Birim başına kcal")
                        Spacer()
                        TextField("Örn: 20", text: $unitCalorieText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                }
            }
            .navigationTitle("Yeni Yiyecek")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kaydet") {
                        save()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty || unitCalorie <= 0)
                }
            }
        }
    }

    private func save() {
        let item = FoodItem(
            name: name.trimmingCharacters(in: .whitespaces),
            imageData: imageData,
            unitCalorie: unitCalorie,
            unitLabel: unitLabel.trimmingCharacters(in: .whitespaces).isEmpty ? "adet" : unitLabel
        )
        modelContext.insert(item)
        dismiss()
    }
}