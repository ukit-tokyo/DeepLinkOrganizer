// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

public class DeepLinkOrganizer {
  let url: URL

  init(url: URL) {
    self.url = url
  }

  func handle() -> String {
    "handled"
  }
}
