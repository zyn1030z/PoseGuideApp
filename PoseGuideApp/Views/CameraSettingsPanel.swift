import SwiftUI

struct CameraSettingsPanel: View {
    @ObservedObject var viewModel: CameraViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            header
            timerPicker
            flashPicker
            gridToggle
            zoomControl
        }
        .padding(18)
        .glassCard(cornerRadius: 28)
    }

    private var header: some View {
        HStack {
            Label("Tuỳ chỉnh camera", systemImage: "slider.horizontal.3")
                .font(.headline.bold())
                .foregroundStyle(.white)
            Spacer()
        }
    }

    private var timerPicker: some View {
        settingRow(title: "Hẹn giờ", icon: "timer") {
            HStack(spacing: 8) {
                ForEach(CameraSettings.TimerMode.allCases, id: \.self) { mode in
                    Button(mode.rawValue) {
                        viewModel.updateTimer(mode)
                    }
                    .buttonStyle(ChipButtonStyle(isSelected: viewModel.settings.timer == mode))
                }
            }
        }
    }

    private var flashPicker: some View {
        settingRow(title: "Flash", icon: "bolt.fill") {
            HStack(spacing: 8) {
                ForEach(CameraSettings.FlashMode.allCases, id: \.self) { mode in
                    Button(mode.rawValue) {
                        viewModel.updateFlash(mode)
                    }
                    .buttonStyle(ChipButtonStyle(isSelected: viewModel.settings.flash == mode))
                }
            }
        }
    }

    private var gridToggle: some View {
        settingRow(title: "Lưới căn khung", icon: "grid") {
            Toggle("", isOn: Binding(
                get: { viewModel.settings.grid },
                set: { viewModel.updateGrid($0) }
            ))
            .labelsHidden()
            .tint(.white)
        }
    }

    private var zoomControl: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Zoom", systemImage: "plus.magnifyingglass")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                Spacer()
                Text(String(format: "%.1fx", viewModel.settings.zoom))
                    .font(.caption.monospacedDigit().bold())
                    .foregroundStyle(.white.opacity(0.78))
            }

            Slider(
                value: Binding(
                    get: { Double(viewModel.settings.zoom) },
                    set: { viewModel.updateZoom(CGFloat($0)) }
                ),
                in: 1...5,
                step: 0.1
            )
            .tint(.white)
        }
    }

    private func settingRow<Content: View>(title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        HStack(spacing: 12) {
            Label(title, systemImage: icon)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
            Spacer()
            content()
        }
    }
}

struct ChipButtonStyle: ButtonStyle {
    let isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.caption.weight(.bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? .white.opacity(0.28) : .white.opacity(0.10), in: Capsule())
            .overlay {
                Capsule().stroke(.white.opacity(isSelected ? 0.44 : 0.18), lineWidth: 1)
            }
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(response: 0.24, dampingFraction: 0.78), value: configuration.isPressed)
    }
}
