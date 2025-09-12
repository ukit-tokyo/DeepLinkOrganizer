//
//  File.swift
//  DeepLinkOrganizer
//
//  Created by Taichi Yuki on 2025/09/12.
//

import Foundation
import Testing

@testable import DeepLinkOrganizer

@Suite("Array Extension Tests")
struct ArrayExtensionTests {
  @Test
  func toDictionary() {
    let array1: [URLQueryItem] = [
      URLQueryItem(name: "key1", value: "value1"),
      URLQueryItem(name: "key2", value: "value2"),
    ]
    let expect1: [String: String] = [
      "key1": "value1",
      "key2": "value2",
    ]
    #expect(array1.toDictionary == expect1)

    let array2: [URLQueryItem] = []
    let expect2: [String: String] = [:]
    #expect(array2.toDictionary == expect2)

    let array3: [URLQueryItem] = [
      URLQueryItem(name: "key1", value: nil),
      URLQueryItem(name: "key2", value: "value2"),
    ]
    let expect3: [String: String] = [
      "key1": "",
      "key2": "value2",
    ]
    #expect(array3.toDictionary == expect3)
  }

  @Test
  func nextOf() {
    let array1 = ["a", "b", "c", "d"]
    #expect(array1.next(of: "a") == "b")
    #expect(array1.next(of: "b") == "c")
    #expect(array1.next(of: "c") == "d")
    #expect(array1.next(of: "d") == nil)
    #expect(array1.next(of: "e") == nil)

    let array2: [String] = []
    #expect(array2.next(of: "a") == nil)

    let array3 = ["only"]
    #expect(array3.next(of: "only") == nil)
    #expect(array3.next(of: "a") == nil)
  }
}
