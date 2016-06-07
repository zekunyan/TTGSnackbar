# TTGSnackbar
A Swift based implementation of the Android Snackbar for iOS

[![Version](https://img.shields.io/cocoapods/v/TTGSnackbar.svg?style=flat)](https://github.com/zekunyan/TTGSnackbar)
[![License](https://img.shields.io/cocoapods/l/TTGSnackbar.svg?style=flat)](https://github.com/zekunyan/TTGSnackbar)
[![Platform](https://img.shields.io/cocoapods/p/TTGSnackbar.svg?style=flat)](https://github.com/zekunyan/TTGSnackbar)

![Screenshot](http://7nj2iz.com1.z0.glb.clouddn.com/TTGSnackbar_8.gif)

# About
TTGSnackbar is useful for showing a brief message at the bottom of the screen with an action button.  
It appears above all other elements on screen and only one can be displayed at a time.  
It disappears after a timeout or after user click the action button.

# Installation
### Requirement
Swift 2.2  
iOS 8+

### CocoaPods
You can use [CocoaPods](http://cocoapods.org) to install `TTGSnackbar` by adding it to your `Podfile`:

```ruby
platform :ios, '8.0'
use_frameworks!

pod "TTGSnackbar"
```

### Carthage
You can use [Carthage](https://github.com/Carthage/Carthage) to install `TTGSnackbar` by adding it to your `Cartfile`:
```
github "zekunyan/TTGSnackbar"
```

### Import

And you need to import the module.  
```
import TTGSnackbar
```

# Usage
## Show a simple message
![Example](http://7nj2iz.com1.z0.glb.clouddn.com/TTGSnackbar_2.png)
```
let snackbar = TTGSnackbar.init(message: "Message", duration: .Short)
snackbar.show()
```
## Show a simple message with an action button
![Example](http://7nj2iz.com1.z0.glb.clouddn.com/TTGSnackbar_3.png)
```
let snackbar = TTGSnackbar.init(message: "Message", duration: .Middle, actionText: "Action")
{ (snackbar) -> Void in
    NSLog("Click action!")
}      
snackbar.show()
```

## Show a simple message with a long running action
![Example](http://7nj2iz.com1.z0.glb.clouddn.com/TTGSnackbar_5.png)
```
let snackbar = TTGSnackbar.init(message: "Message", duration: .Forever, actionText: "Action")
{ (snackbar) -> Void in
    NSLog("Click action!")
    // Dismiss manually after 3 seconds
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(3 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
        snackbar.dismiss()
    }
}      
snackbar.show()
```

## Show a simple message with two action buttons
![Example](http://7nj2iz.com1.z0.glb.clouddn.com/TTGSnackbar_9.png)
```
let snackbar: TTGSnackbar = TTGSnackbar.init(message: "Two actions !", duration: .Long)

// Action 1
snackbar.actionText = "Yes"
snackbar.actionTextColor = UIColor.greenColor()
snackbar.actionBlock = { (snackbar) in NSLog("Click Yes !") }

// Action 2
snackbar.secondActionText = "No"
snackbar.secondActionTextColor = UIColor.yellowColor()
snackbar.secondActionBlock = { (snackbar) in NSLog("Click No !") }

snackbar.show()
```

## Show a simple message with an icon image
![Example](http://7nj2iz.com1.z0.glb.clouddn.com/TTGSnackbar_10.jpg)
```
let snackbar: TTGSnackbar = TTGSnackbar.init(message: "Two actions !", duration: .Long)

// Add icon image
snackbar.icon = UIImage.init(named: "emoji_cool_small")

snackbar.show()
```

# Customization
### Message
`message: String` defines the message to diaplay.

### Message text color
`messageTextColor: UIColor` defines the message text color.

### Message text font
`messageTextFont: UIFont` defines the message text font.

### Display duration
`duration: TTGSnackbarDuration`defines the display duration.  
`TTGSnackbarDuration` : `Short`, `Middle`, `Long` and `Forever`.  
When you set `Forever`, the snackbar will show an activity indicator after user click the action button and you must dismiss the snackbar manually.

### Action title
`actionText: String` defines the action button title.

### Action title color
`actionTextColor: UIColor` defines the action button title color.

### Action title font
`actionTextFont: UIFont` defines the action button title font.

### Action callback
`actionBlock: TTGActionBlock?` will be called when user click the action button.
```
// TTGActionBlock definition.
public typealias TTGActionBlock = (snackbar: TTGSnackbar) -> Void
```

### Second action title, color, font and callback
```
secondActionText: String  
secondActionTextColor: UIColor  
secondActionTextFont: UIFont  
secondActionBlock: TTGActionBlock?
```

### Dismiss callback
`dismissBlock: TTGDismissBlock?` will be called when snackbar  dismiss automatically or when user click action button to dismiss the snackbar.
```
// TTGDismissBlock definition.
public typealias TTGDismissBlock = (snackbar: TTGSnackbar) -> Void
```

### Animation type
`animationType: TTGSnackbarAnimationType` defines the style of snackbar when it show and dismiss.  

`TTGSnackbarAnimationType` : `FadeInFadeOut`, `SlideFromBottomToTop`, `SlideFromBottomBackToBottom`, `SlideFromLeftToRight` and `SlideFromRightToLeft`.

The default value of `animationType` is `SlideFromBottomBackToBottom`, which is the same as Snackbar in Android.

### Animation duration
`animationDuration: NSTimeInterval` defines the duration of show and hide animation.

### Margins
`leftMargin: CGFloat`, `rightMargin: CGFloat` and `bottomMargin: CGFloat` define the margins of snackbar.

### Snackbar height
`height: CGFloat` defines the height of snackbar.

### Corner radius
`cornerRadius: CGFloat` defines the corner radius of snackbar.

### Icon image
`icon: UIImage` defines the icon image.

### Icon image content mode
`iconContentMode: UIViewContentMode` defines the content mode of icon imageView.

# Contact me
zekunyan@163.com
