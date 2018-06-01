//
//  MoreFunctionView.m
//  WeiChat
//
//  Created by haixuan on 16/8/19.
//  Copyright © 2016年 华惠友. All rights reserved.
//

#import "MoreFunctionView.h"
#import "FunctionBtn.h"

@interface MoreFunctionView ()

@property (nonatomic, strong) NSArray *imageArray;
@property (nonatomic, strong) NSArray *titleArray;

@property (nonatomic, strong) NSMutableArray *btnArray;

@end

@implementation MoreFunctionView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:243/255.0 green:243/255.0 blue:243/255.0 alpha:1];
        // 创建按钮
        for (int i = 0; i < self.titleArray.count; i ++) {
            [self creatFunctionBtn:i];
        }
    }
    return self;
}

// 为按钮进行布局
- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat btnX;
    CGFloat btnY;
    CGFloat btnW = 60;
    CGFloat btnH = 80;
    // 视图宽
    CGFloat frameW = self.frame.size.width;
    // 视图高
    CGFloat frameH = self.frame.size.height;
    CGFloat sideW = 4;
    CGFloat marginX = (frameW - 2 * sideW - btnW * 4) / 5.0;
    CGFloat marginY = 10;
    for (int i = 0; i < self.btnArray.count; i ++) {
        FunctionBtn  *btn = self.btnArray[i];
        btnX = sideW + (marginX + btnW) * (i % 4) + marginX;
        btnY = 15 + (marginY + btnH) * (i / 4);
        btn.frame = CGRectMake(btnX, btnY, btnW, btnH);
    }
}

- (void)creatFunctionBtn:(NSInteger)index {
    FunctionBtn *btn = [FunctionBtn functionBtn];
    btn.functionImageV.image = [UIImage imageNamed:self.imageArray[index]];
    btn.functionTileLab.text = self.titleArray[index];
    btn.tag = index;
    [btn addTarget:self action:@selector(functionBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:btn];
    [self.btnArray addObject:btn];
}
// 返回点击的那个按钮
- (void)functionBtnClick:(FunctionBtn *)btn {
    self.indexBolck(btn.tag);
}

- (NSArray *)imageArray {
    if (!_imageArray) {
        _imageArray = [NSArray arrayWithObjects:@"zhaopian",@"paizhao",@"xiaoship",@"weizhi",@"shoucang",@"mingpian",@"yuyin", nil];
    }
    return _imageArray;
}

- (NSArray *)titleArray {
    if (!_titleArray) {
        _titleArray = [NSArray arrayWithObjects:@"照片",@"拍摄",@"小视频",@"位置",@"收藏",@"个人名片",@"语音输入", nil];
    }
    return _titleArray;
}

- (NSMutableArray *)btnArray {
    if (!_btnArray) {
        _btnArray = [NSMutableArray array];
    }
    return _btnArray;
}

@end
