//
//  ChatViewController.h
//  WeiChat
//
//  Created by haixuan on 16/8/11.
//  Copyright © 2016年 华惠友. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "XMPPManager.h"

@interface ChatViewController : UIViewController

@property (nonatomic, strong) XMPPUserCoreDataStorageObject *jidChatTo;

@end
