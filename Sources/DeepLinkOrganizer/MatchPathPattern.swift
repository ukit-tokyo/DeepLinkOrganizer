//
//  File.swift
//  DeepLinkOrganizer
//
//  Created by UKit Studio on 2025/09/13.
//

public enum MatchPathPattern: Equatable {
  case startsWith(any PathConvertible)
  case contains(any PathConvertible)
}

extension MatchPathPattern {
  public static func == (lhs: MatchPathPattern, rhs: MatchPathPattern) -> Bool {
    switch (lhs, rhs) {
    case (.startsWith(let l), .startsWith(let r)):
      return l.pathArray == r.pathArray
    case (.contains(let l), .contains(let r)):
      return l.pathArray == r.pathArray
    default:
      return false
    }
  }
}
