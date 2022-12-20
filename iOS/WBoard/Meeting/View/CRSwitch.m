//
//  CRSwitch.m
//  WBoard
//
//  Created by YunWu01 on 2022/10/9.
//  Copyright © 2022 BossKing10086. All rights reserved.
//

#import "CRSwitch.h"

@implementation CRSwitch

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.onTintColor = UIColorFromHexRGB(0x60ACFF);
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.onTintColor = UIColorFromHexRGB(0x60ACFF);
}

@end
