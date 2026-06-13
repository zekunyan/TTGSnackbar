//
//  AppDelegate.swift
//  TTGSnackbarExample
//
//  Created by tutuge on 2018/10/7.
//  Copyright © 2018 tutuge. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        guard let demo = QuickStartScreenshotDemo.fromLaunchArguments() else {
            return true
        }

        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = QuickStartScreenshotViewController(demo: demo)
        window.makeKeyAndVisible()
        self.window = window
        return true
    }
}

private struct QuickStartScreenshotDemo {
    let id: String
    let title: String
    let subtitle: String
    let message: String
    let detail: String
    let action: String?
    let secondAction: String?
    let iconName: String?
    let style: TTGSnackbarStyle?
    let customContent: Bool
    let color: UIColor

    static func fromLaunchArguments() -> QuickStartScreenshotDemo? {
        let arguments = ProcessInfo.processInfo.arguments
        guard
            let flagIndex = arguments.firstIndex(of: "--quick-start-demo"),
            arguments.indices.contains(flagIndex + 1)
        else {
            return nil
        }

        return demos.first { $0.id == arguments[flagIndex + 1] }
    }

    static let demos: [QuickStartScreenshotDemo] = [
        QuickStartScreenshotDemo(
            id: "simple",
            title: "Show a simple message",
            subtitle: "Present a short snackbar with only a message.",
            message: "TTGSnackbar!",
            detail: "duration: .short",
            action: nil,
            secondAction: nil,
            iconName: nil,
            style: nil,
            customContent: false,
            color: .systemTeal
        ),
        QuickStartScreenshotDemo(
            id: "action",
            title: "Show an action button",
            subtitle: "Attach one recovery action to the snackbar.",
            message: "File deleted",
            detail: "actionText: Undo",
            action: "Undo",
            secondAction: nil,
            iconName: nil,
            style: nil,
            customContent: false,
            color: .systemBlue
        ),
        QuickStartScreenshotDemo(
            id: "loading",
            title: "Show a long-running action",
            subtitle: "Keep the snackbar visible while work runs.",
            message: "Uploading...",
            detail: "duration: .forever",
            action: "Cancel",
            secondAction: nil,
            iconName: nil,
            style: .loading,
            customContent: false,
            color: .systemPink
        ),
        QuickStartScreenshotDemo(
            id: "semantic",
            title: "Use semantic feedback",
            subtitle: "Apply built-in styles for common states.",
            message: "Saved successfully",
            detail: "style: .success",
            action: nil,
            secondAction: nil,
            iconName: nil,
            style: .success,
            customContent: false,
            color: .systemGreen
        ),
        QuickStartScreenshotDemo(
            id: "icon",
            title: "Show an icon",
            subtitle: "Add a leading SF Symbol to the default snackbar.",
            message: "New feature ready",
            detail: "icon: sparkles",
            action: nil,
            secondAction: nil,
            iconName: "sparkles",
            style: nil,
            customContent: false,
            color: .systemPurple
        ),
        QuickStartScreenshotDemo(
            id: "custom",
            title: "Show custom content",
            subtitle: "Embed a custom UIView inside a snackbar.",
            message: "Custom content",
            detail: "UIView hierarchy",
            action: nil,
            secondAction: nil,
            iconName: nil,
            style: nil,
            customContent: true,
            color: .systemIndigo
        )
    ]
}

private final class QuickStartScreenshotViewController: UIViewController {
    private let demo: QuickStartScreenshotDemo
    private var hasShownSnackbar = false

