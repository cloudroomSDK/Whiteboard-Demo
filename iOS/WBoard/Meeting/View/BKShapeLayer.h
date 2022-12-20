//
//  BKShapeLayer.h
//  WBoard
//
//  Created by cloudroom on 2018/7/31.
//  Copyright © 2018年 BossKing10086. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

typedef NS_ENUM(NSUInteger, DrawShapeType) {
    
    SHAPE_NULL,
    INDICATE,    //指示器
    HOTSPOT,    //热点
    TURNPAGEPIC,//
    
    PENCIL,        //铅笔
    NITEPEN,    //荧光笔
    LINE,        //直线
    LINEARROW1,    //单向箭头
    LINEARROW2,    //双向箭头
    TEXT,        //文本
    FILLRECT,    //直角矩形(实心)
    HOLLRECT,    //直角矩形(空心)
    FILLROUNDRECT,    //圆角矩形(实心)
    HOLLROUNDRECT,    //圆角矩形(空心)
    FILLELLIPSE,    //椭圆(实心)
    HOLLELLIPSE,    //椭圆(空心)
    IMAGE,        //贴图
};

@interface BKPath : UIBezierPath
/**< 画笔类型 */
@property (nonatomic, assign, readonly) DrawShapeType type;
+ (instancetype)pathWithWidth:(CGFloat)lWidth sPoint:(CGPoint)sPoint type:(DrawShapeType)type;
@end

@interface BKShapeLayer : CAShapeLayer

/** 当前图层的ID */
@property (nonatomic, copy) NSString *elementID;
/**< 点集 */
@property (nonatomic, strong) NSMutableArray<NSString *> *points;
/**< 原始 */
@property (nonatomic, strong)NSMutableArray<NSNumber *> *originalPoints;
/*是否本地绘制*/
@property(nonatomic,assign)bool bLocal;

@end
