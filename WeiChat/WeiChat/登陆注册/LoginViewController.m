//
//  LoginViewController.m
//  WeiChat
//
//  Created by haixuan on 16/8/10.
//  Copyright © 2016年 华惠友. All rights reserved.
//

#import "LoginViewController.h"
#import "RegsitViewController.h"
#import "OtherViewController.h"

#import "XMPPManager.h"
#import "UserManager.h"

#import "MBProgressHUD+ZY.h"

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *headerImageV;
@property (weak, nonatomic) IBOutlet UILabel *headerID;
@property (weak, nonatomic) IBOutlet UITextField *pswTF;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@end

@implementation LoginViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.pswTF becomeFirstResponder];
    
    UserManager *user = [UserManager sharedmanager];
    [user readLoginInfo];
    if (user.loginName) {
        self.headerID.text = user.loginName;
    } else {
        self.headerID.text = user.registName;
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.loginBtn.enabled = NO;
    [self.loginBtn setBackgroundImage:[UIImage imageNamed:@"fts_green_btn"] forState:UIControlStateDisabled];
    [self.loginBtn setBackgroundImage:[UIImage imageNamed:@"fts_green_btn_HL"] forState:UIControlStateNormal];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if ([self.pswTF becomeFirstResponder]) {
        [self.view endEditing:YES];
    }
}

- (IBAction)contentChange:(UITextField *)sender {
    self.loginBtn.enabled = sender.text.length;
}

- (IBAction)loginBtn:(UIButton *)sender {
    // 存储登陆信息
    UserManager *user = [UserManager sharedmanager];
    user.loginName = self.headerID.text;
    user.loginPsw = self.pswTF.text;
    [user saveLoginInfo];
    
    [MBProgressHUD showMessage:@"正在登陆" toView:self.view];
    
    // 登陆
    XMPPManager *manager = [XMPPManager sharedmanager];
    [manager xmppUserLogin:^(XMPPUserStateType type) {
        [MBProgressHUD hideHUDForView:self.view animated:NO];
        switch (type) {
            case XMPPUserStateTypeSuccess:
                [MBProgressHUD showSuccess:@"登陆成功" toView:self.view];
                break;
            case XMPPUserStateTypeFaild:
                [MBProgressHUD showError:@"用户名或密码不对" toView:self.view];
                break;
            case XMPPUserStateTypeOther:
                [MBProgressHUD showError:@"当前网络状态不佳!稍后重试" toView:self.view];
                break;
        }
        double delayInSeconds = 3.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    }];
}

- (IBAction)moreBtn:(UIButton *)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cutAction = [UIAlertAction actionWithTitle:@"切换账号..." style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //[alert dismissViewControllerAnimated:YES completion:nil];
        
        UIAlertController *alertCut = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *phoneAction = [UIAlertAction actionWithTitle:@"手机号" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            OtherViewController *loginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"OtherViewController"];
            [self presentViewController:loginVC animated:YES completion:nil];
        }];
        UIAlertAction *WeiXinAction = [UIAlertAction actionWithTitle:@"微信号/邮箱地址/QQ号" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            OtherViewController *loginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"OtherViewController"];
            [self presentViewController:loginVC animated:YES completion:nil];
        }];
        UIAlertAction *cancelCutAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alertCut addAction:phoneAction];
        [alertCut addAction:WeiXinAction];
        [alertCut addAction:cancelCutAction];
        [self presentViewController:alertCut animated:YES completion:nil];
    }];
    UIAlertAction *registAction = [UIAlertAction actionWithTitle:@"注册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        RegsitViewController *loginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"RegsitViewController"];
        [self presentViewController:loginVC animated:YES completion:nil];
    }];
    UIAlertAction *safeAction = [UIAlertAction actionWithTitle:@"前往微信安全中心" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [MBProgressHUD showMessage:@"前往微信安全中心" toView:self.view];
        double delayInSeconds = 3.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:cutAction];
    [alert addAction:registAction];
    [alert addAction:safeAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
