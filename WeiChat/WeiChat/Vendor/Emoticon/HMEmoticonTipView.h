//
//  HMEmoticonTipView.h
//  表情键盘
//
//  Created by 张泽楠 on 16/3/5.
//  Copyright © 2016年 张泽楠. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HMEmoticon;

/// 表情提示视图
@interface HMEmoticonTipView : UIImageView
/// 表情模型
@property (nonatomic) HMEmoticon *emoticon;
@end
