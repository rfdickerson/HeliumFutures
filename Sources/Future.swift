import Foundation
import Dispatch

class Future<T> {
    
    // var dispatchQueue: DispatchQueue?
    // var onCompletion: (@escaping (T)->Any)?
    // var onFailureCallback: (@escaping (Error)->Void)?
    
    var value: Result<T>?
    
    let lock = DispatchSemaphore(value: 0)
    
    public init() {
        
    }
    
    public func notify(_ value: Result<T>) {
        
        //lock.wait()
        self.value = value
        lock.signal()
    }
    
    /**
     Set up a routine for when the Future has a successful value.
     
     - parameter qos:                Quality service level of the returned completionHandler
     - parameter completionHandler:  Callback with a successful value
     
     - returns: new Future
     */
    @discardableResult
    public func onSuccess<S>(qos: DispatchQoS,
                          completionHander: @escaping (T)->S) -> Future<S> {
        
        // onCompletion = completionHander
        let dispatchQueue = DispatchQueue(label: "future", qos: qos, attributes: .concurrent)
        
        let nextFuture = Future<S>()
        
        dispatchQueue.async {
            
            self.lock.wait()
            
            switch self.value! {
            case .success(let a):
                
                let returnedValue = completionHander(a)
                nextFuture.notify(.success(returnedValue))
                
            case .error(let error):
                
                //self.onFailure?(error)
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
        
        self.lock.wait()
        
        switch self.value! {
        case .success:
            print("This should not happen")
        case .error(let error):
            completionHander(error)
        }
        
        return self
    }
    
    @discardableResult
    public func then(completionHandler: @escaping (T)->Void) -> Future<T> {
        // TODO: Unimplemented
        return Future()
    }
    
}

