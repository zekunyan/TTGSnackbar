//
//  ViewController.m
//  TTGSnackbarObjcTest
//
//  Created by zorro on 16/5/18.
//  Copyright © 2016年 tutuge. All rights reserved.
//

#import "ViewController.h"

@import TTGSnackbar;

@interface ViewController ()

@end

@implementation ViewController

- (IBAction)show:(id)sender {
    TTGSnackbar* snackbar = [[TTGSnackbar alloc] initWithMessage:@"TTGSnackbar by tutuge" duration:TTGSnackbarDurationLong actionText:@"Done" actionBlock:^(TTGSnackbar* snackbar) {
        NSLog(@"Press done.");
    }];
    snackbar.icon = [UIImage imageNamed:@"emoji_cool_small"];
    [snackbar show];
}

@end
