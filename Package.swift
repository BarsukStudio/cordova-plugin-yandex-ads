// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CapacitorPluginYandexAds",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "CapacitorPluginYandexAds",
            targets: ["YandexAdsPlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/ionic-team/capacitor-swift-pm.git", from: "8.0.0"),
        .package(url: "https://github.com/yandexmobile/yandex-ads-sdk-ios.git", exact: "8.2.0")
    ],
    targets: [
        .target(
            name: "YandexAdsPlugin",
            dependencies: [
                .product(name: "Capacitor", package: "capacitor-swift-pm"),
                .product(name: "Cordova", package: "capacitor-swift-pm"),
                .product(name: "YandexMobileAdsPackage", package: "yandex-ads-sdk-ios")
            ],
            path: "ios/Sources/YandexAdsPlugin"),
        .testTarget(
            name: "YandexAdsPluginTests",
            dependencies: ["YandexAdsPlugin"],
            path: "ios/Tests/YandexAdsPluginTests")
    ]
)
