//
//  WhiteBoardModel.h
//  WBoard
//
//  Created by cloudroom on 2018/8/7.
//  Copyright © 2018年 BossKing10086. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SubPageInfo;
@class BKDrawerModel;

@interface WhiteBoardModel : NSObject
@property (nonatomic, strong) SubPageInfo *whiteBoardBaseInfo;
@property (nonatomic, strong) NSMutableDictionary *whiteBoardPageInfo;
@end

