import Foundation
import Testing

@testable import DeepLinkOrganizer

enum MockAction {
  case action1
  case action2
  case action3
}

struct MockDeepLink: DeepLink {
  typealias Action = MockAction

  let path: String
  let queryKeys: [String]?
  let handle: (URLComponents) -> MockAction
}

@Suite
struct DeepLinkOrganizerTests {
  let mockDeepLink1 = MockDeepLink(
    path: "/path1",
    queryKeys: nil,
    handle: { _ in .action1 }
  )

  let mockDeepLink2 = MockDeepLink(
    path: "/path2",
    queryKeys: nil,
    handle: { _ in .action2 }
  )

  let mockDeepLink3 = MockDeepLink(
    path: "/path3",
    queryKeys: nil,
    handle: { _ in .action3 }
  )

  @Test
  func registerDeepLinks() {
    let organizer = DeepLinkOrganizer<MockDeepLink, MockAction>()

    organizer.register(deepLinks: [
      mockDeepLink1,
      mockDeepLink2,
    ])

    #expect(organizer.deepLinks.count == 2)
    #expect(organizer.deepLinks[0] == mockDeepLink1)
    #expect(organizer.deepLinks[1] == mockDeepLink2)

    organizer.register(deepLinks: [])
  }

  @Test
  func appendDeepLink() {
    let organizer = DeepLinkOrganizer<MockDeepLink, MockAction>()

    organizer.register(deepLinks: [
      mockDeepLink1
    ])

    organizer.append(deepLink: mockDeepLink2)
    organizer.append(deepLink: mockDeepLink3)

    #expect(organizer.deepLinks.count == 3)
    #expect(organizer.deepLinks[0] == mockDeepLink1)
    #expect(organizer.deepLinks[1] == mockDeepLink2)
    #expect(organizer.deepLinks[2] == mockDeepLink3)
  }

  @Test
  func handleURL() throws {
    let organizer = DeepLinkOrganizer<MockDeepLink, MockAction>()

    organizer.set(config: .init(universalLinkHost: "mock_host.com", customScheme: "mockscheme"))

    organizer.register(deepLinks: [
      mockDeepLink1,
      mockDeepLink2,
    ])

    let url = URL(string: "mockscheme://path1")!
    let action = try organizer.handle(url: url)

    #expect(action == .action1)
  }
}
