//
//  WhiteBoardListCell.m
//  WBoard
//
//  Created by YunWu01 on 2022/5/7.
//  Copyright © 2022 BossKing10086. All rights reserved.
//

#import "WhiteBoardListCell.h"

@implementation WhiteBoardListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.nameLabel.highlightedTextColor = UIColorFromRGBA(57, 171, 251, 1.0);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)deleteWhiteBoard:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(deleteWhiteBoardAtCell:)]) {
        [self.delegate deleteWhiteBoardAtCell:self];
    }
}

@end
