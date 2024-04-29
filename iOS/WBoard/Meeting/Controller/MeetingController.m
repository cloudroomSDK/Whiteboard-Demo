//
//  MeetingController.m
//  Meeting
//
//  Created by king on 2017/11/14.
//  Copyright © 2017年 BossKing10086. All rights reserved.
//

#import "MeetingController.h"
#import "AppDelegate.h"
#import "CRSDKHelper.h"
#import "IQKeyboardManager.h"
#import "RotationUtil.h"
#import "MJExtension.h"
#include "BKBrushButton.h"
#import "WhiteBoardModel.h"
#import "WhiteBoardListController.h"
#import "UIImage+Shot.h"
#import "WhiteBoardViewAttrController.h"
#import "BoardInfo+ExInfo.h"

const NSInteger KMAX_WHITEBOARD_COUNT = 10;

@interface MeetingController () <CloudroomVideoMeetingCallBack,CloudroomVideoMgrCallBack, BKBrushViewDelegate, CLBoardViewCallBack, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *topTtitleView;
@property (nonatomic, strong) UIAlertController *dropVC; /**< 掉线弹框 */
@property (weak, nonatomic) IBOutlet UILabel            *meetNumLabel;
@property (weak, nonatomic) IBOutlet CLBoardView        *drawerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *brushToolViewW;
@property (assign,nonatomic) NSInteger currrentPage;  //白板当前页
@property (weak, nonatomic) IBOutlet UIButton *createButton;
@property (weak, nonatomic) IBOutlet UILabel *whiteBoardTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;

@property (weak, nonatomic) IBOutlet UIView *graphicsView;
@property (weak, nonatomic) IBOutlet BKBrushButton *penButton;
@property (weak, nonatomic) IBOutlet BKBrushButton *circleRectButton;
@property (weak, nonatomic) IBOutlet BKBrushButton *circleButton;
@property (weak, nonatomic) IBOutlet BKBrushButton *lineButton;
@property (weak, nonatomic) IBOutlet BKBrushButton *arrowButton;
@property (nonatomic, assign) CLShapeType currentShapeType; // 记录小工具栏内具体的图元类型(这里主要是为了处理当前选中了非图元状态后再选择了颜色后需要切到绘制状态)
@property (nonatomic, assign) CLShapeType currentToolType; // 记录全局操作的工具类型

@property (weak, nonatomic) IBOutlet UIView *brushToolView;
@property (weak, nonatomic) IBOutlet UIStackView *brushSizeStackView;
@property (weak, nonatomic) IBOutlet UIButton *smallBrushBtn;
@property (weak, nonatomic) IBOutlet UIButton *bigBrushBtn;
@property (weak, nonatomic) IBOutlet UIButton *defaultBrushBtn;
@property (weak, nonatomic) IBOutlet UIButton *maxBrushBtn;
@property (weak, nonatomic) IBOutlet UIStackView *brushColorStackView1;
@property (weak, nonatomic) IBOutlet UIStackView *brushColorStackView2;
@property (weak, nonatomic) IBOutlet UIButton *defaultColorButton;


@property (weak, nonatomic) IBOutlet UIView *toolView;
@property (weak, nonatomic) IBOutlet UIStackView *toolStackView1;
@property (weak, nonatomic) IBOutlet UIStackView *toolStackView2;
@property (weak, nonatomic) IBOutlet UIButton *chooseButton;
@property (weak, nonatomic) IBOutlet UIButton *pencilButton;
@property (weak, nonatomic) IBOutlet UIButton *colorButton;
@property (weak, nonatomic) IBOutlet UIButton *textButton;
@property (weak, nonatomic) IBOutlet UIButton *eraserButton;
@property (weak, nonatomic) IBOutlet UIButton *undoButton;
@property (weak, nonatomic) IBOutlet UIButton *redoButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIButton *handsButton;
@property (weak, nonatomic) IBOutlet UIButton *imageButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

@property (nonatomic, strong) NSMutableArray<BoardInfo *> *boardList;
@property (nonatomic, copy) NSString *currentWB;
@property (nonatomic, strong) NSMutableDictionary<NSString *, CLBoardViewAttr *> *wbBoardViewAttrDict;
@property (nonatomic, copy) NSString *mixerID;

@end

