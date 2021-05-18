//
//  Node.swift
//  Feuerlib
//
//  Created by Jannik Feuerhahn on 03.03.21.
//

import Foundation

///A Node represents one match, with two optional competitors and one optinal winner
public class Node<T> {
    public var winner: T?
    public var left: Node?
    public var right: Node?
    
    init() {
        //
    }
    
    init(_ value:T) {
        self.winner = value
    }
    
    ///Returns how many matches have the winner of this match has played before
    public func depth() -> Int {
        if left == nil && right == nil {
            return 0
        } else {
            let lDepth = (left?.depth() ?? 0) + 1
            let rDepth = (right?.depth() ?? 0) + 1
            let result = max(lDepth, rDepth)
            return result
        }
    }
}
