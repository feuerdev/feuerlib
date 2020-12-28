//
//  General.swift
//  Feuerlib
//
//  Created by Jannik Feuerhahn on 27.12.20.
//

import Foundation

/*
 Returns the CFBundleName key from the main bundle
 */
public func getAppName() -> String {
    return Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as! String
}
