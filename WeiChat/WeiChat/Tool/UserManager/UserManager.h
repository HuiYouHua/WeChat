//
//  UserManager.h
//  WeiChat
//
//  Created by haixuan on 16/8/10.
//  Copyright © 2016年 华惠友. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Singleton.h"

@interface UserManager : NSObject
singleton_h(manager)

// 登陆账户密码
@property (nonatomic, copy) NSString *loginName;
@property (nonatomic, copy) NSString *loginPsw;

// 注册账户密码
@property (nonatomic, copy) NSString *registName;
@property (nonatomic, copy) NSString *registPsw;

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, copy) NSString *jid;

// 存储用户登录信息
- (void)saveRegistInfo;
// 存储用户注册信息
- (void)saveLoginInfo;
// 读取注册用户信息
- (void)readRegistInfo;
// 读取登陆用户信息
- (void)readLoginInfo;
// 清除用户信息
- (void)clearUserInfo;

// 自动登陆
- (BOOL)needLogin;



@end