@implementation MeetingController

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self commonSetup];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.drawerView registerWhiteBoardCallback];
    
    [[IQKeyboardManager sharedManager] setEnable:NO];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
    
    // 不灭屏
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    CloudroomVideoMgr *cloudroomVideoMgr = [CloudroomVideoMgr shareInstance];
    [cloudroomVideoMgr setMgrCallback:self];
    
    CloudroomVideoMeeting *cloudroomVideoMeeting = [CloudroomVideoMeeting shareInstance];
    [cloudroomVideoMeeting registerMeetingCallback:self];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.drawerView removeWhiteBoardCallBack];
    
    CloudroomVideoMgr *cloudroomVideoMgr = [CloudroomVideoMgr shareInstance];
    [cloudroomVideoMgr removeMgrCallback:self];
    
    CloudroomVideoMeeting *cloudroomVideoMeeting = [CloudroomVideoMeeting shareInstance];
    [cloudroomVideoMeeting removeMeetingCallBack:self];
    
    [[IQKeyboardManager sharedManager] setEnable:YES];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:YES];
}

#pragma mark - selector
- (IBAction)undoBtnDidClick:(id)sender {
    if ([self.drawerView getUndoEnableState]) {
        [self.drawerView undo];
    }
}
- (IBAction)redoBtnDidClick:(id)sender {
    if ([self.drawerView getRedoEnableState]) {
        [self.drawerView redo];
    }
}

- (IBAction)trashBtnDidClick:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示:" message:@"确定要清除所有内容吗" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *doneAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.drawerView clearCurPage];
    }];
    [alertController addAction:doneAction];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:^{}];
}

- (IBAction)saveBtnDidClick:(id)sender {
    UIImage *image = [UIImage captureImageFromViewLow:self.drawerView.tableView];
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}


- (IBAction)brushGraphicsBtnDidClick:(id)sender {
    self.penButton.selected = NO;
    self.circleRectButton.selected = NO;
    self.circleButton.selected = NO;
    self.lineButton.selected = NO;
    self.arrowButton.selected = NO;

    UIButton *targetBtn = (UIButton*)sender;
    [targetBtn setSelected:!targetBtn.selected];
    
    // 刷新选中图元
    UIImage *graphicImage = [targetBtn currentImage];
    [_pencilButton setImage:graphicImage forState:UIControlStateNormal];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(300 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
        self.graphicsView.hidden = YES;
    });
    
    // 选中图元类型
    CLShapeType shapeType = (CLShapeType)(targetBtn.tag - 1100);
    [self.drawerView setBoardViewToolType:shapeType];
    _currentShapeType = shapeType;
    _currentToolType = _currentShapeType;
}

- (IBAction)operationButtonDidClicked:(UIButton *)sender {
    
    if (sender == self.pencilButton) {
        if (_pencilButton.isSelected || _colorButton.isSelected) {
            // 画笔类型、颜色过来直接调出画笔菜单
            self.graphicsView.hidden = !self.graphicsView.hidden;
        } else {
            // 如果从别的操作切过来，直接使用上一次的图元类型
            [self.drawerView setBoardViewToolType:_currentShapeType];
            _currentToolType = _currentShapeType;
            // 隐藏工具窗
            self.graphicsView.hidden = YES;
        }
    } else {
        self.graphicsView.hidden = YES;
    }
    
    if (sender == self.colorButton) {
        self.brushToolView.hidden = !self.brushToolView.hidden;
        //切了颜色或画笔粗细此时工具调回上次的图元工具
        [self.drawerView setBoardViewToolType:_currentShapeType];
    } else {
        self.brushToolView.hidden = YES;
    }
    
    // 点击框选图元并移动
    if (sender == self.chooseButton) {
        [self.drawerView setBoardViewToolType:CLSHAPE_CHOOSE];
        _currentToolType = CLSHAPE_CHOOSE;
    } else {
        
    }
    
    if (sender == self.handsButton) {
        [self.drawerView setBoardViewToolType:CLSHAPE_SCROLL];
        _currentToolType = CLSHAPE_SCROLL;
    }
    
    if (sender == self.textButton) {
        [self.drawerView setBoardViewToolType:CLSHAPE_TEXT];
        _currentToolType = CLSHAPE_TEXT;
    }
    
    if (sender == self.eraserButton) {
        [self.drawerView setBoardViewToolType:CLSHAPE_ERASER];
        _currentToolType = CLSHAPE_ERASER;
    }
    
    // 清除选中灰色框
    for (UIButton *button in self.toolStackView1.subviews) {
        button.selected = NO;
    }
    for (UIButton *button in self.toolStackView2.subviews) {
        button.selected = NO;
    }
    
    sender.selected = YES;
}



