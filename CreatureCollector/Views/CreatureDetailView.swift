import SwiftData
import SwiftUI

struct CreatureDetailView: View {
    @Bindable var creature: Creature

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var confirmingRelease = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                CreaturePhoto(data: creature.photoData ?? creature.thumbnailData, category: creature.category)
                    .frame(maxWidth: .infinity)
                    .frame(height: 340)
                    .clipShape(RoundedRectangle(cornerRadius: 24))

                VStack(alignment: .leading, spacing: 6) {
                    Text(creature.name)
                        .font(.largeTitle.bold())
                    Text("\(creature.category.emoji) \(creature.category.displayName)")
                        .font(.headline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(creature.category.color.opacity(0.2), in: Capsule())
                    Label {
                        Text("Caught \(creature.caughtAt, format: .dateTime.weekday(.wide).month(.wide).day().year())")
                    } icon: {
                        Image(systemName: "calendar")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("💡 Fun Fact")
                        .font(.headline)
                    Text(creature.funFact)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(.yellow.opacity(0.2), in: RoundedRectangle(cornerRadius: 16))

                VStack(alignment: .leading, spacing: 8) {
                    Text("Nickname")
                        .font(.headline)
                    TextField("Give it a fun name", text: $creature.nickname)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.words)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("My Notes")
                        .font(.headline)
                    TextField("Where did you see it? What was it doing?", text: $creature.notes, axis: .vertical)
                        .lineLimit(3...8)
                        .textFieldStyle(.roundedBorder)
                }
            }
            .padding()
        }
        .navigationTitle(creature.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    creature.isFavorite.toggle()
                } label: {
                    Image(systemName: creature.isFavorite ? "heart.fill" : "heart")
                }
                .tint(.pink)
                .accessibilityLabel(creature.isFavorite ? "Remove from favorites" : "Add to favorites")

                Menu {
                    Button("Release Creature", systemImage: "leaf", role: .destructive) {
                        confirmingRelease = true
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .confirmationDialog(
            "Release \(creature.displayName)?",
            isPresented: $confirmingRelease,
            titleVisibility: .visible
        ) {
            Button("Release", role: .destructive) {
                modelContext.delete(creature)
                dismiss()
            }
        } message: {
            Text("This removes it from your collection for good.")
        }
    }
}
