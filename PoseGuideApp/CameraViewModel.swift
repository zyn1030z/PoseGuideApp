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
    @Published var settings = CameraSettings.default
    @Published var timerCountdown: Int?

    private let sessionQueue = DispatchQueue(label: "poseguide.camera.session")
    private let photoOutput = AVCapturePhotoOutput()
    private var currentPosition: AVCaptureDevice.Position = .back
    private var activeDevice: AVCaptureDevice?

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

    func captureWithTimer() {
        switch settings.timer {
        case .off:
            capturePhoto()
        case .threeSeconds:
            startCountdown(seconds: 3)
        case .fiveSeconds:
            startCountdown(seconds: 5)
        }
    }

    func capturePhoto() {
        let photoSettings = AVCapturePhotoSettings()
        if photoOutput.supportedFlashModes.contains(avFlashMode) {
            photoSettings.flashMode = avFlashMode
        }
        photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }

    func clearCapture() {
        capturedImage = nil
    }

    func updateTimer(_ timer: CameraSettings.TimerMode) {
        settings.timer = timer
    }

    func updateGrid(_ isEnabled: Bool) {
        settings.grid = isEnabled
    }

    func updateFlash(_ flash: CameraSettings.FlashMode) {
        settings.flash = flash
    }

    func updateZoom(_ factor: CGFloat) {
        settings.zoom = min(max(factor, 1.0), 5.0)
        applyZoom(settings.zoom)
    }

    func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url)
    }

    private var avFlashMode: AVCaptureDevice.FlashMode {
        switch settings.flash {
        case .auto: return .auto
        case .on: return .on
        case .off: return .off
        }
    }

    private func startCountdown(seconds: Int) {
        timerCountdown = seconds

        Task { [weak self] in
            for value in stride(from: seconds - 1, through: 0, by: -1) {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                await MainActor.run {
                    self?.timerCountdown = value == 0 ? nil : value
                }
            }
            await MainActor.run {
                self?.capturePhoto()
            }
        }
    }

    private func configureSession() {
        let position = currentPosition
        let zoom = settings.zoom
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
            self.configureZoom(zoom, for: device)

            Task { @MainActor in
                self.activeDevice = device
                self.session = newSession
                self.isSessionReady = true
                self.startSession()
            }
        }
    }

    private func applyZoom(_ factor: CGFloat) {
        guard let activeDevice else { return }
        sessionQueue.async { [weak self] in
            self?.configureZoom(factor, for: activeDevice)
        }
    }

    private func configureZoom(_ factor: CGFloat, for device: AVCaptureDevice) {
        do {
            try device.lockForConfiguration()
            let maxZoom = min(device.activeFormat.videoMaxZoomFactor, 5.0)
            device.videoZoomFactor = min(max(factor, 1.0), maxZoom)
            device.unlockForConfiguration()
        } catch {
            Task { @MainActor in
                self.errorMessage = "Không thể chỉnh zoom camera."
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
