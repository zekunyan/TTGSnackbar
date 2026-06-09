# TTGSnackbar

[简体中文](README.zh-CN.md)

TTGSnackbar is a Swift implementation of an Android-style Snackbar for iOS. It presents short, actionable messages at the top or bottom of the screen, supports custom views, queue management, semantic styles, accessibility, haptics, and Swift concurrency.

> Current development targets **Swift 5.9**, **Xcode 15+**, and **iOS 16.0+**.

[![Build Status](https://travis-ci.org/zekunyan/TTGSnackbar.svg?branch=master)](https://travis-ci.org/zekunyan/TTGSnackbar)
[![Version](https://img.shields.io/cocoapods/v/TTGSnackbar.svg?style=flat)](https://github.com/zekunyan/TTGSnackbar)
[![License](https://img.shields.io/cocoapods/l/TTGSnackbar.svg?style=flat)](https://github.com/zekunyan/TTGSnackbar)
[![Platform](https://img.shields.io/cocoapods/p/TTGSnackbar.svg?style=flat)](https://github.com/zekunyan/TTGSnackbar)
[![Swift 5.9](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://developer.apple.com/swift)
[![Apps Using](https://img.shields.io/badge/Apps%20Using-%3E%20787-blue.svg)](https://github.com/zekunyan/TTGSnackbar)
[![Total Download](https://img.shields.io/badge/Total%20Download-%3E%2036,840-blue.svg)](https://github.com/zekunyan/TTGSnackbar)

![Screenshot](https://github.com/zekunyan/TTGSnackbar/raw/master/Resources/screen_shot.png)

## Preview

![Snackbar example](https://github.com/zekunyan/TTGSnackbar/raw/master/Resources/snackbar_example.gif)

## Features

- Present messages at the bottom or top of the screen.
- Add one or two action buttons, text actions, or icon-only actions.
- Show built-in semantic styles: `default`, `info`, `success`, `warning`, `error`, and `loading`.
- Present custom `UIView` content or display inside a custom container view.
- Queue, replace, or deduplicate snackbars with `TTGSnackbarManager`.
- Await action, tap, swipe, dismiss, drop, or presentation-failure results with Swift concurrency.
- Support Dynamic Type, VoiceOver announcements, Reduce Motion, and haptic feedback.
- Pause and resume dismiss timers manually, on touch, or during app lifecycle interruptions.
- Include a privacy manifest for modern Apple platform requirements.

## Requirements

| TTGSnackbar version | Swift | Xcode | iOS |
| --- | --- | --- | --- |
| Current | 5.9 | 15+ | 16.0+ |
| 1.6.0 | 4.x | 9+ | 8.0+ |
| 1.5.3 | 3.x | 8+ | 8.0+ |

## Installation

### Swift Package Manager

Add this repository URL in Xcode:

```text
https://github.com/zekunyan/TTGSnackbar.git
```

Then import the module:

```swift
import TTGSnackbar
```

### CocoaPods

Add TTGSnackbar to your `Podfile`:

```ruby
pod "TTGSnackbar"
```

Then run:

```sh
pod install
```

### Carthage

Add TTGSnackbar to your `Cartfile`:

```text
github "zekunyan/TTGSnackbar"
```

## Quick Start

### Show a simple message

![Simple snackbar](https://github.com/zekunyan/TTGSnackbar/raw/master/Resources/snackbar_1.png)

```swift
let snackbar = TTGSnackbar(message: "TTGSnackbar!", duration: .short)
snackbar.show()
```

`show()` returns `false` if the snackbar cannot be presented, for example when no active window or custom container is available.

```swift
if !snackbar.show() {
    print("Snackbar could not be presented")
}
```

### Show an action button

![Action snackbar](https://github.com/zekunyan/TTGSnackbar/raw/master/Resources/snackbar_2.png)

```swift
let snackbar = TTGSnackbar(
    message: "File deleted",
    duration: .middle,
    actionText: "Undo"
) { snackbar in
    restoreFile()
    snackbar.dismiss()
}

snackbar.show()
```

### Show a long-running action

![Long-running action](https://github.com/zekunyan/TTGSnackbar/raw/master/Resources/snackbar_3.png)

```swift
let snackbar = TTGSnackbar(
    message: "Uploading…",
    duration: .forever,
    actionText: "Cancel"
) { snackbar in
    cancelUpload()
    snackbar.dismiss()
}

snackbar.show()
```

### Show two action buttons

![Two actions](https://github.com/zekunyan/TTGSnackbar/raw/master/Resources/snackbar_4.png)

```swift
let snackbar = TTGSnackbar(message: "Enable notifications?", duration: .long)

snackbar.actionText = "Enable"
snackbar.actionTextColor = .systemGreen
snackbar.actionBlock = { snackbar in
    enableNotifications()
    snackbar.dismiss()
}

snackbar.secondActionText = "Not now"
snackbar.secondActionTextColor = .systemOrange
snackbar.secondActionBlock = { snackbar in
    snackbar.dismiss()
}

snackbar.show()
```

### Show an icon or icon-only action

![Icon snackbar](https://github.com/zekunyan/TTGSnackbar/raw/master/Resources/snackbar_5.jpg)

```swift
let snackbar = TTGSnackbar(message: "Saved successfully", duration: .middle)
snackbar.icon = UIImage(systemName: "checkmark.circle.fill")
snackbar.iconTintColor = .systemGreen
snackbar.show()
```

```swift
let snackbar = TTGSnackbar(message: "Tap the icon action", duration: .middle)
snackbar.actionIcon = UIImage(systemName: "hand.tap.fill")
snackbar.actionBlock = { snackbar in
    snackbar.dismiss()
}
snackbar.show()
```

### Show custom content

![Custom content](https://github.com/zekunyan/TTGSnackbar/raw/master/Resources/snackbar_6.png)

```swift
let customContentView = UINib(
    nibName: "CustomView",
    bundle: .main
).instantiate(withOwner: nil).first as! UIView

let snackbar = TTGSnackbar(customContentView: customContentView, duration: .long)
snackbar.show()
```

Set `shouldActivateLeftAndRightMarginOnCustomContentView = true` when the custom content view should honor snackbar side margins.

## Modern APIs

### Semantic styles

Use semantic styles for common product states. Styles apply recommended colors, icons, loading behavior, and haptic defaults.

```swift
let success = TTGSnackbar(message: "Saved successfully", duration: .short)
success.style = .success
success.show()

let loading = TTGSnackbar(message: "Syncing…", duration: .forever)
loading.style = .loading
loading.show()
```

Available styles:

- `.default`
- `.info`
- `.success`
- `.warning`
- `.error`
- `.loading`

### Configuration API

Use `TTGSnackbarConfiguration` to build snackbars from one value object. The property-based API remains supported.

```swift
let snackbar = TTGSnackbar(configuration: .init(
    message: "File deleted",
    duration: .long,
    style: .warning,
    actionText: "Undo",
    actionBlock: { snackbar in
        undoDelete()
        snackbar.dismiss()
    }
))

snackbar.show()
```

### Async / await presentation

Swift concurrency callers can await the first action, tap, swipe, dismiss, manager drop, or presentation failure.

```swift
let result = await TTGSnackbar.show(configuration: .init(
    message: "File deleted",
    duration: .long,
    style: .warning,
    actionText: "Undo"
))

switch result {
case .action:
    undoDelete()
case .dismissed:
    break
case .dropped:
    print("A manager policy dropped the snackbar")
case .failedToPresent:
    print("No window or container was available")
default:
    break
}
```

The async helper wires action titles into result callbacks automatically. With property-based presentation, provide an `actionBlock` or `secondActionBlock` for action buttons to become visible.

### Queue management

`TTGSnackbarManager` ensures only one managed snackbar is visible at a time.

```swift
let snackbar = TTGSnackbar(message: "Queued message", duration: .middle)
TTGSnackbarManager.shared.show(snackbar: snackbar, policy: .enqueue)

let urgent = TTGSnackbar(message: "Network disconnected", duration: .long)
urgent.style = .error
TTGSnackbarManager.shared.show(snackbar: urgent, policy: .replaceCurrent)
```

Available policies:

| Policy | Behavior |
| --- | --- |
| `.enqueue` | Show after the current snackbar is dismissed. |
| `.replaceCurrent` | Dismiss the current snackbar and show this one next. |
| `.dropIfShowingSameMessage` | Drop when the same message is already visible or queued. |

`show(snackbar:policy:)` returns `false` when the snackbar is synchronously dropped or cannot be presented.

```swift
let accepted = TTGSnackbarManager.shared.show(
    snackbar: snackbar,
    policy: .dropIfShowingSameMessage
)
```

Objective-C callers can use the same manager:

```objective-c
TTGSnackbar *bar = [[TTGSnackbar alloc] initWithMessage:@"Bar" duration:TTGSnackbarDurationMiddle];
[[TTGSnackbarManager shared] showSnackbar:bar policy:TTGSnackbarPresentationPolicyEnqueue];
```

## Customization

### Text and actions

| Property | Description |
| --- | --- |
| `message` | Main message text. Supports multiline text and runtime updates. |
| `messageTextColor` | Message text color. |
| `messageTextFont` | Message text font. |
| `messageTextAlign` | Message text alignment. |
| `messageContentInset` | Insets for the message label text. |
| `actionText` | Primary action title. |
| `actionIcon` | Primary action icon. |
| `actionTextColor` | Primary action title color. |
| `actionTextFont` | Primary action font. |
| `actionBlock` | Primary action callback. |
| `secondActionText` | Secondary action title. |
| `secondActionIcon` | Secondary action icon. |
| `secondActionTextColor` | Secondary action title color. |
| `secondActionTextFont` | Secondary action font. |
| `secondActionBlock` | Secondary action callback. |
| `actionMaxWidth` | Maximum action-button width. Minimum value is 44. |
| `actionTextNumberOfLines` | Number of action-button title lines. |

### Duration

`duration` defines how long the snackbar remains visible.

| Duration | Behavior |
| --- | --- |
| `.short` | 1 second. |
| `.middle` | 3 seconds. |
| `.long` | 5 seconds. |
| `.custom` | Uses `customDuration`. Set `customDuration > 0`. Invalid values assert in debug builds and fall back to `.short`. |
| `.forever` | Does not auto-dismiss. Dismiss manually. |

### Layout

| Property | Description |
| --- | --- |
| `animationType` | Show and dismiss animation style. |
| `animationDuration` | Show and dismiss animation duration. |
| `animationSpringWithDamping` | Spring damping used by animations. |
| `animationInitialSpringVelocity` | Initial spring velocity used by animations. |
| `leftMargin`, `rightMargin`, `topMargin`, `bottomMargin` | Snackbar margins. |
| `contentInset` | Insets around the built-in or custom content view. |
| `cornerRadius` | Snackbar corner radius. |
| `snackbarMaxWidth` | Maximum snackbar width. Default is -1, which means full width. |
| `containerView` | Custom superview used for presentation instead of the active window. |
| `customContentView` | Custom content shown inside the snackbar. |
| `shouldActivateLeftAndRightMarginOnCustomContentView` | Makes custom content honor side margins. |
| `shouldHonorSafeAreaLayoutGuides` | Uses safe area layout guides when positioning the snackbar. |

Available animation types:

- `.fadeInFadeOut`
- `.slideFromBottomToTop`
- `.slideFromBottomBackToBottom`
- `.slideFromLeftToRight`
- `.slideFromRightToLeft`
- `.slideFromTopToBottom`
- `.slideFromTopBackToTop`

### Icon and indicator

| Property | Description |
| --- | --- |
| `icon` | Leading icon image. |
| `iconContentMode` | Leading icon content mode. |
| `iconBackgroundColor` | Leading icon background color. |
| `iconTintColor` | Leading icon tint color. |
| `iconImageViewWidth` | Leading icon width. |
| `activityIndicatorViewStyle` | Loading indicator style. |
| `activityIndicatorViewColor` | Loading indicator color. |

### Gestures and dismissal

| Property / Method | Description |
| --- | --- |
| `onTapBlock` | Called when the snackbar is tapped. |
| `onSwipeBlock` | Called when the snackbar is swiped. |
| `shouldDismissOnSwipe` | Automatically dismisses on swipe when enabled. |
| `dismiss()` | Dismisses the snackbar with animation. |
| `pauseDismissTimer()` | Pauses the auto-dismiss timer. |
| `resumeDismissTimer()` | Resumes a paused auto-dismiss timer. |
| `pausesDismissTimerOnTouch` | Pauses timed snackbars while users touch them. |
| `pausesDismissTimerWhenAppInactive` | Pauses timed snackbars while the app is inactive. |

### Lifecycle callbacks

| Callback | Description |
| --- | --- |
| `willShowBlock` | Called before presentation animation starts. |
| `didShowBlock` | Called after presentation animation completes. |
| `willDismissBlock` | Called before dismissal animation starts. |
| `didDismissBlock` | Called after the snackbar is removed from its superview. |
| `dismissBlock` | Legacy dismiss callback kept for compatibility. |

### Accessibility, motion, and haptics

| Property | Description |
| --- | --- |
| `shouldAnnounceForAccessibility` | Posts a VoiceOver announcement when shown. |
| `accessibilityAnnouncement` | Custom VoiceOver announcement. Defaults to `message`. |
| `adjustsFontForContentSizeCategory` | Enables Dynamic Type scaling for built-in labels/buttons. |
| `shouldRespectReduceMotion` | Uses a reduced fade animation when Reduce Motion is enabled. |
| `hapticFeedback` | Feedback played when the snackbar appears. |
| `actionHapticFeedback` | Feedback played when action buttons are tapped. |

## Examples

The repository includes Swift and Objective-C example apps that demonstrate the full feature gallery, including semantic styles, custom content, custom containers, manager policies, timer controls, accessibility, haptics, and async result handling.

## License

TTGSnackbar is released under the MIT license. See [LICENSE](LICENSE) for details.