    init(demo: QuickStartScreenshotDemo) {
        self.demo = demo
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        buildInterface()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !hasShownSnackbar else { return }
        hasShownSnackbar = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
            self?.showDemoSnackbar()
        }
    }

    private func buildInterface() {
        view.backgroundColor = .systemGroupedBackground

        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor.systemBackground.cgColor,
            UIColor.systemBlue.withAlphaComponent(0.08).cgColor,
            UIColor.systemTeal.withAlphaComponent(0.10).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.frame = UIScreen.main.bounds
        view.layer.addSublayer(gradient)

        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 18
        view.addSubview(stackView)

        let badge = UILabel()
        badge.text = "Quick Start"
        badge.textColor = demo.color
        badge.font = .systemFont(ofSize: 15, weight: .bold)
        badge.backgroundColor = .systemBackground
        badge.textAlignment = .center
        badge.layer.cornerRadius = 17
        badge.layer.masksToBounds = true
        badge.widthAnchor.constraint(equalToConstant: 130).isActive = true
        badge.heightAnchor.constraint(equalToConstant: 34).isActive = true
        stackView.addArrangedSubview(badge)

        let titleLabel = UILabel()
        titleLabel.text = demo.title
        titleLabel.font = .systemFont(ofSize: 34, weight: .heavy)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 0
        stackView.addArrangedSubview(titleLabel)

        let subtitleLabel = UILabel()
        subtitleLabel.text = demo.subtitle
        subtitleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 0
        stackView.addArrangedSubview(subtitleLabel)

        let cardStackView = UIStackView()
        cardStackView.axis = .vertical
        cardStackView.spacing = 12
        stackView.addArrangedSubview(cardStackView)

        [
            ("Message", demo.message, "text.bubble.fill"),
            ("Behavior", demo.detail, "slider.horizontal.3"),
            ("Result", "Visible inside the simulator", "iphone")
        ].forEach { title, value, iconName in
            cardStackView.addArrangedSubview(makeCard(title: title, value: value, iconName: iconName))
        }

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 28)
        ])
    }

    private func makeCard(title: String, value: String, iconName: String) -> UIView {
        let container = UIView()
        container.backgroundColor = .secondarySystemGroupedBackground
        container.layer.cornerRadius = 18
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.separator.cgColor

        let iconView = UIImageView(image: UIImage(systemName: iconName))
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.tintColor = demo.color
        iconView.contentMode = .scaleAspectFit
        container.addSubview(iconView)

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 15, weight: .bold)
        titleLabel.textColor = .label
        container.addSubview(titleLabel)

        let valueLabel = UILabel()
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 13, weight: .medium)
        valueLabel.textColor = .secondaryLabel
        valueLabel.numberOfLines = 0
        container.addSubview(valueLabel)

        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(greaterThanOrEqualToConstant: 72),

            iconView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 18),
            iconView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 28),
            iconView.heightAnchor.constraint(equalToConstant: 28),

            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 15),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),

            valueLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            valueLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            valueLabel.bottomAnchor.constraint(lessThanOrEqualTo: container.bottomAnchor, constant: -14)
        ])

        return container
    }

    private func showDemoSnackbar() {
        if demo.customContent {
            showCustomSnackbar()
            return
        }

        let snackbar = TTGSnackbar(message: demo.message, duration: .forever)
        snackbar.animationType = .slideFromBottomBackToBottom

        if let style = demo.style {
            snackbar.style = style
        }
        if let iconName = demo.iconName {
            snackbar.icon = UIImage(systemName: iconName)
        }
        if let action = demo.action {
            snackbar.actionText = action
            snackbar.actionBlock = { snackbar in snackbar.dismiss() }
        }
        if let secondAction = demo.secondAction {
            snackbar.secondActionText = secondAction
            snackbar.secondActionBlock = { snackbar in snackbar.dismiss() }
        }

        snackbar.show()
    }

    private func showCustomSnackbar() {
        let contentView = UIStackView()
        contentView.axis = .vertical
        contentView.spacing = 5
        contentView.isLayoutMarginsRelativeArrangement = true
        contentView.layoutMargins = UIEdgeInsets(top: 16, left: 18, bottom: 16, right: 18)
        contentView.backgroundColor = UIColor.ttgDefaultBackground
        contentView.layer.cornerRadius = 18
        contentView.layer.masksToBounds = true

        let titleLabel = UILabel()
        titleLabel.text = "Custom content view"
        titleLabel.textColor = UIColor.ttgDefaultText
        titleLabel.font = .systemFont(ofSize: 17, weight: .bold)
        contentView.addArrangedSubview(titleLabel)

        let detailLabel = UILabel()
        detailLabel.text = "Loaded from a custom UIView hierarchy."
        detailLabel.textColor = UIColor.ttgDefaultText.withAlphaComponent(0.78)
        detailLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        detailLabel.numberOfLines = 0
        contentView.addArrangedSubview(detailLabel)

        let snackbar = TTGSnackbar(customContentView: contentView, duration: .forever)
        snackbar.backgroundColor = .clear
        snackbar.contentInset = .zero
        snackbar.cornerRadius = 18
        snackbar.borderWidth = 0
        snackbar.leftMargin = 16
        snackbar.rightMargin = 16
        snackbar.bottomMargin = 16
        snackbar.shouldActivateLeftAndRightMarginOnCustomContentView = true
        snackbar.show()
    }
}
