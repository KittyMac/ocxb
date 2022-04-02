// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "ocxb",
    platforms: [
        .macOS(.v10_13)
    ],
    products: [
        .executable(name: "ocxb", targets: ["ocxb"])
    ],
    dependencies: [
		
    ],
    targets: [
        .target(
            name: "ocxb",
            dependencies: [ ]
        )
    ]
)
