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
        
        build(finals, rounds: rounds)
        populate(finals, competitors)
        resolveByes(finals)
    }
    
    private func traverse(_ node:Node<T>, perNode: ((Node<T>) -> Void)) {
        
        perNode(node)
        
        if let left = node.left {
            traverse(left, perNode: perNode)
        }
        if let right = node.right {
            traverse(right, perNode: perNode)
        }
        
        
    }
    
    private func resolveByes(_ node:Node<T>) {
        traverse(node) { (node) in
            let leftWinner = node.left?.winner
            let rightWinner = node.right?.winner
            
            if leftWinner != nil, rightWinner == nil {
                node.winner = leftWinner
            }
            if rightWinner != nil, leftWinner == nil {
                node.winner = rightWinner
            }
        }
    }
    
    /**
     Creates an empty Tournament Tree structure acording to the number of rounds to be played
     */
    @discardableResult private func build(_ root:Node<T>, rounds:Int) -> Node<T> {
        if rounds > 0 {
            root.left = build(Node(),rounds: rounds - 1)
            root.right = build(Node(),rounds: rounds - 1)
        }
        return root
    }
    
    /**
     Populates a Tournament tree breadth first and bottom up
     */
    private func populate(_ tree:Node<T>, _ competitors:[T]) {
        for comp in competitors {
            insert(tree, comp)
        }
    }
    
    /**
     Inserts a nodeat the bottom and left most possible spot
     */
    @discardableResult private func insert(_ node:Node<T>, _ competitor:T) -> Bool {
        
        if
            node.left == nil,
            node.right == nil,
            node.winner == nil {
            node.winner = competitor
            return true
        }
        
        if let left = node.left, let right = node.right {
            if insert(left, competitor) {
                return true
            }
            
            if insert(right, competitor) {
                return true
            }
        }
        return false
    }
}
