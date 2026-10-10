# Creature Catcher 🐞📸

An iPhone app for kids to go on creature hunts: snap photos of animals and bugs they find,
and build up a personal collection, kind of like a real-life Pokédex.

## Features

- **Catch with the camera**: take a photo with the iPhone camera, or pick one from the photo library.
- **Automatic name suggestions**: Apple's on-device Vision classifier guesses what the creature is
  ("I think it's a Butterfly!"). Kids can always change the name.
- **Collection grid**: colorful cards grouped by kind (Bugs, Spiders, Birds, Mammals, Reptiles,
  Amphibians, Fish, Other), with filters, favorites and collection stats.
- **Creature pages**: big photo, date caught, nickname, notes and a fun fact about that kind of animal.
- **Badges**: 13 achievements such as *First Catch*, *Bug Hunter*, *Bird Watcher* and *Variety Pack*,
  with progress bars. A confetti "Gotcha!" screen celebrates each catch and any new badges.
- **Private by design**: no accounts, no network calls, no ads. Photos and data stay on the device
  (stored with SwiftData).

## Requirements

- A Mac with **Xcode 16 or newer**
- iOS **17.0+** (iPhone)

## Running it

1. Open `CreatureCollector.xcodeproj` in Xcode.
2. Select the **CreatureCollector** target → **Signing & Capabilities** → choose your Team
   (a free Apple ID works for running on your own phone).
   If Xcode complains about the bundle identifier, change `com.legendsequip.CreatureCollector` to something unique.
3. Plug in an iPhone (or pick a simulator) and press **Run** (⌘R).

> The simulator has no camera, so use **Choose from Photos** there. Use a real iPhone to try the camera.

## Project layout

```
CreatureCollector/
├── CreatureCollectorApp.swift     App entry point + SwiftData container
├── Models/
│   ├── Creature.swift             The saved creature (SwiftData model)
│   ├── CreatureCategory.swift     Kinds of creatures, emoji, colors, fun facts
│   └── Badge.swift                Badge definitions and collection stats
├── Services/
│   └── CreatureIdentifier.swift   On-device animal recognition (Vision)
├── Utilities/
│   └── ImageResizing.swift        Photo resizing helpers
└── Views/
    ├── ContentView.swift          Tab bar: Collection / Catch / Badges
    ├── CatchView.swift            Camera & photo-library entry point
    ├── CameraPicker.swift         System camera wrapper
    ├── NameCreatureView.swift     Name, kind, nickname and notes before saving
    ├── CelebrationView.swift      "Gotcha!" screen with emoji confetti
    ├── CollectionView.swift       The collection grid
    ├── CreatureDetailView.swift   A single creature's page
    └── BadgesView.swift           Achievements
```

## Ideas for later

- iCloud sync between a family's devices
- A "Creature of the Day" challenge
- Map of where each creature was found (opt-in, parent-controlled)
- More detailed species identification using a dedicated wildlife model
