//
//  File.swift
//  DeepLinkOrganizer
//
//  Created by UKit Studio on 2025/09/13.
//

import Foundation
import Testing

@testable import DeepLinkOrganizer

@Test
func pathArray() throws {
  let case1 = "/this/is/path/"
  let expect1 = ["this", "is", "path"]
  #expect(case1.pathArray == expect1)

  let case2 = "/this"
  let expect2 = ["this"]
  #expect(case2.pathArray == expect2)

  let case3 = ""
  let expect3: [String] = []
  #expect(case3.pathArray == expect3)

  let case4 = ["this", "is", "path"]
  let expect4 = ["this", "is", "path"]
  #expect(case4.pathArray == expect4)

  let case5 = ["/this", "is", "path/"]
  let expect5 = ["this", "is", "path"]
  #expect(case5.pathArray == expect5)

  let case6: [String] = []
  let expect6: [String] = []
  #expect(case6.pathArray == expect6)
}
