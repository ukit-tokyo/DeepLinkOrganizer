//
//  File.swift
//  DeepLinkOrganizer
//
//  Created by UKit Studio on 2025/09/10.
//

import Foundation

public enum ExtractionType: Equatable {
  case nextPathOf(String)
}

public protocol DeepLink: Equatable {
  var matchPaths: MatchPathPattern { get }
  var queryKeys: [String]? { get }
  var extraction: ExtractionType? { get }
  var handle: (DeepLinkExtraction) -> Void { get }
}

extension DeepLink {
  static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.matchPaths == rhs.matchPaths
      && lhs.queryKeys == rhs.queryKeys
      && lhs.extraction == rhs.extraction
  }

  public var queryKeys: [String]? { nil }
  public var extraction: ExtractionType? { nil }
}
