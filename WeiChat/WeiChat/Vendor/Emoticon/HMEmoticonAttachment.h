//
//  HMEmoticonAttachment.h
//  表情键盘
//
//  Created by 张泽楠 on 16/3/5.
//  Copyright © 2016年 张泽楠. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HMEmoticon;

@interface HMEmoticonAttachment : NSTextAttachment
@property (nonatomic, readonly) NSString *text;

/// 使用表情模型创建表情字符串
///
/// @param emoticon  表情模型
/// @param font      字体
/// @param textColor 颜色
///
/// @return 属性文本
+ (NSAttributedString *)emoticonStringWithEmoticon:(HMEmoticon * )emoticon font:(UIFont * )font textColor:(UIColor * )textColor;

@end
