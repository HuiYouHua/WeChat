//
//  HMEmoticonButton.h
//  表情键盘
//
//  Created by 张泽楠 on 16/3/5.
//  Copyright © 2016年 张泽楠. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HMEmoticon;

/// 表情按钮
@interface HMEmoticonButton : UIButton

+ (instancetype)emoticonButtonWithFrame:(CGRect)frame tag:(NSInteger)tag;
/// 是否删除按钮
@property (nonatomic, getter=isDeleteButton) BOOL deleteButton;
/// 表情模型
@property (nonatomic) HMEmoticon *emoticon;

@end
