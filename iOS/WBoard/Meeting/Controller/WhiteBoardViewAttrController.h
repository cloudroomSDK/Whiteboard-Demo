//
//  WhiteBoardViewAttrController.h
//  WBoard
//
//  Created by YunWu01 on 2022/10/9.
//  Copyright © 2022 BossKing10086. All rights reserved.
//

#import "BaseController.h"

NS_ASSUME_NONNULL_BEGIN

@interface WhiteBoardViewAttrController : BaseController
@property (nonatomic, strong) CLBoardViewAttr *attr;

@property (nonatomic, copy) void (^asyncViewAttrBlock)(CLBoardViewAttr *attr);

@end

NS_ASSUME_NONNULL_END
