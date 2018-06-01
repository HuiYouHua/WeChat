//
//  ChatMessageModel.m
//  WeiChat
//
//  Created by haixuan on 16/8/15.
//  Copyright © 2016年 华惠友. All rights reserved.
//

#import "ChatMessageModel.h"
#import "NSString+YFTimestamp.h"

@interface ChatMessageModel ()

/** 文字聊天内容 */
@property (nonatomic, copy) NSString *contentText;

/** 文字聊天的背景图 */
@property (nonatomic, strong) UIImage *contectTextBackgroundIma;
@property (nonatomic, strong) UIImage *contectTextBackgroundHLIma;

/** 头像urlStr */
@property (nonatomic, copy) NSString *userIcon;

/** timeStr */
@property (nonatomic, copy) NSString *timeStr;

/** 是我还是他 */
@property (nonatomic, assign, getter=isMe) BOOL me;

/** 图片urlStr */
@property (nonatomic, copy) NSURL *contentImageUrl;

/** 图片内容 */
@property (nonatomic, copy) UIImage *contentImage;

/** 语音内容 */
@property (nonatomic, copy) NSData *contentVoiceData;

/** 音频持续的时间 */
@property (nonatomic, assign) NSInteger voiceDuration;

@end

@implementation ChatMessageModel

#pragma mark -- 解析并处理消息内容,消息model
- (void)setMsg:(XMPPMessageArchiving_Message_CoreDataObject *)msg {
    _msg = msg;
    
    // 判断会话是自己发的还是别人发的
    if ([msg.outgoing intValue]) {
        // 不为0 表示自己
        self.me = YES;
        self.userIcon = @"xhr";
        self.contectTextBackgroundIma = [UIImage imageNamed: @"SenderTextNodeBkg"];
        self.contectTextBackgroundHLIma = [UIImage imageNamed: @"SenderTextNodeBkgHL"];
    } else {
        // 表示别人
        self.me = NO;
        self.userIcon = @"add_friend_icon_offical";
        self.contectTextBackgroundIma = [UIImage imageNamed: @"ReceiverTextNodeBkg"];
        self.contectTextBackgroundHLIma = [UIImage imageNamed: @"ReceiverTextNodeBkgHL"];
    }
    
    // 设置时间戳
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"yyyy-MM-dd hh:mm";
    self.timeStr = [dateFormatter stringFromDate:msg.timestamp];
    
    // 计算时间差是否大于1分钟,大于显示,小于不显示
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *cmp;
    if (self.preMsgDate) {
        cmp = [calendar components:NSCalendarUnitMinute fromDate:self.preMsgDate toDate:msg.timestamp options:NSCalendarWrapComponents];
    }
    self.showTime = cmp.minute > 1;
    
    // 解析消息内容
    //NSString *chatType = [msg.message attributeStringValueForName:@"bodyType"];
    // body为消息,图片,视频,音频识别
    NSString *body = msg.message.body;
    if ([body isEqualToString:@"text"]) {
        XMPPElement *node = msg.message.children.lastObject;
        // 取出消息的解码
        NSString *text = node.stringValue;
        self.contentText = text;
        //NSLog(@"%@",self.contentText);
    } else if ([body isEqualToString:@"image"]) {
#warning 此处采用图片,语音等传输方式为XML携带信息,所以传输速度慢,因为未搭建文件服务器,所以采用该种办法,建议采用文件服务器方式,传递URL
        XMPPElement *node = msg.message.children.lastObject;
        // 取出消息的解码
        NSString *base64str = node.stringValue;
        NSData *data = [[NSData alloc]initWithBase64EncodedString:base64str options:0];
        UIImage *image = [[UIImage alloc]initWithData:data];
        self.contentImage = image;
    } else if ([body isEqualToString:@"voice"]) {
        XMPPElement *node = msg.message.children.lastObject;
        // 取出消息的解码
        NSString *base64str = node.stringValue;
        NSData *data = [[NSData alloc]initWithBase64EncodedString:base64str options:0];
        //NSLog(@"接收录音数据:%@",data);
        self.contentVoiceData = data;
        // 录音时间
        NSString *duringTime = [msg.message attributeStringValueForName:@"duringTime"];
        self.voiceDuration = [duringTime integerValue];
        //NSLog(@"接收时间:%@",duringTime);
    } else if ([body isEqualToString:@"file"]) {
            
    }
#warning 此处采用的是文件服务器方式传输,但由于未建立文件服务器,所以传输对象为写死的一图片,语音等文件的url,仅供测试使用
/*    } else if ([chatType isEqualToString:@"image"]) {
        // 图片
        // body = 图片地址
        self.contentImageUrl = [NSURL URLWithString:body];
    } else if ([chatType isEqualToString:@"video"]) {
        // 视频
        // body = 视频地址
        NSLog(@"%@",body);
    } else if ([chatType isEqualToString:@"voice"]) {
        // 音频
        NSLog(@"%@",body);
    }
 */
}

@end


















