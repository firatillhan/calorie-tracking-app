import SwiftUI
import SwiftData

struct DetailView: View {
    @Bindable var entry: FoodEntry
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var isEditing = false
    @State private var calorieText: String = ""
    @State private var contentText: String = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let data = entry.imageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                VStack(alignment: .leading, spacing: 8) {
                    Label(entry.date.formatted(date: .long, time: .shortened), systemImage: "clock")
                        .foregroundStyle(.secondary)

                    if isEditing {
                        TextField("Kalori", text: $calorieText)
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)
                        TextField("İçerik", text: $contentText, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                    } else {
                        Text("\(entry.calorie) kcal")
                            .font(.title.bold())

                        if !entry.content.isEmpty {
                            Text(entry.content)
                                .font(.body)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("Detay")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(isEditing ? "Kaydet" : "Düzenle") {
                    if isEditing {
                        entry.calorie = Int(calorieText) ?? entry.calorie
                        entry.content = contentText
                    } else {
                        calorieText = "\(entry.calorie)"
                        contentText = entry.content
                    }
                    isEditing.toggle()
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button(role: .destructive) {
                    modelContext.delete(entry)
                    dismiss()
                } label: {
                    Image(systemName: "trash")
                }
            }
        }
    }
}
