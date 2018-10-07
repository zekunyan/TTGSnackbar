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

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    TTGSnackbar *bar = [[TTGSnackbar alloc] initWithMessage:@"TTGSnackbar" duration:TTGSnackbarDurationMiddle];
    [bar show];
}

@end
