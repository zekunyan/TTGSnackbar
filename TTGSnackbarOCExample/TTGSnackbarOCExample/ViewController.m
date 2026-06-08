//
//  ViewController.m
//  TTGSnackbarOCExample
//
//  Created by tutuge on 2018/10/7.
//  Copyright © 2018 tutuge. All rights reserved.
//

#import "ViewController.h"

@import TTGSnackbar;

typedef void (^TTGDemoBlock)(void);

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *ActivityLabel;
@property (nonatomic, strong) UITextField *messageField;
@property (nonatomic, strong) UITextField *actionField;
@property (nonatomic, strong) UILabel *outputLabel;
@property (nonatomic, strong) UIView *customContainerView;
@property (nonatomic, strong) NSArray<NSDictionary *> *demos;
@property (nonatomic, strong) TTGSnackbar *pausedSnackbar;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self buildDemos];
    [self buildInterface];
}

- (void)buildInterface {
    for (UIView *subview in self.view.subviews) {
        [subview removeFromSuperview];
    }
    self.view.backgroundColor = UIColor.systemBackgroundColor;

    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:scrollView];

    UIStackView *stackView = [[UIStackView alloc] init];
    stackView.translatesAutoresizingMaskIntoConstraints = NO;
    stackView.axis = UILayoutConstraintAxisVertical;
    stackView.spacing = 12;
    [scrollView addSubview:stackView];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"TTGSnackbar Feature Gallery";
    titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleLargeTitle];
    titleLabel.adjustsFontForContentSizeCategory = YES;
    titleLabel.numberOfLines = 0;
    [stackView addArrangedSubview:titleLabel];

    UILabel *subtitleLabel = [[UILabel alloc] init];
    subtitleLabel.text = @"Objective-C demo: the same feature set is mirrored in the Swift example. Edit the message/action text, then run any scenario below.";
    subtitleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    subtitleLabel.textColor = UIColor.secondaryLabelColor;
    subtitleLabel.numberOfLines = 0;
    [stackView addArrangedSubview:subtitleLabel];

    self.messageField = [self textFieldWithPlaceholder:@"Message" text:@"TTGSnackbar says hello"];
    self.actionField = [self textFieldWithPlaceholder:@"Action" text:@"Undo"];
    [stackView addArrangedSubview:self.messageField];
    [stackView addArrangedSubview:self.actionField];

    self.customContainerView = [[UIView alloc] init];
    self.customContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    self.customContainerView.backgroundColor = UIColor.secondarySystemBackgroundColor;
    self.customContainerView.layer.cornerRadius = 14;
    self.customContainerView.layer.borderWidth = 1;
    self.customContainerView.layer.borderColor = UIColor.separatorColor.CGColor;
    [self.customContainerView.heightAnchor constraintEqualToConstant:120].active = YES;

    UILabel *containerLabel = [[UILabel alloc] init];
    containerLabel.translatesAutoresizingMaskIntoConstraints = NO;
    containerLabel.text = @"Custom container preview area";
    containerLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    containerLabel.textColor = UIColor.secondaryLabelColor;
    [self.customContainerView addSubview:containerLabel];
    [NSLayoutConstraint activateConstraints:@[
        [containerLabel.centerXAnchor constraintEqualToAnchor:self.customContainerView.centerXAnchor],
        [containerLabel.centerYAnchor constraintEqualToAnchor:self.customContainerView.centerYAnchor]
    ]];
    [stackView addArrangedSubview:self.customContainerView];

    self.outputLabel = [[UILabel alloc] init];
    self.outputLabel.text = @"Run a demo to see callbacks here.";
    self.outputLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    self.outputLabel.textColor = UIColor.secondaryLabelColor;
    self.outputLabel.numberOfLines = 0;
    [stackView addArrangedSubview:self.outputLabel];
    self.ActivityLabel = self.outputLabel;

    [self.demos enumerateObjectsUsingBlock:^(NSDictionary *demo, NSUInteger index, BOOL *stop) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.tag = index;
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        button.titleLabel.numberOfLines = 0;
        button.titleLabel.textAlignment = NSTextAlignmentLeft;
        button.backgroundColor = UIColor.systemBlueColor;
        button.tintColor = UIColor.whiteColor;
        button.layer.cornerRadius = 10;
        button.contentEdgeInsets = UIEdgeInsetsMake(10, 12, 10, 12);
        NSString *title = [NSString stringWithFormat:@"%lu. %@\n%@", (unsigned long)index + 1, demo[@"title"], demo[@"details"]];
        [button setTitle:title forState:UIControlStateNormal];
        [button addTarget:self action:@selector(runDemo:) forControlEvents:UIControlEventTouchUpInside];
        [stackView addArrangedSubview:button];
    }];

    UILayoutGuide *safeArea = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [scrollView.topAnchor constraintEqualToAnchor:safeArea.topAnchor],
        [scrollView.leadingAnchor constraintEqualToAnchor:safeArea.leadingAnchor],
        [scrollView.trailingAnchor constraintEqualToAnchor:safeArea.trailingAnchor],
        [scrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],

        [stackView.topAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.topAnchor constant:20],
        [stackView.leadingAnchor constraintEqualToAnchor:scrollView.frameLayoutGuide.leadingAnchor constant:16],
        [stackView.trailingAnchor constraintEqualToAnchor:scrollView.frameLayoutGuide.trailingAnchor constant:-16],
        [stackView.bottomAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.bottomAnchor constant:-32]
    ]];
}

