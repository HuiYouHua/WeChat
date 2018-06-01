//
//  AppDelegate.m
//  WeiChat
//
//  Created by haixuan on 16/8/10.
//  Copyright © 2016年 华惠友. All rights reserved.
//

#import "AppDelegate.h"

#import "UserManager.h"
#import "XMPPManager.h"

#import "UIColor+Hex.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 本地通知
    float sysVer = [[[UIDevice currentDevice] systemVersion] floatValue];
    if(sysVer < 8){
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
    }else{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= _IPHONE80_
        UIMutableUserNotificationCategory *categorys = [[UIMutableUserNotificationCategory alloc] init];
        UIUserNotificationSettings *userSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIUserNotificationTypeAlert
                                                                                     categories:[NSSet setWithObject:categorys]];
        [[UIApplication sharedApplication] registerUserNotificationSettings:userSettings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
#endif
    }
    
    // 设置所有的tabBar
    UITabBar *tabBar = [UITabBar appearance];
    // 09bb07
    tabBar.tintColor = [UIColor colorFromHexString:@"09bb07"];
    
    UINavigationBar *navBar = [UINavigationBar appearance];
    [navBar setBackgroundImage:[UIImage imageNamed:@"topbarbg_ios7"] forBarMetrics:UIBarMetricsDefault];
    // 设置导航标题颜色和大小
    navBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont systemFontOfSize:17]};
    
    // 设置导航返回按钮的颜色:默认蓝色
    navBar.tintColor = [UIColor whiteColor];
    
    
    
    /**
     *  状态栏颜色
     *  黑色
     *  白色
     */
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    
    if ([[UserManager sharedmanager] needLogin]) {
        
    } else {
        [[XMPPManager sharedmanager] xmppUserLogin:nil];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
