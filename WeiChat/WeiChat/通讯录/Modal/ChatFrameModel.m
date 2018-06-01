//
//  ChatFrameModel.m
//  WeiChat
//
//  Created by haixuan on 16/8/15.
//  Copyright © 2016年 华惠友. All rights reserved.
//

#import "ChatFrameModel.h"
#import "ChatMessageModel.h"

// 时间戳字体大小
#define kTimeFont [UIFont systemFontOfSize:13.0]
// 聊天内容文字大小
#define kContentTextFont [UIFont systemFontOfSize:15.0]
// 头像大小
#define kIconWidth 44

@interface ChatFrameModel ()

/** timeLab */
@property (nonatomic, assign) CGRect timeFrame;

/** 头像frame */
@property (nonatomic, assign) CGRect iconFrame;

/** 内容的frame */
@property (nonatomic, assign) CGRect contentFrame;

/** durationTime的frame */
@property (nonatomic, assign) CGRect durationFrame;

/** cell高度 */
@property (nonatomic, assign) CGFloat cellH;

@end

@implementation ChatFrameModel

- (void)setMsg:(ChatMessageModel *)msg {
    _msg = msg;
    
    // 间距10
    CGFloat margin = 10;
    
    // 时间戳
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    CGFloat timeX;
    CGFloat timeY = margin;
    CGFloat timeW;
    // 通过timeLab的高度控制是否显示时间戳
    CGFloat timeH = msg.showTime ? 20 : 0;
    /**
     *  计算普通文本的大小
     参数一：CGSize)size  表示计算文本的最大宽高、就是限制的最大高度、宽度，一般情况下我们设置最大的宽度、高度不限制CGSizeMake(getScreenWidth(), CGFLOAT_MAX)，注意：限制的宽度不同，计算的高度结果也不同
     
     参数二：NSStringDrawingOptions表示计算的类型
     
     NSStringDrawingUsesLineFragmentOrigin绘制文本时使用 line fragement origin 而不是 baseline origin。一般使用这项
     NSStringDrawingUsesFontLeading 根据字体计算高度
     NSStringDrawingUsesDeviceMetrics 使用象形文字计算高度
     NSStringDrawingTruncatesLastVisibleLine 如果NSStringDrawingUsesLineFragmentOrigin设置，这个选项中没有用
     
     参数三：attributes 表示富文本的属性 NSAttributedString.h比如字体、文字样式等NSFontAttributeName、NSParagraphStyleAttributeName
     
     参数四：NSStringDrawingContext
     When stringDrawingContext=nil, it's equivalent of passing the default instance initialized with [[NSStringDrawingContext alloc] init] context上下文。包括一些信息，例如如何调整字间距以及缩放。该参数一般可为 nil 。
     *
     *  @return CGRect
     */
    CGSize timeSize = [msg.timeStr boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 20)
                                                options:NSStringDrawingUsesLineFragmentOrigin
                                             attributes:@{NSFontAttributeName:kTimeFont}
                                                context:nil].size;
    timeW = timeSize.width + 5;
    timeX = (screenW - timeW) * 0.5;
    self.timeFrame = CGRectMake(timeX, timeY, timeW, timeH);
    
    // 头像
    CGFloat iconX = margin;
    CGFloat iconY = CGRectGetMaxY(self.timeFrame) + margin;
    CGFloat iconW = kIconWidth;
    CGFloat iconH = iconW;
    
    // 会话
    CGFloat contentX;
    CGFloat contentY = iconY;
    CGFloat contentW;
    CGFloat contentH;
    CGFloat contentMaxWidth = screenW - 2 * (2 * margin + iconW);
    
    CGFloat durationX;
    CGFloat durationY = contentY;
    CGFloat durationH = iconH;
    CGFloat durationW = durationH;
    
    NSString *chatType = msg.msg.message.body;
    if ([chatType isEqualToString:@"text"]) {
        CGSize contentSize = [msg.contentText boundingRectWithSize:CGSizeMake(contentMaxWidth, CGFLOAT_MAX)
                                                           options:NSStringDrawingUsesLineFragmentOrigin
                                                        attributes:@{NSFontAttributeName:kContentTextFont}
                                                           context:nil].size;
        contentW = contentSize.width + kContentEdgeLeft + kContentEdgeRight;
        contentH = contentSize.height + kContentEdgeTop + kContentEdgeBottom;
    } else if ([chatType isEqualToString:@"image"]) {
#warning 此处采用图片,语音等传输方式为XML携带信息,所以传输速度慢,因为未搭建文件服务器,所以采用该种办法,建议采用文件服务器方式,传递URL
        contentW = 200;
        contentH = 200;
    } else if ([chatType isEqualToString:@"voice"]) {
        contentH = 44;
        contentW = [self caculculateVoiceLengthWithTime:msg.voiceDuration];
    } else if ([chatType isEqualToString:@"file"]) {
        
    }
#warning 此处采用的是文件服务器方式传输,但由于未建立文件服务器,所以传输对象为写死的一图片,语音等文件的url,仅供测试使用
/*    } else if ([chatType isEqualToString:@"image"]) {
        // 图片
        contentW = 200;
        contentH = 200;
    } else if ([chatType isEqualToString:@"video"]) {
        // 视频
        // body = 视频地址
        
    } else if ([chatType isEqualToString:@"voice"]) {
        // 音频
        
    }
*/
    
    
    // 头像的横坐标和会话内容的横坐标需要进行判断
    if (msg.me) {
        iconX = screenW - margin - iconW;
        contentX = iconX - margin - contentW;
        durationX = contentX - durationW + margin;
    } else {
        iconX = margin;
        contentX = iconX + iconW +  margin;
        durationX = contentX + contentW - margin;
    }
    self.iconFrame = CGRectMake(iconX, iconY, iconW, iconH);
#warning 会话中用户的文本框高度不对,暂未找到解决办法
    self.contentFrame = CGRectMake(contentX, contentY, contentW, contentH);
    self.durationFrame = CGRectMake(durationX, durationY, durationW, durationH);
    // 返回的单元格的高度:判断头像高度与会话内容高度,谁高选择谁,并在其基础上加上间距的距离
    self.cellH = (contentH > iconH) ? CGRectGetMaxY(self.contentFrame) + margin : CGRectGetMaxY(self.iconFrame) + margin;
}

- (CGFloat)caculculateVoiceLengthWithTime:(NSInteger)time {
    if (time < 3) {
        return 64.0;
    } else if (time >= 30) {
        return 280.0;
    } else {
        return 216 / 27.0 * (time - 3) + 64;
    }
}

@end







