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
    guard let config else { throw Error.configNotSet }

    let comps = try parse(url: url)
    let type = try linkType(comps: comps, config: config)
    let link = try match(comps: comps, type: type)
    let extracted = try extract(comps: comps, link: link)

    link.handle(extracted)
  }

  func parse(url: URL) throws -> DeepLinkComponents {
    guard let comps = URLComponents(url: url, resolvingAgainstBaseURL: false),
      let scheme = comps.scheme,
      let host = comps.host
    else {
      throw Error.invalidURL
    }

    let fullPath = host + comps.path
    let paths =
      fullPath
      .components(separatedBy: "/")
      .filter { !$0.isEmpty }

    return .init(
      scheme: scheme,
      fullPath: fullPath,
      paths: paths,
      queryItems: comps.queryItems?.toDictionary
    )
  }

  func linkType(comps: DeepLinkComponents, config: Configuration) throws -> LinkType {
    let scheme = comps.scheme
    let host = comps.host

    let type: LinkType =
      if scheme == config.customScheme {
        .customURLScheme
      } else if scheme == "http" || scheme == "https", host == config.universalLinkHost {
        .universalLink
      } else {
        throw Error.unexpectedURL
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
    let path = comps.fullPath
    let queryItems = comps.queryItems

    let firstMatch = deepLinks.first(where: { link in
      guard let queryItems, let keys = link.queryKeys, !keys.isEmpty else {
        return link.path == path
      }

      let keysContained = keys.allSatisfy { key in
        queryItems.contains(where: { $0.key == key })
      }

      return link.path == path && keysContained
    })

    guard let firstMatch else {
      throw Error.noMatchingDeepLink
    }

    return firstMatch
  }

  func matchCustomURLScheme(comps: DeepLinkComponents) throws -> any DeepLink {
    let matchPath = "/" + comps.fullPath
    let queryItems = comps.queryItems

    let firstMatch = deepLinks.first(where: { link in
      guard let queryItems, let keys = link.queryKeys, !keys.isEmpty else {
        return link.path == matchPath
      }

      let keysContained = keys.allSatisfy { key in
        queryItems.contains(where: { $0.key == key })
      }

      return link.path == matchPath && keysContained
    })

    guard let firstMatch else {
      throw Error.noMatchingDeepLink
    }

    return firstMatch
  }

  func extract(comps: DeepLinkComponents, link: any DeepLink) throws -> DeepLinkExtraction {
    guard let type = link.extractionType,
      case .pathID(let targetPath) = type
    else {
      return DeepLinkExtraction(
        scheme: comps.scheme,
        fullPath: comps.fullPath,
        paths: comps.paths,
        targetID: nil,
        queryItems: comps.queryItems
      )
    }

    let targetID = comps.paths.next(of: targetPath)

    return DeepLinkExtraction(
      scheme: comps.scheme,
      fullPath: comps.fullPath,
      paths: comps.paths,
      targetID: targetID,
      queryItems: comps.queryItems
    )
  }
}

extension DeepLinkOrganizer {
  public struct Configuration: Equatable {
    public let universalLinkHost: String?
    public let customScheme: String?
  }

  public enum Error: Swift.Error {
    case invalidURL
    case configNotSet
    case unexpectedURL
    case noMatchingDeepLink

    public var localizedDescription: String {
      switch self {
      case .invalidURL:
        return "Failed to parse URL. Check URL is in correct format."
      case .configNotSet:
        return "Configuration not set. Set configuration with `set(config:)` before handling URLs."
      case .unexpectedURL:
        return "URL scheme or host is unexpected. Check your `Configuration` settings."
      case .noMatchingDeepLink:
        return "No matching deep link was found."
      }
    }
  }

  enum LinkType {
    case universalLink
    case customURLScheme
  }
}

extension Array where Element: Equatable {
  func next(of element: Element) -> Element? {
    guard let index = self.firstIndex(of: element) else {
      return nil
    }

    let nextIndex = index + 1

    guard nextIndex < self.count else {
      return nil
    }

    return self[nextIndex]
  }
}
