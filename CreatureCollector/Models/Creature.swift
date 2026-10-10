import Foundation
import SwiftData

/// One creature a kid has caught on camera.
@Model
final class Creature {
    var name: String = ""
    var nickname: String = ""
    var categoryRawValue: String = CreatureCategory.other.rawValue
    var notes: String = ""
    var caughtAt: Date = Date()
    var isFavorite: Bool = false
    @Attribute(.externalStorage) var photoData: Data?
    var thumbnailData: Data?

    init(
        name: String,
        nickname: String = "",
        category: CreatureCategory,
        notes: String = "",
        caughtAt: Date = .now,
        photoData: Data?,
        thumbnailData: Data?
    ) {
        self.name = name
        self.nickname = nickname
        self.categoryRawValue = category.rawValue
        self.notes = notes
        self.caughtAt = caughtAt
        self.photoData = photoData
        self.thumbnailData = thumbnailData
    }

    var category: CreatureCategory {
        get { CreatureCategory(rawValue: categoryRawValue) ?? .other }
        set { categoryRawValue = newValue.rawValue }
    }

    var displayName: String {
        nickname.isEmpty ? name : nickname
    }

    /// A fun fact that stays the same for this creature every time it is viewed.
    var funFact: String {
        let facts = category.funFacts
        let seed = name.unicodeScalars.reduce(0) { $0 + Int($1.value) }
        return facts[seed % facts.count]
    }
}
