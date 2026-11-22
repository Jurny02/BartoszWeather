import Testing
import UIKit
@testable import BartoszWeather

struct IconTests {
    @Test(arguments: Icon.allCases)
    func resolvesToSystemSymbol(_ icon: Icon) {
        #expect(UIImage(systemName: icon.rawValue) != nil)
    }
}
