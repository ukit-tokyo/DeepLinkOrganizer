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
  case startsWith
  case contains
}

public protocol DeepLink: Equatable {
  var path: String { get }
  var queryKeys: [String]? { get }
  var matchPathPattern: MatchPathPattern { get }
  var extractionType: ExtractionType? { get }
  var handle: (DeepLinkExtraction) -> Void { get }
}

extension DeepLink {
  static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.path == rhs.path
      && lhs.queryKeys == rhs.queryKeys
      && lhs.matchPathPattern == rhs.matchPathPattern
      && lhs.extractionType == rhs.extractionType
  }

  public var queryKeys: [String]? { nil }
  public var matchPathPattern: MatchPathPattern { .startsWith }
  public var extractionType: ExtractionType? { nil }
}
