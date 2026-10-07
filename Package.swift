// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "TransmissionRemoteGUI",
    platforms: [
        .macOS(.v14)
    ],
    targets: [
        // Pure logic, no UI — testable without a daemon.
        .target(
            name: "TransmissionKit"
        ),
        // Language packs and locale selection, independently testable without SwiftUI.
        .target(name: "TransmissionLocalization"),
        // SwiftUI macOS app.
        .executableTarget(
            name: "TransmissionRemoteGUI",
            dependencies: ["TransmissionKit", "TransmissionLocalization"]
        ),
        // Standalone test runner: the CLT toolchain has no XCTest/Testing,
        // so we run our own lightweight harness (`swift run KitTests`).
        .executableTarget(
            name: "KitTests",
            dependencies: ["TransmissionKit"]
        ),
        .executableTarget(
            name: "LocalizationTests",
            dependencies: ["TransmissionLocalization", "TransmissionKit"]
        ),
    ]
)
