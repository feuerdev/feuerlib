//
//  BinaryTreeTests.swift
//  FeuerlibTests
//
//  Created by Jannik Feuerhahn on 17.01.21.
//

import XCTest
@testable import Feuerlib

class TournamentTreeTests: XCTestCase {

    //Node Tests
    func testNodeReturnsValue() {
        let sut = Node(1)
        XCTAssertEqual(sut.winner, 1)
    }
    
    func testDefaultNodeLeavesReturnNil() {
        let sut = Node(1)
        XCTAssertNil(sut.left)
        XCTAssertNil(sut.right)
    }
    
    func testDepthOfDefaultNodeIsZero() {
        let sut = Node(1)
        XCTAssertEqual(sut.depth(), 0)
    }
    
    func testDepthOfTwoLevelNodeIsTwo() {
        let sut = Node(1)
        sut.left = Node(1)
        sut.left?.left = Node(1)
        XCTAssertEqual(sut.depth(), 2)
        let sut2 = Node(1)
        sut2.right = Node(1)
        sut2.right?.left = Node(1)
        XCTAssertEqual(sut2.depth(), 2)
    }
    
    //Tournament Tests
    func testCreateTournamentWithoutCompetitorsDoesNotCrash() {
        XCTAssertNoThrow(TournamentTree([]))
    }
    
    func testCreateTournamentWithOneCompetitorWinsTournament() {
        let sut = TournamentTree([0])
        XCTAssertEqual(sut.finals.winner, 0)
    }
    
    func testCreateTournamentWithTwoCompetitorsHasNoWinner() {
        let sut = TournamentTree([0, 1])
        XCTAssertNil(sut.finals.winner)
    }
    
    func testCreateTournamentWithThreeCompetitorsCreatesTwoMatches() {
        let sut = TournamentTree([0,1,2])
        XCTAssertNotNil(sut.finals.left)
        XCTAssertNil(sut.finals.left?.winner)
        XCTAssertNotNil(sut.finals.right)
    }
    
    func testCreateTournamentWithThreeCompetitorsThirdCompetitorInstantlyWinsHisBye() {
        let sut = TournamentTree([0,1,2])
        XCTAssertEqual(sut.finals.right?.winner, 1)
        
        //Test resolving a bye where the left side is of a match empty. During normal creation this never happens
        let sut2 = TournamentTree([0,1,2])
        sut2.finals.right?.right = sut2.finals.right?.left
        sut2.finals.right?.left = nil
        sut2.finals.right?.winner = nil
        sut2.resolveByes(sut2.finals)
        XCTAssertEqual(sut.finals.right?.winner, 1)
    }
    
    func testDepthFirstTraversal() {
        let sut = TournamentTree(Array(1...4))
        var count = 0
        var items = [Int]()
        sut.traverse() { (node) in
            count += 1
            items.append(node.winner ?? -1)
        }
        XCTAssertEqual(count, 7)
        XCTAssertEqual(items, [-1, -1, 1, 3, -1, 2, 4])
    }
    
    func testBottomUpBreadthTraversal() {
        let sut = TournamentTree(Array(1...8))
        var count = 0
        var items = [Int]()
        sut.traverseBottomUpBreadth { (node) in
            count += 1
            if let comp = node.winner {
                items.append(comp)
            }
        }
        XCTAssertEqual(items, [1,5,2,6,3,7,4,8])
        XCTAssertEqual(count, 15)
    }
    
    func testNextOpenMatchReturnsNilIfNoMatch() {
        let sut = TournamentTree([])
        XCTAssertNil(sut.nextOpenMatch())
    }
    
    func testNextOpenMatchReturnsNextUndecidedMatch() {
        let sut = TournamentTree(Array(1...3))
        XCTAssertEqual(sut.nextOpenMatch()!.left!.winner, 1)
        sut.finals.left?.winner = 1
        XCTAssertEqual(sut.nextOpenMatch()!.right!.winner, 2)
        
    }
}
