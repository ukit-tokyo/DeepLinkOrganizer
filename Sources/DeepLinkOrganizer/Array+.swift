//
//  File.swift
//  DeepLinkOrganizer
//
//  Created by Taichi Yuki on 2025/09/12.
//

import Foundation

extension Array where Element == URLQueryItem {
  var toDictionary: [String: String] {
    self.reduce(into: [:]) { result, item in
      result[item.name] = item.value ?? ""
    }
  }
}

extension Array where Element: Equatable {
  func next(of element: Element) -> Element? {
    guard let index = self.firstIndex(of: element) else {
      return nil
    }

    let nextIndex = index + 1

    guard nextIndex < self.count else {
      return nil
    }

    return self[nextIndex]
  }
}

