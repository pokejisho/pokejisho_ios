import SwiftUI
import UIKit
import VisionKit

/// Displays `image` and overlays VisionKit Live Text selection using the
/// caller-provided `interaction`, so the caller can read `interaction.selectedText`.
struct LiveTextImageView: UIViewRepresentable {
    let image: UIImage
    let interaction: ImageAnalysisInteraction

    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.addInteraction(interaction)
        interaction.preferredInteractionTypes = .textSelection

        let analyzer = ImageAnalyzer()
        let configuration = ImageAnalyzer.Configuration([.text])
        let interaction = self.interaction
        Task {
            if let analysis = try? await analyzer.analyze(image, configuration: configuration) {
                interaction.analysis = analysis
            }
        }
        return imageView
    }

    func updateUIView(_ uiView: UIImageView, context: Context) {}
}
