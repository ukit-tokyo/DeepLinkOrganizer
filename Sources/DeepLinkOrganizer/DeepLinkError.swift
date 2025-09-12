//
//  File.swift
//  DeepLinkOrganizer
//
//  Created by UKit Studio on 2025/09/12.
//

import Foundation

public enum DeepLinkError: Swift.Error {
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