- (IBAction)exitBtn:(id)sender {
    [self handleExit];
}

//画笔响应
- (IBAction)brushToolSizeBtnDidClick:(id)sender {
    for (UIButton *button in self.brushSizeStackView.subviews) {
        button.selected = NO;
        UIImage *currentImage = [button currentImage];
        [button setImage:[currentImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [button setTintColor:[UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1.0]];
    }
    UIButton *targetBtn = (UIButton*)sender;
    [targetBtn setSelected:!targetBtn.selected];
    
    UIImage *currentImage = [targetBtn currentImage];
    [targetBtn setImage:[currentImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [targetBtn setTintColor:[UIColor colorWithRed:57/255.0 green:129/255.0 blue:252/255.0 alpha:1.0]];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(300 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
        self.brushToolView.hidden = YES;
    });
    
    // 选中画笔粗细
    NSInteger thick = targetBtn.tag - 800;
    CLBoardViewToolAttr *toolAttr = [self.drawerView getBoardViewToolAttr];
    toolAttr.lineWidth = (int)thick;
    [self.drawerView setBoardViewToolAttr:toolAttr];
}

- (IBAction)brushToolColorBtnDidClick:(id)sender {
    
    for (UIButton *button in self.brushColorStackView1.subviews) {
        button.layer.borderColor = [UIColor whiteColor].CGColor;
    }
    for (UIButton *button in self.brushColorStackView2.subviews) {
        button.layer.borderColor = [UIColor whiteColor].CGColor;
    }
    
    UIButton *targetBtn = (UIButton*)sender;
    targetBtn.layer.borderColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1.0].CGColor;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(300 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
        self.brushToolView.hidden = YES;
    });
    
    // 选中颜色
    int pencilColors[] = {0xFFF0F0F0, 0xFF7B7B7B, 0xFFFF0000, 0xFFFF6B00, 0xFFFFB800,
                          0xFF68DB00, 0xFF00DDFF, 0xFF007FFF, 0xFFBD00FF, 0xFFFF00F4};
    int pencilColor = pencilColors[targetBtn.tag - 900];
    CLBoardViewToolAttr *toolAttr = [self.drawerView getBoardViewToolAttr];
    toolAttr.color = pencilColor;
    [self.drawerView setBoardViewToolAttr:toolAttr];

    UIImage *currentImage = [self.colorButton currentImage];
    [self.colorButton setTintColor:UIColorFromHexRGB(pencilColor)];
    [self.colorButton setImage:[currentImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
}

- (IBAction)createNewWhiteBoard:(id)sender {
    NSUInteger count = _boardList.count;
    if (count >= KMAX_WHITEBOARD_COUNT) {
        [HUDUtil hudShow:[NSString stringWithFormat:@"最多同时新建%ld个白板!", KMAX_WHITEBOARD_COUNT] delay:1 animated:YES];
        return;
    }
    
    NSString *nickname = [[CloudroomVideoMeeting shareInstance] getNickName:[[CloudroomVideoMeeting shareInstance] getMyUserID]];
    NSInteger currentIndex = (long)(_boardList.count + 1);
    NSString *name = [NSString stringWithFormat:@"%@的白板-%ld", nickname, currentIndex];
    NSArray<NSString *> *wbNames = [_boardList valueForKey:@"name"];
    while ([wbNames containsObject:name]) {
        currentIndex += 1;
        name = [NSString stringWithFormat:@"%@的白板-%ld", nickname, currentIndex];
    }
    
    NSMutableDictionary *exInfoDict = [NSMutableDictionary dictionary];
    [exInfoDict setValue:name forKey:@"name"];
    NSString *exInfo = [exInfoDict mj_JSONString];
    
    [[CloudroomVideoMeeting shareInstance] createWhiteBoard:720 h:1280 pageCount:3 pageMode:CLPageModeMutilPage exInfo:exInfo];
}

- (IBAction)showWhiteBoardConfigAction:(id)sender {
    if (_currentWB == nil) return;
    
    UIStoryboard *meeting = [UIStoryboard storyboardWithName:@"Meeting" bundle:nil];
    WhiteBoardViewAttrController *boardAttrViewController = [meeting instantiateViewControllerWithIdentifier:@"WhiteBoardViewAttrController"];
    boardAttrViewController.attr = [self.drawerView getBoardViewAttr];
    [self presentViewController:boardAttrViewController animated:YES completion:nil];
    
    weakify(self);
    [boardAttrViewController setAsyncViewAttrBlock:^(CLBoardViewAttr * _Nonnull attr) {
        strongify(wSelf);
        [sSelf.drawerView setBoardViewAttr:attr];
        [sSelf.wbBoardViewAttrDict setValue:attr forKey:sSelf.currentWB];
    }];
}

- (IBAction)showWhiteBoardListAction:(id)sender {
    UIStoryboard *meeting = [UIStoryboard storyboardWithName:@"Meeting" bundle:nil];
    WhiteBoardListController *boardListViewController = [meeting instantiateViewControllerWithIdentifier:@"WhiteBoardListController"];
    boardListViewController.currentWB = _currentWB;
    boardListViewController.boardList = _boardList;
    [self presentViewController:boardListViewController animated:YES completion:nil];
}

- (void)hiddenToolViews:(UITapGestureRecognizer *)tap {
    [self.drawerView resignTextViewFirstResponder];
    
    if (!_graphicsView.isHidden) {
        _graphicsView.hidden = YES;
    }
    
    if (!_brushToolView.isHidden) {
        _brushToolView.hidden = YES;
    }
}
- (IBAction)recordAction:(UIButton *)sender {
    
    NSString *fileName = [NSString stringWithFormat:@"%@_iOS_wBoard_%d.mp4", [self.class getFileNameString], _meetInfo.ID];
    NSString *svrPathName = [NSString stringWithFormat:@"/%@/%@", [self.class getSvrDirString], fileName];
    NSString *mixerCfg = [NSString stringWithFormat:@"{\
        \"mode\": 0,\
        \"videoFileCfg\": {\
            \"svrPathName\": \"%@\",\
            \"vWidth\": 1280,\
            \"vHeight\": 720,\
            \"vFps\": 15,\
            \"layoutConfig\": [\
                {\
                    \"type\": 6,\
                    \"top\": 0,\
                    \"left\": 0,\
                    \"width\": 1280,\
                    \"height\": 720,\
                    \"keepAspectRatio\": 1\
                }\
            ]\
        }\
    }", svrPathName];
    
    if  (sender.isSelected && _mixerID) {
        [[CloudroomVideoMeeting shareInstance] destroyCloudMixer:_mixerID];
        return;
    }
    
    NSString *mixerID = [[CloudroomVideoMeeting shareInstance] createCloudMixer:mixerCfg];
    if (mixerID) {
        _mixerID = mixerID;
        sender.selected = YES;
    }
}

#pragma mark - <UIImagePickerControllerDelegate>

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (!error) {
        [HUDUtil hudShow:@"保存截图成功!" delay:1 animated:YES];
    }
}


#pragma mark - CloudroomVideoMeetingCallBack
// 掉线通知
- (void)lineOff:(CRVIDEOSDK_ERR_DEF)sdkErr {
    if (_dropVC) {
        weakify(self)
        [_dropVC dismissViewControllerAnimated:NO completion:^{
            strongify(wSelf)
            sSelf.dropVC = nil;
            
            if (sdkErr == CRVIDEOSDK_KICKOUT_BY_RELOGIN) { // 被踢
                [sSelf showAlert:@"您的帐号在别处被使用!"];
            } else { // 掉线
                [sSelf showAlert:@"您已掉线!"];
            }
        }];
        return;
    }
    
    if (sdkErr == CRVIDEOSDK_KICKOUT_BY_RELOGIN) { // 被踢
        [self showAlert:@"您的帐号在别处被使用!"];
    } else { // 掉线
        [self showAlert:@"您已掉线!"];
    }
}
#pragma mark - VideoMeetingDelegate
// 入会结果
- (void)enterMeetingRslt:(CRVIDEOSDK_ERR_DEF)code {
    [HUDUtil hudHiddenProgress:YES];
    
    if (code == CRVIDEOSDK_NOERR) {
        [HUDUtil hudShow:@"进入房间成功!" delay:1 animated:YES];
        [self enterMeetingSuccess];
    } else if (code == CRVIDEOSDK_MEETROOMLOCKED) { // FIXME:房间加锁后,进入房间提示语不正确 added by king 201711291513
        [self enterMeetingFail:@"房间已加锁!"];
    } else {
        [self enterMeetingFail:@"进入房间失败!"];
    }
}

// 房间被结束
- (void)meetingStopped {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示:" message:@"退出房间!" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *doneAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self jumpToPMeeting];
    }];
    [alertController addAction:doneAction];
    [self presentViewController:alertController animated:YES completion:^{}];
}

