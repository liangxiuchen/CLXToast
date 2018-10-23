# CLXToast

[![CI Status](http://img.shields.io/travis/liangxiu.chen.cn@gmail.com/CLXToast.svg?style=flat)](https://travis-ci.org/liangxiu.chen.cn@gmail.com/CLXToast)
[![Version](https://img.shields.io/cocoapods/v/CLXToast.svg?style=flat)](http://cocoapods.org/pods/CLXToast)
[![License](https://img.shields.io/cocoapods/l/CLXToast.svg?style=flat)](http://cocoapods.org/pods/CLXToast)
[![Platform](https://img.shields.io/cocoapods/p/CLXToast.svg?style=flat)](http://cocoapods.org/pods/CLXToast)

## Overview

<img width = "300" height = "500" src="https://github.com/liangxiuchen/CLXToast/blob/master/DocumentAssets/ToastDemo.gif" />

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

CLXToast is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:
### Swift
```ruby
pod 'CLXToast'
```
### Objective-C
```ruby
pod 'CLXToast/Objc-Toast'
```

### Usage After 0.2.0

```swift
//----------------------------------HUD Style--------------------------------------------
Toast.hudBuilder.title("it is a title").show()
Toast.hudBuilder.subtitle("it is a subtitle").show()
Toast.hudBuilder.icon(UIImage(named: "toast")).show()
Toast.hudBuilder.title("it is a title").subtitle("it is a subtitle").show()
Toast.hudBuilder.title("it is a long long long long long long long title").subtitle("it is a long long long long long long long long long long long longsubtitle").icon(#imageLiteral(resourceName: "toast")).show()

 //adjust titles space demo
Toast.hudBuilder.title("adjust space").subtitle("adjust space between title and subtitle").interTitlesSpacing(10).show()
Toast.hudBuilder.title("adjust space").subtitle("adjust space between titles and icon").icon(#imageLiteral(resourceName: "toast")).interTitlesIconSpacing(10).show()

//custom subtitle Lable same as title and icon demo
let subtitle = UILabel()
subtitle.text = "adjust space between titles and icon"
subtitle.preferredMaxLayoutWidth = 40
subtitle.numberOfLines = 0
let title = UILabel()
title.text = "it is a title"
title.preferredMaxLayoutWidth = 100
title.numberOfLines = 0
title.font = UIFont.systemFont(ofSize: 16)
title.textColor = UIColor.green
Toast.hudBuilder.titleLabel(title).subtitleLabel(subtitle).icon(#imageLiteral(resourceName: "toast")).show()

//completion callback demo
Toast.hudBuilder.title("it is a completion callback test").show(animated: true) {
      print("--------------------hud is finished--------------------")
}

//config toast instance        
let tst = Toast()        
tst.isConcurrent = true        
tst.contentView.backgroundColor = UIColor.green        
tst.aHud.title("it is a concurrent toast").show()

// full custom hud Demo        
let customHud = CustomHudContent()        
let toast = Toast()
toast.custom(content: customHud).show()

//cancel demo
Toast.hudBuilder.title("i will cancel all.").show(animated: true) {
  Toast.hudBuilder.title("i will never appear").show()
  Toast.cancelAll()
}

//----------------------------------Waiting Style--------------------------------------------

let allItemWaiting = Toast.waiting.prompt("同步中...").show()
DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
    allItemWaiting.dismiss()
}

DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4)) {
    let waitingWithCallBack = Toast.waiting.prompt("等待完成回调...").show(animated: true) {
        Toast.hudBuilder.title("waiting completion").show()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            waitingWithCallBack.dismiss()
        }
}
        
```

### Usage Before 0.2.0

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
