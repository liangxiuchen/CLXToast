# CLXToast

[![CI Status](http://img.shields.io/travis/liangxiu.chen.cn@gmail.com/CLXToast.svg?style=flat)](https://travis-ci.org/liangxiu.chen.cn@gmail.com/CLXToast)
[![Version](https://img.shields.io/cocoapods/v/CLXToast.svg?style=flat)](http://cocoapods.org/pods/CLXToast)
[![License](https://img.shields.io/cocoapods/l/CLXToast.svg?style=flat)](http://cocoapods.org/pods/CLXToast)
[![Platform](https://img.shields.io/cocoapods/p/CLXToast.svg?style=flat)](http://cocoapods.org/pods/CLXToast)

## Overview

<img width = "300" height = "500" src="https://github.com/liangxiuchen/CLXToast/blob/master/DocumentAssets/Hud.gif" /> <img width = "300" height = "500" src="https://github.com/liangxiuchen/CLXToast/blob/master/DocumentAssets/waiting.gif" />

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

CLXToast is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'CLXToast'
```

## Usage

```swift
//HUD Style
Toast().title("nihao").subtitle("subtitle").show()
Toast(style: .hud).title("nihao").subtitle("subtitle").show(animated: true)
Toast(style: .hud).title("nihao").subtitle("subtitle").show(animated: true) {
                DispatchQueue.main.async {
                    Toast.cancelAll()
                }
            }
// waiting Style
let toast = Toast(style: .waiting).prompt("hello waiting").show(animated: false) {
                print("default waiting")
            }
DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
                toast.dismiss()
            }
```

## Author

liangxiuchen

## License

CLXToast is available under the MIT license. See the LICENSE file for more info.