// 房间掉线
- (void)meetingDropped {
    [self showReEnter:@"房间掉线!"];
}

#pragma mark - 云端录制回调

- (void)createCloudMixerFailed:(NSString *)mixerID err:(CRVIDEOSDK_ERR_DEF)err {
    if (![_mixerID isEqualToString:mixerID]) return;
    
    _recordButton.selected = NO;
    _mixerID = nil;
    if (err == CRVIDEOSDK_SEVICE_NOTENABLED) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"您没有录制权限" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *doneAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertController addAction:doneAction];
        [self presentViewController:alertController animated:NO completion:nil];
    }
    
    
}
- (void)cloudMixerStateChanged:(NSString *)operatorID mixerID:(NSString *)mixerID state:(MIXER_STATE)state exParam:(NSString *)exParam {
    if ([_mixerID isEqualToString:mixerID]) {
        if (state == NO_RECORD || state ==  STOPPING) {
            _mixerID = nil;
            _recordButton.selected = NO;
        }
    }
}
- (void)cloudMixerInfoChanged:(NSString *)mixerID {
    
}
- (void)cloudMixerOutputInfoChanged:(NSString *)mixerID jsonStr:(NSString *)jsonStr {
    NSDictionary *dic = jsonStr.mj_JSONObject;
    NSLog(@"cloudMixerOutputInfoChanged:%@", jsonStr);
    int state = [dic[@"state"] intValue];
    int errCode = [dic[@"errCode"] intValue];
    
    NSLog(@"cloudMixerOutputInfoChanged state:%d, errCode:%d", state, errCode);
    /*
    5 上传成功
    6 上传失败
    */
    
    if (errCode == 1 && state == 6) {
        NSString *fileName = dic[@"fileName"];
        if ([fileName rangeOfString:@"iOS_wBoard"].location == NSNotFound) return;
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"上传录像失败，空间不足" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *doneAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertController addAction:doneAction];
        [self presentViewController:alertController animated:NO completion:nil];
    }
}

