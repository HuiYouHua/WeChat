//
//  LongPressBtn.m
//  WeiChat
//
//  Created by haixuan on 16/8/15.
//  Copyright © 2016年 华惠友. All rights reserved.
//

#import "LongPressBtn.h"

@implementation LongPressBtn

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGesture:)];
        // 长按时间
        longPress.minimumPressDuration = 1.2;
        [self addGestureRecognizer:longPress];
    }
    return self;
}

- (void)longPressGesture:(UILongPressGestureRecognizer *)gesture {
    self.block(self);
}

@end
