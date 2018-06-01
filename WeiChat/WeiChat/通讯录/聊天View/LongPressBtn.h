//
//  LongPressBtn.h
//  WeiChat
//
//  Created by haixuan on 16/8/15.
//  Copyright © 2016年 华惠友. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LongPressBtn;
typedef void(^LongPressBtnBlock)(LongPressBtn *btn);

@interface LongPressBtn : UIButton

@property (nonatomic, strong) LongPressBtnBlock block;

@end
