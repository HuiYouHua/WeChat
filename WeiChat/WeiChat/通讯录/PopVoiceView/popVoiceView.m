//
//  popVoiceView.m
//  WeiChat
//
//  Created by haixuan on 16/8/18.
//  Copyright © 2016年 华惠友. All rights reserved.
//

#import "popVoiceView.h"

@interface popVoiceView ()

@end
@implementation popVoiceView

+ (instancetype)voiceAlertPopView {
    return [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil].firstObject;
}

@end
