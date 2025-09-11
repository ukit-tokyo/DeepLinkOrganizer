//
//  File.swift
//  DeepLinkOrganizer
//
//  Created by UKit Studio on 2025/09/10.
//

import Foundation

public protocol DeepLink: Equatable {
  var path: String { get }
  var queryKeys: [String]? { get }
  var handle: (DeepLinkComponents) -> Void { get }
}

extension DeepLink {
  static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.path == rhs.path && lhs.queryItems == rhs.queryItems
  }

  public var queryItems: [String]? { nil }
}
