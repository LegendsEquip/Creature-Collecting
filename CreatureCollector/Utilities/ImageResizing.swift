import UIKit

extension UIImage {
    /// Returns a copy no larger than `maxDimension` on its longest side, with orientation baked in.
    func resized(maxDimension: CGFloat) -> UIImage {
        let longestSide = max(size.width, size.height)
        let scale = min(1, maxDimension / longestSide)
        let newSize = CGSize(width: (size.width * scale).rounded(), height: (size.height * scale).rounded())

        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        return UIGraphicsImageRenderer(size: newSize, format: format).image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}

extension String {
    /// "a Butterfly" / "an Ant"
    var withIndefiniteArticle: String {
        guard let first = lowercased().first else { return self }
        return ("aeiou".contains(first) ? "an " : "a ") + self
    }
}
