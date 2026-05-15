import SwiftUI

struct CameraView: View {
    let sampleImage: UIImage

    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = CameraViewModel()
    @State private var overlayOpacity = 0.35
    @State private var isShowingCapturePreview = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if viewModel.permissionDenied {
                permissionView
            } else {
                CameraPreviewView(session: viewModel.session)
                    .ignoresSafeArea()

                scrims

                Image(uiImage: sampleImage)
                    .resizable()
                    .scaledToFit()
                    .opacity(overlayOpacity)
                    .padding(.horizontal, 12)
                    .allowsHitTesting(false)

                controls
            }
        }
        .task {
            viewModel.requestPermissionAndConfigure()
        }
        .onDisappear {
            viewModel.stopSession()
        }
        .onChange(of: viewModel.capturedImage) { image in
            isShowingCapturePreview = image != nil
        }
        .navigationDestination(isPresented: $isShowingCapturePreview) {
            if let image = viewModel.capturedImage {
                CapturePreviewView(capturedImage: image) {
                    viewModel.clearCapture()
                    isShowingCapturePreview = false
                } goHome: {
                    dismiss()
                }
                .navigationBarBackButtonHidden()
            }
        }
        .alert("Lỗi camera", isPresented: Binding(get: { viewModel.errorMessage != nil }, set: { if !$0 { viewModel.errorMessage = nil } })) {
            Button("OK", role: .cancel) { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private var scrims: some View {
        VStack(spacing: 0) {
            PoseGuideTheme.cameraTopScrim
                .frame(height: 180)
            Spacer()
            PoseGuideTheme.cameraBottomScrim
                .frame(height: 300)
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    private var controls: some View {
        VStack(spacing: 0) {
            topBar
                .padding(.horizontal, 20)
                .padding(.top, 14)

            Spacer()

            bottomPanel
                .padding(.horizontal, 20)
                .padding(.bottom, 28)
        }
    }

    private var topBar: some View {
        HStack(spacing: 12) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
            }
            .buttonStyle(CircularGlassButtonStyle())

            VStack(alignment: .leading, spacing: 2) {
                Text("Camera")
                    .font(.headline.bold())
                    .foregroundStyle(.white)
                Text(viewModel.isSessionReady ? "Overlay đang bật" : "Đang khởi tạo")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white.opacity(0.72))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .glassCard(cornerRadius: 18)

            Spacer()

            Button {
                viewModel.switchCamera()
            } label: {
                Image(systemName: "camera.rotate")
            }
            .buttonStyle(CircularGlassButtonStyle())
        }
    }

    private var bottomPanel: some View {
        VStack(spacing: 18) {
            GlassSliderView(value: $overlayOpacity, range: 0.1...0.8, title: "Độ mờ ảnh mẫu")

            HStack(alignment: .center) {
                sampleThumbnail

                Spacer()

                Button {
                    viewModel.capturePhoto()
                } label: {
                    ZStack {
                        Circle()
                            .fill(.white.opacity(0.20))
                            .frame(width: 92, height: 92)
                        Circle()
                            .stroke(.white.opacity(0.95), lineWidth: 5)
                            .frame(width: 78, height: 78)
                        Circle()
                            .fill(.white)
                            .frame(width: 60, height: 60)
                    }
                }
                .accessibilityLabel("Chụp ảnh")

                Spacer()

                VStack(spacing: 5) {
                    Image(systemName: "figure.stand")
                        .font(.title3)
                    Text("Pose")
                        .font(.caption2.weight(.bold))
                }
                .foregroundStyle(.white)
                .frame(width: 58, height: 58)
                .softCard(cornerRadius: 18)
            }
        }
        .padding(16)
        .glassCard(cornerRadius: 30)
    }

    private var sampleThumbnail: some View {
        Image(uiImage: sampleImage)
            .resizable()
            .scaledToFill()
            .frame(width: 58, height: 58)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(.white.opacity(0.34), lineWidth: 1)
            }
    }

    private var permissionView: some View {
        ZStack {
            PoseGuideTheme.appGradient
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 54, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 92, height: 92)
                    .background(.white.opacity(0.14), in: Circle())
                    .overlay {
                        Circle().stroke(.white.opacity(0.24), lineWidth: 1)
                    }

                VStack(spacing: 8) {
                    Text("Cần quyền Camera")
                        .font(.title2.bold())
                        .foregroundStyle(.white)

                    Text("Vui lòng mở Settings và cấp quyền Camera để chụp ảnh theo dáng mẫu.")
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.76))
                        .multilineTextAlignment(.center)
                }

                VStack(spacing: 12) {
                    Button("Mở Settings") {
                        viewModel.openSettings()
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(PrimaryGlassButtonStyle())

                    Button("Đóng") {
                        dismiss()
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(SecondaryGlassButtonStyle())
                }
            }
            .padding(24)
            .glassCard(cornerRadius: 32)
            .padding(24)
        }
    }
}
