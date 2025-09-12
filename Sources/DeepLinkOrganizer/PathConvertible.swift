//
//  File.swift
//  DeepLinkOrganizer
//
//  Created by UKit Studio on 2025/09/13.
//

import Foundation

public protocol PathConvertible: Equatable where Self: Sequence {
  var pathArray: [String] { get }
}

extension String: PathConvertible {
  public var pathArray: [String] {
    self.components(separatedBy: "/")
      .filter { !$0.isEmpty }
  }
}

extension Array: PathConvertible where Element == String {
  public var pathArray: [String] {
    self.map { str in
      str.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
    }
  }
}
