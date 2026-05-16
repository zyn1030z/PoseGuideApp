import SwiftUI

struct ImageEditorView: View {
    let sourceImage: UIImage
    let onCancel: () -> Void
    let onDone: (UIImage) -> Void

    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 1
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var workingImage: UIImage

    init(sourceImage: UIImage, onCancel: @escaping () -> Void, onDone: @escaping (UIImage) -> Void) {
        self.sourceImage = sourceImage
        self.onCancel = onCancel
        self.onDone = onDone
        _workingImage = State(initialValue: sourceImage)
    }

    var body: some View {
        ZStack {
            PoseGuideTheme.appGradient.ignoresSafeArea()

            VStack(spacing: 18) {
                header

                ZStack {
                    Color.black.opacity(0.16)

                    Image(uiImage: workingImage)
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(scale)
                        .offset(offset)
                        .gesture(dragGesture)
                        .gesture(magnificationGesture)

                    CropOverlay()
                        .padding(18)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 420)
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .glassCard(cornerRadius: 30)

                controls
            }
            .padding(20)
        }
    }

    private var header: some View {
        HStack {
            Text("Chỉnh ảnh mẫu")
                .font(.title2.bold())
                .foregroundStyle(.white)
            Spacer()
        }
    }

    private var controls: some View {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                Button {
                    rotateImage()
                } label: {
                    Label("Xoay 90°", systemImage: "rotate.right")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(SecondaryGlassButtonStyle())

                Button {
                    resetTransform()
                } label: {
                    Label("Reset", systemImage: "arrow.counterclockwise")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(SecondaryGlassButtonStyle())
            }

            HStack(spacing: 10) {
                Button("Huỷ") {
                    onCancel()
                }
                .frame(maxWidth: .infinity)
                .buttonStyle(SecondaryGlassButtonStyle())

                Button("Dùng ảnh này") {
                    onDone(croppedOutputImage())
                }
                .frame(maxWidth: .infinity)
                .buttonStyle(PrimaryGlassButtonStyle())
            }
        }
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                offset = CGSize(
                    width: lastOffset.width + value.translation.width,
                    height: lastOffset.height + value.translation.height
                )
            }
            .onEnded { _ in
                lastOffset = offset
            }
    }

    private var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                scale = min(max(lastScale * value, 1), 5)
            }
            .onEnded { _ in
                lastScale = scale
            }
    }

    private func rotateImage() {
        guard let cgImage = workingImage.cgImage else { return }
        let size = CGSize(width: cgImage.height, height: cgImage.width)
        UIGraphicsBeginImageContextWithOptions(size, false, workingImage.scale)
        defer { UIGraphicsEndImageContext() }

        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.translateBy(x: size.width / 2, y: size.height / 2)
        context.rotate(by: .pi / 2)
        workingImage.draw(in: CGRect(x: -CGFloat(cgImage.width) / 2, y: -CGFloat(cgImage.height) / 2, width: CGFloat(cgImage.width), height: CGFloat(cgImage.height)))

        if let rotated = UIGraphicsGetImageFromCurrentImageContext() {
            workingImage = rotated
            resetTransform()
        }
    }

    private func resetTransform() {
        scale = 1
        lastScale = 1
        offset = .zero
        lastOffset = .zero
    }

    private func croppedOutputImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 1200, height: 1200))
        return renderer.image { context in
            context.cgContext.setFillColor(UIColor.black.cgColor)
            context.cgContext.fill(CGRect(x: 0, y: 0, width: 1200, height: 1200))

            let imageSize = workingImage.size
            let fitScale = min(1200 / imageSize.width, 1200 / imageSize.height)
            let drawWidth = imageSize.width * fitScale * scale
            let drawHeight = imageSize.height * fitScale * scale
            let drawX = (1200 - drawWidth) / 2 + offset.width * 2
            let drawY = (1200 - drawHeight) / 2 + offset.height * 2

            workingImage.draw(in: CGRect(x: drawX, y: drawY, width: drawWidth, height: drawHeight))
        }
    }
}
