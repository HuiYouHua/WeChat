//
//  UIColor+Hex.m
//  WeiChatDemo
//
//  Created by 张泽楠 on 16/6/7.
//  Copyright © 2016年 张泽楠. All rights reserved.
//

#import "UIColor+Hex.h"

@implementation UIColor (Hex)
+ (UIColor*)colorFromHexString:(NSString*)hexString {
    if (!hexString.length) {
        return nil;
    }
    
    unsigned int baseValue;
    NSScanner* scanner = [NSScanner scannerWithString:hexString];
    
    [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@" #"]];
    [scanner  scanHexInt:&baseValue];
    
    return  [UIColor colorWithRed:((baseValue & 0xff0000) >> 16)/255.0 green:((baseValue & 0xff00) >> 8)/255.0 blue:(baseValue & 0xff)/255.0 alpha:1.0];
}

@end
