//
//  FunctionBtn.m
//  WeiChat
//
//  Created by haixuan on 16/8/19.
//  Copyright © 2016年 华惠友. All rights reserved.
//

#import "FunctionBtn.h"

@implementation FunctionBtn

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (instancetype)functionBtn {
    return [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil].firstObject;
}

- (void)awakeFromNib {
    self.functionImageV.layer.borderWidth = 0.5;
    self.functionImageV.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.functionImageV.layer.cornerRadius = 5;
    self.functionTileLab.backgroundColor = [UIColor colorWithRed:243/255.0 green:243/255.0 blue:243/255.0 alpha:1];
}

@end
