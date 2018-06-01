//
//  ChatTableViewCell.m
//  WeiChat
//
//  Created by haixuan on 16/8/15.
//  Copyright © 2016年 华惠友. All rights reserved.
//

#import "ChatTableViewCell.h"

#import "LongPressBtn.h"
#import "ChatFrameModel.h"
#import "ChatMessageModel.h"

#import "UIButton+WebCache.h"

// 时间戳字体大小
#define kTimeFont [UIFont systemFontOfSize:13.0]
// 聊天内容文字大小
#define kContentTextFont [UIFont systemFontOfSize:15.0]
#define BackGround243Color [UIColor colorWithRed:243/255.0 green:243/255.0 blue:243/255.0 alpha:1]

@interface ChatTableViewCell ()

/** timeLab */
@property (nonatomic, weak) UILabel *timeLab;

/** 头像 */
@property (nonatomic, weak) LongPressBtn *userIconBtn;

/** 聊天内容 */
@property (nonatomic, weak) LongPressBtn *contentBtn;

/** timeLab */
@property (nonatomic, weak) UILabel *durationLab;

@end
@implementation ChatTableViewCell

/**
 *  重写initWithStyle:resueldentifier方法:
 >添加所有需要显示的子控件(不需要设置frame和数据，子控件添加到contentView中)
 >进行子控件一次性的设置(比如某些子控件的只需要设置一次数据：某些固定的图标、文字的字体..)
 */
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    // 在初始化里创建控件
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = BackGround243Color;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // 时间戳
        UILabel *timeLab = [[UILabel alloc] init];
        timeLab.backgroundColor = [UIColor grayColor];
        timeLab.textColor = [UIColor whiteColor];
        timeLab.textAlignment = NSTextAlignmentCenter;
        timeLab.font = kTimeFont;
        timeLab.layer.cornerRadius = 3;
        [self.contentView addSubview:timeLab];
        self.timeLab = timeLab;
        
        // 头像按钮
        LongPressBtn *userIconBtn = [LongPressBtn buttonWithType:0];
        userIconBtn.block = ^(LongPressBtn *btn) {
            // 长按时的业务逻辑
        };
        [userIconBtn addTarget:self action:@selector(showUserDetailInfo:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:userIconBtn];
        self.userIconBtn = userIconBtn;
        
        // 会话内容按钮
        LongPressBtn *contextTextBtn = [LongPressBtn buttonWithType:0];
        contextTextBtn.block = ^(LongPressBtn *btn) {
          // 长按时的业务逻辑
            
            // 复制粘贴撤回等操作
            ChatMessageModel *msgModel = self.chatFrame.msg;
            [self.contentBtn setBackgroundImage:msgModel.contectTextBackgroundHLIma forState:UIControlStateNormal];
        };
        [contextTextBtn addTarget:self action:@selector(showContextTextInfo:) forControlEvents:UIControlEventTouchUpInside];
        contextTextBtn.titleLabel.font = kContentTextFont;
        contextTextBtn.titleLabel.numberOfLines = 0;
        [contextTextBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.contentBtn = contextTextBtn;
        [self.contentView addSubview:contextTextBtn];
        
        UILabel *durationLab = [[UILabel alloc] init];
        //durationLab.backgroundColor = [UIColor grayColor];
        durationLab.textColor = [UIColor lightGrayColor];
        durationLab.textAlignment = NSTextAlignmentCenter;
        durationLab.font = [UIFont systemFontOfSize:14.0];
        durationLab.hidden = YES;
        [self.contentView addSubview: durationLab];
        self.durationLab = durationLab;
    }
    return self;
}

/**
 *  创建一个类工厂方法,用于快速创建cell
    外部可以直接调用该方法创建cell
 */
+ (instancetype)cellWithTableView:(UITableView *)tableView {
    //static NSString *ID = @"ChatTableViewCell";
    ChatTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(self)];
    if (!cell) {
        cell = [[ChatTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass(self)];
    }
    return cell;
}

/**
 *  重写frame数据模型属性的setter方法
    在这个方法中设置子控件的显示数据和frame
 */
