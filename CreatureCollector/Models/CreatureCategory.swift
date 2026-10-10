import SwiftUI

/// The broad kinds of creatures a kid can collect.
enum CreatureCategory: String, CaseIterable, Codable, Identifiable {
    case insect
    case arachnid
    case bird
    case mammal
    case reptile
    case amphibian
    case fish
    case other

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .insect: "Bugs & Insects"
        case .arachnid: "Spiders"
        case .bird: "Birds"
        case .mammal: "Mammals"
        case .reptile: "Reptiles"
        case .amphibian: "Amphibians"
        case .fish: "Fish & Sea Life"
        case .other: "Other Critters"
        }
    }

    var shortName: String {
        switch self {
        case .insect: "Bug"
        case .arachnid: "Spider"
        case .bird: "Bird"
        case .mammal: "Mammal"
        case .reptile: "Reptile"
        case .amphibian: "Amphibian"
        case .fish: "Fish"
        case .other: "Critter"
        }
    }

    var emoji: String {
        switch self {
        case .insect: "🐞"
        case .arachnid: "🕷️"
        case .bird: "🐦"
        case .mammal: "🦊"
        case .reptile: "🦎"
        case .amphibian: "🐸"
        case .fish: "🐟"
        case .other: "🐾"
        }
    }

    var color: Color {
        switch self {
        case .insect: .orange
        case .arachnid: .purple
        case .bird: .blue
        case .mammal: .brown
        case .reptile: .green
        case .amphibian: .mint
        case .fish: .cyan
        case .other: .gray
        }
    }

    var funFacts: [String] {
        switch self {
        case .insect:
            [
                "Every insect has six legs and three body parts: head, thorax and abdomen.",
                "There are more kinds of beetles than any other animal on Earth!",
                "Butterflies taste with their feet.",
            ]
        case .arachnid:
            [
                "Spiders have eight legs, so they aren't insects!",
                "Spider silk is stronger than steel of the same thickness.",
                "Most spiders have eight eyes.",
            ]
        case .bird:
            [
                "Birds are the only animals with feathers.",
                "Birds have hollow bones that help them fly.",
                "Hummingbirds can fly backwards!",
            ]
        case .mammal:
            [
                "Mammals have hair or fur and drink milk when they are babies.",
                "Bats are the only mammals that can really fly.",
                "A squirrel can find nuts it buried months ago by smell.",
            ]
        case .reptile:
            [
                "Reptiles have dry, scaly skin.",
                "Reptiles warm up by lying in the sun.",
                "Some lizards can drop their tail to escape and grow a new one!",
            ]
        case .amphibian:
            [
                "Amphibians start life in water and many move onto land later.",
                "Frogs can breathe through their skin.",
                "A group of frogs is called an army!",
            ]
        case .fish:
            [
                "Fish breathe underwater using gills.",
                "Some fish can change color to hide.",
                "Fish have been on Earth for over 500 million years.",
            ]
        case .other:
            [
                "Scientists discover thousands of new animal species every year.",
                "Snails can sleep for up to three years!",
                "Earthworms have five hearts.",
            ]
        }
    }
}
