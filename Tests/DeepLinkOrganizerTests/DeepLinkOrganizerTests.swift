import Foundation
import Testing

@testable import DeepLinkOrganizer

@Test func handle() async throws {
  let url = URL(string: "https://example.com/path")!
  let organizer = DeepLinkOrganizer(url: url)
  let result = organizer.handle()
  #expect(result == "handled")
}
