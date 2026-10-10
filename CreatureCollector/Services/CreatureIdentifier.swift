import ImageIO
import UIKit
import Vision

/// What the on-device classifier thinks is in a photo.
struct CreatureGuess {
    let name: String
    let category: CreatureCategory
    let confidence: Float
    /// True when the classifier only knows the broad group (e.g. "Bird") rather than a specific animal.
    let isGeneral: Bool
}

/// Suggests a creature name using Apple's built-in Vision image classifier.
/// Everything runs on the device; no photos ever leave the phone.
enum CreatureIdentifier {
    private static let minimumConfidence: Float = 0.1

    static func identify(_ image: UIImage) async -> CreatureGuess? {
        guard let cgImage = image.cgImage else { return nil }
        let orientation = CGImagePropertyOrientation(image.imageOrientation)

        return await Task.detached(priority: .userInitiated) {
            let request = VNClassifyImageRequest()
            let handler = VNImageRequestHandler(cgImage: cgImage, orientation: orientation)
            do {
                try handler.perform([request])
            } catch {
                return nil
            }
            return bestGuess(from: request.results ?? [])
        }.value
    }

    private static func bestGuess(from observations: [VNClassificationObservation]) -> CreatureGuess? {
        let matches = observations
            .filter { $0.confidence >= minimumConfidence }
            .compactMap { observation -> CreatureGuess? in
                let key = observation.identifier.lowercased()
                if let category = specificAnimals[key] {
                    return CreatureGuess(name: prettyName(key), category: category, confidence: observation.confidence, isGeneral: false)
                }
                if let category = generalGroups[key] {
                    return CreatureGuess(name: category.shortName, category: category, confidence: observation.confidence, isGeneral: true)
                }
                return nil
            }
            .sorted { $0.confidence > $1.confidence }

        return matches.first { !$0.isGeneral } ?? matches.first
    }

    private static func prettyName(_ identifier: String) -> String {
        identifier.replacingOccurrences(of: "_", with: " ").capitalized
    }

    private static let generalGroups: [String: CreatureCategory] = [
        "animal": .other,
        "insect": .insect,
        "arachnid": .arachnid,
        "bird": .bird,
        "mammal": .mammal,
        "reptile": .reptile,
        "amphibian": .amphibian,
        "fish": .fish,
        "invertebrate": .other,
    ]

    private static let specificAnimals: [String: CreatureCategory] = {
        var table: [String: CreatureCategory] = [:]
        let groups: [CreatureCategory: [String]] = [
            .insect: [
                "ant", "bee", "beetle", "butterfly", "caterpillar", "cicada", "cricket", "dragonfly",
                "firefly", "fly", "grasshopper", "ladybug", "mantis", "praying_mantis", "mosquito",
                "moth", "wasp", "hornet", "termite", "cockroach", "bumblebee", "damselfly", "stick_insect",
            ],
            .arachnid: ["spider", "tarantula", "scorpion", "tick", "daddy_longlegs"],
            .bird: [
                "blue_jay", "cardinal", "chicken", "crow", "dove", "duck", "eagle", "falcon", "finch",
                "flamingo", "goose", "gull", "seagull", "hawk", "heron", "hummingbird", "owl", "parrot",
                "peacock", "pelican", "penguin", "pigeon", "raven", "robin", "rooster", "sparrow",
                "songbird", "swan", "toucan", "turkey", "vulture", "woodpecker", "ostrich", "cockatoo",
                "bluebird", "chickadee", "magpie", "starling",
            ],
            .mammal: [
                "bat", "bear", "beaver", "camel", "cat", "chipmunk", "cow", "cattle", "deer", "dog",
                "dolphin", "donkey", "elephant", "ferret", "fox", "giraffe", "goat", "gorilla",
                "guinea_pig", "hamster", "hedgehog", "hippopotamus", "horse", "kangaroo", "koala",
                "lion", "llama", "monkey", "moose", "mouse", "opossum", "otter", "panda", "pig",
                "rabbit", "bunny", "raccoon", "rat", "rhinoceros", "seal", "sheep", "skunk", "sloth",
                "squirrel", "tiger", "whale", "wolf", "zebra", "kitten", "puppy", "groundhog",
                "porcupine", "lamb", "alpaca", "polar_bear", "sea_lion", "leopard", "cheetah",
            ],
            .reptile: [
                "alligator", "crocodile", "gecko", "iguana", "lizard", "snake", "tortoise", "turtle",
                "chameleon", "komodo_dragon", "rattlesnake", "python",
            ],
            .amphibian: ["frog", "toad", "salamander", "newt", "tadpole", "axolotl"],
            .fish: [
                "goldfish", "shark", "salmon", "trout", "clownfish", "jellyfish", "octopus", "starfish",
                "sea_star", "crab", "lobster", "shrimp", "seahorse", "stingray", "eel", "koi", "squid",
                "angelfish", "pufferfish", "sea_urchin",
            ],
            .other: ["snail", "slug", "worm", "earthworm", "centipede", "millipede", "dinosaur"],
        ]
        for (category, names) in groups {
            for name in names { table[name] = category }
        }
        return table
    }()
}

extension CGImagePropertyOrientation {
    init(_ orientation: UIImage.Orientation) {
        switch orientation {
        case .up: self = .up
        case .upMirrored: self = .upMirrored
        case .down: self = .down
        case .downMirrored: self = .downMirrored
        case .left: self = .left
        case .leftMirrored: self = .leftMirrored
        case .right: self = .right
        case .rightMirrored: self = .rightMirrored
        @unknown default: self = .up
        }
    }
}
