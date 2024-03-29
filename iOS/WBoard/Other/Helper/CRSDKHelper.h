//
//  MeetingHelper.h
//  Meeting
//
//  Created by king on 2017/2/10.
//  Copyright © 2017年 BossKing10086. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const MeetingHelper_server;
extern NSString * const MeetingHelper_account;
extern NSString * const MeetingHelper_pswd;
extern NSString * const MeetingHelper_nickname;

@interface CRSDKHelper : NSObject

@property (nonatomic, copy, readonly) NSString *server; /**< 服务器地址 */
@property (nonatomic, copy, readonly) NSString *account; /**< 账户 */
@property (nonatomic, copy, readonly) NSString *pswd; /**< 密码 */
@property (nonatomic, copy, readonly) NSString *nickname; /**< 登录昵称(user_xxxx) */

+ (instancetype)shareInstance;

/**
 写 账号/密码/服务器地址 信息
 @param account 账号
 @param pswd 密码
 @param server 服务器地址
 */
- (void)writeAccount:(NSString *)account pswd:(NSString *)pswd server:(NSString *)server;

/**
 写 昵称
 
 @param nickname 昵称
 */
- (void)setNickname:(NSString *)nickname;

/**
 读取信息(账号/密码/服务器地址/昵称)
 */
- (void)readInfo;

/**
 恢复默认值(不包括 昵称)
 */
- (void)resetInfo;

@end
