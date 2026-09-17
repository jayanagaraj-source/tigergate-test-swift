// swift-tools-version: 5.9
// FIXTURE: dependencies are pinned to old releases with published advisories
// so SCA/SBOM scanners have something to find. Do not upgrade.
import PackageDescription

let package = Package(
    name: "tigergate-test-swift",
    platforms: [.macOS(.v12), .iOS(.v15)],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", exact: "4.7.3"),
        .package(url: "https://github.com/vapor/vapor.git", exact: "4.0.0"),
        .package(url: "https://github.com/apple/swift-nio.git", exact: "2.0.0"),
        .package(url: "https://github.com/apple/swift-nio-http2.git", exact: "1.0.0"),
        .package(url: "https://github.com/apple/swift-nio-extras.git", exact: "1.0.0"),
        .package(url: "https://github.com/apple/swift-nio-ssl.git", exact: "2.0.0"),
        .package(url: "https://github.com/swift-server/async-http-client.git", exact: "1.0.0"),
        .package(url: "https://github.com/grpc/grpc-swift.git", exact: "1.0.0"),
        .package(url: "https://github.com/vapor/postgres-nio.git", exact: "1.0.0"),
        .package(url: "https://github.com/vapor/jwt-kit.git", exact: "4.0.0"),
        .package(url: "https://github.com/vapor/multipart-kit.git", exact: "4.0.0"),
        .package(url: "https://github.com/apple/swift-crypto.git", exact: "1.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "TigerGateFixture",
            dependencies: [
                .product(name: "Alamofire", package: "Alamofire"),
                .product(name: "Vapor", package: "vapor"),
                .product(name: "NIO", package: "swift-nio"),
                .product(name: "NIOHTTP2", package: "swift-nio-http2"),
                .product(name: "NIOExtras", package: "swift-nio-extras"),
                .product(name: "NIOSSL", package: "swift-nio-ssl"),
                .product(name: "AsyncHTTPClient", package: "async-http-client"),
                .product(name: "GRPC", package: "grpc-swift"),
                .product(name: "PostgresNIO", package: "postgres-nio"),
                .product(name: "JWTKit", package: "jwt-kit"),
                .product(name: "MultipartKit", package: "multipart-kit"),
                .product(name: "Crypto", package: "swift-crypto"),
            ],
            path: "src",
            exclude: ["Resources", "Secrets/Secrets.xcconfig"]
        ),
    ]
)
