[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

#  StopKit

`StopKit` is a small iOS and Mac framework for working with units of light in photography. `StopKit` is fully compatible with both Objective-C and Swift.

Here at Cascable, we use `StopKit` extensively — In our camera SDK [CascableCore](https://developer.cascable.se/), camera exposure properties such as shutter speed, aperture, exposure compensation, ISO, etc are all `StopKit` values, and our consumer app [Cascable](http://cascable.se/) uses `StopKit` to power its Shutter Robot automation tool.

## Examples

### Comparing Values

When comparing values, `StopKit` provides `compare(_:)` and `stopsDifference(from:)`. Since you can't compare indeterminate values with determinate values, these methods can fail, returning `ExposureComparisonInvalid` or `nil`  respectively. You can use the `isDeterminate` property to exclude such values from calculations.

In general, a postive stops value means "more light" or "a brighter image", and a negative value means "less light" or "a darker image". However, `compare(_:)` will return a result that sorts the values into what the user would typically consider "correct" (for example, aperture values have the smallest number/largest stops value at the beginning of the list).

```swift

print(ApertureValue.f8().stopsDifference(from: ApertureValue.f4()))
// -2 stops (since f8 lets less light through than f4)

print(ApertureValue.f8().compare(ApertureValue.f4()).rawValue)
// -1  (ComparisonResult.orderedAscending)

print(ApertureValue.f8().stopsDifference(from: ApertureValue.f4()))
// nil, since this isn't a valid comparison

print(ApertureValue.f8().compare(ShutterSpeedValue.oneSecondShutterSpeed()).rawValue)
// -100 (ExposureComparisonInvalid), since this isn't a valid comparison
```


### Transforming Values

When transforming values, use the `-adding(_:)` method. Since you can't transform indeterminate values such as bulb shutter speeds or automatic values, this method can return `nil`. You can use the `isDeterminate` property to exclude such values from calculations.

In general, a postive stops value means "more light" or "a brighter image", and a negative value means "less light" or "a darker image".

```swift
let stops = ExposureStops(fromDecimalValue: 1.0)

let f8 = ApertureValue.f8()
print(f8.adding(stops)) // f/5.6

let one250th = ShutterSpeedValue.oneTwoHundredFiftiethShutterSpeed()
print(one250th.adding(stops)) // 1/125

let iso100 = ISOValue.iso100()
print(iso100.adding(stops)) // ISO 200

let zeroEV = ExposureCompensationValue.zeroEV()
print(zeroEV.adding(stops)) // 1 EV
```

## License

StopKit is licensed under the MIT license. For full details, see the [LICENSE](LICENSE) file.
