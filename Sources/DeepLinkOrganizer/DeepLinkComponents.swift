//
//  File.swift
//  DeepLinkOrganizer
//
//  Created by UKit Studio on 2025/09/11.
//

import Foundation

struct DeepLinkComponents: Equatable {
  let scheme: String
  let host: String
  let path: String
  let fullPath: String
  let paths: [String]
  let queryItems: [String: String]?

  init(urlComponents: URLComponents) {
    let host = urlComponents.host ?? ""
    let fullPath = host + urlComponents.path

    self.scheme = urlComponents.scheme ?? ""
    self.host = host
    self.path = urlComponents.path
    self.fullPath = fullPath
    self.paths = fullPath
      .components(separatedBy: "/")
      .filter { !$0.isEmpty }

    self.queryItems = urlComponents.queryItems?.toDictionary
  }
}

public struct DeepLinkExtraction: Equatable {
  public let scheme: String
  public let host: String
  public let path: String
  public let fullPath: String
  public let paths: [String]
  public let targetPath: String?
  public let queryItems: [String: String]?

  public init (
    scheme: String,
    host: String,
    path: String,
    fullPath: String,
    paths: [String],
    targetPath: String?,
    queryItems: [String: String]?
  ) {
    self.scheme = scheme
    self.host = host
    self.path = path
    self.fullPath = fullPath
    self.paths = paths
    self.targetPath = targetPath
    self.queryItems = queryItems
  }

  init(comps: DeepLinkComponents, targetPath: String?) {
    self.scheme = comps.scheme
    self.host = comps.host
    self.path = comps.path
    self.fullPath = comps.fullPath
    self.paths = comps.paths
    self.queryItems = comps.queryItems

    self.targetPath = targetPath
  }
}