#pragma mark - 白板View回调
- (void)notifyBoardCurPageChanged:(CLBoardView *)boardView curPage:(NSInteger)curPage operatorID:(NSString *)operatorID {
    // 当前滚动到第几页：接近中间点的页
}
- (void)notifyRedoEnableChanged:(CLBoardView *)boardView bEnable:(BOOL)bEnable {
    self.redoButton.enabled = bEnable;
}
- (void)notifyUndoEnableChanged:(CLBoardView *)boardView bEnable:(BOOL)bEnable {
    self.undoButton.enabled = bEnable;
}
- (void)notifyViewScaleChanged:(NSString *)boardID boardView:(CLBoardView *)boardView scale:(int)scale {
    
}
- (void)notifyMarkException:(CLBoardView *)boardView exType:(CLBoardViewMarkExceptionType)exType {
    if (exType == CLMarkExceptionTypeSinglePageLimit) {
        [HUDUtil hudShow:@"单页图元数量超出限制" delay:0.85 animated:YES];
    } else if (exType == CLMarkExceptionTypeSingleLineLimt) {
        [HUDUtil hudShow:@"单笔图元长度超出限制" delay:0.85 animated:YES];
    }
}

#pragma mark - V4白板回调

- (void)notifyCreateBoard:(BoardInfo *)board operatorID:(NSString *)operatorID {
    NSString *myUserID = [[CloudroomVideoMeeting shareInstance] getMyUserID];
    if ([myUserID isEqualToString:operatorID])
    [HUDUtil hudShow:@"创建白板成功" delay:0.75 animated:YES];
    
    if (_pencilButton.isSelected == NO)
    [self operationButtonDidClicked:self.pencilButton]; // 设置默认选中绘制状态
    
    if (_toolView.isHidden) _toolView.hidden = NO;
    if (_topTtitleView.isHidden) _topTtitleView.hidden = NO;
    
    // 新建的白板如果要切到当前，需要设置为当前白板，否则远端仍然是上一个当前白板,从无到有不需要设置
    // 且自己是创建者
    if (_boardList.count > 0 && [myUserID isEqualToString:operatorID]) {
        [[CloudroomVideoMeeting shareInstance] setCurrentBoard:board.boardID];
    }
    
    self.whiteBoardTitleLabel.text = board.name;
    [self.boardList addObject:board];
    
    CLBoardViewAttr *jsonAttr = [self defaultBoardViewAttr];
    [self.wbBoardViewAttrDict setValue:jsonAttr forKey:board.boardID];
    
    [self.drawerView setBoardID:board.boardID boardViewAttr:jsonAttr]; // 给白板配置白板ID
    [self.drawerView setBoardViewToolType:_currentToolType]; // 设置当前图元工具
    
    _currentWB = board.boardID;
    
    // 发送通知
    [[NSNotificationCenter defaultCenter] postNotificationName:KWhiteBoardListDidChangeNotification object:nil userInfo:nil];
}

