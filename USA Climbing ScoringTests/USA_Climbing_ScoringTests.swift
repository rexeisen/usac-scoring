//
//  USA_Climbing_ScoringTests.swift
//  USA Climbing ScoringTests
//
//  Created by Jon Rexeisen on 3/14/23.
//

import XCTest
@testable import USA_Climbing_Scoring

final class USA_Climbing_ScoringTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }
    
    func testRouteSortLastBest() throws {
        let example = """
{
"attempts": [
  "9",
  "10",
  "12"
],
"climbTime": "02:58.58",
"disc": "leadtr",
"eid": "1188",
"jid": 3373,
"lid": "L5",
"live": 1,
"mid": "29670274",
"rid": "R10",
"round": "final",
"tsRecv": 1677952378677,
"tsSent": 1677952378295,
"ver": 8
}
"""
        let decoder = JSONDecoder()
        let data = try XCTUnwrap(example.data(using: .utf8))
        let routeCard = try decoder.decode(RouteCard.self, from: data)
        
        let bestAttempt = try XCTUnwrap(routeCard.bestAttempt)
        XCTAssertEqual(bestAttempt.score, "12")
        XCTAssertEqual(bestAttempt.attempt, 3)
        
    }
    
    func testRouteSortFirstBest() throws {
        let example = """
{
"attempts": [
  "12",
  "11",
  "9"
],
"climbTime": "02:58.58",
"disc": "leadtr",
"eid": "1188",
"jid": 3373,
"lid": "L5",
"live": 1,
"mid": "29670274",
"rid": "R10",
"round": "final",
"tsRecv": 1677952378677,
"tsSent": 1677952378295,
"ver": 8
}
"""
        let decoder = JSONDecoder()
        let data = try XCTUnwrap(example.data(using: .utf8))
        let routeCard = try decoder.decode(RouteCard.self, from: data)
        
        let bestAttempt = try XCTUnwrap(routeCard.bestAttempt)
        XCTAssertEqual(bestAttempt.score, "12")
        XCTAssertEqual(bestAttempt.attempt, 1)
        
    }
    
    func testRouteSortTop() throws {
        let example = """
{
"attempts": [
  "12",
  "TOP"
],
"climbTime": "02:58.58",
"disc": "leadtr",
"eid": "1188",
"jid": 3373,
"lid": "L5",
"live": 1,
"mid": "29670274",
"rid": "R10",
"round": "final",
"tsRecv": 1677952378677,
"tsSent": 1677952378295,
"ver": 8
}
"""
        let decoder = JSONDecoder()
        let data = try XCTUnwrap(example.data(using: .utf8))
        let routeCard = try decoder.decode(RouteCard.self, from: data)
        
        let bestAttempt = try XCTUnwrap(routeCard.bestAttempt)
        XCTAssertEqual(bestAttempt.score, "TOP")
        XCTAssertEqual(bestAttempt.attempt, 2)
        
    }
    
    func testRouteSameScore() throws {
        let example = """
{
"attempts": [
  "7",
  "0",
  "7",
],
"climbTime": "02:58.58",
"disc": "leadtr",
"eid": "1188",
"jid": 3373,
"lid": "L5",
"live": 1,
"mid": "29670274",
"rid": "R10",
"round": "final",
"tsRecv": 1677952378677,
"tsSent": 1677952378295,
"ver": 8
}
"""
        let decoder = JSONDecoder()
        let data = try XCTUnwrap(example.data(using: .utf8))
        let routeCard = try decoder.decode(RouteCard.self, from: data)
        
        let bestAttempt = try XCTUnwrap(routeCard.bestAttempt)
        XCTAssertEqual(bestAttempt.score, "7")
        XCTAssertEqual(bestAttempt.attempt, 1)
        
    }
    
    func testRouteSameScoreWithPlus() throws {
        let example = """
{
"attempts": [
  "7",
  "0",
  "7+",
],
"climbTime": "02:58.58",
"disc": "leadtr",
"eid": "1188",
"jid": 3373,
"lid": "L5",
"live": 1,
"mid": "29670274",
"rid": "R10",
"round": "final",
"tsRecv": 1677952378677,
"tsSent": 1677952378295,
"ver": 8
}
"""
        let decoder = JSONDecoder()
        let data = try XCTUnwrap(example.data(using: .utf8))
        let routeCard = try decoder.decode(RouteCard.self, from: data)
        
        let bestAttempt = try XCTUnwrap(routeCard.bestAttempt)
        XCTAssertEqual(bestAttempt.score, "7+")
        XCTAssertEqual(bestAttempt.attempt, 3)
        
    }

}
