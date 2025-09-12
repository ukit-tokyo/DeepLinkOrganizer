//
//  File.swift
//  DeepLinkOrganizer
//
//  Created by Taichi Yuki on 2025/09/12.
//

import Foundation
import Testing

@testable import DeepLinkOrganizer

struct MockLink1: DeepLink {
  let matchPaths: MatchPathPattern = .startsWith(["path"])
  let handle: (DeepLinkExtraction) -> Void
}

@Suite
struct DeepLinkHanderTests {
  @Test
  func handleSchemeURL() throws {
    let organizer = DeepLinkOrganizer()

    #expect(throws: DeepLinkError.configNotSet) {
      let url = URL(string: "scheme://path")!
      try organizer.handle(url: url)
    }

    let mock = MockLink1 { extraction in
      let expect = DeepLinkExtraction(
        scheme: "scheme",
        host: "path",
        path: "",
        fullPath: "path",
        paths: ["path"],
        targetPath: nil,
        queryItems: nil
      )
      #expect(extraction == expect)
    }

    organizer.set(config: .init(universalLinkHost: nil, customScheme: "scheme"))
    organizer.register(deepLinks: [
      mock
    ])

    let url1 = URL(string: "scheme://path")!
    try organizer.handle(url: url1)
  }

  @Test
  func handleUniversalLinkURL() throws {
    let organizer = DeepLinkOrganizer()

    #expect(throws: DeepLinkError.configNotSet) {
      let url = URL(string: "https://host.com/path?key=value")!
      try organizer.handle(url: url)
    }

    let mock = MockLink1 { extraction in
      let expect = DeepLinkExtraction(
        scheme: "https",
        host: "host.com",
        path: "/path",
        fullPath: "host.com/path",
        paths: ["host.com", "path"],
        targetPath: nil,
        queryItems: ["key": "value"]
      )
      #expect(extraction == expect)
    }

    organizer.set(config: .init(universalLinkHost: "host.com", customScheme: nil))
    organizer.register(deepLinks: [
      mock
    ])

    let url = URL(string: "https://host.com/path?key=value")!
    try organizer.handle(url: url)
  }
}

struct MockLink2: DeepLink {
  let matchPaths: MatchPathPattern = .startsWith(["users"])
  let queryKeys: [String]? = ["key1", "key2"]
  let extractionType: ExtractionType? = .nextPathOf("users")
  let handle: (DeepLinkExtraction) -> Void
}

extension DeepLinkHanderTests {
  @Test
  func handlerUsersURL() async throws {
    let organizer = DeepLinkOrganizer()

    let mock = MockLink2 { extraction in
      let expect = DeepLinkExtraction(
        scheme: "https",
        host: "host.com",
        path: "/users/123/profile",
        fullPath: "host.com/users/123/profile",
        paths: ["host.com", "users", "123", "profile"],
        targetPath: "123",
        queryItems: ["key1": "value1", "key2": "value2"]
      )
      #expect(extraction == expect)
    }

    organizer.set(config: .init(universalLinkHost: "host.com", customScheme: nil))
    organizer.register(deepLinks: [
      mock
    ])

    let url = URL(string: "https://host.com/users/123/profile?key1=value1&key2=value2")!
    try organizer.handle(url: url)
  }
}

struct MockLink3: DeepLink {
  let matchPaths: MatchPathPattern = .contains(["shops", "products"])
  let extractionType: ExtractionType? = .nextPathOf("products")
  let handle: (DeepLinkExtraction) -> Void
}

extension DeepLinkHanderTests {
  @Test
  func handlerProductURL() async throws {
    let organizer = DeepLinkOrganizer()

    let mock = MockLink3 { extraction in
      let expect = DeepLinkExtraction(
        scheme: "https",
        host: "host.com",
        path: "/shops/123/products/456",
        fullPath: "host.com/shops/123/products/456",
        paths: ["host.com", "shops", "123", "products", "456"],
        targetPath: "456",
        queryItems: ["key1": "value1", "key2": "value2"]
      )
      #expect(extraction == expect)
    }

    organizer.set(config: .init(universalLinkHost: "host.com", customScheme: nil))
    organizer.register(deepLinks: [
      mock
    ])

    let url = URL(string: "https://host.com/shops/123/products/456?key1=value1&key2=value2")!
    try organizer.handle(url: url)
  }
}
