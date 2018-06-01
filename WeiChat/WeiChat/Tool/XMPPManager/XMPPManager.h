//
//  XMPPManager.h
//  WeiChat
//
//  Created by haixuan on 16/8/10.
//  Copyright © 2016年 华惠友. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"
#import "XMPP.h"


// 用于提供电子名片增删改查操作
#import "XMPPvCardTempModule.h"
// 代表电子名片Modal
#import "XMPPvCardTemp.h"
// 代表电子名片在core data中存储
#import "XMPPvCardCoreDataStorage.h"

// 头像模块:可以根据代理方法获取头像变化的时机
#import "XMPPvCardAvatarModule.h"

// 自动连接
#import "XMPPReconnect.h"

// 花名册模块(好友列表)
#import "XMPPRoster.h"
#import "XMPPRosterMemoryStorage.h"
#import "XMPPRosterCoreDataStorage.h"

#import "XMPPUserCoreDataStorageObject.h"

// 聊天模块
#import "XMPPMessageArchiving.h"
#import "XMPPMessageArchivingCoreDataStorage.h"

#ifdef DEBUG
#define kHostName @"192.168.199.111"
//#define kHostName @"127.0.0.1"
#define kHostPort 5222
#else
#define kHostNanme @""
#define kHostPort 5222
#endif

#define kLoginStateNotification @"LoginStateNotification"

typedef NS_ENUM(NSUInteger, XMPPUserStateType) {
    // 登陆注册成功状态
    XMPPUserStateTypeSuccess,
    // 登陆注册失败状态
    XMPPUserStateTypeFaild,
    // 其他位置状态,网络不好
    XMPPUserStateTypeOther
};

typedef void(^UserSatateBlock)(XMPPUserStateType type);
typedef void(^ImageBlock)(UIImage *image);

@interface XMPPManager : NSObject

singleton_h(manager)

/**
 *  XMPP通道流
 */
@property (nonatomic, strong) XMPPStream *stream;
@property (nonatomic, strong) UserSatateBlock block;

/**
 *  电子名片
 */
@property (nonatomic, strong) XMPPvCardCoreDataStorage *vCardStorage;
@property (nonatomic, strong) XMPPvCardTempModule *vCardModule;
@property (nonatomic, strong) XMPPvCardAvatarModule *vCardAvatar;
@property (nonatomic, strong) ImageBlock imageBlock;

/**
 *  自动连接
 */
@property (nonatomic, strong) XMPPReconnect *reconnect;

/**
 *  花名册
 */
@property (nonatomic, strong) XMPPRoster *roster;
@property (nonatomic, strong) XMPPRosterCoreDataStorage *rosterStorage;

/**
 *  聊天模块
 */
@property (nonatomic, strong) XMPPMessageArchiving *messageArchiving;
@property (nonatomic, strong) XMPPMessageArchivingCoreDataStorage *archivingStorage;

// 连接服务器
- (void)connect;
// 登陆
- (void)xmppUserLogin:(UserSatateBlock)block;
// 注册
- (void)xmppUserRegist:(UserSatateBlock)block;
// 注销
- (void)xmppUserLogout;

// block回调获取用户头像
- (void)xmppGetUserHeaderImage:(ImageBlock)block;

@end