- (void)notifyCloseBoard:(BoardInfo *)board operatorID:(NSString *)operatorID {
    NSString *myUserID = [[CloudroomVideoMeeting shareInstance] getMyUserID];
    if ([myUserID isEqualToString:operatorID])
    [HUDUtil hudShow:@"删除白板成功" delay:0.75 animated:YES];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"boardID == %@", board.boardID];
    NSArray *result = [_boardList filteredArrayUsingPredicate:predicate];
    if (result.count == 1) {
        [_boardList removeObjectsInArray:result];
        [self.wbBoardViewAttrDict removeObjectForKey:board.boardID];
    }
    
    if (_boardList.count == 0) {
        _topTtitleView.hidden = YES;
        [self.drawerView setBoardID:nil boardViewAttr:nil]; // 清理
    } else {
        
    }
    
    // 发送通知
    [[NSNotificationCenter defaultCenter] postNotificationName:KWhiteBoardListDidChangeNotification object:nil userInfo:nil];
}

- (void)notifyCurrentBoard:(NSString *)boardID operatorID:(NSString *)operatorID {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"boardID == %@", boardID];
    NSArray *result = [_boardList filteredArrayUsingPredicate:predicate];
    if (result.count == 1) {
        BoardInfo *board = [result firstObject];
        self.whiteBoardTitleLabel.text = board.name;
        NSMutableDictionary *jsonAttr = [self.wbBoardViewAttrDict valueForKey:boardID];
        [self.drawerView  setBoardID:boardID boardViewAttr:jsonAttr]; // 给白板配置白板ID
        [self.drawerView setBoardViewToolType:_currentToolType]; // 设置当前图元工具

        _currentWB = boardID;
    }
}

- (void)notifyInitBoardList:(NSArray<NSString *> *)boardIDList {
    if (boardIDList.count > 0) {
        if (_toolView.isHidden) _toolView.hidden = NO;
        if (_topTtitleView.isHidden) _topTtitleView.hidden = NO;
    }
    
    for (NSString *boardID in boardIDList) {
        BoardInfo *board = [[CloudroomVideoMeeting shareInstance] getBoardInfo:boardID];
        [self.boardList addObject:board];
    }
    NSString *curWB = [[CloudroomVideoMeeting shareInstance] getCurrentBoard];
    _currentWB = curWB;
    
    for (int i = 0; i < self.boardList.count; i++) {
        BoardInfo *board = [self.boardList objectAtIndex:i];
        // 找到当前白板
        CLBoardViewAttr *jsonAttr = [self defaultBoardViewAttr];
        if ([board.boardID isEqualToString:curWB]) {
            [self.drawerView  setBoardID:curWB boardViewAttr:jsonAttr];
            [self.drawerView setBoardViewToolType:_currentToolType]; // 设置当前图元工具

            self.whiteBoardTitleLabel.text = board.name;
        }

        if (![self.wbBoardViewAttrDict valueForKey:board.boardID]) {
            [self.wbBoardViewAttrDict setValue:jsonAttr forKey:board.boardID];
        }
    }
}

