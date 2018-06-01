//
//  HMEmoticon.h
//  表情键盘
//
//  Created by 张泽楠 on 16/3/3.
//  Copyright © 2016年 张泽楠. All rights reserved.
//

#import <Foundation/Foundation.h>

/// 表情模型
@interface HMEmoticon : NSObject

/// 表情类型 0 图片/1 emoji
@property (nonatomic, assign) NSInteger type;
/// 表情描述文字
@property (nonatomic, copy) NSString *chs;
/// 表情所在目录
@property (nonatomic, copy) NSString *directory;
/// 表情图片
@property (nonatomic, copy) NSString *png;
/// 图片表情路径
@property (nonatomic, readonly) NSString *imagePath;
/// emoji 编码
@property (nonatomic, copy) NSString *code;
/// emoji 字符串
@property (nonatomic, copy) NSString *emoji;
/// 是否 emoji
@property (nonatomic, readonly) BOOL isEmoji;
/// 使用次数
@property (nonatomic, assign) NSInteger times;

+ (instancetype)emoticonWithDict:(NSDictionary *)dict;

/// 保存使用的字典
- (NSDictionary * )dictionary;

@end