- (UITextField *)textFieldWithPlaceholder:(NSString *)placeholder text:(NSString *)text {
    UITextField *textField = [[UITextField alloc] init];
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.placeholder = placeholder;
    textField.text = text;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    return textField;
}

- (void)buildDemos {
    __weak typeof(self) weakSelf = self;
    self.demos = @[
        [self demoWithTitle:@"Basic message" details:@"Duration, margins, text styling and animation" block:^{ [weakSelf showBasicMessage]; }],
        [self demoWithTitle:@"Action button" details:@"Primary action callback, separator and button styling" block:^{ [weakSelf showAction]; }],
        [self demoWithTitle:@"Two actions" details:@"Primary and secondary actions side by side" block:^{ [weakSelf showTwoActions]; }],
        [self demoWithTitle:@"Icon and action icon" details:@"SF Symbol icon plus an icon-only action" block:^{ [weakSelf showIcons]; }],
        [self demoWithTitle:@"Semantic styles" details:@"Success, warning and error styles queued together" block:^{ [weakSelf showSemanticStyles]; }],
        [self demoWithTitle:@"Loading / forever" details:@"Indefinite snackbar that dismisses manually" block:^{ [weakSelf showLoadingForever]; }],
        [self demoWithTitle:@"Custom content view" details:@"Embed a custom UIView inside TTGSnackbar" block:^{ [weakSelf showCustomContentView]; }],
        [self demoWithTitle:@"Custom container" details:@"Present inside the preview container instead of the window" block:^{ [weakSelf showInCustomContainer]; }],
        [self demoWithTitle:@"Manager queue" details:@"FIFO queue with one snackbar visible at a time" block:^{ [weakSelf showManagerQueue]; }],
        [self demoWithTitle:@"Manager replace current" details:@"An urgent snackbar replaces the active one" block:^{ [weakSelf showManagerReplace]; }],
        [self demoWithTitle:@"Drop duplicate message" details:@"Manager ignores repeated messages" block:^{ [weakSelf showManagerDropDuplicate]; }],
        [self demoWithTitle:@"Lifecycle callbacks" details:@"will/did show and will/did dismiss callbacks" block:^{ [weakSelf showLifecycleCallbacks]; }],
        [self demoWithTitle:@"Accessibility + haptics" details:@"VoiceOver announcement, Dynamic Type and feedback" block:^{ [weakSelf showAccessibilityAndHaptics]; }],
        [self demoWithTitle:@"Pause / resume timer" details:@"Programmatically pause and resume auto dismiss" block:^{ [weakSelf showPauseResumeTimer]; }],
        [self demoWithTitle:@"Top presentation" details:@"Top animation, custom layout and border" block:^{ [weakSelf showTopPresentation]; }],
        [self demoWithTitle:@"Await/callback result" details:@"ObjC callback result mirrors Swift async/await demo" block:^{ [weakSelf showCallbackResult]; }]
    ];
}

- (NSDictionary *)demoWithTitle:(NSString *)title details:(NSString *)details block:(TTGDemoBlock)block {
    return @{@"title": title, @"details": details, @"block": [block copy]};
}

- (void)runDemo:(UIButton *)sender {
    [self.view endEditing:YES];
    TTGDemoBlock block = self.demos[sender.tag][@"block"];
    if (block) {
        block();
    }
}

