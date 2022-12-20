//
//  AppDelegate.m
//  Meeting
//
//  Created by king on 2017/2/9.
//  Copyright © 2017年 BossKing10086. All rights reserved.
//

#import "AppDelegate.h"
#import "CRSDKHelper.h"
#import "IQKeyboardManager.h"
#import "PathUtil.h"
#import <Bugly/Bugly.h>

@interface AppDelegate ()

@end

@implementation AppDelegate
#pragma mark - UIApplicationDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self setupConfigure];
    [Bugly startWithAppId:@"743962c80d"];
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // FIXME:应用退出崩溃 added by king 201803091647
    [[CloudroomVideoSDK shareInstance] uninit];
}

#pragma mark - private method
- (void)setupConfigure
{
    [self _setupForStatusBar];
    [self _setupForVideoCallSDK];
    [self _setupForIQKeyboard];
}

- (void)_setupForStatusBar
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)_setupForVideoCallSDK
{
    CRSDKHelper *meetingHelper = [CRSDKHelper shareInstance];
    [meetingHelper readInfo];
    
    if ([NSString stringCheckEmptyOrNil:meetingHelper.account] ||
        [NSString stringCheckEmptyOrNil:meetingHelper.pswd] ||
        [NSString stringCheckEmptyOrNil:meetingHelper.server]) {
        [meetingHelper resetInfo];
    }
    
    // FIXME:WARNING: QApplication was not created in the main() thread.QObject::connect: No such slot MeetRecordImpl::slot_SetScreenShare(bool)
    SdkInitDat *sdkInitData = [[SdkInitDat alloc] init];
    // TODO:必须指定日志文件路径,才能产生日志文件,并能够上传 added by king 201711061904
    [sdkInitData setSdkDatSavePath:[PathUtil searchPathInCacheDir:@"CloudroomVideoSDK"]];
    [sdkInitData setShowSDKLogConsole:YES];
    [sdkInitData setNoCall:YES];
    [sdkInitData setNoQueue:YES];
    [sdkInitData setNoMediaDatToSvr:NO];
    sdkInitData.datEncType = @"0";
    [sdkInitData.params setValue:@"0" forKey:@"VerifyHttpsCert"];
    [sdkInitData.params setValue:@"0" forKey:@"HttpDataEncrypt"];
    CRVIDEOSDK_ERR_DEF error = [[CloudroomVideoSDK shareInstance] initSDK:sdkInitData];
    
    if (error != CRVIDEOSDK_NOERR) {
        WLog(@"CloudroomVideoSDK init error!");
        [[CloudroomVideoSDK shareInstance] uninit];
    }
    
    WLog(@"GetCloudroomVideoSDKVer:%@", [CloudroomVideoSDK getCloudroomVideoSDKVer]);
}

// FIXME:修改键盘ToolBar按钮标题
- (void)_setupForIQKeyboard
{
    [[IQKeyboardManager sharedManager] setToolbarDoneBarButtonItemText:@"完成"];
}

@end
