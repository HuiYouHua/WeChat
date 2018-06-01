//
//  RegsitViewController.m
//  WeiChat
//
//  Created by haixuan on 16/8/10.
//  Copyright © 2016年 华惠友. All rights reserved.
//

#import "RegsitViewController.h"

#import "UserManager.h"
#import "XMPPManager.h"

#import "MBProgressHUD+ZY.h"

@interface RegsitViewController ()

@property (weak, nonatomic) IBOutlet UITextField *nameTF;
@property (weak, nonatomic) IBOutlet UIButton *registBtn;
@end

@implementation RegsitViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.nameTF becomeFirstResponder];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.registBtn.enabled = NO;
    
    [self.registBtn setBackgroundImage:[UIImage imageNamed:@"fts_green_btn"] forState:UIControlStateDisabled];
    [self.registBtn setBackgroundImage:[UIImage imageNamed:@"fts_green_btn_HL"] forState:UIControlStateNormal];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}


- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if ([self.nameTF becomeFirstResponder]) {
        [self.view endEditing:YES];
    }
}

- (IBAction)contentChange:(UITextField *)sender {
    self.registBtn.enabled = sender.text.length;
}

- (IBAction)registBtn:(UIButton *)sender {
    UserManager *user = [UserManager sharedmanager];
    // 设置loginName和loginPsw为nil是为了在授权登录时判断是登陆还是注册
    user.loginName = nil;
    user.loginPsw = nil;
    [user saveLoginInfo];

    // 保存注册信息,在注册的时候取出注册信息进行注册
    user.registName = self.nameTF.text;
    user.registPsw = self.nameTF.text;
    [user saveRegistInfo];
    
    [MBProgressHUD showMessage:@"正在注册" toView:self.view];
    
    [[XMPPManager sharedmanager] xmppUserRegist:^(XMPPUserStateType type) {
        [MBProgressHUD hideHUDForView:self.view animated:NO];
        
        switch (type) {
            case XMPPUserStateTypeSuccess:
                // 注册成功后返回登陆界面进行登陆
                [MBProgressHUD showSuccess:@"注册成功" toView:self.view];
                [self dismissViewControllerAnimated:YES completion:nil];
                break;
            case XMPPUserStateTypeFaild:
                [MBProgressHUD showError:@"该用户名已经被注册了" toView:self.view];
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
