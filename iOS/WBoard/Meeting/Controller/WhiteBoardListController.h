//
//  WhiteBoardListController.h
//  WBoard
//
//  Created by YunWu01 on 2022/5/7.
//  Copyright © 2022 BossKing10086. All rights reserved.
//

#import "BaseController.h"

NS_ASSUME_NONNULL_BEGIN

UIKIT_EXTERN NSNotificationName const KWhiteBoardListDidChangeNotification;

@interface WhiteBoardListController : BaseController
@property (nonatomic, copy) NSString *currentWB;
@property (nonatomic, strong) NSMutableArray<BoardInfo *> *boardList;
@end

NS_ASSUME_NONNULL_END
