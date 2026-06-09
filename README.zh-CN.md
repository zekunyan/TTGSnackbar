# TTGSnackbar

[English](README.md)

TTGSnackbar 是一个 Swift 实现的 iOS Snackbar 组件，风格类似 Android Snackbar。它可以在屏幕顶部或底部展示短消息，并支持操作按钮、自定义视图、队列管理、语义样式、无障碍、触觉反馈和 Swift Concurrency。

> 当前开发版本要求 **Swift 5.9**、**Xcode 15+** 和 **iOS 16.0+**。

[![Build Status](https://travis-ci.org/zekunyan/TTGSnackbar.svg?branch=master)](https://travis-ci.org/zekunyan/TTGSnackbar)
[![Version](https://img.shields.io/cocoapods/v/TTGSnackbar.svg?style=flat)](https://github.com/zekunyan/TTGSnackbar)
[![License](https://img.shields.io/cocoapods/l/TTGSnackbar.svg?style=flat)](https://github.com/zekunyan/TTGSnackbar)
[![Platform](https://img.shields.io/cocoapods/p/TTGSnackbar.svg?style=flat)](https://github.com/zekunyan/TTGSnackbar)
[![Swift 5.9](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://developer.apple.com/swift)

![截图](https://github.com/zekunyan/TTGSnackbar/raw/master/Resources/screen_shot.png)

## 预览

![Snackbar 示例](https://github.com/zekunyan/TTGSnackbar/raw/master/Resources/snackbar_example.gif)

## 功能特性

- 在屏幕底部或顶部展示消息。
- 支持一个或两个操作按钮、文字按钮和纯图标按钮。
- 内置语义样式：`default`、`info`、`success`、`warning`、`error`、`loading`。
- 支持自定义 `UIView` 内容，也可以展示在自定义容器视图中。
- 使用 `TTGSnackbarManager` 对 Snackbar 进行排队、替换或去重。
- 使用 Swift Concurrency 等待 action、tap、swipe、dismiss、drop 或展示失败结果。
- 支持 Dynamic Type、VoiceOver 播报、Reduce Motion 和触觉反馈。
- 支持手动暂停/恢复 dismiss timer，也支持触摸和 App 生命周期自动暂停。
- 包含隐私清单，适配现代 Apple 平台要求。

## 环境要求

| TTGSnackbar 版本 | Swift | Xcode | iOS |
| --- | --- | --- | --- |
| 当前版本 | 5.9 | 15+ | 16.0+ |
| 1.6.0 | 4.x | 9+ | 8.0+ |
| 1.5.3 | 3.x | 8+ | 8.0+ |

## 安装

### Swift Package Manager

在 Xcode 中添加以下仓库地址：

```text
https://github.com/zekunyan/TTGSnackbar.git
```

然后导入模块：

```swift
import TTGSnackbar
```

### CocoaPods

在 `Podfile` 中添加：

```ruby
pod "TTGSnackbar"
```

然后执行：

```sh
pod install
```

### Carthage

在 `Cartfile` 中添加：

```text
github "zekunyan/TTGSnackbar"
```

## 快速开始

### 展示简单消息

![简单 Snackbar](https://github.com/zekunyan/TTGSnackbar/raw/master/Resources/snackbar_1.png)

```swift
let snackbar = TTGSnackbar(message: "TTGSnackbar!", duration: .short)
snackbar.show()
```

`show()` 会在无法展示时返回 `false`，例如当前没有 active window，也没有传入自定义容器。

```swift
if !snackbar.show() {
    print("Snackbar 无法展示")
}
```

### 展示操作按钮

![带按钮的 Snackbar](https://github.com/zekunyan/TTGSnackbar/raw/master/Resources/snackbar_2.png)

```swift
let snackbar = TTGSnackbar(
    message: "文件已删除",
    duration: .middle,
    actionText: "撤销"
) { snackbar in
    restoreFile()
    snackbar.dismiss()
}

snackbar.show()
```

### 展示长任务操作

![长任务操作](https://github.com/zekunyan/TTGSnackbar/raw/master/Resources/snackbar_3.png)

```swift
let snackbar = TTGSnackbar(
    message: "正在上传…",
    duration: .forever,
    actionText: "取消"
) { snackbar in
    cancelUpload()
    snackbar.dismiss()
}

snackbar.show()
```

### 展示两个操作按钮

![两个按钮](https://github.com/zekunyan/TTGSnackbar/raw/master/Resources/snackbar_4.png)

```swift
let snackbar = TTGSnackbar(message: "开启通知？", duration: .long)

snackbar.actionText = "开启"
snackbar.actionTextColor = .systemGreen
snackbar.actionBlock = { snackbar in
    enableNotifications()
    snackbar.dismiss()
}

snackbar.secondActionText = "稍后"
snackbar.secondActionTextColor = .systemOrange
snackbar.secondActionBlock = { snackbar in
    snackbar.dismiss()
}

snackbar.show()
```

### 展示图标或纯图标操作

![图标 Snackbar](https://github.com/zekunyan/TTGSnackbar/raw/master/Resources/snackbar_5.jpg)

```swift
let snackbar = TTGSnackbar(message: "保存成功", duration: .middle)
snackbar.icon = UIImage(systemName: "checkmark.circle.fill")
snackbar.iconTintColor = .systemGreen
snackbar.show()
```

```swift
let snackbar = TTGSnackbar(message: "点击图标操作", duration: .middle)
snackbar.actionIcon = UIImage(systemName: "hand.tap.fill")
snackbar.actionBlock = { snackbar in
    snackbar.dismiss()
}
snackbar.show()
```

### 展示自定义内容

![自定义内容](https://github.com/zekunyan/TTGSnackbar/raw/master/Resources/snackbar_6.png)

```swift
let customContentView = UINib(
    nibName: "CustomView",
    bundle: .main
).instantiate(withOwner: nil).first as! UIView

let snackbar = TTGSnackbar(customContentView: customContentView, duration: .long)
snackbar.show()
```

如果希望自定义内容遵循 Snackbar 左右边距，可设置 `shouldActivateLeftAndRightMarginOnCustomContentView = true`。

## 现代 API

### 语义样式

语义样式适合常见业务状态，会应用推荐颜色、图标、loading 状态和默认触觉反馈。

```swift
let success = TTGSnackbar(message: "保存成功", duration: .short)
success.style = .success
success.show()

let loading = TTGSnackbar(message: "同步中…", duration: .forever)
loading.style = .loading
loading.show()
```

可用样式：

- `.default`
- `.info`
- `.success`
- `.warning`
- `.error`
- `.loading`

### Configuration API

可以使用 `TTGSnackbarConfiguration` 通过一个值对象创建 Snackbar。原有属性式 API 仍然支持。

```swift
let snackbar = TTGSnackbar(configuration: .init(
    message: "文件已删除",
    duration: .long,
    style: .warning,
    actionText: "撤销",
    actionBlock: { snackbar in
        undoDelete()
        snackbar.dismiss()
    }
))

snackbar.show()
```

### Async / await 展示

Swift Concurrency 调用方可以等待第一个 action、tap、swipe、dismiss、manager drop 或展示失败结果。

```swift
let result = await TTGSnackbar.show(configuration: .init(
    message: "文件已删除",
    duration: .long,
    style: .warning,
    actionText: "撤销"
))

switch result {
case .action:
    undoDelete()
case .dismissed:
    break
case .dropped:
    print("Manager 策略丢弃了这个 Snackbar")
case .failedToPresent:
    print("没有可用 window 或 container")
default:
    break
}
```

async helper 会自动把 action title 转换为结果回调。使用属性式展示时，如果希望按钮可见，仍需要提供 `actionBlock` 或 `secondActionBlock`。

### 队列管理

`TTGSnackbarManager` 可以保证同一时间只有一个托管的 Snackbar 可见。

```swift
let snackbar = TTGSnackbar(message: "排队消息", duration: .middle)
TTGSnackbarManager.shared.show(snackbar: snackbar, policy: .enqueue)

let urgent = TTGSnackbar(message: "网络已断开", duration: .long)
urgent.style = .error
TTGSnackbarManager.shared.show(snackbar: urgent, policy: .replaceCurrent)
```

可用策略：

| 策略 | 行为 |
| --- | --- |
| `.enqueue` | 当前 Snackbar 消失后再展示。 |
| `.replaceCurrent` | 关闭当前 Snackbar，并优先展示新的 Snackbar。 |
| `.dropIfShowingSameMessage` | 如果相同消息正在展示或排队，则丢弃新的 Snackbar。 |

当 Snackbar 被同步丢弃或无法展示时，`show(snackbar:policy:)` 会返回 `false`。

```swift
let accepted = TTGSnackbarManager.shared.show(
    snackbar: snackbar,
    policy: .dropIfShowingSameMessage
)
```

Objective-C 调用方也可以使用同一个 manager：

```objective-c
TTGSnackbar *bar = [[TTGSnackbar alloc] initWithMessage:@"Bar" duration:TTGSnackbarDurationMiddle];
[[TTGSnackbarManager shared] showSnackbar:bar policy:TTGSnackbarPresentationPolicyEnqueue];
```

## 自定义能力

### 文本与操作按钮

| 属性 | 说明 |
| --- | --- |
| `message` | 主消息文本，支持多行和运行时更新。 |
| `messageTextColor` | 主消息文本颜色。 |
| `messageTextFont` | 主消息文本字体。 |
| `messageTextAlign` | 主消息文本对齐方式。 |
| `messageContentInset` | 主消息文本内边距。 |
| `actionText` | 主操作按钮标题。 |
| `actionIcon` | 主操作按钮图标。 |
| `actionTextColor` | 主操作按钮标题颜色。 |
| `actionTextFont` | 主操作按钮字体。 |
| `actionBlock` | 主操作回调。 |
| `secondActionText` | 第二操作按钮标题。 |
| `secondActionIcon` | 第二操作按钮图标。 |
| `secondActionTextColor` | 第二操作按钮标题颜色。 |
| `secondActionTextFont` | 第二操作按钮字体。 |
| `secondActionBlock` | 第二操作回调。 |
| `actionMaxWidth` | 操作按钮最大宽度，最小值为 44。 |
| `actionTextNumberOfLines` | 操作按钮标题行数。 |

### 展示时长

`duration` 定义 Snackbar 展示时长。

| 时长 | 行为 |
| --- | --- |
| `.short` | 1 秒。 |
| `.middle` | 3 秒。 |
| `.long` | 5 秒。 |
| `.custom` | 使用 `customDuration`，需设置 `customDuration > 0`。无效值会在 debug 构建中触发断言，并回退到 `.short`。 |
| `.forever` | 不自动消失，需要手动 dismiss。 |

### 布局

| 属性 | 说明 |
| --- | --- |
| `animationType` | 展示和消失动画类型。 |
| `animationDuration` | 展示和消失动画时长。 |
| `animationSpringWithDamping` | 动画弹簧阻尼。 |
| `animationInitialSpringVelocity` | 动画初速度。 |
| `leftMargin`、`rightMargin`、`topMargin`、`bottomMargin` | Snackbar 外边距。 |
| `contentInset` | 内置或自定义内容视图的内边距。 |
| `cornerRadius` | Snackbar 圆角。 |
| `snackbarMaxWidth` | Snackbar 最大宽度，默认 -1 表示全宽。 |
| `containerView` | 自定义展示父视图，不设置时使用 active window。 |
| `customContentView` | 自定义内容视图。 |
| `shouldActivateLeftAndRightMarginOnCustomContentView` | 自定义内容是否遵循左右边距。 |
| `shouldHonorSafeAreaLayoutGuides` | 布局时是否遵循 safe area。 |

可用动画类型：

- `.fadeInFadeOut`
- `.slideFromBottomToTop`
- `.slideFromBottomBackToBottom`
- `.slideFromLeftToRight`
- `.slideFromRightToLeft`
- `.slideFromTopToBottom`
- `.slideFromTopBackToTop`

### 图标与 loading indicator

| 属性 | 说明 |
| --- | --- |
| `icon` | 左侧图标。 |
| `iconContentMode` | 左侧图标 content mode。 |
| `iconBackgroundColor` | 左侧图标背景色。 |
| `iconTintColor` | 左侧图标 tint 颜色。 |
| `iconImageViewWidth` | 左侧图标宽度。 |
| `activityIndicatorViewStyle` | loading indicator 样式。 |
| `activityIndicatorViewColor` | loading indicator 颜色。 |

### 手势与关闭

| 属性 / 方法 | 说明 |
| --- | --- |
| `onTapBlock` | 点击 Snackbar 时调用。 |
| `onSwipeBlock` | 滑动 Snackbar 时调用。 |
| `shouldDismissOnSwipe` | 开启后滑动会自动关闭 Snackbar。 |
| `dismiss()` | 使用动画关闭 Snackbar。 |
| `pauseDismissTimer()` | 暂停自动关闭 timer。 |
| `resumeDismissTimer()` | 恢复已暂停的自动关闭 timer。 |
| `pausesDismissTimerOnTouch` | 用户触摸时暂停定时 Snackbar。 |
| `pausesDismissTimerWhenAppInactive` | App inactive 时暂停定时 Snackbar。 |

### 生命周期回调

| 回调 | 说明 |
| --- | --- |
| `willShowBlock` | 展示动画开始前调用。 |
| `didShowBlock` | 展示动画完成后调用。 |
| `willDismissBlock` | 消失动画开始前调用。 |
| `didDismissBlock` | 从父视图移除后调用。 |
| `dismissBlock` | 为兼容保留的旧 dismiss 回调。 |

### 无障碍、动画偏好与触觉反馈

| 属性 | 说明 |
| --- | --- |
| `shouldAnnounceForAccessibility` | 展示时发送 VoiceOver 播报。 |
| `accessibilityAnnouncement` | 自定义 VoiceOver 播报内容，默认使用 `message`。 |
| `adjustsFontForContentSizeCategory` | 内置 label/button 是否支持 Dynamic Type。 |
| `shouldRespectReduceMotion` | 开启 Reduce Motion 时使用更弱的淡入淡出动画。 |
| `hapticFeedback` | Snackbar 出现时的触觉反馈。 |
| `actionHapticFeedback` | 点击操作按钮时的触觉反馈。 |

## 示例工程

仓库包含 Swift 和 Objective-C 示例 App，演示完整 feature gallery：语义样式、自定义内容、自定义容器、manager 策略、timer 控制、无障碍、触觉反馈和 async result 等能力。

## License

TTGSnackbar 使用 MIT 协议发布，详见 [LICENSE](LICENSE)。
