import Foundation
import Testing

@testable import DeepLinkOrganizer

struct MockDeepLink: DeepLink {
  let matchPaths: MatchPathPattern
  let queryKeys: [String]?
  let extractionType: ExtractionType?
  let handle: (DeepLinkExtraction) -> Void
}

@Suite("DeepLinkOrganizer Tests")
struct DeepLinkOrganizerTests {
  let mockDeepLink1 = MockDeepLink(
    matchPaths: .startsWith(["path1"]),
    queryKeys: nil,
    extractionType: nil,
    handle: { _ in }
  )

  let mockDeepLink2 = MockDeepLink(
    matchPaths: .startsWith(["path2"]),
    queryKeys: nil,
    extractionType: nil,
    handle: { _ in }
  )

  let mockDeepLink3 = MockDeepLink(
    matchPaths: .startsWith(["path3"]),
    queryKeys: nil,
    extractionType: nil,
    handle: { _ in }
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
  func handleCustomURLScheme() throws {
    let organizer = DeepLinkOrganizer()

    let mockDeepLink = MockDeepLink(
      matchPaths: .startsWith(["this", "is", "path"]),
      queryKeys: nil,
      extractionType: .nextPathOf("this"),
      handle: { comps in
        #expect(comps.scheme == "mockscheme")
        #expect(comps.path == "/is/path")
        #expect(comps.fullPath == "this/is/path")
        #expect(comps.paths == ["this", "is", "path"])
        #expect(comps.targetPath == "is")
        #expect(comps.queryItems == ["key": "value"])
      }
    )

    organizer.set(config: .init(universalLinkHost: nil, customScheme: "mockscheme"))

    organizer.register(deepLinks: [
      mockDeepLink
    ])

    let url = URL(string: "mockscheme://this/is/path?key=value")!
    try organizer.handle(url: url)
  }

  @Test
  func trimPath() throws {
    let organizer = DeepLinkOrganizer()

    let expect = "this/is/path"

    let path1 = "/this/is/path/"
    #expect(organizer.trimSlashes(path1) == expect)

    let path2 = "///this/is/path///"
    #expect(organizer.trimSlashes(path2) == expect)

    let path3 = "this/is/path"
    #expect(organizer.trimSlashes(path3) == expect)
  }

  @Test
  func matchPath() throws {
    let organizer = DeepLinkOrganizer()
    let path = "/this/is/path"

    #expect(organizer.matchPath(path, expect: .startsWith(["this", "is"])) == true)
    #expect(organizer.matchPath(path, expect: .contains(["this", "is"])) == true)

    #expect(organizer.matchPath(path, expect: .startsWith(["is", "path"])) == false)
    #expect(organizer.matchPath(path, expect: .contains(["is", "path"])) == true)

    #expect(organizer.matchPath(path, expect: .startsWith(["this", "is", "path"])) == true)
    #expect(organizer.matchPath(path, expect: .contains(["this", "is", "path"])) == true)

    #expect(organizer.matchPath(path, expect: .startsWith(["this", "path"])) == false)
    #expect(organizer.matchPath(path, expect: .contains(["this", "path"])) == true)

    #expect(organizer.matchPath(path, expect: .startsWith(["this", "is", "not", "path"])) == false)
    #expect(organizer.matchPath(path, expect: .contains(["this", "is", "not", "path"])) == false)
  }

  @Test
  func parseURL() throws {
    let organizer = DeepLinkOrganizer()

    #expect(throws: DeepLinkError.invalidURL) {
      _ = try organizer.parse(url: URL(string: "invalid_url")!)
    }

    let urlString = "https://host.com/this/is/path?param1=value1&param2=value2"
    let expect = DeepLinkComponents(urlComponents: URLComponents(string: urlString)!)
    let comps = try organizer.parse(url: URL(string: urlString)!)
    #expect(comps == expect)
  }

  @Test
  func linkType() throws {
    let organizer = DeepLinkOrganizer()

    let config = DeepLinkOrganizer.Configuration(
      universalLinkHost: "mock.com",
      customScheme: "mockscheme"
    )

    let url1 = URL(string: "mockscheme://this/is/path")!
    let comps1 = try organizer.parse(url: url1)
    let type1 = try organizer.linkType(comps: comps1, config: config)
    #expect(type1 == .customURLScheme)

    let url2 = URL(string: "https://mock.com/this/is/path")!
    let comps2 = try organizer.parse(url: url2)
    let type2 = try organizer.linkType(comps: comps2, config: config)
    #expect(type2 == .universalLink)

    let url3 = URL(string: "https://unexpected.com/this/is/path")!
    let comps3 = try organizer.parse(url: url3)
    #expect(throws: DeepLinkError.unexpectedURL) {
      _ = try organizer.linkType(comps: comps3, config: config)
    }

