// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "TTGSnackbar",
    platforms: [.iOS(.v9)],
    products: [
        .library(name: "TTGSnackbar", targets: ["TTGSnackbar"])
    ],
    targets: [
        .target(
            name: "TTGSnackbar",
            path: "TTGSnackbar",
            resources: [.copy("PrivacyInfo.xcprivacy")]
        )
    ],
    swiftLanguageVersions: [.v5]
)
