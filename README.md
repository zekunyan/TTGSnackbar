# TTGSnackbar
A Swift based implementation of the Android Snackbar for iOS

[![Version](https://img.shields.io/cocoapods/v/TTGSnackbar.svg?style=flat)](https://github.com/zekunyan/TTGSnackbar)
[![License](https://img.shields.io/cocoapods/l/TTGSnackbar.svg?style=flat)](https://github.com/zekunyan/TTGSnackbar)
[![Platform](https://img.shields.io/cocoapods/p/TTGSnackbar.svg?style=flat)](https://github.com/zekunyan/TTGSnackbar)

![Screenshot](http://7nj2iz.com1.z0.glb.clouddn.com/TTGSnackbar_1.gif?refresh)

# About
TTGSnackbar is useful for showing a brief message at the bottom of the screen with an action button.  
It appears above all other elements on screen and only one can be displayed at a time.  
It disappears after a timeout or after user click the action button.

# Installation
The recommended way is to use CocoaPods.   
```
pod 'TTGSnackbar'
```  
And you need to import the module.  
```
import TTGSnackbar
```

# Usage
## Show a simple message
![Example](http://7nj2iz.com1.z0.glb.clouddn.com/TTGSnackbar_2.png)
```
let snackbar = TTGSnackbar.init(message: "Message", duration: TTGSnackbarDuration.Short)
snackbar.show()
```
## Show a simple message with an action button
![Example](http://7nj2iz.com1.z0.glb.clouddn.com/TTGSnackbar_3.png)
```
let snackbar = TTGSnackbar.init(message: "Message", duration: TTGSnackbarDuration.Middle, actionText: "Action")
{ (snackbar) -> Void in
    NSLog("Click action!")
}      
snackbar.show()
```

## Show a simple message with a long running action
![Example](http://7nj2iz.com1.z0.glb.clouddn.com/TTGSnackbar_5.png)
```
let snackbar = TTGSnackbar.init(message: "Message", duration: TTGSnackbarDuration.Forever, actionText: "Action")
{ (snackbar) -> Void in
    NSLog("Click action!")
    // Dismiss manually after 3 seconds
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(3 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
        snackbar.dismiss()
    }
}      
snackbar.show()
```

# Customization
### Message
`message: String` define the message to diaplay.

### Message text color
`messageTextColor: UIColor` define the message text color.

### Display duration
`duration: TTGSnackbarDuration`define the display duration.  
`TTGSnackbarDuration` : `Short`, `Middle`, `Long` and `Forever`.  
When you set `Forever`, the snackbar will show an activity indicator after user click the action button and you must dismiss the snackbar manually.

### Action title
`actionText: String` define the action button title.

### Action title color
`actionTextColor: UIColor` define the action button title color.

### Action callback
`actionBlock: TTGActionBlock?` will be called when user click the action button.
```
// TTGActionBlock definition.
public typealias TTGActionBlock = (snackbar: TTGSnackbar) -> Void
```

### Dismiss callback
`dismissBlock: TTGDismissBlock?` will be called when snackbar  dismiss automatically or when user click action button to dismiss the snackbar.
```
// TTGDismissBlock definition.
public typealias TTGDismissBlock = (snackbar: TTGSnackbar) -> Void
```

### Animation type
`animationType: TTGSnackbarAnimationType` define the style of snackbar when it show and dismiss.  

`TTGSnackbarAnimationType` : `FadeInFadeOut`, `SlideFromBottomToTop`, `SlideFromBottomBackToBottom`, `SlideFromLeftToRight`, and `SlideFromRightToLeft`.

The default value of `animationType` is `SlideFromBottomBackToBottom`, which is the same as Snackbar in Android.

# Contact me
zekunyan@163.com