    let url4 = URL(string: "unknownscheme://this/is/path")!
    let comps4 = try organizer.parse(url: url4)
    #expect(throws: DeepLinkError.unexpectedURL) {
      _ = try organizer.linkType(comps: comps4, config: config)
    }
  }

  @Test
  func matchUniversalLink() throws {
    let organizer = DeepLinkOrganizer()
    organizer.set(config: .init(universalLinkHost: "mock.com", customScheme: nil))

    let expect1 = MockDeepLink(
      matchPaths: .startsWith(["path1"]),
      queryKeys: nil,
      extractionType: nil,
      handle: { _ in }
    )
    let expect2 = MockDeepLink(
      matchPaths: .startsWith(["path2"]),
      queryKeys: ["key1", "key2"],
      extractionType: nil,
      handle: { _ in }
    )
    organizer.register(deepLinks: [
      expect1, expect2,
    ])

    let url1 = URL(string: "https://mock.com/path1")!
    let comps1 = try organizer.parse(url: url1)
    let deeplink1 = try organizer.matchUniversalLink(comps: comps1)
    #expect(deeplink1 as? MockDeepLink == expect1)

    let url2 = URL(string: "https://mock.com/path2?key1=value1&key2=value2&key3=value3")!
    let comps2 = try organizer.parse(url: url2)
    let deeplink2 = try organizer.matchUniversalLink(comps: comps2)
    #expect(deeplink2 as? MockDeepLink == expect2)

    #expect(throws: DeepLinkError.noMatchingDeepLink) {
      let url3 = URL(string: "https://mock.com/path2?key1=value1")!
      let comps3 = try organizer.parse(url: url3)
      _ = try organizer.matchUniversalLink(comps: comps3)
    }

    #expect(throws: DeepLinkError.noMatchingDeepLink) {
      let url3 = URL(string: "https://mock.com/path3?key1=value1&key2=value2&key3=value3")!
      let comps3 = try organizer.parse(url: url3)
      _ = try organizer.matchUniversalLink(comps: comps3)
    }
  }

  @Test
  func matchCustomURLScheme() throws {
    let organizer = DeepLinkOrganizer()
    organizer.set(config: .init(universalLinkHost: nil, customScheme: "scheme"))

    let expect1 = MockDeepLink(
      matchPaths: .startsWith(["path1"]),
      queryKeys: nil,
      extractionType: nil,
      handle: { _ in }
    )
    let expect2 = MockDeepLink(
      matchPaths: .startsWith(["path2"]),
      queryKeys: ["key1", "key2"],
      extractionType: nil,
      handle: { _ in }
    )
    organizer.register(deepLinks: [
      expect1, expect2,
    ])

    let url1 = URL(string: "scheme://path1/path")!
    let comps1 = try organizer.parse(url: url1)
    let deeplink1 = try organizer.matchCustomURLScheme(comps: comps1)
    #expect(deeplink1 as? MockDeepLink == expect1)

    let url2 = URL(string: "scheme://path2/path3?key1=value1&key2=value2")!
    let comps2 = try organizer.parse(url: url2)
    let deeplink2 = try organizer.matchCustomURLScheme(comps: comps2)
    #expect(deeplink2 as? MockDeepLink == expect2)

    #expect(throws: DeepLinkError.noMatchingDeepLink) {
      let url1 = URL(string: "scheme://hoge.com/path1")!
      let comps1 = try organizer.parse(url: url1)
      _ = try organizer.matchCustomURLScheme(comps: comps1)
    }
  }

  @Test
  func extract() throws {
    let organizer = DeepLinkOrganizer()

    let url1 = URL(string: "https://host.com/path1?key=value")!
    let comps1 = try organizer.parse(url: url1)
    let link1 = MockDeepLink(
      matchPaths: .startsWith(["path1"]),
      queryKeys: nil,
      extractionType: nil,
      handle: { _ in }
    )
    let expect1 = DeepLinkExtraction(
      scheme: "https",
      host: "host.com",
      path: "/path1",
      fullPath: "host.com/path1",
      paths: ["host.com", "path1"],
      targetPath: nil,
      queryItems: ["key": "value"]
    )
    let extract1 = try organizer.extract(comps: comps1, link: link1)
    #expect(extract1 == expect1)

    let url2 = URL(string: "https://host.com/path3/path4?key=value")!
    let comps2 = try organizer.parse(url: url2)
    let link2 = MockDeepLink(
      matchPaths: .startsWith(["path3"]),
      queryKeys: nil,
      extractionType: .nextPathOf("path3"),
      handle: { _ in }
    )
    let expect2 = DeepLinkExtraction(
      scheme: "https",
      host: "host.com",
      path: "/path3/path4",
      fullPath: "host.com/path3/path4",
      paths: ["host.com", "path3", "path4"],
      targetPath: "path4",
      queryItems: ["key": "value"]
    )

    let extract2 = try organizer.extract(comps: comps2, link: link2)

    #expect(extract2 == expect2)
  }
}
