//
//  popVoiceView.h
//  WeiChat
//
//  Created by haixuan on 16/8/18.
//  Copyright © 2016年 华惠友. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface popVoiceView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *voiceImageV;

@property (weak, nonatomic) IBOutlet UILabel *voiceTitleLab;

+ (instancetype)voiceAlertPopView;

@end