- (NSString *)message {
    NSString *text = [self.messageField.text stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    return text.length > 0 ? text : @"TTGSnackbar says hello";
}

- (NSString *)actionText {
    NSString *text = [self.actionField.text stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    return text.length > 0 ? text : @"Undo";
}

- (TTGSnackbar *)baseSnackbarWithMessage:(NSString *)message duration:(TTGSnackbarDuration)duration {
    TTGSnackbar *snackbar = [[TTGSnackbar alloc] initWithMessage:message ?: [self message] duration:duration];
    snackbar.animationType = TTGSnackbarAnimationTypeSlideFromBottomBackToBottom;
    snackbar.contentInset = UIEdgeInsetsMake(8, 12, 8, 12);
    snackbar.leftMargin = 12;
    snackbar.rightMargin = 12;
    snackbar.bottomMargin = 12;
    snackbar.cornerRadius = 8;
    __weak typeof(self) weakSelf = self;
    snackbar.dismissBlock = ^(TTGSnackbar *dismissedSnackbar) {
        weakSelf.outputLabel.text = [NSString stringWithFormat:@"Dismissed: %@", message ?: [weakSelf message]];
    };
    return snackbar;
}

- (void)showBasicMessage {
    TTGSnackbar *snackbar = [self baseSnackbarWithMessage:[[self message] stringByAppendingString:@" — basic"] duration:TTGSnackbarDurationMiddle];
    snackbar.backgroundColor = UIColor.systemTealColor;
    snackbar.messageTextColor = UIColor.whiteColor;
    snackbar.messageTextFont = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    [snackbar show];
}

- (void)showAction {
    __weak typeof(self) weakSelf = self;
    TTGSnackbar *snackbar = [[TTGSnackbar alloc] initWithMessage:[self message]
                                                        duration:TTGSnackbarDurationMiddle
                                                      actionText:[self actionText]
                                                     actionBlock:^(TTGSnackbar *snackbar) {
        weakSelf.outputLabel.text = @"Primary action tapped";
        [snackbar dismiss];
    }];
    snackbar.actionTextColor = UIColor.systemYellowColor;
    snackbar.actionTextFont = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    snackbar.actionMaxWidth = 120;
    snackbar.separateViewBackgroundColor = UIColor.systemYellowColor;
    snackbar.animationType = TTGSnackbarAnimationTypeSlideFromBottomBackToBottom;
    [snackbar show];
}

- (void)showTwoActions {
    __weak typeof(self) weakSelf = self;
    TTGSnackbar *snackbar = [self baseSnackbarWithMessage:[NSString stringWithFormat:@"%@ — choose an action", [self message]] duration:TTGSnackbarDurationMiddle];
    snackbar.actionText = @"Yes";
    snackbar.actionTextColor = UIColor.systemGreenColor;
    snackbar.actionBlock = ^(TTGSnackbar *snackbar) {
        weakSelf.outputLabel.text = @"Tapped Yes";
        [snackbar dismiss];
    };
    snackbar.secondActionText = @"No";
    snackbar.secondActionTextColor = UIColor.systemOrangeColor;
    snackbar.secondActionBlock = ^(TTGSnackbar *snackbar) {
        weakSelf.outputLabel.text = @"Tapped No";
        [snackbar dismiss];
    };
    [snackbar show];
}

- (void)showIcons {
    __weak typeof(self) weakSelf = self;
    TTGSnackbar *snackbar = [self baseSnackbarWithMessage:[NSString stringWithFormat:@"%@ — icon demo", [self message]] duration:TTGSnackbarDurationMiddle];
    snackbar.icon = [UIImage systemImageNamed:@"sparkles"];
    snackbar.iconTintColor = UIColor.systemYellowColor;
    snackbar.actionIcon = [UIImage systemImageNamed:@"hand.tap.fill"];
    snackbar.actionText = @"";
    snackbar.actionBlock = ^(TTGSnackbar *snackbar) {
        weakSelf.outputLabel.text = @"Icon action tapped";
        [snackbar dismiss];
    };
    [snackbar show];
}

- (void)showSemanticStyles {
    TTGSnackbar *success = [self baseSnackbarWithMessage:@"Saved successfully" duration:TTGSnackbarDurationShort];
    success.style = TTGSnackbarStyleSuccess;
    TTGSnackbar *warning = [self baseSnackbarWithMessage:@"Please review your settings" duration:TTGSnackbarDurationShort];
    warning.style = TTGSnackbarStyleWarning;
    TTGSnackbar *error = [self baseSnackbarWithMessage:@"Network request failed" duration:TTGSnackbarDurationShort];
    error.style = TTGSnackbarStyleError;
    [[TTGSnackbarManager shared] showSnackbar:success policy:TTGSnackbarPresentationPolicyEnqueue];
    [[TTGSnackbarManager shared] showSnackbar:warning policy:TTGSnackbarPresentationPolicyEnqueue];
    [[TTGSnackbarManager shared] showSnackbar:error policy:TTGSnackbarPresentationPolicyEnqueue];
}

- (void)showLoadingForever {
    __weak typeof(self) weakSelf = self;
    TTGSnackbar *snackbar = [self baseSnackbarWithMessage:@"Syncing data… tap Done after work completes" duration:TTGSnackbarDurationForever];
    snackbar.style = TTGSnackbarStyleLoading;
    snackbar.actionText = @"Done";
    snackbar.actionBlock = ^(TTGSnackbar *snackbar) {
        weakSelf.outputLabel.text = @"Loading completed";
        [snackbar dismiss];
    };
    [snackbar show];
}

- (void)showCustomContentView {
    UIStackView *container = [[UIStackView alloc] init];
    container.axis = UILayoutConstraintAxisVertical;
    container.spacing = 4;
    container.layoutMarginsRelativeArrangement = YES;
    container.layoutMargins = UIEdgeInsetsMake(12, 16, 12, 16);
    container.backgroundColor = UIColor.systemIndigoColor;
    container.layer.cornerRadius = 12;

    UILabel *title = [[UILabel alloc] init];
    title.text = @"Custom content";
    title.textColor = UIColor.whiteColor;
    title.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    UILabel *detail = [[UILabel alloc] init];
    detail.text = @"Use any UIView hierarchy inside a snackbar.";
    detail.textColor = [UIColor.whiteColor colorWithAlphaComponent:0.85];
    detail.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    detail.numberOfLines = 0;
    [container addArrangedSubview:title];
    [container addArrangedSubview:detail];

    TTGSnackbar *snackbar = [[TTGSnackbar alloc] initWithMessage:@"" duration:TTGSnackbarDurationMiddle];
    snackbar.customContentView = container;
    snackbar.leftMargin = 24;
    snackbar.rightMargin = 24;
    snackbar.shouldActivateLeftAndRightMarginOnCustomContentView = YES;
    [snackbar show];
}

- (void)showInCustomContainer {
    TTGSnackbar *snackbar = [self baseSnackbarWithMessage:@"Shown inside a custom container" duration:TTGSnackbarDurationMiddle];
    snackbar.containerView = self.customContainerView;
    snackbar.style = TTGSnackbarStyleInfo;
    [snackbar show];
}

- (void)showManagerQueue {
    self.outputLabel.text = @"Queued 3 snackbars";
    NSArray<NSNumber *> *styles = @[@(TTGSnackbarStyleInfo), @(TTGSnackbarStyleSuccess), @(TTGSnackbarStyleWarning)];
    for (NSInteger index = 1; index <= 3; index++) {
        TTGSnackbar *snackbar = [self baseSnackbarWithMessage:[NSString stringWithFormat:@"Queued snackbar #%ld", (long)index] duration:TTGSnackbarDurationShort];
        snackbar.style = (TTGSnackbarStyle)[styles[index - 1] integerValue];
        [[TTGSnackbarManager shared] showSnackbar:snackbar policy:TTGSnackbarPresentationPolicyEnqueue];
    }
}

- (void)showManagerReplace {
    TTGSnackbar *normal = [self baseSnackbarWithMessage:@"Normal queued snackbar" duration:TTGSnackbarDurationLong];
    normal.style = TTGSnackbarStyleInfo;
    [[TTGSnackbarManager shared] showSnackbar:normal policy:TTGSnackbarPresentationPolicyEnqueue];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        TTGSnackbar *urgent = [self baseSnackbarWithMessage:@"Urgent replacement snackbar" duration:TTGSnackbarDurationMiddle];
        urgent.style = TTGSnackbarStyleError;
        [[TTGSnackbarManager shared] showSnackbar:urgent policy:TTGSnackbarPresentationPolicyReplaceCurrent];
    });
}

