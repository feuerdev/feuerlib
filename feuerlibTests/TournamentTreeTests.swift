//
//  BinaryTreeTests.swift
//  FeuerlibTests
//
//  Created by Jannik Feuerhahn on 17.01.21.
//

import XCTest
@testable import Feuerlib

class TournamentTreeTests: XCTestCase {

    func testNodeReturnsValue() {
        let sut = Node(1)
        XCTAssertEqual(sut.winner, 1)
    }
    
    func testDefaultNodeLeavesReturnNil() {
        let sut = Node(1)
        XCTAssertNil(sut.left)
        XCTAssertNil(sut.right)
    }
    
    
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
    }
    
    func testTraversals() {
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
    
}
