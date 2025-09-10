import Foundation
import Testing

@testable import DeepLinkOrganizer

struct MockDeepLink: DeepLink {
  let path: String = "/path"
  let action: DeepLinkAction = .none
}

struct Mock2DeepLink: DeepLink {
  let path: String = "/path2"
  let action: DeepLinkAction = .none
}

@Suite
struct DeepLinkOrganizerTests {
  @Test
  func registerDeepLinks() {
    let organizer = DeepLinkOrganizer()

    organizer.register(deepLinks: [
      MockDeepLink(),
      Mock2DeepLink(),
    ])

    #expect(organizer.deepLinks.count == 2)
    #expect(organizer.deepLinks[0] as! MockDeepLink == MockDeepLink())
    #expect(organizer.deepLinks[1] as! Mock2DeepLink == Mock2DeepLink())

    organizer.register(deepLinks: [])
  }

  @Test
  func appendDeepLink() {
    let organizer = DeepLinkOrganizer()

    organizer.append(deepLink: Mock2DeepLink())
    organizer.append(deepLink: MockDeepLink())

    #expect(organizer.deepLinks.count == 2)
    #expect(organizer.deepLinks[0] as? Mock2DeepLink == Mock2DeepLink())
    #expect(organizer.deepLinks[1] as? MockDeepLink == MockDeepLink())
  }
}
