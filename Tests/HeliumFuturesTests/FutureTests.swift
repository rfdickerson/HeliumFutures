/**
    Copyright (c) 2016 IBM Corporation 2016
    Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
    The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

import XCTest
import Dispatch

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
	import Darwin
#elseif os(Linux)
	import Glibc
#endif

@testable import HeliumFutures

class HeliumFuturesTests: XCTestCase {
    
    struct NoCityFound: Error, CustomStringConvertible {
        
        let city: String
        
        var description: String {
            return "City requested was \(city)"
        }
        
    }
    
    func getUserCity(withName name: String, oncompletion: (String)->Void) {
     
        oncompletion("Austin")
        
    }
    
    func getUserCity(withName name: String) -> Future<String> {
        
        let p = Promise<String>()
        
        p.dispatchQueue.async {
            
            self.getUserCity(withName: name) {
                p.completeWithSuccess(value: $0)
            }
            
        }
        
        return p.future
        
    }
    
    
    func getCityTemperature(withName name: String) -> Future<Double> {
        
        let p = Promise<Double>()
        
        p.dispatchQueue.async {
            
            if name == "Austin" {
                sleep(1)
                p.completeWithSuccess(value: 98.6)
            } else {
                p.completeWithFail(error: NoCityFound(city: name))
            }
            
        }
        
        return p.future
    }
    
    func testGetUserCity() {
        
        let cityExpectation = expectation(description: "Getting the user's city")
        
        getUserCity(withName: "Robert")
            .onSuccess { city -> Void in
                print("User's city is \(city)")
                cityExpectation.fulfill()
                
        }
        
        waitForExpectations(timeout: 5, handler: { error in XCTAssertNil(error, "Timeout") })
        
    }
    
    func testGetGoodCity() {
        
        let expectation1 = expectation(description: "Testing good city")
        getCityTemperature(withName: "Austin")
            .onSuccess { temperature -> Double in
                print(temperature)
                XCTAssertEqual(temperature, 98.6)
                expectation1.fulfill()
                return temperature
            }
            .onSuccess { temperature -> Void in
                print("Temperature was \(temperature)")
                XCTAssertEqual(temperature, 98.6)
            }
            .onFailure { error in
                XCTFail()
            }
        
        waitForExpectations(timeout: 5, handler: { error in XCTAssertNil(error, "Timeout") })
    }
    
    func testBiggerChain() {
        let expectation3 = expectation(description: "Testing a longer chain")
        getCityTemperature(withName: "Austin")
            .onSuccess { temperature -> String in
                return temperature > 90 ? "Hot" : "Cold"
            }
            .onSuccess { condition -> Void in
                print("The weather condition is \(condition)")
                expectation3.fulfill()
            }
        
        waitForExpectations(timeout: 5, handler: { error in XCTAssertNil(error, "Timeout") })
    }
    
    
    func testGetBadCity() {
        
        let expectation2 = expectation(description: "Testing bad city")
        
        getCityTemperature(withName: "Seattle")
            .onSuccess{ value in
                XCTFail()
            }
            .onFailure { error in
                print(error)
                expectation2.fulfill()
            }
        
        waitForExpectations(timeout: 5, handler: { error in XCTAssertNil(error, "Timeout") })
        
    }


    static var allTests : [(String, (HeliumFuturesTests) -> () throws -> Void)] {
        return [
            ("testGetBadCity", testGetBadCity),
            ("testGetGoodCity", testGetGoodCity),
            ("testBiggerChain", testBiggerChain)
        ]
    }
}
