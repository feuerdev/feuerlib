//
//  General.swift
//  Feuerlib
//
//  Created by Jannik Feuerhahn on 27.12.20.
//

import Foundation


///Returns the CFBundleName key from the main bundle
public func getAppName() -> String? {
    return Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
}

/// Prints out the time it took for the closure to run
public func profile(title:String, operation:() -> Void) {
    let timeElapsed = profile {
        operation()
    }
    print("Time elapsed for \(title): \(timeElapsed) s.")
}

///Returns the time it took for the closure to run
public func profile(operation:() -> Void) -> TimeInterval {
    let startTime = CFAbsoluteTimeGetCurrent()
    operation()
    let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
    return timeElapsed
}
