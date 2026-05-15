import Combine
import Foundation
import Photos
import UIKit

@MainActor
final class PhotoLibraryManager: ObservableObject {
    @Published var alertTitle = ""
    @Published var alertMessage = ""
    @Published var isShowingAlert = false

    func save(_ image: UIImage) {
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)

        switch status {
        case .authorized, .limited:
            writeImage(image)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { [weak self] newStatus in
                Task { @MainActor in
                    if newStatus == .authorized || newStatus == .limited {
                        self?.writeImage(image)
                    } else {
                        self?.showAlert(title: "Không có quyền lưu ảnh", message: "Vui lòng cấp quyền Photos trong Settings để lưu ảnh.")
                    }
                }
            }
        default:
            showAlert(title: "Không có quyền lưu ảnh", message: "Vui lòng cấp quyền Photos trong Settings để lưu ảnh.")
        }
    }

    private func writeImage(_ image: UIImage) {
        PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        } completionHandler: { [weak self] success, error in
            Task { @MainActor in
                if success {
                    self?.showAlert(title: "Đã lưu ảnh", message: "Ảnh đã được lưu vào thư viện.")
                } else {
                    self?.showAlert(title: "Lưu ảnh thất bại", message: error?.localizedDescription ?? "Vui lòng thử lại.")
                }
            }
        }
    }

    private func showAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        isShowingAlert = true
    }
}
