import SwiftUI
import SwiftData

struct FoodLibraryView: View {
    @Query(sort: \FoodItem.name) private var foodItems: [FoodItem]
    @State private var showingAddFood = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(foodItems) { item in
                    NavigationLink(destination: FoodQuantityView(foodItem: item)) {
                        HStack {
                            if let data = item.imageData, let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 44, height: 44)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            } else {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(.systemGray5))
                                    .frame(width: 44, height: 44)
                                    .overlay(Image(systemName: "fork.knife").foregroundStyle(.secondary))
                            }
                            VStack(alignment: .leading) {
                                Text(item.name)
                                    .font(.subheadline.bold())
                                Text("\(Int(item.unitCalorie)) kcal / \(item.unitLabel)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Yiyecek Listesi")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddFood = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddFood) {
                AddFoodItemView()
            }
            .overlay {
                if foodItems.isEmpty {
                    ContentUnavailableView(
                        "Liste Boş",
                        systemImage: "fork.knife",
                        description: Text("Sağ üstteki + ile yeni yiyecek ekleyebilirsin.")
                    )
                }
            }
        }
    }
}