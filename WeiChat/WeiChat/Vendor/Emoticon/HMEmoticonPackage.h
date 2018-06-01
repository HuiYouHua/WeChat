//
//  HMEmoticonPackage.h
//  表情键盘
//
//  Created by 张泽楠 on 16/3/3.
//  Copyright © 2016年 张泽楠. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HMEmoticon.h"

/// 表情包模型
@interface HMEmoticonPackage : NSObject

/// 表情包分组名
@property (nonatomic, copy) NSString *groupName;
/// 表情包所在目录
@property (nonatomic, copy) NSString *directory;
/// 表情包对应背景图片名称
@property (nonatomic, copy) NSString *bgImageName;
/// 表情包中的`表情模型`数组
@property (nonatomic) NSMutableArray *emoticonsList;

+ ( instancetype)packageWithDict:(NSDictionary * )dict;
- ( instancetype)initWithDict:(NSDictionary *)dict;

@end
