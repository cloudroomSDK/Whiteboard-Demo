//
//  WBDesc_V2+ExInfo.m
//  WBoard
//
//  Created by YunWu01 on 2022/10/17.
//  Copyright © 2022 BossKing10086. All rights reserved.
//

#import "BoardInfo+ExInfo.h"
#import "MJExtension.h"

@implementation BoardInfo (ExInfo)

- (NSString *)name {
    NSDictionary *exInfoDict = [self.extInfo mj_JSONObject];
    return [exInfoDict valueForKey:@"name"];
}

@end
