//
//  AddFriendTableViewController.m
//  WeiChat
//
//  Created by haixuan on 16/8/11.
//  Copyright © 2016年 华惠友. All rights reserved.
//

#import "AddFriendTableViewController.h"

#import "XMPPManager.h"
#import "UserManager.h"

#import "XIAlertView.h"

@interface AddFriendTableViewController ()

@property (weak, nonatomic) IBOutlet UITextField *searchTextField;

@end

@implementation AddFriendTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tabBarController.tabBar.hidden = YES;
    
    UIImageView *rightView = [[UIImageView alloc]init];
    rightView.image = [UIImage imageNamed:@"add_friend_searchicon"];
    rightView.frame = CGRectMake(20, 5, 25, 25);
    rightView.contentMode = UIViewContentModeCenter;
    self.searchTextField.leftView = rightView;
    self.searchTextField.leftViewMode = UITextFieldViewModeAlways;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)searchBtn:(UIButton *)sender {
    if ([self.searchTextField.text isEqualToString:[UserManager sharedmanager].loginName]) {
        [self showAlert:@"不能添加自己为好友"];
        return;
    }
    
    NSString *jidStr = [NSString stringWithFormat:@"%@@%@",self.searchTextField.text,kHostName];
    XMPPJID *jid = [XMPPJID jidWithString:jidStr];
    
    XMPPManager *manager = [XMPPManager sharedmanager];
    if ([manager.rosterStorage userExistsWithJID:jid xmppStream:manager.stream]) {
        [self showAlert:@"不能重复添加好友"];
        return;
    }
    
    [manager.roster subscribePresenceToUser:jid];
    [self showAlert:@"已发送添加好友请求"];
}

- (void)showAlert:(NSString *)str {
    XIAlertView *alertView = [[XIAlertView alloc] initWithTitle:@"提示" message:str cancelButtonTitle:@"取消"];
    [alertView addDefaultStyleButtonWithTitle:@"确认" handler:^(XIAlertView *alertView, XIAlertButtonItem *buttonItem) {
        [alertView dismiss];
    }];
    [alertView show];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}



#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of rows
//    return 0;
//}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
