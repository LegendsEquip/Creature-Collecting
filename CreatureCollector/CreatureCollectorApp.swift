import SwiftData
import SwiftUI

@main
struct CreatureCollectorApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Creature.self)
    }
}
