import SwiftData
import SwiftUI

struct BadgesView: View {
    @Query private var creatures: [Creature]

    private let columns = [GridItem(.adaptive(minimum: 150), spacing: 16)]

    var body: some View {
        let stats = CollectionStats(creatures: creatures)
        let earnedCount = Badge.all.filter { $0.isEarned(with: stats) }.count

        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 6) {
                        Text("\(earnedCount) of \(Badge.all.count)")
                            .font(.largeTitle.bold())
                        Text("badges earned")
                            .foregroundStyle(.secondary)
                        ProgressView(value: Double(earnedCount), total: Double(Badge.all.count))
                            .tint(.yellow)
                            .padding(.horizontal, 40)
                    }

                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(Badge.all) { badge in
                            BadgeTile(badge: badge, stats: stats)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Badges")
        }
    }
}

private struct BadgeTile: View {
    let badge: Badge
    let stats: CollectionStats

    var body: some View {
        let earned = badge.isEarned(with: stats)
        let progress = min(badge.progress(stats), badge.goal)

        VStack(spacing: 8) {
            Text(badge.emoji)
                .font(.system(size: 52))
                .grayscale(earned ? 0 : 1)
                .opacity(earned ? 1 : 0.4)
            Text(badge.title)
                .font(.headline)
            Text(badge.detail)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            if earned {
                Label("Earned!", systemImage: "checkmark.seal.fill")
                    .font(.caption.bold())
                    .foregroundStyle(.green)
            } else {
                ProgressView(value: Double(progress), total: Double(badge.goal))
                Text("\(progress) / \(badge.goal)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 190)
        .padding(12)
        .background(earned ? Color.yellow.opacity(0.2) : Color.secondary.opacity(0.08), in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(earned ? Color.yellow : .clear, lineWidth: 2))
    }
}

#Preview {
    BadgesView()
        .modelContainer(for: Creature.self, inMemory: true)
}
