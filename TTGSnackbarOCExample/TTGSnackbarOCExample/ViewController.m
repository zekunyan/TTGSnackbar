//
//  ViewController.m
//  TTGSnackbarOCExample
//
//  Created by tutuge on 2018/10/7.
//  Copyright © 2018 tutuge. All rights reserved.
//

#import "ViewController.h"

@import TTGSnackbar;

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *ActivityLabel;
-(TTGSnackbar*)createSnackbar:(NSString*)message;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.ActivityLabel setText:@""];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    TTGSnackbar *bar = [[TTGSnackbar alloc] initWithMessage:@"TTGSnackbar" duration:TTGSnackbarDurationMiddle];
    [bar show];
}

- (IBAction)demoSnackbarManager:(id)sender {
    [self.ActivityLabel setText:@""];
    
    TTGSnackbar *bar1 = [self createSnackbar:@"TTGSnackbar - 1"];
    TTGSnackbar *bar2 = [self createSnackbar:@"TTGSnackbar - 2"];
    TTGSnackbar *bar3 = [self createSnackbar:@"TTGSnackbar - 3"];

    [[TTGSnackbarManager shared] showWithSnackbar: bar1];
    [[TTGSnackbarManager shared] showWithSnackbar: bar2];
    [[TTGSnackbarManager shared] showWithSnackbar: bar3];
}

- (TTGSnackbar*)createSnackbar:(NSString*)message {
    TTGSnackbar *bar = [[TTGSnackbar alloc] initWithMessage:message duration:TTGSnackbarDurationMiddle];
    [bar setDismissBlock:^(TTGSnackbar * snackBar) {
        [self.ActivityLabel setText: [message stringByAppendingString:@" :Dismissed"]];
    }];
    return bar;
}


@end
