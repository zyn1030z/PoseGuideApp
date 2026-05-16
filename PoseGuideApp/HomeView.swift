import PhotosUI
import SwiftUI

struct HomeView: View {
    @State private var selectedItem: PhotosPickerItem?
    @State private var sampleImage: UIImage?
    @State private var pendingEditImage: UIImage?
    @State private var isShowingCamera = false
    @State private var isShowingEditor = false

    var body: some View {
        NavigationStack {
            ZStack {
                PoseGuideTheme.appGradient
                    .ignoresSafeArea()

                decorativeBackground

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 26) {
                        header
                            .padding(.top, 28)

                        samplePreview

                        actionButtons
                    }
                    .padding(.horizontal, 22)
                    .padding(.bottom, 28)
                }
            }
            .navigationDestination(isPresented: $isShowingCamera) {
                if let sampleImage {
                    CameraView(sampleImage: sampleImage)
                        .navigationBarBackButtonHidden()
                }
            }
            .fullScreenCover(isPresented: $isShowingEditor) {
                ImageEditorView(sourceImage: pendingEditImage ?? sampleImage ?? UIImage()) {
                    isShowingEditor = false
                    pendingEditImage = nil
                } onDone: { edited in
                    sampleImage = edited
                    pendingEditImage = nil
                    isShowingEditor = false
                }
            }
            .task(id: selectedItem) {
                await loadSelectedImage()
            }
        }
    }

    private var decorativeBackground: some View {
        ZStack {
            Circle()
                .fill(PoseGuideTheme.cyan.opacity(0.28))
                .frame(width: 260, height: 260)
                .blur(radius: 38)
                .offset(x: -150, y: -270)

            Circle()
                .fill(PoseGuideTheme.secondary.opacity(0.30))
                .frame(width: 320, height: 320)
                .blur(radius: 46)
                .offset(x: 170, y: 230)
        }
        .ignoresSafeArea()
    }

    private var header: some View {
        VStack(spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: "figure.stand")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
                    .background(.white.opacity(0.14), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(.white.opacity(0.24), lineWidth: 1)
                    }

                VStack(alignment: .leading, spacing: 4) {
                    Text("PoseGuide")
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text("Căn dáng nhanh với ảnh mẫu")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white.opacity(0.74))
                }

                Spacer()
            }

            Text("Chọn một ảnh tạo dáng yêu thích, sau đó mở camera và căn dáng theo lớp overlay trong suốt.")
                .font(.body)
                .foregroundStyle(.white.opacity(0.78))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var samplePreview: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Ảnh mẫu")
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                    Text(sampleImage == nil ? "Chưa có ảnh được chọn" : "Sẵn sàng để chụp theo mẫu")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.68))
                }

                Spacer()

                Image(systemName: sampleImage == nil ? "photo.badge.plus" : "checkmark.seal.fill")
                    .font(.title2)
                    .foregroundStyle(sampleImage == nil ? .white.opacity(0.72) : PoseGuideTheme.cyan)
            }

            ZStack {
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(.white.opacity(0.10))
                    .frame(height: 360)

                if let sampleImage {
                    Image(uiImage: sampleImage)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .padding(10)
                        .transition(.scale.combined(with: .opacity))
                } else {
                    VStack(spacing: 14) {
                        Image(systemName: "person.crop.rectangle.stack")
                            .font(.system(size: 56, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.74))
                        Text("Chọn ảnh mẫu để bắt đầu")
                            .font(.headline)
                            .foregroundStyle(.white)
                        Text("Ảnh sẽ được phủ mờ lên camera để bạn căn dáng chính xác hơn.")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.66))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 28)
                    }
                }
            }

            if sampleImage != nil {
                Button {
                    pendingEditImage = sampleImage
                    DispatchQueue.main.async {
                        isShowingEditor = true
                    }
                } label: {
                    Label("Chỉnh crop/rotate", systemImage: "crop.rotate")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(SecondaryGlassButtonStyle())
            }
        }
        .padding(18)
        .glassCard(cornerRadius: 32)
        .animation(.spring(response: 0.35, dampingFraction: 0.82), value: sampleImage != nil)
    }

    private var actionButtons: some View {
        VStack(spacing: 14) {
            PhotosPicker(selection: $selectedItem, matching: .images) {
                Label("Chọn ảnh mẫu", systemImage: "photo.on.rectangle.angled")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryGlassButtonStyle())

            Button {
                isShowingCamera = true
            } label: {
                Label("Chụp theo mẫu", systemImage: "camera.viewfinder")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryGlassButtonStyle(isDisabled: sampleImage == nil))
            .disabled(sampleImage == nil)
        }
    }

    private func loadSelectedImage() async {
        guard let selectedItem else { return }
        guard let data = try? await selectedItem.loadTransferable(type: Data.self), let image = UIImage(data: data) else { return }
        sampleImage = image
        pendingEditImage = nil
        isShowingEditor = false
    }
}

#Preview {
    HomeView()
}