- (void)setChatFrame:(ChatFrameModel *)chatFrame {
    _chatFrame = chatFrame;
    
    // 根据frame模型获得数据模型
    ChatMessageModel *msgModel = chatFrame.msg;
    
    // 根据数据模型进行数据赋值
    self.timeLab.text = msgModel.timeStr;
    
    [self.userIconBtn setBackgroundImage:[UIImage imageNamed:msgModel.userIcon] forState:UIControlStateNormal];
    [self.contentBtn setBackgroundImage:msgModel.contectTextBackgroundIma forState:UIControlStateNormal];
    [self.contentBtn setBackgroundImage:msgModel.contectTextBackgroundHLIma forState:UIControlStateHighlighted];
    
    self.durationLab.hidden = ![msgModel.msg.message.body isEqualToString:@"voice"];
    
    NSString *chatType = msgModel.msg.message.body;
    if ([chatType isEqualToString:@"text"]) {
        // 文本 直接加载单元格
        // body
        self.contentBtn.contentEdgeInsets = UIEdgeInsetsMake(kContentEdgeTop, kContentEdgeLeft, kContentEdgeBottom, kContentEdgeRight);
        NSLog(@"文字聊天内容:%@",msgModel.contentText);
        [self.contentBtn setTitle:msgModel.contentText forState:UIControlStateNormal];
    } else if ([chatType isEqualToString:@"image"]) {
#warning 此处采用图片,语音等传输方式为XML携带信息,所以传输速度慢,因为未搭建文件服务器,所以采用该种办法,建议采用文件服务器方式,传递URL
        [self.contentBtn setImage:msgModel.contentImage forState:UIControlStateNormal];
        NSLog(@"图片聊天内容:%@",msgModel.contentImage);
        //self.contentBtn.contentEdgeInsets = UIEdgeInsetsZero;
        //[self.contentBtn setTitle: @"" forState: UIControlStateNormal];
    }  else if ([chatType isEqualToString:@"voice"]) {
        [self.contentBtn setImage: [UIImage imageNamed: @"SenderVoiceNodePlaying"] forState:UIControlStateNormal];
        self.durationLab.text = [NSString stringWithFormat:@"%zd \"", msgModel.voiceDuration];
    } else if ([chatType isEqualToString:@"file"]) {
        
    }

#warning 此处采用的是文件服务器方式传输,但由于未建立文件服务器,所以传输对象为写死的一图片,语音等文件的url,仅供测试使用
/*    } else if ([chatType isEqualToString:@"image"]) {
        // 图片
        // body = 图片地址
        [self.contentBtn sd_setImageWithURL:msgModel.contentImageUrl forState:UIControlStateNormal];
        self.contentBtn.contentEdgeInsets = UIEdgeInsetsZero;
        [self.contentBtn setTitle: @"" forState: UIControlStateNormal];
    } else if ([chatType isEqualToString:@"video"]) {
        // 视频
        // body = 视频地址

    } else if ([chatType isEqualToString:@"voice"]) {
        // 音频

    }
 */
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // 根据frame模型进行赋值
    self.timeLab.frame = self.chatFrame.timeFrame;
    self.userIconBtn.frame = self.chatFrame.iconFrame;
    self.contentBtn.frame = self.chatFrame.contentFrame;
    self.durationLab.frame = self.chatFrame.durationFrame;
}

// 头像按钮点击事件
- (void)showUserDetailInfo:(LongPressBtn *)btn {
    
}

// 聊天内容点击事件
- (void)showContextTextInfo:(LongPressBtn *)btn {
    
    NSString *chatType = self.chatFrame.msg.msg.message.body;
    if ([chatType isEqualToString:@"text"]) {
        // 文本 直接加载单元格
        
    } else if ([chatType isEqualToString:@"image"]) {
        // 图片
        // body = 图片地址
        if ([self.delegate respondsToSelector:@selector(getCurrentChatCell:withCurrentChatFrame:)]) {
            [self.delegate getCurrentChatCell:self withCurrentChatFrame:self.chatFrame];
        }
    } else if ([chatType isEqualToString:@"voice"]) {
        // 音频
        if ([self.delegate respondsToSelector:@selector(getCurrentChatCell:withCurrentChatFrame:)]) {
            [self.delegate getCurrentChatCell:self withCurrentChatFrame:self.chatFrame];
        }
    } else if ([chatType isEqualToString:@"file"]) {
        // 音频
        
    }
   
}


@end





