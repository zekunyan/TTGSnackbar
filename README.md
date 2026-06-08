# TTGSnackbar
A Swift based implementation of the Android Snackbar for iOS

[![Build Status](https://travis-ci.org/zekunyan/TTGSnackbar.svg?branch=master)](https://travis-ci.org/zekunyan/TTGSnackbar)
[![Version](https://img.shields.io/cocoapods/v/TTGSnackbar.svg?style=flat)](https://github.com/zekunyan/TTGSnackbar)
[![License](https://img.shields.io/cocoapods/l/TTGSnackbar.svg?style=flat)](https://github.com/zekunyan/TTGSnackbar)
[![Platform](https://img.shields.io/cocoapods/p/TTGSnackbar.svg?style=flat)](https://github.com/zekunyan/TTGSnackbar)
[![Swift5.9](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://developer.apple.com/swift)
[![Apps Using](https://img.shields.io/badge/Apps%20Using-%3E%20787-blue.svg)](https://github.com/zekunyan/TTGSnackbar)
[![Total Download](https://img.shields.io/badge/Total%20Download-%3E%2036,840-blue.svg)](https://github.com/zekunyan/TTGSnackbar)

![Screenshot](https://github.com/zekunyan/TTGSnackbar/raw/master/Resources/screen_shot.png)

# Gif

![Screenshot](https://github.com/zekunyan/TTGSnackbar/raw/master/Resources/snackbar_example.gif)

# About
TTGSnackbar is useful for showing a brief message at bottom or top of the screen with one or two action buttons.
It appears above all other elements on screen.  
It disappears after a timeout or after user click the action button.

# Installation

### Swift 5.9
Current version
Xcode 15+
iOS 16+

### Swift 4
Version 1.6.0
Xcode 9  
iOS 8+

### Swift 3 
Version 1.5.3
Xcode 8  
iOS 8+

### CocoaPods
You can use [CocoaPods](http://cocoapods.org) to install `TTGSnackbar` by adding it to your `Podfile`:

```ruby
pod "TTGSnackbar"
```

### Swift Package Manager
You can use [Swift Package Manager](https://swift.org/package-manager/) by adding this repository URL to Xcode:

```
https://github.com/zekunyan/TTGSnackbar.git
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
let snackbar = TTGSnackbar(message: "TTGSnackbar !", duration: .short)
snackbar.show()
```
## Show a simple message with an action button
![Example](https://github.com/zekunyan/TTGSnackbar/raw/master/Resources/snackbar_2.png)
```
let snackbar = TTGSnackbar(
    message: "TTGSnackBar !",
    duration: .middle,
    actionText: "Action!",
    actionBlock: { (snackbar) in
        print("Click action!")
    }
)
snackbar.show()
```

## Show a simple message with a long running action
![Example](https://github.com/zekunyan/TTGSnackbar/raw/master/Resources/snackbar_3.png)
```
let snackbar = TTGSnackbar(
    message: "TTGSnackbar !",
    duration: .forever,
    actionText: "Action",
    actionBlock: { (snackbar) in
        print("Click action!")
        // Dismiss manually after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
            snackbar.dismiss()
        }   
    }
)
snackbar.show()
```

## Show a simple message with two action buttons
![Example](https://github.com/zekunyan/TTGSnackbar/raw/master/Resources/snackbar_4.png)
```
let snackbar = TTGSnackbar(message: "Two actions !", duration: .long)

// Action 1
snackbar.actionText = "Yes"
snackbar.actionTextColor = UIColor.green
snackbar.actionBlock = { (snackbar) in NSLog("Click Yes !") }

// Action 2
snackbar.secondActionText = "No"
snackbar.secondActionTextColor = UIColor.yellow
snackbar.secondActionBlock = { (snackbar) in NSLog("Click No !") }

snackbar.show()
```

## Show a simple message with an icon image
![Example](https://github.com/zekunyan/TTGSnackbar/raw/master/Resources/snackbar_5.jpg)
```
let snackbar = TTGSnackbar(message: "TTGSnackbar !", duration: .long)

// Add icon image
snackbar.icon = UIImage(named: "emoji_cool_small")

snackbar.show()
```

## [Improved!] Show custom content view in snackbar
![Example](https://github.com/zekunyan/TTGSnackbar/raw/master/Resources/snackbar_6.png)
```
// Instantiate the custom content view
let customContentView = UINib(nibName: "CustomView", bundle:Bundle.main).instantiate(withOwner: nil, options: nil).first as! UIView?

// Initialize the snackbar with the custom content view
let snackbar = TTGSnackbar(customContentView: customContentView, duration: .long)

snackbar.show()
```

## Make use of the Gesture recognizers in snackbar
![Example](https://github.com/zekunyan/TTGSnackbar/raw/master/Resources/snackbar_5.jpg)
```
let snackbar = TTGSnackbar(message: "TTGSnackbar !", duration: .long)

// Add icon image
snackbar.icon = UIImage(named: "emoji_cool_small")

// Add the gesture recognizer callbacks
snackbar.onTapBlock = { snackbar in
    snackbar.dismiss()
}

snackbar.onSwipeBlock = { (snackbar, direction) in
    
    // Change the animation type to simulate being dismissed in that direction
    if direction == .right {
        snackbar.animationType = .slideFromLeftToRight
    } else if direction == .left {
        snackbar.animationType = .slideFromRightToLeft
    } else if direction == .up {
        snackbar.animationType = .slideFromTopBackToTop
    } else if direction == .down {
        snackbar.animationType = .slideFromTopBackToTop
    }
    
    snackbar.dismiss()
}

snackbar.show()
```
## Modern semantic styles

Use built-in semantic styles for common product states. Styles configure recommended colors, SF Symbol icons, loading state and haptic feedback.

```swift
let snackbar = TTGSnackbar(message: "Saved successfully", duration: .short)
snackbar.style = .success
snackbar.show()

let loading = TTGSnackbar(message: "Syncing…", duration: .forever)
loading.style = .loading
loading.show()
```

## Configuration API

For modern Swift call sites, build a snackbar from a single value-based configuration. Existing property-based APIs are still supported.

```swift
let snackbar = TTGSnackbar(configuration: .init(
    message: "File deleted",
    duration: .long,
    style: .warning,
    actionText: "Undo",
    actionBlock: { snackbar in
        snackbar.dismiss()
    }
))
snackbar.show()
```

## Async / await presentation

Swift 5.9 projects can await the first action, tap, swipe or dismiss result.

```swift
let result = await TTGSnackbar.show(configuration: .init(
    message: "File deleted",
    duration: .long,
    style: .warning,
    actionText: "Undo"
))

if case .action = result {
    undoDelete()
}
```

## [New!] Automatic handling of Showing one Snackbar at a time

`TTGSnackbarManager` can queue, replace or deduplicate snackbars so only one managed snackbar is presented at a time.

### **Usage**:

**Swift**
```swift
let snackbar = TTGSnackbar(message: "TTGSnackbar !", duration: .long)
TTGSnackbarManager.shared.show(snackbar: snackbar, policy: .enqueue)

let urgent = TTGSnackbar(message: "Network disconnected", duration: .long)
urgent.style = .error
TTGSnackbarManager.shared.show(snackbar: urgent, policy: .replaceCurrent)
```

**Objective-c**
```objective-c
TTGSnackbar *bar = [[TTGSnackbar alloc] initWithMessage:@"Bar1" duration:TTGSnackbarDurationMiddle];
[bar setDismissBlock:^(TTGSnackbar * snackBar) {
    // Whatever you want for dismiss.
}];
[[TTGSnackbarManager shared] showSnackbar:bar];
```

# Customization

### Message
`message: String` defines the message to display. **Supports multi line text.** **Supports updating on the fly.** 

### Message text color
`messageTextColor: UIColor` defines the message text color.

### Message text font
`messageTextFont: UIFont` defines the message text font.

### Display duration
`duration: TTGSnackbarDuration` defines the display duration.
`TTGSnackbarDuration` : `short`, `middle`, `long`, `custom` and `forever`.
When you set `forever`, the snackbar will show an activity indicator after user click the action button and you must dismiss the snackbar manually.

### Semantic style
`style: TTGSnackbarStyle` applies built-in visual styles: `default`, `info`, `success`, `warning`, `error` and `loading`.

### Lifecycle callbacks
`willShowBlock`, `didShowBlock`, `willDismissBlock` and `didDismissBlock` let you observe presentation transitions for analytics, queueing or custom coordination.

### Accessibility and motion
`shouldAnnounceForAccessibility` enables VoiceOver announcements, `accessibilityAnnouncement` overrides the announced text, `adjustsFontForContentSizeCategory` enables Dynamic Type scaling, and `shouldRespectReduceMotion` falls back to a fade animation when Reduce Motion is enabled.

### Dismiss timer controls
`pauseDismissTimer()` and `resumeDismissTimer()` allow manual timer control. `pausesDismissTimerOnTouch` and `pausesDismissTimerWhenAppInactive` pause timed snackbars during interaction or app lifecycle interruptions.

### Haptic feedback
`hapticFeedback` controls feedback when the snackbar appears, and `actionHapticFeedback` controls feedback when users tap action buttons.

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
`actionBlock: TTGActionBlock?` will be called when user clicks the action button.
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

### Snackbar MaxWidth
`snackbarMaxWidth: CGFloat` will set the max width of the snackbar if on larger devices you don not want it full width. Default is -1 which is denotes full-width.

### Dismiss callback
`dismissBlock: TTGDismissBlock?` will be called when snackbar  dismiss automatically or when user click action button to dismiss the snackbar.
```
// TTGDismissBlock definition.
public typealias TTGDismissBlock = (snackbar: TTGSnackbar) -> Void
```

### On Tap Gesture callback
`onTapBlock: TTGActionBlock` will be called when the user taps the snackbar.
```
// TTGActionBlock definition.
public typealias TTGActionBlock = (snackbar: TTGSnackbar) -> Void
```

### On Swipe Gesture callback
`onSwipeBlock: TTGSwipeBlock` will be called when the user swipes on the snackbar
```
/// Swipe gesture callback closure
public typealias TTGSwipeBlock = (_ snackbar: TTGSnackbar, _ direction: UISwipeGestureRecognizer.Direction) -> Void
```

### Auto Dismissal using Swipe Gestures
`shouldDismissOnSwipe: Bool` will determine if the snackbar will automatically be dismissed when it's swiped
```
/// A property to make the snackbar auto dismiss on Swipe Gesture
public var shouldDismissOnSwipe: Bool = false
```

### Animation type
`animationType: TTGSnackbarAnimationType` defines the style of snackbar when it show and dismiss.  

`TTGSnackbarAnimationType` : `fadeInFadeOut`, `slideFromBottomToTop`, `slideFromBottomBackToBottom`, `slideFromLeftToRight`,  `slideFromRightToLeft`, `slideFromTopToBottom` and `slideFromTopBackToTop`.

The default value of `animationType` is `slideFromBottomBackToBottom`, which is the same as Snackbar in Android.

### Animation duration
`animationDuration: TimeInterval` defines the duration of show and hide animation.

### Margins
`leftMargin: CGFloat`, `rightMargin: CGFloat`, `topMargin: CGFloat` and `bottomMargin: CGFloat` defines the margins of snackbar

### [New!] Custom Content View to follow left and right margins
`shouldActivateLeftAndRightMarginOnCustomContentView: Bool` will activate the left and right margins if using a `customContentView`
```
/// a property to enable left and right margin when using customContentView
public var shouldActivateLeftAndRightMarginOnCustomContentView: Bool = false
```

### Padding (Content inset)
`contentInset: UIEdgeInsets` defines the padding(content inset) of content in the snackbar. Default is `UIEdgeInsets.init(top: 0, left: 4, bottom: 0, right: 4)`.

### Corner radius
`cornerRadius: CGFloat` defines the corner radius of snackbar.

### Icon image
`icon: UIImage` defines the icon image.

### Icon image content mode
`iconContentMode: UIView.ContentMode` defines the content mode of icon imageView.

### [New!] Custom container view
`containerView: UIView` defines the custom container(super) view for snackbar to show.

### [New!] Custom content view
`customContentView: UIView?` defines the custom content view to show in the snackbar.

### [New!] Separator line view background color
`separateViewBackgroundColor: UIColor = UIColor.gray` defines the separator line color.

### ActivityIndicatorViewStyle
`activityIndicatorViewStyle: UIActivityIndicatorView.Style` defines the activityIndicatorViewStyle in snackbar.

### ActivityIndicatorView color
`activityIndicatorViewColor: UIColor` defines the activityIndicatorView color in snackbar.

### Animation SpringWithDamping
`animationSpringWithDamping: CGFloat` defines the spring animation damping value. Default is 0.7.

### Animation initialSpringVelocity
`animationInitialSpringVelocity: CGFloat` defines the spring animation initial velocity. Default is 5.

# Contact me
zekunyan@163.com
