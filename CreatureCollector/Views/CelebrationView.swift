import SwiftUI

/// The "Gotcha!" screen shown after a creature is added.
struct CelebrationView: View {
    let result: CatchResult
    var onDone: () -> Void

    @State private var appeared = false

    private var creature: Creature { result.creature }

    var body: some View {
        ZStack {
            Color.black.opacity(0.45)
                .ignoresSafeArea()
                .onTapGesture(perform: onDone)

            ConfettiView(symbols: [creature.category.emoji, "⭐️", "🎉", "✨"])

            VStack(spacing: 16) {
                if let data = creature.thumbnailData, let image = UIImage(data: data) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 140, height: 140)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(creature.category.color, lineWidth: 6))
                }

                Text("Gotcha!")
                    .font(.system(size: 44, weight: .heavy, design: .rounded))

                Text("You caught \(creature.name.withIndefiniteArticle)!")
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)

                ForEach(result.newBadges) { badge in
                    Label {
                        Text("New badge: \(badge.title)")
                            .font(.headline)
                    } icon: {
                        Text(badge.emoji)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(.yellow.opacity(0.3), in: Capsule())
                }

                Button(action: onDone) {
                    Text("Awesome!")
                        .font(.title3.bold())
                        .frame(maxWidth: .infinity, minHeight: 50)
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .padding(.top, 8)
            }
            .padding(28)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 32))
            .padding(32)
            .scaleEffect(appeared ? 1 : 0.4)
            .opacity(appeared ? 1 : 0)
        }
        .fontDesign(.rounded)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                appeared = true
            }
        }
    }
}

/// Emoji confetti that rains down once.
struct ConfettiView: View {
    let symbols: [String]

    @State private var pieces = (0..<40).map(ConfettiPiece.init)
    @State private var falling = false

    var body: some View {
        GeometryReader { geometry in
            ForEach(pieces) { piece in
                Text(symbols[piece.id % symbols.count])
                    .font(.system(size: piece.size))
                    .rotationEffect(.degrees(falling ? piece.spin : 0))
                    .position(
                        x: piece.x * geometry.size.width,
                        y: falling ? geometry.size.height + 80 : -80
                    )
                    .animation(.easeIn(duration: piece.duration).delay(piece.delay), value: falling)
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .onAppear { falling = true }
    }
}

struct ConfettiPiece: Identifiable {
    let id: Int
    let x = CGFloat.random(in: 0...1)
    let size = CGFloat.random(in: 20...40)
    let spin = Double.random(in: -360...360)
    let duration = Double.random(in: 2...3.5)
    let delay = Double.random(in: 0...0.8)

    init(id: Int) {
        self.id = id
    }
}
