import XCTest
import Dispatch

@testable import FutureLib

class FutureLibTests: XCTestCase {
    
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
            .onSuccess(qos: .userInitiated) { city -> Void in
                print("User's city is \(city)")
                cityExpectation.fulfill()
                
        }
        
        waitForExpectations(timeout: 5, handler: { error in XCTAssertNil(error, "Timeout") })
        
    }
    
    func testGetGoodCity() {
        
        let expectation1 = expectation(description: "Testing good city")
        getCityTemperature(withName: "Austin")
            .onSuccess(qos: .userInitiated) { temperature -> Double in
                print(temperature)
                XCTAssertEqual(temperature, 98.6)
                expectation1.fulfill()
                return temperature
            }
            .onSuccess(qos: .userInitiated) { temperature -> Void in
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
            .onSuccess(qos: .userInitiated) { temperature -> String in
                return temperature > 90 ? "Hot" : "Cold"
            }
            .onSuccess(qos: .userInitiated) { condition -> Void in
                print("The weather condition is \(condition)")
                expectation3.fulfill()
            }
        
        waitForExpectations(timeout: 5, handler: { error in XCTAssertNil(error, "Timeout") })
    }
    
    
    func testGetBadCity() {
        
        let expectation2 = expectation(description: "Testing bad city")
        
        getCityTemperature(withName: "Seattle")
            .onSuccess(qos: .userInitiated) { value in
                XCTFail()
            }
            .onFailure { error in
                print(error)
                expectation2.fulfill()
            }
        
        waitForExpectations(timeout: 5, handler: { error in XCTAssertNil(error, "Timeout") })
        
    }


    static var allTests : [(String, (FutureLibTests) -> () throws -> Void)] {
        return [
            ("testGetBadCity", testGetBadCity),
            ("testGetGoodCity", testGetGoodCity),
            ("testBiggerChain", testBiggerChain)
        ]
    }
}
