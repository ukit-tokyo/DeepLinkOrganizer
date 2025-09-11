//
//  File.swift
//  DeepLinkOrganizer
//
//  Created by Taichi Yuki on 2025/09/11.
//

import Foundation

struct DeepLinkComponents {
  let scheme: String
  let fullPath: String
  let paths: [String]
  let queryItems: [String: String]?

  var host: String? {
    paths.first
  }
}

public struct DeepLinkExtraction {
  public let scheme: String
  public let fullPath: String
  public let paths: [String]
  public let targetID: String?
  public let queryItems: [String: String]?
}

extension Array where Element == URLQueryItem {
  var toDictionary: [String: String] {
    self.reduce(into: [:]) { result, item in
      result[item.name] = item.value ?? ""
    }
  }
}
