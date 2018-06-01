//
//  FunctionBtn.h
//  WeiChat
//
//  Created by haixuan on 16/8/19.
//  Copyright © 2016年 华惠友. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FunctionBtn : UIButton

@property (weak, nonatomic) IBOutlet UIImageView *functionImageV;

@property (weak, nonatomic) IBOutlet UILabel *functionTileLab;

+ (instancetype)functionBtn;

@end
