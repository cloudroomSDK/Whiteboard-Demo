//
//  PreMeetingController.m
//  Meeting
//
//  Created by king on 2018/6/27.
//  Copyright © 2018年 BossKing10086. All rights reserved.
//

#import "PreMeetingController.h"
#import "PreSettingsController.h"
#import "PMTopView.h"
#import "PMBottomView.h"

#import "AppDelegate.h"
#import "CRSDKHelper.h"
#import "MeetingController.h"

@interface PreMeetingController () <CloudroomVideoMgrCallBack,CloudroomVideoMeetingCallBack>

@property (weak, nonatomic) IBOutlet PMTopView *topView;
@property (weak, nonatomic) IBOutlet PMBottomView *bottomView;
@property (nonatomic, assign) BOOL createMeeting;
@property (nonatomic, copy) NSString *meetingID;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UILabel *appVersionLab;

@end

@implementation PreMeetingController
#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self _commonSetup];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    CloudroomVideoMgr *cloudroomVideoMgr = [CloudroomVideoMgr shareInstance];
    [cloudroomVideoMgr setMgrCallback:self];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    CloudroomVideoMgr *cloudroomVideoMgr = [CloudroomVideoMgr shareInstance];
    [cloudroomVideoMgr removeMgrCallback:self];
}

#pragma mark - CloudroomVideoMeetingCallBack
// 登录成功
- (void)loginSuccess:(NSString *)usrID cookie:(NSString *)cookie {
    [HUDUtil hudHiddenProgress:YES];
    
    if (_createMeeting) {
        [self _handleCreateMeeting];
    } else {
        [self _handleEnterMeeting];
    }
}

// 登录失败
- (void)loginFail:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie {
    [HUDUtil hudHiddenProgress:YES];
    
    if (sdkErr == CRVIDEOSDK_NOSERVER_RSP) {
        [HUDUtil hudShow:@"服务器无响应" delay:3 animated:YES];
    }
    else if (sdkErr == CRVIDEOSDK_LOGINSTATE_ERROR) {
        [HUDUtil hudShow:@"登陆状态不对" delay:3 animated:YES];
        [[CloudroomVideoMgr shareInstance] logout];
    }
    else if (sdkErr == CRVIDEOSDK_SOCKETTIMEOUT) {
        [HUDUtil hudShow:@"网络超时" delay:3 animated:YES];
    }
    else {
        [HUDUtil hudShow:@"登录失败" delay:3 animated:YES];
    }
}

// 创建房间成功回调
- (void)createMeetingSuccess:(MeetInfo *)meetInfo cookie:(NSString *)cookie {
    [HUDUtil hudHiddenProgress:YES];
    [self _jumpToMeetingWithMeetInfo:meetInfo createRoom:YES];
}

// 创建房间失败回调
- (void)createMeetingFail:(CRVIDEOSDK_ERR_DEF)sdkErr cookie:(NSString *)cookie {
    [HUDUtil hudHiddenProgress:YES];
    [HUDUtil hudShow:@"创建失败" delay:3 animated:YES];
}

#pragma mark - private method
- (void)_commonSetup {
    // 设置属性
    [self _setupProperty];
    [self.versionLabel setText:[NSString stringWithFormat:@"SDK版本号:%@",[CloudroomVideoSDK getCloudroomVideoSDKVer]]];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    
    [_appVersionLab setText:[NSString stringWithFormat:@"app版本号:%@",[infoDictionary objectForKey:@"CFBundleShortVersionString"]]];
}

/* 设置属性 */
- (void)_setupProperty {

    weakify(self)
    _createMeeting = NO;
    [_bottomView setResponse:^(PMBottomView *view, UIButton *sender, NSString *inputText) {
        strongify(wSelf)
        switch ([sender tag]) {
            case PMBottomViewBtnTypeCreate: { // 创建房间
                [sSelf _loginAndCreateMeeting];
                break;
            }
            case PMBottomViewBtnTypeEnter: { // 进入房间
                [sSelf _loginAndEnterMeeting:inputText];
                break;
            }
        }
    }];
    
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    textAttrs[NSForegroundColorAttributeName] = [UIColor whiteColor];
    textAttrs[NSFontAttributeName] = [UIFont boldSystemFontOfSize:18.0f];
    textAttrs[NSKernAttributeName] = @(1.0);
    if (@available(iOS 15.0, *)) {
        
        UINavigationBarAppearance *appearance = [UINavigationBarAppearance new];
        [appearance configureWithOpaqueBackground];
        
        appearance.titleTextAttributes = textAttrs;
        appearance.backgroundColor = [UIColor colorWithRed:33/255.0 green:162/255.0 blue:135/255.0 alpha:1.0];
        appearance.shadowImage = [UIImage new];
        
        self.navigationController.navigationBar.scrollEdgeAppearance = appearance;
        self.navigationController.navigationBar.standardAppearance = appearance;
        
    }
}

- (void)_loginAndCreateMeeting {
    _createMeeting = YES;
    [self _handleLogin];
}

- (void)_loginAndEnterMeeting:(NSString *)inputText {
    _createMeeting = NO;
    _meetingID = inputText;
    [self _handleLogin];
}

