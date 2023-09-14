//
//  WhiteBoardListController.m
//  WBoard
//
//  Created by YunWu01 on 2022/5/7.
//  Copyright © 2022 BossKing10086. All rights reserved.
//

#import "WhiteBoardListController.h"
#import "WhiteBoardListCell.h"
#import "MJExtension.h"
#import "BoardInfo+ExInfo.h"

NSNotificationName const KWhiteBoardListDidChangeNotification = @"KWhiteBoardListDidChangeNotification";

static NSString *const cellID = @"WhiteBoardListCell";

@interface WhiteBoardListController ()<UITableViewDelegate, UITableViewDataSource, WhiteBoardListCellDelegate>
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation WhiteBoardListController

- (UIModalPresentationStyle)modalPresentationStyle {
    return UIModalPresentationOverFullScreen;
}

- (UIModalTransitionStyle)modalTransitionStyle {
    return UIModalTransitionStyleCrossDissolve;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KWhiteBoardListDidChangeNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    [self.tableView registerNib:[UINib nibWithNibName:@"WhiteBoardListCell" bundle:nil] forCellReuseIdentifier:cellID];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(whiteBoardListDidChange:) name:KWhiteBoardListDidChangeNotification object:nil];
}

- (IBAction)dismissBoardListViewController:(UITapGestureRecognizer *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)whiteBoardListDidChange:(NSNotification *)noti {
    [self.tableView reloadData];
}

#pragma mark - WhiteBoardListCellDelegate

- (void)deleteWhiteBoardAtCell:(UITableViewCell *)cell {
    [HUDUtil hudShow:@"正在删除..." delay:0.25 animated:YES];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    BoardInfo *board = [_boardList objectAtIndex:indexPath.row];
    [_boardList removeObject:board];
    
    [[CloudroomVideoMeeting shareInstance] closeBoard:board.boardID];
    
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    
    NSString *currentBoard = [[CloudroomVideoMeeting shareInstance] getCurrentBoard];
    if (![currentBoard isEqualToString:board.boardID]) return;
    
    // 删除完后切到下一个白板(删除的是当前白板)
    NSInteger row = indexPath.row < (_boardList.count - 1) ? indexPath.row : _boardList.count - 1;
    if (_boardList.count > 0) {
        NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:row inSection:0];
        [self tableView:self.tableView didSelectRowAtIndexPath:nextIndexPath];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _boardList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WhiteBoardListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    cell.delegate = self;
    
    BoardInfo *wbDesc = [_boardList objectAtIndex:indexPath.row];
    cell.nameLabel.text = [wbDesc name];
    cell.nameLabel.highlighted = [wbDesc.boardID isEqualToString:_currentWB];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BoardInfo *wbDesc = [_boardList objectAtIndex:indexPath.row];
    [[CloudroomVideoMeeting shareInstance] setCurrentBoard:wbDesc.boardID];
    
    _currentWB = wbDesc.boardID;
    [self.tableView reloadData];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
