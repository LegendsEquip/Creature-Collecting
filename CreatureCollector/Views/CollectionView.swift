import SwiftData
import SwiftUI

struct CollectionView: View {
    var onCatchTapped: () -> Void

    @Query(sort: \Creature.caughtAt, order: .reverse) private var creatures: [Creature]
    @State private var selectedCategory: CreatureCategory?
    @State private var favoritesOnly = false

    private let columns = [GridItem(.adaptive(minimum: 150), spacing: 16)]

    private var visibleCreatures: [Creature] {
        creatures.filter { creature in
            (selectedCategory == nil || creature.category == selectedCategory)
                && (!favoritesOnly || creature.isFavorite)
        }
    }

    private var categoriesInCollection: [CreatureCategory] {
        CreatureCategory.allCases.filter { category in creatures.contains { $0.category == category } }
    }

    var body: some View {
        NavigationStack {
            Group {
                if creatures.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            summary
                            filterBar
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(visibleCreatures) { creature in
                                    NavigationLink(value: creature) {
                                        CreatureCard(creature: creature)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("My Collection")
            .navigationDestination(for: Creature.self) { creature in
                CreatureDetailView(creature: creature)
            }
            .toolbar {
                if !creatures.isEmpty {
                    Button {
                        favoritesOnly.toggle()
                    } label: {
                        Image(systemName: favoritesOnly ? "heart.fill" : "heart")
                    }
                    .tint(.pink)
                    .accessibilityLabel(favoritesOnly ? "Show all creatures" : "Show favorites only")
                }
            }
        }
    }

    private var summary: some View {
        let stats = CollectionStats(creatures: creatures)
        return HStack(spacing: 12) {
            StatTile(value: stats.total, label: "Caught", emoji: "📸")
            StatTile(value: stats.uniqueNames, label: "Different", emoji: "🔎")
            StatTile(value: stats.kinds, label: "Kinds", emoji: "🌈")
        }
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(title: "All", isSelected: selectedCategory == nil, color: .accentColor) {
                    selectedCategory = nil
                }
                ForEach(categoriesInCollection) { category in
                    FilterChip(
                        title: "\(category.emoji) \(category.shortName)",
                        isSelected: selectedCategory == category,
                        color: category.color
                    ) {
                        selectedCategory = selectedCategory == category ? nil : category
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No Creatures Yet", systemImage: "binoculars.fill")
        } description: {
            Text("Head outside and look for birds, bugs, squirrels and more. Every photo you take goes here!")
        } actions: {
            Button("Start Catching", action: onCatchTapped)
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .controlSize(.large)
        }
    }
}

struct CreatureCard: View {
    let creature: Creature

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                CreaturePhoto(data: creature.thumbnailData, category: creature.category)
                    .frame(height: 150)
                    .frame(maxWidth: .infinity)
                    .clipped()

                if creature.isFavorite {
                    Image(systemName: "heart.fill")
                        .foregroundStyle(.pink)
                        .padding(8)
                        .background(.thinMaterial, in: Circle())
                        .padding(8)
                }
            }

            HStack(spacing: 6) {
                Text(creature.category.emoji)
                VStack(alignment: .leading, spacing: 0) {
                    Text(creature.displayName)
                        .font(.headline)
                        .lineLimit(1)
                    Text(creature.caughtAt, format: .dateTime.month().day())
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 0)
            }
            .padding(10)
        }
        .background(creature.category.color.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(creature.category.color.opacity(0.5), lineWidth: 2))
    }
}

/// Shows a stored photo, or the category emoji if the photo is missing.
struct CreaturePhoto: View {
    let data: Data?
    let category: CreatureCategory

    var body: some View {
        if let data, let image = UIImage(data: data) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
        } else {
            ZStack {
                category.color.opacity(0.2)
                Text(category.emoji).font(.system(size: 60))
            }
        }
    }
}

private struct StatTile: View {
    let value: Int
    let label: String
    let emoji: String

    var body: some View {
        VStack(spacing: 2) {
            Text(emoji)
            Text("\(value)")
                .font(.title.bold())
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color.secondary.opacity(0.12), in: RoundedRectangle(cornerRadius: 16))
    }
}

private struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? color : color.opacity(0.15), in: Capsule())
                .foregroundStyle(isSelected ? Color.white : Color.primary)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    CollectionView(onCatchTapped: {})
        .modelContainer(for: Creature.self, inMemory: true)
}
