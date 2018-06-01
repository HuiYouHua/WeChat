//
//  MeDetailTableViewController.m
//  WeiChat
//
//  Created by haixuan on 16/8/11.
//  Copyright © 2016年 华惠友. All rights reserved.
//

#import "MeDetailTableViewController.h"
#import "XIAlertView.h"

#import "XMPPManager.h"
#import "UserManager.h"

#define selfWith self.view.bounds.size.width
#define selfHeight self.view.bounds.size.height
#define selfBacground [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0]

@interface MeDetailTableViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *headerImageV;
@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet UILabel *weiXinNameLab;
@property (weak, nonatomic) IBOutlet UILabel *sexLab;
@property (weak, nonatomic) IBOutlet UILabel *addressLab;
@property (weak, nonatomic) IBOutlet UILabel *moodLab;

@end

@implementation MeDetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tabBarController.tabBar.hidden = YES;
    
    [self setCustomLeftButton];
    /**
     *  从电子名片的模型中获取自已用户信息的电子名片展示在个人信息中
     */
    XMPPManager *manager = [XMPPManager sharedmanager];
    XMPPvCardTemp *vCard = manager.vCardModule.myvCardTemp;
    self.nameLab.text = vCard.name;
    self.weiXinNameLab.text = [NSString stringWithFormat:@"微信号:  %@",[UserManager sharedmanager].loginName];
    self.headerImageV.image = [UIImage imageWithData:vCard.photo];
    self.sexLab.text = @"男";
    self.addressLab.text = [vCard.addresses lastObject];
    self.moodLab.text = @"天气不错";
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            UIAlertController *alertCut = [UIAlertController alertControllerWithTitle:@"请选择图片来源" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *takePhoto1 = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                XIAlertView *alertView = [[XIAlertView alloc] initWithTitle:@"提示" message:@"模拟器无法执行拍照功能" cancelButtonTitle:@"取消"];
                [alertView addDefaultStyleButtonWithTitle:@"确认" handler:^(XIAlertView *alertView, XIAlertButtonItem *buttonItem) {
                    [alertView dismiss];
                }];
                [alertView show];
            }];
            UIAlertAction *takePhoto2 = [UIAlertAction actionWithTitle:@"从手机相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                picker.allowsEditing = YES;
                picker.delegate = self;
                [self presentViewController:picker animated:YES completion:nil];
            }];
            UIAlertAction *takePhoto3 = [UIAlertAction actionWithTitle:@"保存图片" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                XIAlertView *alertView = [[XIAlertView alloc] initWithTitle:@"提示" message:@"我表示拒绝" cancelButtonTitle:@"取消"];
                [alertView addDefaultStyleButtonWithTitle:@"确认" handler:^(XIAlertView *alertView, XIAlertButtonItem *buttonItem) {
                    [alertView dismiss];
                }];
                [alertView show];
            }];
            UIAlertAction *cancelCutAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            }];
            [alertCut addAction:takePhoto1];
            [alertCut addAction:takePhoto2];
            [alertCut addAction:takePhoto3];
            [alertCut addAction:cancelCutAction];
            [self presentViewController:alertCut animated:YES completion:nil];
        }
    }
}

#pragma mark -- UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info; {
    UIImage *image = info[UIImagePickerControllerEditedImage];
    
    // 选取头像成功后需要手动将数据更新到服务器
    XMPPManager *manager = [XMPPManager sharedmanager];
    XMPPvCardTemp *vCard = manager.vCardModule.myvCardTemp;
    vCard.photo = UIImageJPEGRepresentation(image, 0.75);
    //vCard.nickname = @"华惠友";
    // 更新到服务器
    [manager.vCardModule updateMyvCardTemp:vCard];
    
    // 更换头像返回上个界面
    self.headerImageV.image = image;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setCustomLeftButton {
    UIView* leftButtonView = [[UIView alloc]initWithFrame:CGRectMake(-15, 0, 60, 40)];
    UIButton* leftButton = [UIButton buttonWithType:UIButtonTypeSystem];
    leftButton.backgroundColor = [UIColor clearColor];
    leftButton.frame = leftButtonView.frame;
    [leftButton setImage:[UIImage imageNamed:@"navigator_btn_back"] forState:UIControlStateNormal];
    [leftButton setTitle:@"我" forState:UIControlStateNormal];
    //leftButton.tintColor = [UIColor redColor];
    leftButton.autoresizesSubviews = YES;
    leftButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    leftButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
    [leftButton addTarget:self action:@selector(goToBack) forControlEvents:UIControlEventTouchUpInside];
    [leftButtonView addSubview:leftButton];
    UIBarButtonItem* leftBarButton = [[UIBarButtonItem alloc] initWithCustomView:leftButtonView];
    self.navigationItem.leftBarButtonItem = leftBarButton;
}

- (void)goToBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
