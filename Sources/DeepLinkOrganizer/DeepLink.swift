//
//  File.swift
//  DeepLinkOrganizer
//
//  Created by UKit Studio on 2025/09/10.
//

import Foundation

public enum DeepLinkAction: Equatable {
  case none
}

public protocol DeepLink: Equatable {
  var host: String? { get }
  var path: String { get }
  var queryItems: [String: String]? { get }
  var action: DeepLinkAction { get }

  func handle() -> DeepLinkAction
}

extension DeepLink {
  public var host: String? { nil }
  public var queryItems: [String: String]? { nil }

  public func handle() -> DeepLinkAction { action }
}
