// swift-tools-version: 5.6

// WARNING:
// This file is automatically generated.
// Do not edit it by hand because the contents will be replaced.

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "Challenge",
    platforms: [
        .iOS("15.2")
    ],
    products: [
        .iOSApplication(
            name: "Challenge",
            targets: ["AppModule"],
            bundleIdentifier: "com.steadman.SwiftStudentChallenge",
            teamIdentifier: "95SLPS7Q77",
            displayVersion: "1.0",
            bundleVersion: "1",
            appIcon: .asset("AppIcon"),
            accentColor: .presetColor(.orange),
            supportedDeviceFamilies: [
                .pad,
                .phone
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft,
                .portraitUpsideDown(.when(deviceFamilies: [.pad]))
            ],
            capabilities: [
                .camera(purposeString: "Required for ARKit and RealityKit")
            ],
            appCategory: .entertainment
        )
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            path: "."
        )
    ]
)