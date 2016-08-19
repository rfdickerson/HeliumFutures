# FutureLib

Futures and Promises for Swift 3

## Example Usage:

```swift
let temperatureFuture = getCityTemperature(withName: "Austin")
temperatureFuture.onSuccess(qos: .userInitiated) { value in
    
    print(value)
    
    
}.onFailure { error in
        
    print(error)
}
```
