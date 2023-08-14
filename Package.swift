// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "AssetsPickerViewController",
    defaultLocalization: "en",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "AssetsPickerViewController",
            targets: ["AssetsPickerViewController"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/SnapKit/SnapKit", from: "5.0.1")
    ],
    targets: [
        .target(
            name: "AssetsPickerViewController",
            dependencies: ["SnapKit"],
            path: "AssetsPickerViewController",
            sources: ["Classes"],
            resources: [.process("Assets")],
            swiftSettings: [.unsafeFlags(["-Xfrontend", "-warn-concurrency"])]
        )
    ],
    swiftLanguageVersions: [.v4_2, .v5]
)