#pragma mark - private method

+ (NSString *)createUUID {
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
    NSString *uuid = [NSString stringWithString:(__bridge NSString *)uuid_string_ref];
    CFRelease(uuid_ref);
    CFRelease(uuid_string_ref);
    uuid = [uuid lowercaseString];
    return uuid;
}

+ (NSString *)getSvrDirString {
    // 获取当前时间
    NSDate *currentDate = [NSDate date];

    // 创建日期格式化器
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];

    // 将日期转换为指定格式的字符串
    NSString *formattedDateString = [dateFormatter stringFromDate:currentDate];
    
    return formattedDateString;
}

+ (NSString *)getFileNameString {
    // 获取当前时间
    NSDate *currentDate = [NSDate date];

    // 创建日期格式化器
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd_HH-mm-ss"];

    // 将日期转换为指定格式的字符串
    NSString *formattedDateString = [dateFormatter stringFromDate:currentDate];
    
    return formattedDateString;
}

- (CLBoardViewAttr *)defaultBoardViewAttr {
    CLBoardViewAttr *attr = [[CLBoardViewAttr alloc] init];
    attr.readOnly = NO;
    attr.asyncPage = NO;
    attr.followPage = NO;
    attr.asyncScale = NO;
    attr.followScale = NO;
    return attr;
}

- (void)commonSetup {
    //初始化界面设置
    [self initDefaultUI];
    // 入会操作
    [self enterMeeting];
}

-(void)initDefaultUI{
    
    // 处理颜色菜单初始化白色边框，选中目标边框变色
    for (UIButton *button in self.brushColorStackView1.subviews) {
        button.layer.borderColor = [UIColor whiteColor].CGColor;
        button.layer.borderWidth = 4.0;
    }
    for (UIButton *button in self.brushColorStackView2.subviews) {
        button.layer.borderColor = [UIColor whiteColor].CGColor;
        button.layer.borderWidth = 4.0;
    }
    
    [self.smallBrushBtn setSelected:YES];
    
    self.toolView.layer.cornerRadius = 2.5;
    self.toolView.layer.shadowOffset = CGSizeZero;
    self.toolView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.toolView.layer.shadowOpacity = 0.3;
    self.toolView.layer.shadowRadius = 2.5;
    
    self.brushToolView.layer.cornerRadius = 3.0;
    self.brushToolView.layer.shadowOffset = CGSizeZero;
    self.brushToolView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.brushToolView.layer.shadowOpacity = 0.3;
    self.brushToolView.layer.shadowRadius = 3.0;
    
    self.graphicsView.layer.cornerRadius = 3.0;
    self.graphicsView.layer.shadowOffset = CGSizeZero;
    self.graphicsView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.graphicsView.layer.shadowOpacity = 0.3;
    self.graphicsView.layer.shadowRadius = 3.0;
    
    [self brushGraphicsBtnDidClick:self.penButton]; // 设置默认图元类型
    [self operationButtonDidClicked:self.pencilButton]; // 设置默认选中绘制状态
    [self brushToolSizeBtnDidClick:self.smallBrushBtn]; // 设置默认画笔粗细
    [self brushToolColorBtnDidClick:self.defaultColorButton]; // 设置默认画笔颜色
    
    [self.drawerView setBoardViewCallback:self];
    [self.drawerView configBoardTextViewContainer:self.view]; // 配置内部输入框父视图
    
    
    [self.drawerView setBoardViewAttr:[self defaultBoardViewAttr]];
    [self.drawerView setViewScaleRange:1.0 max:5.0];
    
    _topTtitleView.hidden = YES;
    _toolView.hidden = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenToolViews:)];
    [self.view addGestureRecognizer:tap];
    
//    self.view.backgroundColor = [UIColor brownColor];
//    self.drawerView.backgroundColor = [UIColor clearColor];
//    [self.drawerView setPageBackgroundColor:[UIColor clearColor]];
}
/**
 设置属性
 */
- (void)setStatusBarBG {
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    
    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
        statusBar.backgroundColor = UIColorFromRGBA(0, 0, 0, 0.5);
    }
}

