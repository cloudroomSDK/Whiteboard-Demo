//
//  PreSettingsController.m
//  Meeting
//
//  Created by king on 2018/6/27.
//  Copyright © 2018年 BossKing10086. All rights reserved.
//

#import "PreSettingsController.h"
#import "PSTopView.h"
#import "PSBottomView.h"
#import "CRSDKHelper.h"
#import "PMRoundTextField.h"
#import "NSString+K.h"
#import "AppConfig.h"

NSString *const kAppIDDefaultShow = @"默认appID";
NSString *const kAppIDPlaceholder = @"请配置appID";

@interface PreSettingsController ()

@property (weak, nonatomic) IBOutlet PSBottomView *bottomView;

@end

@implementation PreSettingsController
#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self _commonSetup];
     self.title = @"登录设置";
}

-(void)dealloc{
    [self _handleSave];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark - private method
- (void)_commonSetup {
    [self _setupProperty];
}

- (void)_setupProperty {
    weakify(self)
//    [_topView setResponse:^(PSTopView *view, UIButton *sender) {
//        strongify(wSelf)
//        [sSelf _handleSave];
//        [sSelf dismissViewControllerAnimated:YES completion:nil];
//    }];
    
    [_bottomView setResponse:^(PSBottomView *view, UIButton *sender) {
        strongify(wSelf)
        [sSelf _handleReset];
    }];
    
    CRSDKHelper *meetingHelper = [CRSDKHelper shareInstance];
    
    if ([NSString stringCheckEmptyOrNil:meetingHelper.account] ||
        [NSString stringCheckEmptyOrNil:meetingHelper.pswd] ||
        [NSString stringCheckEmptyOrNil:meetingHelper.server]) {
        [self _handleReset];
    }
    else {
        [self reloadConfigView];
    }
}

- (void)_handleSave {
    NSString *server = _bottomView.serverTextField.text;
    NSString *account = _bottomView.userTextField.text;
    NSString *pswd = _bottomView.paswdTextField.text;
        
    if ([NSString stringCheckEmptyOrNil:server]) {
        [HUDUtil hudShow:@"服务器地址不能为空!" delay:3 animated:YES];
        return;
    }
    
    if ([NSString stringCheckEmptyOrNil:account]) {
        [HUDUtil hudShow:@"用户名不能为空!" delay:3 animated:YES];
        return;
    }
    
    if ([NSString stringCheckEmptyOrNil:pswd]) {
        [HUDUtil hudShow:@"密码不能为空!" delay:3 animated:YES];
        return;
    }
    
    // 不保存默认展示
    if ([account isEqualToString:kAppIDDefaultShow] || [account isEqualToString:KDefaultAppID]) {
        account = nil;
        pswd = nil;
    }
    
    CRSDKHelper *meetingHelper = [CRSDKHelper shareInstance];
    [meetingHelper writeAccount:account pswd:pswd server:server];
}

- (void)_handleReset {
    CRSDKHelper *meetingHelper = [CRSDKHelper shareInstance];
    [meetingHelper resetInfo];
    
    [self reloadConfigView];
}

- (void)reloadConfigView {
    CRSDKHelper *meetingHelper = [CRSDKHelper shareInstance];
    
    if ([KDefaultAppID isEqualToString:meetingHelper.account] && KDefaultAppID.length > 0) {
        _bottomView.userTextField.text = kAppIDDefaultShow;
    } else {
        _bottomView.userTextField.text = meetingHelper.account;
    }
    _bottomView.serverTextField.text = meetingHelper.server;
    _bottomView.paswdTextField.text = meetingHelper.pswd;
}

#pragma mark - override
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}
@end
