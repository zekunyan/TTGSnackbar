//
//  ViewController.swift
//  TTGSnackbarExample
//
//  Created by tutuge on 2018/10/7.
//  Copyright © 2018 tutuge. All rights reserved.
//

import UIKit

private struct SnackbarDemo {
    let title: String
    let details: String
    let run: () -> Void
}

class ViewController: UIViewController {
    @IBOutlet weak var messageTextField: UITextField?
    @IBOutlet weak var actionTextField: UITextField?
    @IBOutlet weak var durationSegmented: UISegmentedControl?
    @IBOutlet weak var outputLabel: UILabel?
    @IBOutlet weak var animationTypeSegmented: UISegmentedControl?

    private let messageField = UITextField()
    private let actionField = UITextField()
    private let output = UILabel()
    private let customContainerView = UIView()
    private var demos: [SnackbarDemo] = []
    private var pausedSnackbar: TTGSnackbar?

    override func viewDidLoad() {
        super.viewDidLoad()
        buildDemos()
        buildInterface()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    private func buildInterface() {
        view.subviews.forEach { $0.removeFromSuperview() }
        view.backgroundColor = .systemBackground

        let headerContainer = UIView()
        headerContainer.translatesAutoresizingMaskIntoConstraints = false
        headerContainer.backgroundColor = .systemBackground
        headerContainer.layer.shadowColor = UIColor.black.cgColor
        headerContainer.layer.shadowOpacity = 0.08
        headerContainer.layer.shadowRadius = 10
        headerContainer.layer.shadowOffset = CGSize(width: 0, height: 3)
        view.addSubview(headerContainer)

        let headerStackView = UIStackView()
        headerStackView.translatesAutoresizingMaskIntoConstraints = false
        headerStackView.axis = .vertical
        headerStackView.spacing = 6
        headerContainer.addSubview(headerStackView)

        let listScrollView = UIScrollView()
        listScrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(listScrollView)

        let listStackView = UIStackView()
        listStackView.translatesAutoresizingMaskIntoConstraints = false
        listStackView.axis = .vertical
        listStackView.spacing = 12
        listScrollView.addSubview(listStackView)

        let titleLabel = UILabel()
        titleLabel.text = "TTGSnackbar Feature Gallery"
        titleLabel.font = .preferredFont(forTextStyle: .title2)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.numberOfLines = 0
        headerStackView.addArrangedSubview(titleLabel)

        let subtitleLabel = UILabel()
        subtitleLabel.text = "Swift demo: the same feature set is mirrored in the Objective-C example. Edit the message/action text, then run any scenario below."
        subtitleLabel.font = .preferredFont(forTextStyle: .subheadline)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 0
        headerStackView.addArrangedSubview(subtitleLabel)

        configureTextField(messageField, placeholder: "Message", text: "TTGSnackbar says hello")
        configureTextField(actionField, placeholder: "Action", text: "Undo")
        messageField.accessibilityIdentifier = "demo.messageField"
        actionField.accessibilityIdentifier = "demo.actionField"
        headerStackView.addArrangedSubview(messageField)
        headerStackView.addArrangedSubview(actionField)

        customContainerView.translatesAutoresizingMaskIntoConstraints = false
        customContainerView.backgroundColor = .secondarySystemBackground
        customContainerView.layer.cornerRadius = 14
        customContainerView.layer.borderWidth = 1
        customContainerView.layer.borderColor = UIColor.separator.cgColor
        customContainerView.accessibilityIdentifier = "demo.customContainer"
        customContainerView.heightAnchor.constraint(equalToConstant: 76).isActive = true
        let containerLabel = UILabel()
        containerLabel.translatesAutoresizingMaskIntoConstraints = false
        containerLabel.text = "Custom container preview area"
        containerLabel.font = .preferredFont(forTextStyle: .footnote)
        containerLabel.textColor = .secondaryLabel
        customContainerView.addSubview(containerLabel)
        NSLayoutConstraint.activate([
            containerLabel.centerXAnchor.constraint(equalTo: customContainerView.centerXAnchor),
            containerLabel.centerYAnchor.constraint(equalTo: customContainerView.centerYAnchor)
        ])
        headerStackView.addArrangedSubview(customContainerView)

        output.accessibilityIdentifier = "demo.outputLabel"
        output.text = "Run a demo to see callbacks here."
        output.font = .preferredFont(forTextStyle: .footnote)
        output.textColor = .secondaryLabel
        output.numberOfLines = 0
        headerStackView.addArrangedSubview(output)
        outputLabel = output

        demos.enumerated().forEach { index, demo in
            listStackView.addArrangedSubview(makeDemoButton(for: demo, index: index))
        }

        NSLayoutConstraint.activate([
            headerContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            headerStackView.topAnchor.constraint(equalTo: headerContainer.topAnchor, constant: 8),
            headerStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            headerStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            headerStackView.bottomAnchor.constraint(equalTo: headerContainer.bottomAnchor, constant: -8),

            listScrollView.topAnchor.constraint(equalTo: headerContainer.bottomAnchor),
            listScrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            listScrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            listScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            listStackView.topAnchor.constraint(equalTo: listScrollView.contentLayoutGuide.topAnchor, constant: 10),
            listStackView.leadingAnchor.constraint(equalTo: listScrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            listStackView.trailingAnchor.constraint(equalTo: listScrollView.frameLayoutGuide.trailingAnchor, constant: -16),
            listStackView.bottomAnchor.constraint(equalTo: listScrollView.contentLayoutGuide.bottomAnchor, constant: -32)
        ])
    }

    private func configureTextField(_ textField: UITextField, placeholder: String, text: String) {
        textField.borderStyle = .roundedRect
        textField.placeholder = placeholder
        textField.text = text
        textField.clearButtonMode = .whileEditing
    }

    private func makeDemoButton(for demo: SnackbarDemo, index: Int) -> UIButton {
        let accentColor = demoAccentColor(at: index)

        let button = UIButton(type: .custom)
        button.tag = index
        button.accessibilityIdentifier = "demo." + demo.title.lowercased()
            .replacingOccurrences(of: " / ", with: "-")
            .replacingOccurrences(of: " + ", with: "-")
            .replacingOccurrences(of: " ", with: "-")
        button.accessibilityLabel = demo.title
        button.backgroundColor = .secondarySystemGroupedBackground
        button.layer.cornerRadius = 14
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.separator.cgColor
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.08
        button.layer.shadowRadius = 10
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.clipsToBounds = false
        button.addAction(UIAction { [weak self] _ in
            self?.view.endEditing(true)
            demo.run()
        }, for: .touchUpInside)

        let accentView = UIView()
        accentView.translatesAutoresizingMaskIntoConstraints = false
        accentView.backgroundColor = accentColor
        accentView.isUserInteractionEnabled = false
        accentView.layer.cornerRadius = 3
        button.addSubview(accentView)

        let iconContainer = UIView()
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.backgroundColor = accentColor.withAlphaComponent(0.14)
        iconContainer.isUserInteractionEnabled = false
        iconContainer.layer.cornerRadius = 18
        button.addSubview(iconContainer)

        let iconView = UIImageView(image: UIImage(systemName: demoIconName(at: index)))
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.tintColor = accentColor
        iconView.contentMode = .scaleAspectFit
        iconView.isUserInteractionEnabled = false
        iconContainer.addSubview(iconView)

        let numberLabel = UILabel()
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        numberLabel.text = String(format: "%02d", index + 1)
        numberLabel.font = .monospacedDigitSystemFont(ofSize: 11, weight: .semibold)
        numberLabel.textColor = accentColor
        numberLabel.isUserInteractionEnabled = false
        button.addSubview(numberLabel)

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = demo.title
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 0
        titleLabel.isUserInteractionEnabled = false
        button.addSubview(titleLabel)

        let detailLabel = UILabel()
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        detailLabel.text = demo.details
        detailLabel.font = .preferredFont(forTextStyle: .subheadline)
        detailLabel.adjustsFontForContentSizeCategory = true
        detailLabel.textColor = .secondaryLabel
        detailLabel.numberOfLines = 0
        detailLabel.isUserInteractionEnabled = false
        button.addSubview(detailLabel)

        let chevronView = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevronView.translatesAutoresizingMaskIntoConstraints = false
        chevronView.tintColor = .tertiaryLabel
        chevronView.isUserInteractionEnabled = false
        button.addSubview(chevronView)

        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(greaterThanOrEqualToConstant: 82),

            accentView.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 12),
            accentView.topAnchor.constraint(equalTo: button.topAnchor, constant: 14),
            accentView.bottomAnchor.constraint(equalTo: button.bottomAnchor, constant: -14),
            accentView.widthAnchor.constraint(equalToConstant: 5),

            iconContainer.leadingAnchor.constraint(equalTo: accentView.trailingAnchor, constant: 12),
            iconContainer.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 36),
            iconContainer.heightAnchor.constraint(equalToConstant: 36),

            iconView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 18),
            iconView.heightAnchor.constraint(equalToConstant: 18),

