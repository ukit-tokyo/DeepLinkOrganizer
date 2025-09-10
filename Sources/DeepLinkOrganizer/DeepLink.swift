//
//  File.swift
//  DeepLinkOrganizer
//
//  Created by UKit Studio on 2025/09/10.
//

import Foundation

public protocol DeepLink: Equatable {
  associatedtype Action

  var path: String { get }
  var queryItems: [URLQueryItem]? { get }

  func handle(with queryItems: [URLQueryItem]?) -> Action
}

extension DeepLink {
  public var queryItems: [URLQueryItem]? { nil }
}
