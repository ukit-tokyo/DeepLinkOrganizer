// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

public final class DeepLinkOrganizer {
  private(set) public var deepLinks: [any DeepLink] = []
  private(set) public var config: Configuration?

  public init(config: Configuration? = nil) {
    self.config = config
  }

  public func set(config: Configuration) {
    self.config = config
  }

  public func register(deepLinks: [any DeepLink]) {
    self.deepLinks = deepLinks
  }

  public func append(deepLink: any DeepLink) {
    self.deepLinks.append(deepLink)
  }

  public func handle(url: URL) throws {
    guard let config else { throw DeepLinkError.configNotSet }

    let comps = try parse(url: url)
    let type = try linkType(comps: comps, config: config)
    let link = try match(comps: comps, type: type)
    let extracted = try extract(comps: comps, link: link)

    link.handle(extracted)
  }

  func parse(url: URL) throws -> DeepLinkComponents {
    guard let comps = URLComponents(url: url, resolvingAgainstBaseURL: false),
      comps.scheme != nil,
      comps.host != nil
    else {
      throw DeepLinkError.invalidURL
    }

    return DeepLinkComponents(urlComponents: comps)
  }

  func linkType(comps: DeepLinkComponents, config: Configuration) throws -> LinkType {
    let scheme = comps.scheme
    let host = comps.host

    let type: LinkType =
      if scheme == config.customScheme {
        .customURLScheme
      } else if host == config.universalLinkHost {
        .universalLink
      } else {
        throw DeepLinkError.unexpectedURL
      }

    return type
  }

  func match(comps: DeepLinkComponents, type: LinkType) throws -> any DeepLink {
    switch type {
    case .universalLink:
      try matchUniversalLink(comps: comps)
    case .customURLScheme:
      try matchCustomURLScheme(comps: comps)
    }
  }

  func matchUniversalLink(comps: DeepLinkComponents) throws -> any DeepLink {
    let path = comps.path
    let queryItems = comps.queryItems

    let firstMatch = deepLinks.first(where: { link in
      guard let queryItems, let keys = link.queryKeys, !keys.isEmpty else {
        return matchPath(path, expect: link.path, pattern: link.matchPathPattern)
      }

      let keysContained = keys.allSatisfy { key in
        queryItems.contains(where: { $0.key == key })
      }

      return keysContained
      && self.matchPath(
          path,
          expect: link.path,
          pattern: link.matchPathPattern
        )
    })

    guard let firstMatch else {
      throw DeepLinkError.noMatchingDeepLink
    }

    return firstMatch
  }

  func matchCustomURLScheme(comps: DeepLinkComponents) throws -> any DeepLink {
    let path = comps.fullPath
    let queryItems = comps.queryItems

    let firstMatch = deepLinks.first(where: { link in
      guard let queryItems, let keys = link.queryKeys, !keys.isEmpty else {
        return self.matchPath(path, expect: link.path, pattern: link.matchPathPattern)
      }

      let keysContained = keys.allSatisfy { key in
        queryItems.contains(where: { $0.key == key })
      }

      return keysContained
        && self.matchPath(
          path,
          expect: link.path,
          pattern: link.matchPathPattern
        )
    })

    guard let firstMatch else {
      throw DeepLinkError.noMatchingDeepLink
    }

    return firstMatch
  }

  func extract(comps: DeepLinkComponents, link: any DeepLink) throws -> DeepLinkExtraction {
    guard let type = link.extractionType,
      case .nextPathOf(let path) = type
    else {
      return DeepLinkExtraction(
        comps: comps,
        targetPath: nil
      )
    }

    let target = comps.paths.next(of: path)

    return DeepLinkExtraction(
      comps: comps,
      targetPath: target
    )
  }

  func matchPath(_ path: String, expect: String, pattern: MatchPathPattern) -> Bool {
    let expect = trimSlashes(expect)
    let path = trimSlashes(path)

    return switch pattern {
    case .startsWith:
      path.starts(with: expect)
    case .contains:
      path.contains(expect)
    }
  }

  func trimSlashes(_ str: String) -> String {
    str.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
  }
}

extension DeepLinkOrganizer {
  public struct Configuration: Equatable {
    public let universalLinkHost: String?
    public let customScheme: String?
  }

  enum LinkType {
    case universalLink
    case customURLScheme
  }
}
