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
    
    
    func testExample() {
        
        let newNumber = getCityTemperature(withName: "Seattle")
        newNumber.onSuccess(qos: .userInitiated) { value in
            
            print(value)
            
            
        }
        .onFailure { error in
                
                print(error)
        }

        sleep(2)
        
        
    }


    static var allTests : [(String, (FutureLibTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