- (void)showManagerDropDuplicate {
    self.outputLabel.text = @"Submitted duplicate messages; only one should appear.";
    for (NSInteger index = 0; index < 3; index++) {
        TTGSnackbar *snackbar = [self baseSnackbarWithMessage:@"Duplicate manager message" duration:TTGSnackbarDurationShort];
        snackbar.style = TTGSnackbarStyleWarning;
        [[TTGSnackbarManager shared] showSnackbar:snackbar policy:TTGSnackbarPresentationPolicyDropIfShowingSameMessage];
    }
}

- (void)showLifecycleCallbacks {
    __weak typeof(self) weakSelf = self;
    TTGSnackbar *snackbar = [self baseSnackbarWithMessage:@"Lifecycle callbacks are logged" duration:TTGSnackbarDurationMiddle];
    snackbar.willShowBlock = ^(TTGSnackbar *snackbar) { weakSelf.outputLabel.text = @"willShow"; };
    snackbar.didShowBlock = ^(TTGSnackbar *snackbar) { weakSelf.outputLabel.text = @"didShow"; };
    snackbar.willDismissBlock = ^(TTGSnackbar *snackbar) { weakSelf.outputLabel.text = @"willDismiss"; };
    snackbar.didDismissBlock = ^(TTGSnackbar *snackbar) { weakSelf.outputLabel.text = @"didDismiss"; };
    [snackbar show];
}

