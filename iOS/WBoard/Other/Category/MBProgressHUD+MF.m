//
//  MBProgressHUD+MF.m
//  MyFreeMall
//
//  Created by boundlessocean on 16/9/6.
//  Copyright © 2016年 GXCloud. All rights reserved.
//

#import "MBProgressHUD+MF.h"

@implementation MBProgressHUD (MF)
#pragma mark 显示错误信息

+ (void)showError:(NSString *)error
           ToView:(UIView *)view{
    
    [self showCustomIcon:@"icon-error.png"
                   Title:error
                  ToView:view];
}

+ (void)showSuccess:(NSString *)success
             ToView:(UIView *)view{
    
    [self showCustomIcon:@"icon-success.png"
                   Title:success
                  ToView:view];
}

#pragma mark 显示一些信息
+ (MBProgressHUD *)showMessage:(NSString *)message ToView:(UIView *)view {
    if (view == nil) view = (UIView*)[UIApplication sharedApplication].delegate.window;
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.margin = 15;
    hud.cornerRadius = 5;
    hud.labelFont = [UIFont systemFontOfSize:(14)];
    hud.labelText = message;
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    // YES代表需要蒙版效果
    hud.dimBackground = NO;
    return hud;
}

//加载视图
+(void)showLoadToView:(UIView *)view{
    [self showMessage:@"加载中..." ToView:view];
}


/**
 *  进度条View
 */
+ (MBProgressHUD *)showProgressToView:(UIView *)view ProgressModel:(MBProgressHUDMode)model Text:(NSString *)text{
    if (view == nil) view = (UIView*)[UIApplication sharedApplication].delegate.window;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = model;
    hud.labelText = text;
    return hud;
}

//快速显示一条提示信息,并返回对象;
+ (MBProgressHUD *)showMessage:(NSString *)message{
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:(UIView*)[UIApplication sharedApplication].delegate.window animated:YES];
    hud.margin = 15;
    hud.cornerRadius = 5;
    hud.labelFont = [UIFont systemFontOfSize:(14)];
    hud.labelText = message;
    //模式
    hud.mode = MBProgressHUDModeText;
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    // YES代表需要蒙版效果
    hud.dimBackground = NO;
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    // X秒之后再消失
    [hud hide:YES afterDelay:0.9];
    return hud;
}



//快速显示一条提示信息
+ (void)showAutoMessage:(NSString *)message{
    
    [self showAutoMessage:message
                   ToView:nil];
}


//自动消失提示，无图
+ (void)showAutoMessage:(NSString *)message
                 ToView:(UIView *)view{
    
    [self showMessage:message
               ToView:view
           RemainTime:0.9
                Model:MBProgressHUDModeText];
}

//自定义停留时间，有图
+(void)showIconMessage:(NSString *)message
                ToView:(UIView *)view
            RemainTime:(CGFloat)time{
    
    [self showMessage:message
               ToView:view
           RemainTime:time
                Model:MBProgressHUDModeIndeterminate];
}

//自定义停留时间，无图
+(void)showMessage:(NSString *)message
            ToView:(UIView *)view
        RemainTime:(CGFloat)time{
    
    [self showMessage:message
               ToView:view
           RemainTime:time
                Model:MBProgressHUDModeText];
}


+(void)showMessage:(NSString *)message
            ToView:(UIView *)view
        RemainTime:(CGFloat)time
             Model:(MBProgressHUDMode)model{
    
    if (view == nil) view = (UIView*)[UIApplication sharedApplication].delegate.window;
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.margin = 15;
    hud.cornerRadius = 5;
    hud.labelFont = [UIFont systemFontOfSize:(14)];
    hud.labelText = message;
    //模式
    hud.mode = model;
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    // YES代表需要蒙版效果
    hud.dimBackground = NO;
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    // X秒之后再消失
    [hud hide:YES afterDelay:time];
}

+ (void)showCustomIcon:(NSString *)iconName
                 Title:(NSString *)title
                ToView:(UIView *)view{
    
    if (view == nil) view = (UIView*)[UIApplication sharedApplication].delegate.window;
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.labelText = title;
    // 设置图片
    
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:iconName]];
    
    // 再设置模式
    hud.mode = MBProgressHUDModeCustomView;
    
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    
    // 1秒之后再消失
    [hud hide:YES afterDelay:0.9];
}

+ (void)hideHUDForView:(UIView *)view
{
    if (view == nil) view = (UIView*)[UIApplication sharedApplication].delegate.window;
    [self hideHUDForView:view animated:YES];
}

+ (void)hideHUD
{
    [self hideHUDForView:nil];
}
@end
