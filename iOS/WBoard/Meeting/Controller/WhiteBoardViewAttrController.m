//
//  WhiteBoardViewAttrController.m
//  WBoard
//
//  Created by YunWu01 on 2022/10/9.
//  Copyright © 2022 BossKing10086. All rights reserved.
//

#import "WhiteBoardViewAttrController.h"

@interface WhiteBoardViewAttrController ()
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UISwitch *readOnlySwitch;
@property (weak, nonatomic) IBOutlet UISwitch *sendPageSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *recvPageSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *sendScaleSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *recvScaleSwitch;
@end

@implementation WhiteBoardViewAttrController

- (UIModalPresentationStyle)modalPresentationStyle {
    return UIModalPresentationOverFullScreen;
}

- (UIModalTransitionStyle)modalTransitionStyle {
    return UIModalTransitionStyleCrossDissolve;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
}

- (IBAction)dismissAlertAction:(UITapGestureRecognizer *)sender {
    CGPoint location = [sender locationInView:self.view];
    if (CGRectContainsPoint(self.contentView.frame, location)) {
        return;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setAttr:(NSMutableDictionary *)attr {
    _attr = attr;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.readOnlySwitch setOn:!_attr.readOnly];
    [self.sendPageSwitch setOn:_attr.asyncPage];
    [self.recvPageSwitch setOn:_attr.followPage];
    [self.sendScaleSwitch setOn:_attr.asyncScale];
    [self.recvScaleSwitch setOn:_attr.followScale];
}

- (IBAction)readOnly:(UISwitch *)sender {
    _attr.readOnly = !sender.on;
    if (_asyncViewAttrBlock) _asyncViewAttrBlock(_attr);
}

- (IBAction)sendPageAsyc:(UISwitch *)sender {
    _attr.asyncPage = sender.on;
    if (_asyncViewAttrBlock) _asyncViewAttrBlock(_attr);
}

- (IBAction)recvPageAsyc:(UISwitch *)sender {
    _attr.followPage = sender.on;
    if (_asyncViewAttrBlock) _asyncViewAttrBlock(_attr);
}

- (IBAction)sendScaleAsyc:(UISwitch *)sender {
    _attr.asyncScale = sender.on;
    if (_asyncViewAttrBlock) _asyncViewAttrBlock(_attr);
}

- (IBAction)recvScaleAsyc:(UISwitch *)sender {
    _attr.followScale = sender.on;
    if (_asyncViewAttrBlock) _asyncViewAttrBlock(_attr);
}

@end