            numberLabel.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 12),
            numberLabel.topAnchor.constraint(equalTo: button.topAnchor, constant: 14),

            titleLabel.leadingAnchor.constraint(equalTo: numberLabel.leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: numberLabel.bottomAnchor, constant: 3),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: chevronView.leadingAnchor, constant: -12),

            detailLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            detailLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 3),
            detailLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            detailLabel.bottomAnchor.constraint(lessThanOrEqualTo: button.bottomAnchor, constant: -14),

            chevronView.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -14),
            chevronView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            chevronView.widthAnchor.constraint(equalToConstant: 12),
            chevronView.heightAnchor.constraint(equalToConstant: 18)
        ])

        return button
    }

    private func demoAccentColor(at index: Int) -> UIColor {
        let colors: [UIColor] = [
            .systemTeal,
            .systemIndigo,
            .systemGreen,
            .systemPink,
            .systemOrange,
            .systemPurple,
            .systemBlue,
            .systemMint,
            .systemCyan,
            .systemRed
        ]
        return colors[index % colors.count]
    }

    private func demoIconName(at index: Int) -> String {
        let icons = [
            "text.bubble",
            "sparkles.rectangle.stack",
            "hand.tap",
            "checkmark.circle",
            "sparkles",
            "paintpalette",
            "clock.badge.exclamationmark",
            "square.stack.3d.up",
            "rectangle.inset.filled",
            "list.bullet.rectangle",
            "arrow.triangle.2.circlepath",
            "rectangle.2.swap",
            "waveform.path.ecg",
            "accessibility",
            "pause.circle",
            "arrow.up.to.line",
            "return"
        ]
        return icons[index % icons.count]
    }

    private func buildDemos() {
        demos = [
            SnackbarDemo(title: "Basic message", details: "Duration, margins, text styling and animation") { [weak self] in
                self?.showBasicMessage()
            },
            SnackbarDemo(title: "Animation styles", details: "Fade, bottom, left and right transitions") { [weak self] in
                self?.showAnimationStyles()
            },
            SnackbarDemo(title: "Action button", details: "Primary action callback, separator and button styling") { [weak self] in
                self?.showAction()
            },
            SnackbarDemo(title: "Two actions", details: "Primary and secondary actions side by side") { [weak self] in
                self?.showTwoActions()
            },
            SnackbarDemo(title: "Icon and action icon", details: "SF Symbol icon plus an icon-only action") { [weak self] in
                self?.showIcons()
            },
            SnackbarDemo(title: "Semantic styles", details: "Success, warning and error styles queued together") { [weak self] in
                self?.showSemanticStyles()
            },
            SnackbarDemo(title: "Loading / forever", details: "Indefinite snackbar that dismisses manually") { [weak self] in
                self?.showLoadingForever()
            },
            SnackbarDemo(title: "Custom content view", details: "Embed a custom UIView inside TTGSnackbar") { [weak self] in
                self?.showCustomContentView()
            },
            SnackbarDemo(title: "Custom container", details: "Present inside the preview container instead of the window") { [weak self] in
                self?.showInCustomContainer()
            },
            SnackbarDemo(title: "Manager queue", details: "FIFO queue with one snackbar visible at a time") { [weak self] in
                self?.showManagerQueue()
            },
            SnackbarDemo(title: "Manager replace current", details: "An urgent snackbar replaces the active one") { [weak self] in
                self?.showManagerReplace()
            },
            SnackbarDemo(title: "Drop duplicate message", details: "Manager ignores repeated messages") { [weak self] in
                self?.showManagerDropDuplicate()
            },
            SnackbarDemo(title: "Lifecycle callbacks", details: "will/did show and will/did dismiss callbacks") { [weak self] in
                self?.showLifecycleCallbacks()
            },
            SnackbarDemo(title: "Accessibility + haptics", details: "VoiceOver announcement, Dynamic Type and feedback") { [weak self] in
                self?.showAccessibilityAndHaptics()
            },
            SnackbarDemo(title: "Pause / resume timer", details: "Programmatically pause and resume auto dismiss") { [weak self] in
                self?.showPauseResumeTimer()
            },
            SnackbarDemo(title: "Top presentation", details: "Top animation, custom layout and border") { [weak self] in
                self?.showTopPresentation()
            },
            SnackbarDemo(title: "Await/callback result", details: "Swift async/await result mirrors ObjC callback demo") { [weak self] in
                self?.showAsyncResult()
            }
        ]
    }

    private var message: String {
        let text = messageField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return text.isEmpty ? "TTGSnackbar says hello" : text
    }

    private var actionText: String {
        let text = actionField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return text.isEmpty ? "Undo" : text
    }

    private func baseSnackbar(_ message: String? = nil, duration: TTGSnackbarDuration = .middle) -> TTGSnackbar {
        let snackbar = TTGSnackbar(message: message ?? self.message, duration: duration)
        snackbar.animationType = .slideFromBottomBackToBottom
        snackbar.contentInset = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        snackbar.leftMargin = 12
        snackbar.rightMargin = 12
        snackbar.bottomMargin = 12
        snackbar.cornerRadius = 8
        snackbar.dismissBlock = { [weak self] _ in
            self?.output.text = "Dismissed: \(message ?? self?.message ?? "Snackbar")"
        }
        return snackbar
    }

    private func showBasicMessage() {
        let snackbar = baseSnackbar("\(message) — basic")
        snackbar.backgroundColor = .systemTeal
        snackbar.messageTextColor = .white
        snackbar.messageTextFont = .preferredFont(forTextStyle: .headline)
        snackbar.show()
    }

    private func showAnimationStyles() {
        output.text = "Queued bottom animation styles"
        let animationDemos: [(String, TTGSnackbarAnimationType, UIColor)] = [
            ("Fade in / fade out", .fadeInFadeOut, .systemIndigo),
            ("Slide from bottom, dismiss upward", .slideFromBottomToTop, .systemBlue),
            ("Slide from bottom, back to bottom", .slideFromBottomBackToBottom, .systemTeal),
            ("Slide from left to right", .slideFromLeftToRight, .systemGreen),
            ("Slide from right to left", .slideFromRightToLeft, .systemOrange)
        ]

        animationDemos.forEach { title, animationType, color in
            let snackbar = baseSnackbar(title, duration: .short)
            snackbar.animationType = animationType
            snackbar.backgroundColor = color
            snackbar.messageTextColor = .white
            snackbar.messageTextFont = .preferredFont(forTextStyle: .headline)
            TTGSnackbarManager.shared.show(snackbar: snackbar, policy: .enqueue)
        }
    }

    private func showAction() {
        let snackbar = TTGSnackbar(message: message, duration: .middle, actionText: actionText) { [weak self] snackbar in
            self?.output.text = "Primary action tapped"
            snackbar.dismiss()
        }
        snackbar.actionTextColor = .systemYellow
        snackbar.actionTextFont = .preferredFont(forTextStyle: .headline)
        snackbar.actionMaxWidth = 120
        snackbar.separateViewBackgroundColor = .systemYellow
        snackbar.animationType = .slideFromBottomBackToBottom
        snackbar.show()
    }

    private func showTwoActions() {
        let snackbar = baseSnackbar("\(message) — choose an action")
        snackbar.actionText = "Yes"
        snackbar.actionTextColor = .systemGreen
        snackbar.actionBlock = { [weak self] snackbar in
            self?.output.text = "Tapped Yes"
            snackbar.dismiss()
        }
        snackbar.secondActionText = "No"
        snackbar.secondActionTextColor = .systemOrange
        snackbar.secondActionBlock = { [weak self] snackbar in
            self?.output.text = "Tapped No"
            snackbar.dismiss()
        }
        snackbar.show()
    }

    private func showIcons() {
        let snackbar = baseSnackbar("\(message) — icon demo")
        snackbar.icon = UIImage(systemName: "sparkles")
        snackbar.iconTintColor = .systemYellow
        snackbar.actionIcon = UIImage(systemName: "hand.tap.fill")
        snackbar.actionText = ""
        snackbar.actionBlock = { [weak self] snackbar in
            self?.output.text = "Icon action tapped"
            snackbar.dismiss()
        }
        snackbar.show()
    }

    private func showSemanticStyles() {
        let success = baseSnackbar("Saved successfully", duration: .short)
        success.style = .success
        let warning = baseSnackbar("Please review your settings", duration: .short)
        warning.style = .warning
        let error = baseSnackbar("Network request failed", duration: .short)
        error.style = .error
        [success, warning, error].forEach { TTGSnackbarManager.shared.show(snackbar: $0, policy: .enqueue) }
    }

    private func showLoadingForever() {
        let snackbar = baseSnackbar("Syncing data… tap Done after work completes", duration: .forever)
        snackbar.style = .loading
        snackbar.actionText = "Done"
        snackbar.actionBlock = { [weak self] snackbar in
            self?.output.text = "Loading completed"
            snackbar.dismiss()
        }
        snackbar.show()
    }

    private func showCustomContentView() {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 4
        container.isLayoutMarginsRelativeArrangement = true
        container.layoutMargins = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        container.backgroundColor = .systemIndigo
        container.layer.cornerRadius = 12
        container.layer.masksToBounds = true

        let title = UILabel()
        title.text = "Custom content"
        title.textColor = .white
        title.font = .preferredFont(forTextStyle: .headline)
        let detail = UILabel()
        detail.text = "Use any UIView hierarchy inside a snackbar."
        detail.textColor = .white.withAlphaComponent(0.85)
        detail.font = .preferredFont(forTextStyle: .footnote)
        detail.numberOfLines = 0
        container.addArrangedSubview(title)
        container.addArrangedSubview(detail)

        let snackbar = TTGSnackbar(customContentView: container, duration: .middle)
        snackbar.backgroundColor = .clear
        snackbar.contentInset = .zero
        snackbar.cornerRadius = 12
        snackbar.borderColor = .clear
        snackbar.borderWidth = 0
        snackbar.leftMargin = 24
        snackbar.rightMargin = 24
        snackbar.shouldActivateLeftAndRightMarginOnCustomContentView = true
        snackbar.show()
    }

    private func showInCustomContainer() {
        let snackbar = baseSnackbar("Shown inside a custom container", duration: .middle)
        snackbar.containerView = customContainerView
        snackbar.style = .info
        snackbar.show()
    }

    private func showManagerQueue() {
        output.text = "Queued 3 snackbars"
        for index in 1...3 {
            let snackbar = baseSnackbar("Queued snackbar #\(index)", duration: .short)
            snackbar.style = index == 1 ? .info : (index == 2 ? .success : .warning)
            TTGSnackbarManager.shared.show(snackbar: snackbar, policy: .enqueue)
        }
    }

    private func showManagerReplace() {
        let normal = baseSnackbar("Normal queued snackbar", duration: .long)
        normal.style = .info
        TTGSnackbarManager.shared.show(snackbar: normal, policy: .enqueue)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let urgent = self.baseSnackbar("Urgent replacement snackbar", duration: .middle)
            urgent.style = .error
            TTGSnackbarManager.shared.show(snackbar: urgent, policy: .replaceCurrent)
        }
    }

    private func showManagerDropDuplicate() {
        output.text = "Submitted duplicate messages; only one should appear."
        for _ in 0..<3 {
            let snackbar = baseSnackbar("Duplicate manager message", duration: .short)
            snackbar.style = .warning
            TTGSnackbarManager.shared.show(snackbar: snackbar, policy: .dropIfShowingSameMessage)
        }
    }

    private func showLifecycleCallbacks() {
        let snackbar = baseSnackbar("Lifecycle callbacks are logged", duration: .middle)
        snackbar.willShowBlock = { [weak self] _ in self?.output.text = "willShow" }
        snackbar.didShowBlock = { [weak self] _ in self?.output.text = "didShow" }
        snackbar.willDismissBlock = { [weak self] _ in self?.output.text = "willDismiss" }
        snackbar.didDismissBlock = { [weak self] _ in self?.output.text = "didDismiss" }
        snackbar.show()
    }

    private func showAccessibilityAndHaptics() {
        let snackbar = baseSnackbar("Accessibility announcement with haptic feedback", duration: .middle)
        snackbar.shouldAnnounceForAccessibility = true
        snackbar.accessibilityAnnouncement = "TTGSnackbar accessibility and haptic demo"
        snackbar.hapticFeedback = .success
        snackbar.actionHapticFeedback = .mediumImpact
        snackbar.adjustsFontForContentSizeCategory = true
        snackbar.shouldRespectReduceMotion = true
        snackbar.style = .success
        snackbar.actionText = actionText
        snackbar.actionBlock = { [weak self] snackbar in
            self?.output.text = "Accessible action tapped"
            snackbar.dismiss()
        }
        snackbar.show()
    }

    private func showPauseResumeTimer() {
        let snackbar = baseSnackbar("Timer paused for 2 seconds, then resumes", duration: .long)
        snackbar.style = .info
        snackbar.pausesDismissTimerOnTouch = true
        snackbar.show()
        pausedSnackbar = snackbar
        snackbar.pauseDismissTimer()
        output.text = "Timer paused"
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self, weak snackbar] in
            snackbar?.resumeDismissTimer()
            self?.output.text = "Timer resumed"
        }
    }

    private func showTopPresentation() {
        let snackbar = baseSnackbar("Top presentation with custom border", duration: .middle)
        snackbar.animationType = .slideFromTopBackToTop
        snackbar.topMargin = 12
        snackbar.bottomMargin = 12
        snackbar.borderColor = UIColor.systemBlue
        snackbar.borderWidth = 2
        snackbar.snackbarMaxWidth = 420
        snackbar.show()
    }

    private func showAsyncResult() {
        output.text = "Awaiting snackbar result…"
        Task { @MainActor in
            let result = await TTGSnackbar.show(configuration: .init(
                message: "Async result demo",
                duration: .long,
                style: .warning,
                actionText: actionText
            ))
            output.text = "Async result: \(result)"
        }
    }
}
