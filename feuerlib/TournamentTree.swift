//
//  BinaryTree.swift
//  Feuerlib
//
//  Created by Jannik Feuerhahn on 17.01.21.
//

import Foundation

class Node<T> {
    var winner: T?
    var left: Node?
    var right: Node?
    
    convenience init(_ value:T) {
        self.init()
        self.winner = value
    }
}

class TournamentTree<T> {
    var finals: Node<T>
    
    init(_ competitors:[T]) {
        finals = Node()
        
        let count = competitors.count
        
        guard count > 0 else {
            return
        }
        
        let rounds = Int(ceil(log2(Double(count))))
        
        build(rounds: rounds)
//        populate(
    }
    
    func build(root:Node<T>?, rounds:Int) {
        if rounds == 0 {
            return
        } else {
            let root = root ?? self.finals
            root.left = Node()
            build(root: root.left!, rounds: rounds-1)
            root.right = Node()
            build(root: root.right!, rounds: rounds-1)
        }
    }
}
