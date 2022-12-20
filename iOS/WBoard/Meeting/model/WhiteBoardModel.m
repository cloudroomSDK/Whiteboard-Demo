//
//  WhiteBoardModel.m
//  WBoard
//
//  Created by cloudroom on 2018/8/7.
//  Copyright © 2018年 BossKing10086. All rights reserved.
//

#import "WhiteBoardModel.h"
@implementation WhiteBoardModel
-(NSMutableDictionary *)whiteBoardPageInfo{
    if(_whiteBoardPageInfo == nil){
        _whiteBoardPageInfo = [NSMutableDictionary dictionary];
    }
    return  _whiteBoardPageInfo;
}
@end

