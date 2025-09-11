//
//  File.swift
//  DeepLinkOrganizer
//
//  Created by Taichi Yuki on 2025/09/11.
//

import Foundation

public struct DeepLinkComponents {
  public let scheme: String
  public let host: String
  public let path: String
  public let queryItems: [URLQueryItem]?
}
