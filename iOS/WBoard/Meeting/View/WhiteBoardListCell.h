//
//  WhiteBoardListCell.h
//  WBoard
//
//  Created by YunWu01 on 2022/5/7.
//  Copyright © 2022 BossKing10086. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol WhiteBoardListCellDelegate <NSObject>

- (void)deleteWhiteBoardAtCell:(UITableViewCell *)cell;

@end

@interface WhiteBoardListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) id<WhiteBoardListCellDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
