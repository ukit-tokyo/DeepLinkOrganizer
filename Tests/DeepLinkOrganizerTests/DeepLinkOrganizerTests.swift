import Foundation
import Testing

@testable import DeepLinkOrganizer

struct MockDeepLink: DeepLink {
  let path: String
  let queryKeys: [String]?
  let handle: (DeepLinkComponents) -> Void
}

@Suite
struct DeepLinkOrganizerTests {
  let mockDeepLink1 = MockDeepLink(
    path: "/path1",
    queryKeys: nil,
    handle: { comps in }
  )

  let mockDeepLink2 = MockDeepLink(
    path: "/path2",
    queryKeys: nil,
    handle: { comps in }
  )

  let mockDeepLink3 = MockDeepLink(
    path: "/path3",
    queryKeys: nil,
    handle: { comps in }
  )

  @Test
  func setConfiguration() {
    let organizer = DeepLinkOrganizer()

    #expect(organizer.config == nil)

    let config = DeepLinkOrganizer.Configuration(
      universalLinkHost: "mock_host.com",
      customScheme: "mockscheme"
    )
    organizer.set(config: config)

    #expect(organizer.config == config)
  }

  @Test
  func registerDeepLinks() {
    let organizer = DeepLinkOrganizer()

    #expect(organizer.deepLinks.isEmpty)

    organizer.register(deepLinks: [
      mockDeepLink1,
      mockDeepLink2,
    ])

    #expect(organizer.deepLinks.count == 2)
    #expect(organizer.deepLinks[0] as? MockDeepLink == mockDeepLink1)
    #expect(organizer.deepLinks[1] as? MockDeepLink == mockDeepLink2)

    organizer.register(deepLinks: [])
  }

  @Test
  func appendDeepLink() {
    let organizer = DeepLinkOrganizer()

    #expect(organizer.deepLinks.isEmpty)

    organizer.register(deepLinks: [
      mockDeepLink1
    ])

    organizer.append(deepLink: mockDeepLink2)
    organizer.append(deepLink: mockDeepLink3)

    #expect(organizer.deepLinks.count == 3)
    #expect(organizer.deepLinks[0] as? MockDeepLink == mockDeepLink1)
    #expect(organizer.deepLinks[1] as? MockDeepLink == mockDeepLink2)
    #expect(organizer.deepLinks[2] as? MockDeepLink == mockDeepLink3)
  }

  @Test
  func handleURL() throws {
    let organizer = DeepLinkOrganizer()

    let mockDeepLink = MockDeepLink(
      path: "/host/path",
      queryKeys: nil,
      handle: { comps in
        #expect(comps.scheme == "mockscheme")
        #expect(comps.host == "host")
        #expect(comps.path == "/path")
        #expect(comps.queryItems == [URLQueryItem(name: "key", value: "value")])
      }
    )

    organizer.set(config: .init(universalLinkHost: "mock_host.com", customScheme: "mockscheme"))

    organizer.register(deepLinks: [
      mockDeepLink,
    ])

    let url = URL(string: "mockscheme://host/path?key=value")!
    try organizer.handle(url: url)
  }
}
