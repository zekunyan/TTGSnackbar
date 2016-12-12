//
//  ViewController.m
//  TTGSnackbarObjcExample
//
//  Created by tutuge on 2016/12/13.
//  Copyright © 2016年 tutuge. All rights reserved.
//

#import "ViewController.h"

#import <TTGSnackbar/TTGSnackbar-Swift.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    TTGSnackbar *snackbar = [[TTGSnackbar alloc] initWithMessage:@"TTGSnackbar" duration:TTGSnackbarDurationMiddle];
    [snackbar setDismissBlock:^(TTGSnackbar *snackbar) {
        NSLog(@"snackbar dismiss");
    }];
    [snackbar show];
}

@end
