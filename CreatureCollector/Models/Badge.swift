import Foundation

/// Totals used to work out which badges have been earned.
struct CollectionStats {
    let total: Int
    let uniqueNames: Int
    let kinds: Int
    private let byCategory: [CreatureCategory: Int]

    init(creatures: [Creature]) {
        total = creatures.count
        uniqueNames = Set(creatures.map { $0.name.trimmingCharacters(in: .whitespaces).lowercased() }).count
        byCategory = Dictionary(grouping: creatures, by: \.category).mapValues(\.count)
        kinds = byCategory.keys.filter { $0 != .other }.count
    }

    func count(of category: CreatureCategory) -> Int {
        byCategory[category, default: 0]
    }
}

struct Badge: Identifiable {
    let id: String
    let emoji: String
    let title: String
    let detail: String
    let goal: Int
    let progress: (CollectionStats) -> Int

    func isEarned(with stats: CollectionStats) -> Bool {
        progress(stats) >= goal
    }

    static let all: [Badge] = [
        Badge(id: "first", emoji: "🎉", title: "First Catch", detail: "Catch your very first creature", goal: 1) { $0.total },
        Badge(id: "explorer", emoji: "🧭", title: "Explorer", detail: "Catch 5 creatures", goal: 5) { $0.total },
        Badge(id: "naturalist", emoji: "🔬", title: "Naturalist", detail: "Catch 15 creatures", goal: 15) { $0.total },
        Badge(id: "scientist", emoji: "🏆", title: "Super Scientist", detail: "Catch 30 creatures", goal: 30) { $0.total },
        Badge(id: "sleuth", emoji: "🔎", title: "Species Sleuth", detail: "Find 10 different creatures", goal: 10) { $0.uniqueNames },
        Badge(id: "variety", emoji: "🌈", title: "Variety Pack", detail: "Find 5 different kinds of animals", goal: 5) { $0.kinds },
        Badge(id: "bugs", emoji: "🐞", title: "Bug Hunter", detail: "Catch 5 bugs", goal: 5) { $0.count(of: .insect) },
        Badge(id: "birds", emoji: "🦉", title: "Bird Watcher", detail: "Catch 5 birds", goal: 5) { $0.count(of: .bird) },
        Badge(id: "mammals", emoji: "🐿️", title: "Furry Friends", detail: "Catch 5 mammals", goal: 5) { $0.count(of: .mammal) },
        Badge(id: "spiders", emoji: "🕸️", title: "Spider Spotter", detail: "Catch 3 spiders", goal: 3) { $0.count(of: .arachnid) },
        Badge(id: "reptiles", emoji: "🐢", title: "Scale Seeker", detail: "Catch 3 reptiles", goal: 3) { $0.count(of: .reptile) },
        Badge(id: "amphibians", emoji: "🐸", title: "Frog Finder", detail: "Catch 3 amphibians", goal: 3) { $0.count(of: .amphibian) },
        Badge(id: "fish", emoji: "🐠", title: "Fish Friend", detail: "Catch 3 fish or sea creatures", goal: 3) { $0.count(of: .fish) },
    ]

    /// Badges earned by `after` that were not yet earned by `before`.
    static func newlyEarned(before: CollectionStats, after: CollectionStats) -> [Badge] {
        all.filter { !$0.isEarned(with: before) && $0.isEarned(with: after) }
    }
}
