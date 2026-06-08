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

    private let animationTypes: [TTGSnackbarAnimationType] = [
        .slideFromBottomBackToBottom,
        .fadeInFadeOut,
        .slideFromLeftToRight,
        .slideFromTopBackToTop
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        buildDemos()
        buildInterface()
    }

    private func buildInterface() {
        view.subviews.forEach { $0.removeFromSuperview() }
        view.backgroundColor = .systemBackground

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 12
        scrollView.addSubview(stackView)

        let titleLabel = UILabel()
        titleLabel.text = "TTGSnackbar Feature Gallery"
        titleLabel.font = .preferredFont(forTextStyle: .largeTitle)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.numberOfLines = 0
        stackView.addArrangedSubview(titleLabel)

        let subtitleLabel = UILabel()
        subtitleLabel.text = "Swift demo: the same feature set is mirrored in the Objective-C example. Edit the message/action text, then run any scenario below."
        subtitleLabel.font = .preferredFont(forTextStyle: .subheadline)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 0
        stackView.addArrangedSubview(subtitleLabel)

        configureTextField(messageField, placeholder: "Message", text: "TTGSnackbar says hello")
        configureTextField(actionField, placeholder: "Action", text: "Undo")
        messageField.accessibilityIdentifier = "demo.messageField"
        actionField.accessibilityIdentifier = "demo.actionField"
        stackView.addArrangedSubview(messageField)
        stackView.addArrangedSubview(actionField)

        customContainerView.translatesAutoresizingMaskIntoConstraints = false
        customContainerView.backgroundColor = .secondarySystemBackground
        customContainerView.layer.cornerRadius = 14
        customContainerView.layer.borderWidth = 1
        customContainerView.layer.borderColor = UIColor.separator.cgColor
        customContainerView.accessibilityIdentifier = "demo.customContainer"
        customContainerView.heightAnchor.constraint(equalToConstant: 120).isActive = true
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
        stackView.addArrangedSubview(customContainerView)

        output.accessibilityIdentifier = "demo.outputLabel"
        output.text = "Run a demo to see callbacks here."
        output.font = .preferredFont(forTextStyle: .footnote)
        output.textColor = .secondaryLabel
        output.numberOfLines = 0
        stackView.addArrangedSubview(output)
        outputLabel = output

        demos.enumerated().forEach { index, demo in
            let button = UIButton(type: .system)
            var configuration = UIButton.Configuration.filled()
            configuration.title = "\(index + 1). \(demo.title)"
            configuration.subtitle = demo.details
            configuration.titleAlignment = .leading
            configuration.baseBackgroundColor = .systemBlue
            configuration.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 12, bottom: 10, trailing: 12)
            button.configuration = configuration
            button.accessibilityIdentifier = "demo." + demo.title.lowercased()
                .replacingOccurrences(of: " / ", with: "-")
                .replacingOccurrences(of: " + ", with: "-")
                .replacingOccurrences(of: " ", with: "-")
            button.contentHorizontalAlignment = .leading
            button.addAction(UIAction { [weak self] _ in
                self?.view.endEditing(true)
                demo.run()
            }, for: .touchUpInside)
            stackView.addArrangedSubview(button)
        }

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -32)
        ])
    }

    private func configureTextField(_ textField: UITextField, placeholder: String, text: String) {
        textField.borderStyle = .roundedRect
        textField.placeholder = placeholder
        textField.text = text
        textField.clearButtonMode = .whileEditing
    }

    private func buildDemos() {
        demos = [
            SnackbarDemo(title: "Basic message", details: "Duration, margins, text styling and animation") { [weak self] in
                self?.showBasicMessage()
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
        snackbar.animationType = animationTypes.randomElement() ?? .slideFromBottomBackToBottom
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
