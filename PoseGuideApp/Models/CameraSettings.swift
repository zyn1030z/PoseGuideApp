import Foundation

struct CameraSettings: Codable, Equatable, Identifiable {
    let id = UUID()
    var timer: TimerMode = .off
    var grid: Bool = false
    var zoom: CGFloat = 1.0
    var flash: FlashMode = .auto

    enum TimerMode: String, Codable, CaseIterable {
        case off = "Off"
        case threeSeconds = "3s"
        case fiveSeconds = "5s"
    }

    enum FlashMode: String, Codable, CaseIterable {
        case auto = "Auto"
        case on = "On"
        case off = "Off"
    }
}

extension CameraSettings {
    static let `default` = CameraSettings()
}
