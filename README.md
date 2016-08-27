# Ileri

Elegant and lightweight Futures for Swift 3

## Example Usage:

```swift
let temperatureFuture = getCityTemperature(withName: "Austin")
    .onSuccess { value -> Void in
        print(value)
    }.onFailure { error in
        print(error)
    }
```
