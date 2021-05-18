//
//  BinaryTree.swift
//  Feuerlib
//
//  Created by Jannik Feuerhahn on 17.01.21.
//

import Foundation

///A TournamentTree is a binary Tree that is built from the bottom up to represent a knockout tournament.
public class TournamentTree<T> {
    
    ///Root node of the tree
    public var finals: Node<T>
    public var competitors: [T]
    
    public init(_ competitors:[T]) {
        self.competitors = competitors
        self.finals = Node()
        
        build(finals, rounds: self.rounds())
        populate(finals, competitors)
        resolveByes(finals)
    }
    
    ///Returns the number of Rounds in the Tournament (Layers in the Tree)
    public func rounds() -> Int {
        guard competitors.count > 0 else {
            return 0
        }
        
        return Int(ceil(log2(Double(competitors.count))))
    }
    
    ///Returns the first unresolved match found in a bottom-up-breadth-first search
    public func nextOpenMatch() -> Node<T>? {
        var found = false
        var result: Node<T>? = nil
        traverseBottomUpBreadth { (node) in
            if !found,
               node.left?.winner != nil,
               node.right?.winner != nil,
               node.winner == nil {
                result = node
                found = true
            }
        }
        return result
    }
    
    ///Calls the given closure for every Node in the Tree in order depth-first order
    func traverse(perNode: ((Node<T>) -> Void)) {
        func helper(_ node:Node<T>, perNode: ((Node<T>) -> Void)) {
            perNode(node)
            if let left = node.left {
                helper(left, perNode: perNode)
            }
            if let right = node.right {
                helper(right, perNode: perNode)
            }
        }
        helper(self.finals, perNode: perNode)
    }
    
    ///Helper function
    private func traverseBottomUpBreadth(levels:Int, perNode: ((Node<T>) -> Void)) {
        var result = [Node<T>]();

        var q = [finals]
        while !q.isEmpty {
            var nodes = [Node<T>]();
            for n in q {
                nodes.append(q.removeFirst())
                if let left = n.left {
                    q.append(left)
                }
                if let right = n.right {
                    q.append(right)
                }
            }
            result.append(contentsOf: nodes.reversed())
        }
        

        for n in result.reversed() {
            if n.depth() <= levels {
                perNode(n)
            }
        }
    }
    
    ///Calls the given closure for every Node in the Tree in order of the matches being played
    public func traverseBottomUpBreadth(perNode: ((Node<T>) -> Void)) {
        traverseBottomUpBreadth(levels: self.rounds(), perNode: perNode)
    }
    
    ///Automatically advances players in matches with only one competitor
    public func resolveByes(_ node:Node<T>) {
        traverseBottomUpBreadth(levels: 1) { (node) in
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
    
    ///Creates an empty Tournament Tree structure acording to the number of rounds to be played
    @discardableResult private func build(_ root:Node<T>, rounds:Int) -> Node<T> {
        if rounds > 0 {
            root.left = build(Node(),rounds: rounds - 1)
            root.right = build(Node(),rounds: rounds - 1)
        }
        return root
    }
    
    ///Populates a Tournament tree breadth first and bottom up
    private func populate(_ tree:Node<T>, _ competitors:[T]) {
        var index = 0
        var evenIndex = 0
        var oddIndex = 0
        let leafs = pow(2.0, Double(self.rounds()))
        traverseBottomUpBreadth { (node) in
            if index < Int(leafs) {
                if index % 2 == 0 {
                    node.winner = competitors[safe: evenIndex]
                    evenIndex += 1
                } else {
                    
                    node.winner = competitors[safe: Int(leafs/2)+oddIndex]
                    oddIndex += 1
                }
            }
            index += 1
        }
    }
}
