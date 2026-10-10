import SwiftData
import SwiftUI

/// Shown after a photo is taken: suggests a name and lets the kid edit it before saving.
struct NameCreatureView: View {
    let photo: UIImage
    var onSaved: (CatchResult) -> Void

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var creatures: [Creature]

    @State private var name = ""
    @State private var nickname = ""
    @State private var category: CreatureCategory = .other
    @State private var notes = ""
    @State private var isIdentifying = true
    @State private var guess: CreatureGuess?

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var alreadyCaughtCount: Int {
        guard !trimmedName.isEmpty else { return 0 }
        return creatures.filter { $0.name.caseInsensitiveCompare(trimmedName) == .orderedSame }.count
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Image(uiImage: photo)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    identificationMessage
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())

                Section("What did you find?") {
                    TextField("Creature name, like Ladybug", text: $name)
                        .font(.title3)
                        .textInputAutocapitalization(.words)
                    Picker("Kind", selection: $category) {
                        ForEach(CreatureCategory.allCases) { kind in
                            Text("\(kind.emoji) \(kind.shortName)").tag(kind)
                        }
                    }
                }

                Section("Nickname (optional)") {
                    TextField("Give it a fun name, like Sir Hops-a-Lot", text: $nickname)
                        .textInputAutocapitalization(.words)
                }

                Section("Notes (optional)") {
                    TextField("Where did you see it? What was it doing?", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }

                if alreadyCaughtCount > 0 {
                    Section {
                        Label(
                            "You already have \(alreadyCaughtCount) \(trimmedName). This one makes \(alreadyCaughtCount + 1)!",
                            systemImage: "sparkles"
                        )
                        .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("New Creature!")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .safeAreaInset(edge: .bottom) {
                Button(action: save) {
                    Text("Add to My Collection!")
                        .font(.title3.bold())
                        .frame(maxWidth: .infinity, minHeight: 56)
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .disabled(trimmedName.isEmpty)
                .padding()
                .background(.bar)
            }
            .task { await identify() }
        }
    }

    @ViewBuilder
    private var identificationMessage: some View {
        Group {
            if isIdentifying {
                HStack(spacing: 10) {
                    ProgressView()
                    Text("Looking closely…")
                }
            } else if let guess, guess.isGeneral {
                Text("It looks like \(guess.name.lowercased().withIndefiniteArticle)! Do you know what kind? \(guess.category.emoji)")
            } else if let guess {
                Text("I think it's \(guess.name.withIndefiniteArticle)! \(guess.category.emoji) You can change the name if I got it wrong.")
            } else {
                Text("Hmm, I'm not sure what this is. 🤔 Can you name it?")
            }
        }
        .font(.headline)
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }

    private func identify() async {
        let result = await CreatureIdentifier.identify(photo)
        guess = result
        if let result, trimmedName.isEmpty {
            name = result.name
            category = result.category
        }
        isIdentifying = false
    }

    private func save() {
        let fullSize = photo.resized(maxDimension: 1600)
        let thumbnail = photo.resized(maxDimension: 400)
        let creature = Creature(
            name: trimmedName,
            nickname: nickname.trimmingCharacters(in: .whitespacesAndNewlines),
            category: category,
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
            photoData: fullSize.jpegData(compressionQuality: 0.8),
            thumbnailData: thumbnail.jpegData(compressionQuality: 0.7)
        )

        let statsBefore = CollectionStats(creatures: creatures)
        let statsAfter = CollectionStats(creatures: creatures + [creature])
        let newBadges = Badge.newlyEarned(before: statsBefore, after: statsAfter)

        modelContext.insert(creature)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        onSaved(CatchResult(creature: creature, newBadges: newBadges))
        dismiss()
    }
}
