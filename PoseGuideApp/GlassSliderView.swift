import SwiftUI

struct GlassSliderView: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let title: String

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text(title)
                    .font(.caption.weight(.semibold))
                Spacer()
                Text("\(Int(value * 100))%")
                    .font(.caption.monospacedDigit().weight(.bold))
            }
            .foregroundStyle(.white)

            Slider(value: $value, in: range)
                .tint(.white)
        }
        .padding(16)
        .glassCard(cornerRadius: 20)
    }
}
