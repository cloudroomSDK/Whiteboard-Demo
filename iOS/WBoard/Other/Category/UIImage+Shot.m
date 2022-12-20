//
//  UIImage+Shot.m
//  CloudMeeting
//
//  Created by YunWu01 on 2020/10/20.
//  Copyright © 2020 CloudMeeting. All rights reserved.
//

#import "UIImage+Shot.h"

@implementation UIImage (Shot)

+ (UIImage *)captureImageFromViewLow:(UIView *)orgView {
    
    //获取指定View的图片
    
    UIGraphicsBeginImageContextWithOptions(orgView.bounds.size, NO, 0.0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [orgView.layer renderInContext:context];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
    
}

//- (UIImage *)imageWithClippedRect:(CGRect)rect {
//    CGContextInspectSize(rect.size);
//    CGRect imageRect = CGRectMakeWithSize(self.size);
//    if (CGRectContainsRect(rect, imageRect)) {
//        // 要裁剪的区域比自身大，所以不用裁剪直接返回自身即可
//        return self;
//    }
//    // 由于CGImage是以pixel为单位来计算的，而UIImage是以point为单位，所以这里需要将传进来的point转换为pixel
//    CGRect scaledRect = CGRectApplyScale(rect, self.scale);
//    CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, scaledRect);
//    UIImage *imageOut = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
//    CGImageRelease(imageRef);
//    return imageOut;
//}

@end
