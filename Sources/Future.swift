/**
    Copyright (c) 2016 IBM Corporation 2016


    Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

*/

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
    public func onSuccess<S>( completionHander: @escaping (T) throws ->S ) -> Future<S> {
        
        let nextFuture = Future<S>()
        
        futureQueue.sync() {
            
            semaphore.wait()
            
            self.lock.wait()
            let value = self.value!
            self.lock.signal()
            
            switch value {
            case .success(let a):
                
                do {
                let returnedValue = try completionHander(a)
                nextFuture.notify(.success(returnedValue))
                } catch {
                    // nextFuture.notify(.error())
                }
                
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

