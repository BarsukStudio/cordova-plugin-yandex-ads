import XCTest
@testable import YandexAdsPlugin

final class YandexAdsTests: XCTestCase {
    func testPluginModuleLoads() {
        XCTAssertNotNil(YandexAdsPlugin.self)
    }
}
