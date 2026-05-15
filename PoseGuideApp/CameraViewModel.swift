import AVFoundation
import Combine
import SwiftUI

@MainActor
final class CameraViewModel: NSObject, ObservableObject {
    @Published var session = AVCaptureSession()
    @Published var capturedImage: UIImage?
    @Published var permissionDenied = false
    @Published var isSessionReady = false
    @Published var errorMessage: String?

    private let sessionQueue = DispatchQueue(label: "poseguide.camera.session")
    private let photoOutput = AVCapturePhotoOutput()
    private var currentPosition: AVCaptureDevice.Position = .back

    func requestPermissionAndConfigure() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            configureSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                Task { @MainActor in
                    if granted {
                        self?.configureSession()
                    } else {
                        self?.permissionDenied = true
                    }
                }
            }
        default:
            permissionDenied = true
        }
    }

    func startSession() {
        sessionQueue.async { [weak self] in
            guard let self, !self.session.isRunning else { return }
            self.session.startRunning()
        }
    }

    func stopSession() {
        sessionQueue.async { [weak self] in
            guard let self, self.session.isRunning else { return }
            self.session.stopRunning()
        }
    }

    func switchCamera() {
        currentPosition = currentPosition == .back ? .front : .back
        configureSession()
    }

    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    func clearCapture() {
        capturedImage = nil
    }

    func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url)
    }

    private func configureSession() {
        let position = currentPosition
        sessionQueue.async { [weak self] in
            guard let self else { return }

            let newSession = AVCaptureSession()
            newSession.sessionPreset = .photo

            guard
                let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position),
                let input = try? AVCaptureDeviceInput(device: device),
                newSession.canAddInput(input)
            else {
                Task { @MainActor in
                    self.errorMessage = "Không thể mở camera trên thiết bị này."
                }
                return
            }

            newSession.addInput(input)

            guard newSession.canAddOutput(self.photoOutput) else {
                Task { @MainActor in
                    self.errorMessage = "Không thể cấu hình chụp ảnh."
                }
                return
            }

            newSession.addOutput(self.photoOutput)

            Task { @MainActor in
                self.session = newSession
                self.isSessionReady = true
                self.startSession()
            }
        }
    }
}

extension CameraViewModel: AVCapturePhotoCaptureDelegate {
    nonisolated func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error {
            Task { @MainActor in
                self.errorMessage = error.localizedDescription
            }
            return
        }

        guard let data = photo.fileDataRepresentation(), let image = UIImage(data: data) else {
            Task { @MainActor in
                self.errorMessage = "Không thể xử lý ảnh vừa chụp."
            }
            return
        }

        Task { @MainActor in
            self.capturedImage = image
        }
    }
}
