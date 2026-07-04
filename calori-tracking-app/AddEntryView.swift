import SwiftUI
import SwiftData
import PhotosUI

struct AddEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var selectedPhoto: PhotosPickerItem?
    @State private var imageData: Data?
    @State private var content: String = ""
    @State private var quantityText: String = "1"
    @State private var unitCalorieText: String = ""

    private var quantity: Double {
        Double(quantityText.replacingOccurrences(of: ",", with: ".")) ?? 1
    }

    private var unitCalorie: Double {
        Double(unitCalorieText.replacingOccurrences(of: ",", with: ".")) ?? 0
    }

    private var totalCalorie: Int {
        Int((quantity * unitCalorie).rounded())
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
                                .frame(maxHeight: 200)
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
                                .padding(.vertical, 30)
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

                Section("İçerik") {
                    TextField("Örn: Karpuz", text: $content, axis: .vertical)
                        .lineLimit(2...4)
                }

                Section {
                    HStack {
                        Text("Adet / Miktar")
                        Spacer()
                        TextField("1", text: $quantityText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                    HStack {
                        Text("Birim başına kcal")
                        Spacer()
                        TextField("Örn: 20", text: $unitCalorieText)
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
                } header: {
                    Text("Miktar ve Kalori")
                } footer: {
                    Text("Basit girişte Adet'i 1 bırakıp direkt toplam kaloriyi 'birim başına kcal' alanına yazabilirsin. Örn: 4 dilim karpuz, dilim başına 20 kcal → 80 kcal.")
                }

                Section {
                    Text("Tarih ve saat otomatik eklenecek: \(Date().formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Yeni Kayıt")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kaydet") {
                        save()
                    }
                    .disabled(totalCalorie <= 0)
                }
            }
        }
    }

    private func save() {
        let entry = FoodEntry(
            date: Date(),
            calorie: totalCalorie,
            content: content,
            imageData: imageData,
            quantity: quantity,
            unitCalorie: unitCalorie
        )
        modelContext.insert(entry)
        dismiss()
    }
}
