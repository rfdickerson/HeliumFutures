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
    
    func getCityTemperature(withName name: String) -> Future<Double> {
        let p = Promise<Double>()
        
        p.dispatchQueue.async {
            
            if name == "Austin" {
                sleep(3)
                p.completeWithSuccess(value: 98.6)
            } else {
                p.completeWithFail(error: NoCityFound(city: name))
            }
            
        }
        
        return p.future
    }
    
    
    func testGetGoodCity() {
        
        let expectation1 = expectation(description: "Testing good city")
        let newNumber = getCityTemperature(withName: "Austin")
        newNumber.onSuccess(qos: .userInitiated) { value in
            print(value)
            XCTAssertEqual(value, 98.6)
            expectation1.fulfill()
        }
        .onFailure { error in
            XCTFail()
        }
        
        waitForExpectations(timeout: 5, handler: { error in XCTAssertNil(error, "Timeout") })
    }
    
    func testGetBadCity() {
        
        let expectation2 = expectation(description: "Testing bad city")
        
        let newNumber = getCityTemperature(withName: "Seattle")
        newNumber.onSuccess(qos: .userInitiated) { value in
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
            ("testGetGoodCity", testGetGoodCity)
        ]
    }
}