/* 登录 */
- (void)_handleLogin {
    CRSDKHelper *meetingHelper = [CRSDKHelper shareInstance];
    
    NSString *nickname = [NSString stringWithFormat:@"iOS_%04zd", [self _randomNumFrom:1000 to:9999]];
    
    // 云屋SDK登陆账号,实际开发中,请联系云屋工作人员获取
    NSString *account = meetingHelper.account;
    // 密码通过MD5以后
    NSString *pswd = meetingHelper.pswd;
    // 服务器地址
    NSString *server = meetingHelper.server;
    
    if ([NSString stringCheckEmptyOrNil:server]) {
        [HUDUtil hudShow:@"服务器地址不能为空!" delay:3 animated:YES];
        return;
    }
    
    if ([NSString stringCheckEmptyOrNil:account]) {
        [HUDUtil hudShow:@"账号不能为空!" delay:3 animated:YES];
        [self _handleSettings];
        return;
    }
    
    if ([NSString stringCheckEmptyOrNil:pswd]) {
        [HUDUtil hudShow:@"密码不能为空!" delay:3 animated:YES];
        [self _handleSettings];
        return;
    }
    
    if ([NSString stringCheckEmptyOrNil:nickname]) {
        [HUDUtil hudShow:@"昵称不能为空!" delay:3 animated:YES];
        return;
    }
    
    NSString *md5Pswd = [NSString md5:meetingHelper.pswd];
    
    WLog(@"server:%@ nickname:%@ account:%@ pswd:%@", server, nickname, account, md5Pswd);
    
    CloudroomVideoMgr *cloudroomVideoMgr = [CloudroomVideoMgr shareInstance];
    CloudroomVideoSDK *cloudroomVideoSDK = [CloudroomVideoSDK shareInstance];
    
    [meetingHelper writeAccount:account pswd:pswd server:server];
    meetingHelper.nickname = nickname;
    
    // 设置服务器地址
    [cloudroomVideoSDK setServerAddr:server];
    
    [HUDUtil hudShowProgress:@"正在登录中..." animated:YES];
    
    // 发送"登录"指令
    NSString *cookie = [NSString stringWithFormat:@"%f",CFAbsoluteTimeGetCurrent()];
      [cloudroomVideoMgr login:account appSecret:md5Pswd nickName:nickname userID:nickname userAuthCode:@"" cookie:cookie];
}

/* 注销 */
- (void)_handleLogout {
    // 注销
    [[CloudroomVideoMgr shareInstance] logout];
    
    // 跳转到"登录"界面
    UIStoryboard *login = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    BaseNavController *loginNav = [login instantiateInitialViewController];
    
    if (loginNav) {
        [[[[UIApplication sharedApplication] delegate] window] setRootViewController:loginNav];
    }
}

/* 设置 */
- (IBAction)_handleSettings {
    UIStoryboard *preMeeting = [UIStoryboard storyboardWithName:@"PMeeting" bundle:nil];
    PreSettingsController *vc = [preMeeting instantiateViewControllerWithIdentifier:@"PreSettingsController"];
    [self.navigationController pushViewController:vc animated:YES];

}

/* 创建房间 */
- (void)_handleCreateMeeting {
    NSString *userID = [[CRSDKHelper shareInstance] nickname];
    NSString *title = nil;
    if (![NSString stringCheckEmptyOrNil:userID]) {
        title = [NSString stringWithFormat:@"%@的视频房间", userID];
    }
    
    [HUDUtil hudShowProgress:@"正在创建房间..." animated:YES];
    NSString *cookie = [NSString stringWithFormat:@"%f", CFAbsoluteTimeGetCurrent()];
    // 发送"创建房间"命令(不设置密码)
    [[CloudroomVideoMgr shareInstance] createMeeting:title createPswd:NO cookie:cookie];
}

/* 进入房间 */
- (void)_handleEnterMeeting {
    NSString *inputText = _meetingID;
    if ([NSString stringCheckEmptyOrNil:inputText]) {
        [HUDUtil hudShow:@"房间号不能为空" delay:3 animated:YES];
        return;
    }
    
    MeetInfo *meetInfo = [[MeetInfo alloc] init];
    [meetInfo setID:[inputText intValue]];
    
    [self _jumpToMeetingWithMeetInfo:meetInfo createRoom:NO];
}

/**
 跳转到"房间"界面
 @param meetInfo 房间信息
 */
- (void)_jumpToMeetingWithMeetInfo:(MeetInfo *)meetInfo createRoom:(BOOL)createRoom {
    UIStoryboard *meeting = [UIStoryboard storyboardWithName:@"Meeting" bundle:nil];
    MeetingController *meetingVC = [meeting instantiateViewControllerWithIdentifier:@"MeetingController"];
    meetingVC.createRoom = createRoom;
    [meetingVC setMeetInfo:meetInfo];
    
    WLog(@"meetID:%d", meetInfo.ID);
    
    if(@available(iOS 13.0, *)) {
        
        meetingVC.modalPresentationStyle = UIModalPresentationFullScreen;
    }
    
    if (meetingVC) {
        [self presentViewController:meetingVC animated:YES completion:nil];
    }
}

/* 四位随机数生成 参考: [iOS 随机数生成][https://www.jianshu.com/p/f3f26608d1dd] */
- (NSInteger)_randomNumFrom:(NSInteger)from to:(NSInteger)to {
    return (from + (NSInteger)(arc4random() % (to - from + 1)));
}

#pragma mark - override
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}
@end
