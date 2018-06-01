//
//  ChatFrameModel.h
//  WeiChat
//
//  Created by haixuan on 16/8/15.
//  Copyright © 2016年 华惠友. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define kContentEdgeTop 15
#define kContentEdgeLeft 20
#define kContentEdgeBottom 25
#define kContentEdgeRight 20

@class ChatMessageModel;

@interface ChatFrameModel : NSObject

/** 会话对象 */
@property (nonatomic, strong) ChatMessageModel *msg;

/**>>>>>下面都是布局属性>>>>>>*/
/**
 *  因为每个控件的frame和cell的高度只允许外界使用，不能让别人更改，所有在声明这几个属性时，我们要给她们添加readonly(只生成set方法，不生成get方法)
 */
/** timeLab */
@property (nonatomic, assign, readonly) CGRect timeFrame;

/** 头像frame */
@property (nonatomic, assign, readonly) CGRect iconFrame;

/** 内容的frame */
@property (nonatomic, assign, readonly) CGRect contentFrame;

/** 语音时间的frame */
@property (nonatomic, assign, readonly) CGRect durationFrame;

/** cell高度 */
@property (nonatomic, assign, readonly) CGFloat cellH;
@end
