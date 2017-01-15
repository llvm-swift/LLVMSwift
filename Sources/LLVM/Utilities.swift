//
//  Utilities.swift
//  LLVM
//
//  Created by Harlan Haskins on 1/15/17.
//
//

import Foundation

extension UnsafeMutablePointer {
  internal func asArray(count: Int) -> [Pointee] {
    var vals = [Pointee]()
    for i in 0..<count {
      vals.append(self[i])
    }
    return vals
  }
}
