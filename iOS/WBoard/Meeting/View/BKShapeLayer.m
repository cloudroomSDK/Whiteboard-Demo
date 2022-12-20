//
//  BKShapeLayer.m
//  WBoard
//
//  Created by cloudroom on 2018/7/31.
//  Copyright © 2018年 BossKing10086. All rights reserved.
//

#import "BKShapeLayer.h"
@interface BKPath ()

@property (nonatomic, assign, readwrite) DrawShapeType type; /**< 类型 */

@end

@implementation BKPath
#pragma mark - public method
+ (instancetype)pathWithWidth:(CGFloat)width sPoint:(CGPoint)sPoint type:(DrawShapeType)type {
    BKPath * path = [[self alloc] init];
    path.lineWidth = width;
    path.lineCapStyle = kCGLineCapRound; // 线条拐角
    path.lineJoinStyle = kCGLineJoinRound; // 终点处理
    [path moveToPoint:sPoint];
    path.type = type;
    return path;
}
@end


@implementation BKShapeLayer

-(NSMutableArray<NSString *> *)points{
    
    if(_points == nil)
    {
        _points = [NSMutableArray array];
    }
    return _points;
}

-(NSMutableArray<NSNumber *> *)originalPoints
{
    if(_originalPoints == nil)
    {
        _originalPoints = [NSMutableArray array];
    }
    return _originalPoints;
}
@end
