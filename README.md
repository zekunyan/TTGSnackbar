# TTGSnackbar
A Swift based implementation of the Android Snackbar for iOS

[![Build Status](https://travis-ci.org/zekunyan/TTGSnackbar.svg?branch=master)](https://travis-ci.org/zekunyan/TTGSnackbar)
[![Version](https://img.shields.io/cocoapods/v/TTGSnackbar.svg?style=flat)](https://github.com/zekunyan/TTGSnackbar)
[![License](https://img.shields.io/cocoapods/l/TTGSnackbar.svg?style=flat)](https://github.com/zekunyan/TTGSnackbar)
[![Platform](https://img.shields.io/cocoapods/p/TTGSnackbar.svg?style=flat)](https://github.com/zekunyan/TTGSnackbar)
[![Swift3](https://img.shields.io/badge/Swift-3-orange.svg)](https://developer.apple.com/swift)
[![Apps Using](https://img.shields.io/badge/Apps%20Using-%3E%20416-blue.svg)](https://github.com/zekunyan/TTGSnackbar)
[![Total Download](https://img.shields.io/badge/Total%20Download-%3E%2020329-blue.svg)](https://github.com/zekunyan/TTGSnackbar)

![Screenshot](https://github.com/zekunyan/TTGSnackbar/raw/master/Resources/screen_shot.png)

# Gif

![Screenshot](https://github.com/zekunyan/TTGSnackbar/raw/master/Resources/snackbar_example.gif)

# About
TTGSnackbar is useful for showing a brief message at bottom or top of the screen with one or two action button.  
It appears above all other elements on screen.  
It disappears after a timeout or after user click the action button.

# Installation
### Requirement
Swift 3  
Xcode 8  
iOS 8+

### CocoaPods
You can use [CocoaPods](http://cocoapods.org) to install `TTGSnackbar` by adding it to your `Podfile`:

```ruby
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
![Example](https://github.com/zekunyan/TTGSnackbar/raw/master/Resources/snackbar_1.png)
```
let snackbar = TTGSnackbar.init(message: "Message", duration: .Short)
snackbar.show()
```
## Show a simple message with an action button
![Example](https://github.com/zekunyan/TTGSnackbar/raw/master/Resources/snackbar_2.png)
```
let snackbar = TTGSnackbar.init(message: "Message", duration: .Middle, actionText: "Action")
{ (snackbar) -> Void in
    NSLog("Click action!")
}      
snackbar.show()
```

## Show a simple message with a long running action
![Example](https://github.com/zekunyan/TTGSnackbar/raw/master/Resources/snackbar_3.png)
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
![Example](https://github.com/zekunyan/TTGSnackbar/raw/master/Resources/snackbar_4.png)
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
![Example](https://github.com/zekunyan/TTGSnackbar/raw/master/Resources/snackbar_5.jpg)
```
let snackbar: TTGSnackbar = TTGSnackbar.init(message: "Two actions !", duration: .Long)

// Add icon image
snackbar.icon = UIImage.init(named: "emoji_cool_small")

snackbar.show()
```

## Show custom content view in snackbar
![Example](https://github.com/zekunyan/TTGSnackbar/raw/master/Resources/snackbar_6.png)
```
let snackbar: TTGSnackbar = TTGSnackbar.init(message: "", duration: .Long)

// Get custom content view
let customContentView = UINib.init(nibName: "CustomView", bundle:Bundle.main).instantiate(withOwner: nil, options: nil).first as! UIView?

// Set custom content view
snackbar.customContentView = customContentView

snackbar.show()
```

# Customization
### Message
`message: String` defines the message to diaplay. **Support multi line text.**

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

### Action max width
`actionMaxWidth: CGFloat` defines the action button max width. Min is 44.

### Action text number of lines
`actionTextNumberOfLines: Int` defines the number of lines of action button title. Default is 1.

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

`TTGSnackbarAnimationType` : `FadeInFadeOut`, `SlideFromBottomToTop`, `SlideFromBottomBackToBottom`, `SlideFromLeftToRight`,  `SlideFromRightToLeft`, `SlideFromTopToBottom` and `SlideFromTopBackToTop`.

The default value of `animationType` is `SlideFromBottomBackToBottom`, which is the same as Snackbar in Android.

### Animation duration
`animationDuration: NSTimeInterval` defines the duration of show and hide animation.

### Margins
`leftMargin: CGFloat`, `rightMargin: CGFloat`, `topMargin: CGFloat` and `bottomMargin: CGFloat` defines the margins of snackbar

### Padding (Content inset)
`contentInset: UIEdgeInsets` defines the padding(content inset) of content in the snackbar. Default is `UIEdgeInsets.init(top: 0, left: 4, bottom: 0, right: 4)`.

### Corner radius
`cornerRadius: CGFloat` defines the corner radius of snackbar.

### Icon image
`icon: UIImage` defines the icon image.

### Icon image content mode
`iconContentMode: UIViewContentMode` defines the content mode of icon imageView.

### [New!] Custom container view
`containerView: UIView` defines the custom container(super) view for snackbar to show.

### [New!] Custom content view
`customContentView: UIView?` defines the custom content view to show in the snackbar.

### [New!] Separator line view background color
`separateViewBackgroundColor: UIColor = UIColor.gray` defines the separator line color.

### ActivityIndicatorViewStyle
`activityIndicatorViewStyle: UIActivityIndicatorViewStyle` defines the activityIndicatorViewStyle in snackbar.

### ActivityIndicatorView color
`activityIndicatorViewColor: UIColor` defines the activityIndicatorView color in snackbar.

### Animation SpringWithDamping
`animationSpringWithDamping: CGFloat` defines the spring animation damping value. Default is 0.7.

### Animation initialSpringVelocity
`animationInitialSpringVelocity: CGFloat` defines the spring animation initial velocity. Default is 5.

# Contact me
zekunyan@163.com
