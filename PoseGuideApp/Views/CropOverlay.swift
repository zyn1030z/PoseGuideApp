import SwiftUI

struct CropOverlay: View {
    var body: some View {
        ZStack {
            Rectangle()
                .stroke(.white.opacity(0.9), lineWidth: 2)
            ForEach(1...2, id: \.self) { index in
                GeometryReader { proxy in
                    let width = proxy.size.width
                    let height = proxy.size.height
                    Path { path in
                        let x = width * CGFloat(index) / 3
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: height))

                        let y = height * CGFloat(index) / 3
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: width, y: y))
                    }
                    .stroke(.white.opacity(0.36), lineWidth: 1)
                }
            }
        }
        .allowsHitTesting(false)
    }
}
