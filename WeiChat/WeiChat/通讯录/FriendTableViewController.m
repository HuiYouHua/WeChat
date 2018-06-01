//
//  FriendTableViewController.m
//  WeiChat
//
//  Created by haixuan on 16/8/10.
//  Copyright © 2016年 华惠友. All rights reserved.
//

#import "FriendTableViewController.h"
#import "XMPPManager.h"
#import "UserManager.h"

#import "FriendTableViewCell.h"
#import "SystemTableViewCell.h"

#import "XIAlertView.h"

#import "ChatViewController.h"

@interface FriendTableViewController ()<NSFetchedResultsControllerDelegate,XMPPRosterDelegate> {
    NSFetchedResultsController *_fetchedRequestC;
}

@property (nonatomic, strong) NSArray *systemArray;
@property (nonatomic, strong) NSMutableArray *friendsArray;

@end

@implementation FriendTableViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.tabBarController.tabBar.hidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SystemTableViewCell" bundle:nil] forCellReuseIdentifier:@"SystemTableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"FriendTableViewCell" bundle:nil] forCellReuseIdentifier:@"FriendTableViewCell"];
    [self getFirends];
}

#pragma mark -- 获取好友列表
- (void)getFirends {
    XMPPManager *manager = [XMPPManager sharedmanager];
    [manager.roster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    UserManager *user = [UserManager sharedmanager];
    // 通过XMPPRosterCoreDataStorage的数据库获得管理对象上下文
    NSManagedObjectContext *context = manager.rosterStorage.mainThreadManagedObjectContext;
    // 设置请求实体对象,在数据库中名为XMPPUserCoreDataStorageObject的一张表
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"XMPPUserCoreDataStorageObject"];
    // 设置谓词查询条件,用户名是自己的JID
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr=%@",user.jid];
    request.predicate = predicate;
    
    // 排序:按照用户名进行排序
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES]
    ;
    request.sortDescriptors = @[sort];
    
    _fetchedRequestC = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    _fetchedRequestC.delegate = self;

    NSError *error = nil;
    if ([_fetchedRequestC performFetch:&error]) {
        NSLog(@"%@",error);
    }
    [self.friendsArray removeAllObjects];
    [self.friendsArray addObjectsFromArray:_fetchedRequestC.fetchedObjects];
    [self.tableView reloadData];
    
    for (XMPPUserCoreDataStorageObject *obj in self.friendsArray) {
        //NSLog(@"%@ ++ %@ ++ %@", obj.jidStr, obj.nickname, obj.displayName);
    }
}

#pragma mark - NSFetchedResultsControllerDelegate
// 代理方法,当数据发生变化时调用该方法
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(nullable NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(nullable NSIndexPath *)newIndexPath {
    NSLog(@"数据发生变化");
    [self.friendsArray removeAllObjects];
    [self.friendsArray addObjectsFromArray:controller.fetchedObjects];
    for (XMPPUserCoreDataStorageObject *obj in self.friendsArray) {
        //NSLog(@"%@ -- %@ -- %@", obj.jidStr, obj.nickname, obj.displayName);
    }
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 4;
    } else {
        return self.friendsArray.count;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        SystemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SystemTableViewCell" forIndexPath:indexPath];
        cell.headImageV.image = [UIImage imageNamed:self.systemArray[0][indexPath.row]];
        cell.titleLab.text = self.systemArray[1][indexPath.row];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    if (indexPath.section == 1) {
        FriendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FriendTableViewCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        XMPPUserCoreDataStorageObject *obj = self.friendsArray[indexPath.row];
        cell.headImageV.image = obj.photo;
        cell.titleLab.text = obj.jidStr;
        switch ([obj.sectionNum intValue]) {
            case 0:
                cell.stateLab.text = @"在线";
                break;
            case 1:
                cell.stateLab.text = @"离开";
                break;
            case 2:
                cell.stateLab.text = @"离线";
                break;
        }
        return cell;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除好友";
}

#pragma mark -- 删除好友
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        XMPPUserCoreDataStorageObject *friend = self.friendsArray[indexPath.row];
        // 从服务器删
        [[XMPPManager sharedmanager].roster removeUser:friend.jid];
        // 从数组缓存中删
        [self.friendsArray removeObject:friend];
        // 从表中删
        [tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationFade];
    }
    
}

#pragma mark -- XMPPRosterDelegate监听好友请求,收到好友请求时调用该代理方法
- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence {
    XMPPRoster *roster = [XMPPManager sharedmanager].roster;
    NSString *message = [NSString stringWithFormat:@"%@请求添加你为好友",presence.from.user];
    XIAlertView *alertView = [[XIAlertView alloc] initWithTitle:@"提示" message:message cancelButtonTitle:@"拒绝"];
    [alertView addDefaultStyleButtonWithTitle:@"接收" handler:^(XIAlertView *alertView, XIAlertButtonItem *buttonItem) {
        if (buttonItem == 0) {
            [roster rejectPresenceSubscriptionRequestFrom:presence.from];
        } else {
            [roster acceptPresenceSubscriptionRequestFrom:presence.from andAddToRoster:YES];
        }
        [alertView dismiss];
    }];
    [alertView show];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    XMPPUserCoreDataStorageObject *obj = self.friendsArray[indexPath.row];
    ChatViewController *chatVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"];
    chatVC.jidChatTo = obj;
    //chatVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chatVC animated:YES];
}

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

#pragma mark -- 懒加载
- (NSArray *)systemArray {
    if (!_systemArray) {
        _systemArray = @[@[@"plugins_FriendNotify",@"add_friend_icon_addgroup",@"Contact_icon_ContactTag",@"add_friend_icon_offical",],@[@"新的朋友",@"群聊",@"标签",@"公众号",]];
    }
    return _systemArray;
}

- (NSMutableArray *)friendsArray {
    if (!_friendsArray) {
        _friendsArray = [NSMutableArray array];
    }
    return _friendsArray;
}



@end
