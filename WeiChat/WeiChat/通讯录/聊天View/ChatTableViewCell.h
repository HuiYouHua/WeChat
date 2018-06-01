//
//  ChatTableViewCell.h
//  WeiChat
//
//  Created by haixuan on 16/8/15.
//  Copyright © 2016年 华惠友. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ChatTableViewCell;
@class ChatFrameModel;

@protocol ChatCellDelegate <NSObject>

@optional
/** 长按图片单元格时展示图片详情,返回单元格内容 */
- (void)getCurrentChatCell:(ChatTableViewCell *)cell withCurrentChatFrame:(ChatFrameModel *)chatFrameModel;

@end

@interface ChatTableViewCell : UITableViewCell

@property (nonatomic, strong) ChatFrameModel *chatFrame;
@property (nonatomic, weak) id<ChatCellDelegate> delegate;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end
