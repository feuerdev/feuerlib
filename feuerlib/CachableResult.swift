//
//  CachableResult.swift
//  Feuerlib
//
//  Created by Jannik Feuerhahn on 30.12.20.
//

import Foundation

public class CachableResult<Key, Success, Failure> where Failure : Error {
    public var result:Result<Success, Failure>
    public var cacheKey:Key
    
    public init(_ result:Result<Success, Failure>, _ cacheKey:Key) {
        self.result = result
        self.cacheKey = cacheKey
    }
}
