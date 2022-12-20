//
//  BKBrushButton.m
//  WBoard
//
//  Created by cloudroom on 2018/7/30.
//  Copyright © 2018年 BossKing10086. All rights reserved.
//

#import "BKBrushButton.h"

@implementation BKBrushButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib {
    [super awakeFromNib];
    self.layer.cornerRadius = 1.0;
    self.layer.masksToBounds = YES;
}

-(void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    if(self.selected)
    {
        self.backgroundColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1.0];
    }else{
        self.backgroundColor = [UIColor clearColor];
    }
}

- (UIEdgeInsets)contentEdgeInsets {
    return UIEdgeInsetsMake(2, 2, 2, 2);
}

@end
