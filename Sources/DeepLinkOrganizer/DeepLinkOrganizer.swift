// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

public final class DeepLinkOrganizer {
  private(set) public var deepLinks: [any DeepLink] = []

  public init(deepLinks: [any DeepLink] = []) {
    self.deepLinks = deepLinks
  }

  public func register(deepLinks: [any DeepLink]) {
    self.deepLinks = deepLinks
  }

  public func append(deepLink: any DeepLink) {
    self.deepLinks.append(deepLink)
  }

  public func handle() -> DeepLinkAction {
    .none
  }
}
