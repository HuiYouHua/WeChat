//
//  ChatMessageModel.h
//  WeiChat
//
//  Created by haixuan on 16/8/15.
//  Copyright © 2016年 华惠友. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "XMPPManager.h"

@interface ChatMessageModel : NSObject

/** 会话对象 */
@property (nonatomic, strong) XMPPMessageArchiving_Message_CoreDataObject *msg;

/** 文字聊天内容 */
@property (nonatomic, copy, readonly) NSString *contentText;
/** 文字聊天的背景图 */
@property (nonatomic, strong, readonly) UIImage *contectTextBackgroundIma;
@property (nonatomic, strong, readonly) UIImage *contectTextBackgroundHLIma;

/** 头像urlStr */
@property (nonatomic, copy, readonly) NSString *userIcon;

/** timeStr */
@property (nonatomic, copy, readonly) NSString *timeStr;

/** 是我还是他 */
@property (nonatomic, assign, getter=isMe, readonly) BOOL me;

/** 上条信息的发送时间 */
@property (nonatomic, copy) NSDate *preMsgDate;

/** 是否显示时间 */
@property (nonatomic, assign, getter= isShowTime) BOOL showTime;

/** 图片urlStr */
@property (nonatomic, copy, readonly) NSURL *contentImageUrl;

/** 图片内容 */
@property (nonatomic, copy, readonly) UIImage *contentImage;

/** 语音内容 */
@property (nonatomic, copy, readonly) NSData *contentVoiceData;
/** 音频持续的时间 */
@property (nonatomic, assign, readonly) NSInteger voiceDuration;
@end
