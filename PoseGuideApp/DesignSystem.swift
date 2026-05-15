import SwiftUI

enum PoseGuideTheme {
    static let primary = Color(red: 0.45, green: 0.35, blue: 0.95)
    static let secondary = Color(red: 0.95, green: 0.36, blue: 0.72)
    static let cyan = Color(red: 0.28, green: 0.78, blue: 0.96)
    static let ink = Color(red: 0.08, green: 0.08, blue: 0.16)

    static let appGradient = LinearGradient(
        colors: [
            Color(red: 0.16, green: 0.12, blue: 0.38),
            Color(red: 0.36, green: 0.23, blue: 0.78),
            Color(red: 0.95, green: 0.40, blue: 0.70)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let accentGradient = LinearGradient(
        colors: [primary, secondary],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let cameraTopScrim = LinearGradient(
        colors: [.black.opacity(0.62), .black.opacity(0)],
        startPoint: .top,
        endPoint: .bottom
    )

    static let cameraBottomScrim = LinearGradient(
        colors: [.black.opacity(0), .black.opacity(0.72)],
        startPoint: .top,
        endPoint: .bottom
    )
}

extension View {
    func glassCard(cornerRadius: CGFloat = 28) -> some View {
        self
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(.white.opacity(0.28), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.16), radius: 24, x: 0, y: 14)
    }

    func softCard(cornerRadius: CGFloat = 28) -> some View {
        self
            .background(.white.opacity(0.14), in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(.white.opacity(0.22), lineWidth: 1)
            }
    }
}
