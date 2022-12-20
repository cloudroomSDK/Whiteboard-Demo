//
//  BaseController.m
//  VideoCall
//
//  Created by king on 2016/11/22.
//  Copyright © 2016年 CloudRoom. All rights reserved.
//

#import "BaseController.h"

@interface BaseController ()

@end

@implementation BaseController
#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupForBase];
}

- (void)dealloc {
    WLog(@"%@", [self class]);
}

#pragma mark - private method
- (void)_setupForBase {
    self.navigationController.navigationBar.topItem.title = @"";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

#pragma mark - override
- (BOOL)shouldAutorotate {
    return YES;
}

//- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
//    return UIInterfaceOrientationMaskPortrait;
//}
//
//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
//    return UIInterfaceOrientationPortrait;
//}
@end
