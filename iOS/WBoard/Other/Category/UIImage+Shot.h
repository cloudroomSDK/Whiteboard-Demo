//
//  UIImage+Shot.h
//  CloudMeeting
//
//  Created by YunWu01 on 2020/10/20.
//  Copyright © 2020 CloudMeeting. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Shot)

+ (UIImage *)captureImageFromViewLow:(UIView *)orgView;

//- (UIImage *)imageWithClippedRect:(CGRect)rect;

@end

NS_ASSUME_NONNULL_END
