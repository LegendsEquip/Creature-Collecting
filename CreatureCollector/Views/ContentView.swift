import SwiftData
import SwiftUI

enum AppTab: Hashable {
    case collection
    case catchCreature
    case badges
}

struct ContentView: View {
    @State private var selectedTab: AppTab = .catchCreature

    var body: some View {
        TabView(selection: $selectedTab) {
            CollectionView(onCatchTapped: { selectedTab = .catchCreature })
                .tabItem { Label("Collection", systemImage: "square.grid.2x2.fill") }
                .tag(AppTab.collection)

            CatchView(onFinished: { selectedTab = .collection })
                .tabItem { Label("Catch", systemImage: "camera.fill") }
                .tag(AppTab.catchCreature)

            BadgesView()
                .tabItem { Label("Badges", systemImage: "rosette") }
                .tag(AppTab.badges)
        }
        .fontDesign(.rounded)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Creature.self, inMemory: true)
}
