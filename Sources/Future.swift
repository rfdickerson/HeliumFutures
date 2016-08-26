import Foundation
import Dispatch

let futureQueue = DispatchQueue(label: "future", qos: .userInitiated, attributes: .concurrent)

class Future<T> {
    
    var value: Result<T>?
    
    let lock = DispatchSemaphore(value: 1)
    
    let semaphore = DispatchSemaphore(value: 0)
    
    // let group = DispatchGroup()
    
    public init() { }
    
    public func notify(_ value: Result<T>) {
        
        lock.wait()
        self.value = value
        lock.signal()
        
        semaphore.signal()
        
    }
    
    /**
     Set up a routine for when the Future has a successful value.
     
     - parameter qos:                Quality service level of the returned completionHandler
     - parameter completionHandler:  Callback with a successful value
     
     - returns: new Future
     */
    @discardableResult
    public func onSuccess<S>( completionHander: @escaping (T)->S ) -> Future<S> {
        
        let nextFuture = Future<S>()
        
        futureQueue.sync() {
            
            semaphore.wait()
            
            self.lock.wait()
            let value = self.value!
            self.lock.signal()
            
            switch value {
            case .success(let a):
                
                let returnedValue = completionHander(a)
                nextFuture.notify(.success(returnedValue))
                
            case .error(let error):
                
                nextFuture.notify(.error(error))
                
            }
            
        }
        
        return nextFuture
    }
    
    /**
     Set up a routine if there is an error.
     
     - parameter completionHandler:  Callback with an error
     
     - returns: new Future
     */
    @discardableResult
    public func onFailure(completionHander: @escaping (Error)->Void) -> Future<T> {
        
        semaphore.wait()
        
        self.lock.wait()
        let value = self.value!
        self.lock.signal()
        
        switch value {
        case .error(let error):
            completionHander(error)
        default:
            break
        }
        
        
        
        return self
    }
    
    @discardableResult
    public func then(completionHandler: @escaping (T)->Void) -> Future<T> {
        // TODO: Unimplemented
        return Future()
    }
    
}

