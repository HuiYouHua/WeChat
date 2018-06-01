//
//  OtherViewController.m
//  WeiChat
//
//  Created by haixuan on 16/8/10.
//  Copyright © 2016年 华惠友. All rights reserved.
//

#import "OtherViewController.h"

#import "UserManager.h"
#import "XMPPManager.h"

#import "MBProgressHUD+ZY.h"

@interface OtherViewController ()
@property (weak, nonatomic) IBOutlet UITextField *nameTF;
@property (weak, nonatomic) IBOutlet UITextField *pswTF;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;

@end

@implementation OtherViewController

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.view endEditing:YES];
    //if ([self.nameTF becomeFirstResponder]) {
        [self.nameTF resignFirstResponder];
    //}
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

- (IBAction)contentChange:(UITextField *)sender {
    self.loginBtn.enabled = sender.text.length;
}
- (IBAction)textFieldChange:(UITextField *)sender {
    self.loginBtn.enabled = sender.text.length;
}

- (IBAction)loginBtn:(UIButton *)sender {
    [self.view endEditing:YES];
    
    UserManager *user = [UserManager sharedmanager];
    user.loginName = self.nameTF.text;
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

- (IBAction)cancelBtn:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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
