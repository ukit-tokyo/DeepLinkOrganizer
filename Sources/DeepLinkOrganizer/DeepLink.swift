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

public enum MatchPathPattern: Equatable {
  case startsWith([String])
  case contains([String])
}

public protocol DeepLink: Equatable {
  var matchPaths: MatchPathPattern { get }
  var queryKeys: [String]? { get }
  var extractionType: ExtractionType? { get }
  var handle: (DeepLinkExtraction) -> Void { get }
}

extension DeepLink {
  static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.matchPaths == rhs.matchPaths
      && lhs.queryKeys == rhs.queryKeys
      && lhs.extractionType == rhs.extractionType
  }

  public var queryKeys: [String]? { nil }
  public var extractionType: ExtractionType? { nil }
}
