//
//  KCKSwift.swift
//  Kiriha
//
//  Created by 御前崎悠羽 on 2022/1/27.
//

import Foundation

public var enablePrintInRelease: Bool = false

public func kiriha_print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
#if DEBUG
    for item in items {
        print(item)
    }
#else
    if enablePrintInRelease {
        for item in items {
            print(item)
        }
    }
#endif
}

public func kiriha_file_print(_ items: Any..., separator: String = " ", terminator: String = "\n",
                          file: String = #file, method: String = #function, line: Int = #line) {
#if DEBUG
    print("file: \(file), method: \(method), line: \(line)")
#else
    if enablePrintInRelease {
        print("file: \(file), method: \(method), line: \(line)")
    }
#endif
    kiriha_print(items, separator: separator, terminator: terminator)
}
