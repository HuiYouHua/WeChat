//
//  MoreFunctionView.h
//  WeiChat
//
//  Created by haixuan on 16/8/19.
//  Copyright © 2016年 华惠友. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^functionBtnClickIndexBlock)(NSInteger index);

@interface MoreFunctionView : UIView

@property (nonatomic, copy) functionBtnClickIndexBlock indexBolck;

@end
