

import Foundation
import Dispatch

enum Result<T> {
    case error(Error)
    case success(T)
}

class Promise<T> {
    
    let dispatchQueue: DispatchQueue
    
    let future: Future<T>
    
    init() {
        
        future = Future<T>()
        
        dispatchQueue = DispatchQueue(label: "promise",
                                      qos: .userInitiated,
                                      attributes: .concurrent)
    }
    
    func completeWithSuccess(value: T) {
        future.notify(.success(value))
    }
    
    func completeWithFail(error: Error) {
        future.notify(.error(error))
    }
    
}






