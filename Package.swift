// swift-tools-version:5.0.0
import PackageDescription

let package = Package(
    name: "sql-http",
    products: [
        .library(name: "SQLHttp", targets: ["SQLHttp"])
    ],
    dependencies: [
        .package(url: "https://github.com/kperson/swift-request-adapter-base.git", .upToNextMajor(from: "1.0.0"))
    ],
    targets: [
        .target(
            name: "SQLHttp",
            dependencies: ["HttpExecuter"]
        ),
        .testTarget(
            name: "SQLHttpTests",
            dependencies: [
                "SQLHttp"
            ]
        )
    ]
)
