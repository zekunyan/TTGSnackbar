// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "TTGSnackbar",
    platforms: [.iOS(.v91)],
    products: [
        .library(name: "TTGSnackbar", targets: ["TTGSnackbar"])
    ],
    targets: [
        .target(name: "TTGSnackbar", path: "TTGSnackbar")
    ]
)
