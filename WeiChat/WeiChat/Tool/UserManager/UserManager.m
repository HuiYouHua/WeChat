//
//  UserManager.m
//  WeiChat
//
//  Created by haixuan on 16/8/10.
//  Copyright © 2016年 华惠友. All rights reserved.
//

#import "UserManager.h"
#import "XMPPManager.h"

#define kName @"name"
#define kPsw @"psw"

@implementation UserManager
singleton_m(manager)

- (void)saveLoginInfo {
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user setObject:self.loginName forKey:kName];
    [user setObject:self.loginPsw forKey:kPsw];
    [user synchronize];
}

- (void)saveRegistInfo {
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user setObject:self.registPsw forKey:kName];
    [user setObject:self.registPsw forKey:kPsw];
    [user synchronize];
}

// 读取登陆用户信息
- (void)readLoginInfo {
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    self.loginName = [user valueForKey:kName];
    self.loginPsw = [user valueForKey:kPsw];
    [self readUserInfo];
}

// 读取注册用户信息
- (void)readRegistInfo {
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    self.registName = [user valueForKey:kName];
    self.registPsw = [user valueForKey:kPsw];
    [self readUserInfo];
}

- (void)readUserInfo {
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *path = [cachePath stringByAppendingPathComponent:@"head.png"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        NSData *data = [NSData dataWithContentsOfFile:path];
        self.image = [UIImage imageWithData:data];
    } else {
        self.image = [UIImage imageNamed:@"DefaultProfileHead"];
    }
}

- (void)clearUserInfo {
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user removeObjectForKey:kPsw];
    [user removeObjectForKey:kName];
}

- (BOOL)needLogin {
    [self readLoginInfo];
    if (self.loginName) {
        return NO;
    }
    return YES;
}

- (NSString *)jid {
    [self readLoginInfo];
    NSString *jid = [NSString stringWithFormat:@"%@@%@",self.loginName,kHostName];
    return jid;
}

@end