- (void)showAccessibilityAndHaptics {
    __weak typeof(self) weakSelf = self;
    TTGSnackbar *snackbar = [self baseSnackbarWithMessage:@"Accessibility announcement with haptic feedback" duration:TTGSnackbarDurationMiddle];
    snackbar.shouldAnnounceForAccessibility = YES;
    snackbar.accessibilityAnnouncement = @"TTGSnackbar accessibility and haptic demo";
    snackbar.hapticFeedback = TTGSnackbarHapticFeedbackSuccess;
    snackbar.actionHapticFeedback = TTGSnackbarHapticFeedbackMediumImpact;
    snackbar.adjustsFontForContentSizeCategory = YES;
    snackbar.shouldRespectReduceMotion = YES;
    snackbar.style = TTGSnackbarStyleSuccess;
    snackbar.actionText = [self actionText];
    snackbar.actionBlock = ^(TTGSnackbar *snackbar) {
        weakSelf.outputLabel.text = @"Accessible action tapped";
        [snackbar dismiss];
    };
    [snackbar show];
}

- (void)showPauseResumeTimer {
    TTGSnackbar *snackbar = [self baseSnackbarWithMessage:@"Timer paused for 2 seconds, then resumes" duration:TTGSnackbarDurationLong];
    snackbar.style = TTGSnackbarStyleInfo;
    snackbar.pausesDismissTimerOnTouch = YES;
    [snackbar show];
    self.pausedSnackbar = snackbar;
    [snackbar pauseDismissTimer];
    self.outputLabel.text = @"Timer paused";
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf.pausedSnackbar resumeDismissTimer];
        weakSelf.outputLabel.text = @"Timer resumed";
    });
}

- (void)showTopPresentation {
    TTGSnackbar *snackbar = [self baseSnackbarWithMessage:@"Top presentation with custom border" duration:TTGSnackbarDurationMiddle];
    snackbar.animationType = TTGSnackbarAnimationTypeSlideFromTopBackToTop;
    snackbar.topMargin = 12;
    snackbar.bottomMargin = 12;
    snackbar.borderColor = UIColor.systemBlueColor;
    snackbar.borderWidth = 2;
    snackbar.snackbarMaxWidth = 420;
    [snackbar show];
}

- (void)showCallbackResult {
    __weak typeof(self) weakSelf = self;
    TTGSnackbar *snackbar = [self baseSnackbarWithMessage:@"Callback result demo" duration:TTGSnackbarDurationLong];
    snackbar.style = TTGSnackbarStyleWarning;
    snackbar.actionText = [self actionText];
    snackbar.actionBlock = ^(TTGSnackbar *snackbar) {
        weakSelf.outputLabel.text = @"Callback result: action";
        [snackbar dismiss];
    };
    snackbar.onTapBlock = ^(TTGSnackbar *snackbar) {
        weakSelf.outputLabel.text = @"Callback result: tap";
    };
    snackbar.didDismissBlock = ^(TTGSnackbar *snackbar) {
        if (![weakSelf.outputLabel.text hasPrefix:@"Callback result:"]) {
            weakSelf.outputLabel.text = @"Callback result: dismissed";
        }
    };
    [snackbar show];
}

@end
