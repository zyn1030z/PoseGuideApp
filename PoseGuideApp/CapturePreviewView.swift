import SwiftUI

struct CapturePreviewView: View {
    let capturedImage: UIImage
    let retake: () -> Void
    let goHome: () -> Void

    @StateObject private var photoLibraryManager = PhotoLibraryManager()

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            Image(uiImage: capturedImage)
                .resizable()
                .scaledToFit()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                PoseGuideTheme.cameraTopScrim
                    .frame(height: 160)
                Spacer()
                PoseGuideTheme.cameraBottomScrim
                    .frame(height: 340)
            }
            .ignoresSafeArea()
            .allowsHitTesting(false)

            VStack(spacing: 0) {
                topLabel
                    .padding(.top, 16)
                    .padding(.horizontal, 20)

                Spacer()

                bottomControls
                    .padding(.horizontal, 20)
                    .padding(.bottom, 28)
            }
        }
        .alert(photoLibraryManager.alertTitle, isPresented: $photoLibraryManager.isShowingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(photoLibraryManager.alertMessage)
        }
    }

    private var topLabel: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Ảnh đã chụp")
                    .font(.headline.bold())
                    .foregroundStyle(.white)
                Text("Lưu lại hoặc chụp lại nếu muốn căn dáng tốt hơn")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white.opacity(0.72))
            }
            Spacer()
        }
        .padding(16)
        .glassCard(cornerRadius: 22)
    }

    private var bottomControls: some View {
        VStack(spacing: 14) {
            Button {
                photoLibraryManager.save(capturedImage)
            } label: {
                Label("Lưu ảnh", systemImage: "square.and.arrow.down.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryGlassButtonStyle())

            HStack(spacing: 12) {
                Button {
                    retake()
                } label: {
                    Label("Chụp lại", systemImage: "arrow.counterclockwise")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(SecondaryGlassButtonStyle())

                Button {
                    goHome()
                } label: {
                    Label("Trang chủ", systemImage: "house.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(SecondaryGlassButtonStyle())
            }
        }
        .padding(16)
        .glassCard(cornerRadius: 30)
    }
}
