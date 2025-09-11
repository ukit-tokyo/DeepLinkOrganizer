//
//  File.swift
//  DeepLinkOrganizer
//
//  Created by UKit Studio on 2025/09/10.
//

import Foundation

public enum ExtractionType {
  case pathID(String)
}

public protocol DeepLink: Equatable {
  var path: String { get }
  var queryKeys: [String]? { get }
  var extractionType: ExtractionType? { get }
  var handle: (DeepLinkExtraction) -> Void { get }
}

extension DeepLink {
  static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.path == rhs.path && lhs.queryKeys == rhs.queryKeys
  }

  public var queryKeys: [String]? { nil }
  public var extractionType: ExtractionType? { nil }
}