/* 入会操作 */
- (void)enterMeeting {
    WLog(@"");
    
    if (_meetInfo.ID > 0) {
        [HUDUtil hudShowProgress:@"正在进入房间..." animated:YES];
        CloudroomVideoMeeting *cloudroomVideoMeeting = [CloudroomVideoMeeting shareInstance];
        [cloudroomVideoMeeting enterMeeting:_meetInfo.ID];
        [self.meetNumLabel setText:[NSString stringWithFormat:@"房间ID：%d",_meetInfo.ID]];
    }
}

/* 入会成功 */
- (void)enterMeetingSuccess {
//    [[CloudroomVideoMeeting shareInstance] setSpeakerOut:YES];
    if (_createRoom) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self createNewWhiteBoard:nil];
        });
    }
    
    // 检查云端录制状态
    CloudroomVideoMeeting *cloudroomVideoMeeting = [CloudroomVideoMeeting shareInstance];
    NSString *info = [cloudroomVideoMeeting getAllCloudMixerInfo];
    NSArray *cloudMixerInfo = [info mj_JSONObject];
    for (NSDictionary *item in cloudMixerInfo) {
        NSString *owner = [item valueForKey:@"owner"];
        if ([owner isEqualToString:[cloudroomVideoMeeting getMyUserID]]) {
            _mixerID = [item valueForKey:@"ID"];
            MIXER_STATE state = [[item valueForKey:@"state"] intValue];
            if (state == RECORDING) {
                self.recordButton.selected = YES;
            }
            break;
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%d", _meetInfo.ID] forKey:@"KLastEnterMeetingID"];
}

/**
 入会失败
 @param message 失败信息
 */
- (void)enterMeetingFail:(NSString *)message {
    [HUDUtil hudShow:message delay:3 animated:YES];
    
    if (_meetInfo.ID > 0) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示:" message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self jumpToPMeeting];
        }];
        UIAlertAction *doneAction = [UIAlertAction actionWithTitle:@"重试" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self enterMeeting];
        }];
        [alertController addAction:cancelAction];
        [alertController addAction:doneAction];
        [self presentViewController:alertController animated:NO completion:nil];
    }
}

/**
 重登操作
 @param message 重登信息
 */
- (void)showReEnter:(NSString *)message {
    weakify(self)
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示:" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"离开房间" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        strongify(wSelf)
        [sSelf jumpToPMeeting];
        sSelf.dropVC = nil;
        
    }];
    UIAlertAction *doneAction = [UIAlertAction actionWithTitle:@"重新登录" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        strongify(wSelf)
        // 离开房间
        [[CloudroomVideoMeeting shareInstance] exitMeeting];
        // 重新入会
        [sSelf enterMeeting];
        sSelf.dropVC = nil;
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:doneAction];
    [self presentViewController:alertController animated:NO completion:^{}];
    _dropVC = alertController;
}

/* 掉线/被踢下线 */
- (void)showAlert:(NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示:" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *doneAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self jumpToPMeeting];
    }];
    [alertController addAction:doneAction];
    [self presentViewController:alertController animated:YES completion:^{}];
}

/* 退出 */
- (void)handleExit {
    // FIXME: 退出房间,防止误操作 (king 20180717)
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"离开房间?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
    UIAlertAction *done = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self jumpToPMeeting];
        
    }];
    [alertVC addAction:cancel];
    [alertVC addAction:done];
    [self presentViewController:alertVC animated:YES completion:nil];
}

/* 跳转到"预入会"界面 */
- (void)jumpToPMeeting {
    // 离开房间
    [[CloudroomVideoMeeting shareInstance] exitMeeting];
    // 注销
    [[CloudroomVideoMgr shareInstance] logout];
    // 退出界面
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark -lazing
- (NSMutableArray<BoardInfo *> *)boardList {
    if (!_boardList) {
        _boardList = [NSMutableArray array];
    }
    return _boardList;
}

- (NSMutableDictionary<NSString *,CLBoardViewAttr *> *)wbBoardViewAttrDict {
    if (!_wbBoardViewAttrDict) {
        _wbBoardViewAttrDict = [NSMutableDictionary dictionary];
    }
    return _wbBoardViewAttrDict;
}

@end
