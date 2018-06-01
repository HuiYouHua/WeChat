//
//  XMPPManager.m
//  WeiChat
//
//  Created by haixuan on 16/8/10.
//  Copyright © 2016年 华惠友. All rights reserved.
//

#import "XMPPManager.h"
#import "UserManager.h"

// 流代理,名片代理,头像代理
@interface XMPPManager ()<XMPPStreamDelegate,XMPPvCardTempModuleDelegate,XMPPvCardAvatarDelegate>

@end

@implementation XMPPManager
#pragma mark 创建XMPPManager单例类
singleton_m(manager)

#pragma mark 创建XMPPStream对象
// 登录注册什么的都是和服务器交互,所以我们用到的类就是XMPPStream
- (void)connect {
    if (!self.stream) {
        // 创建XMPPStream,只需要初始化一次,所以加判断
        self.stream = [[XMPPStream alloc] init];
        // 设置stream的域名和端口号
        self.stream.hostName = kHostName;
        self.stream.hostPort = kHostPort;
        // 添加代理 连接成功后调用传密码的方法
        [self.stream addDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        /**
         *  XMPPvCardCoreDataStorage和XMPPvCardTempModule模块的激活与设置代理
         */
        self.vCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
        self.vCardModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:self.vCardStorage];
        [self.vCardModule activate:self.stream];
        [self.vCardModule addDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        /**
         *  XMPPvCardAvatarModule模块激活与设置代理
         */
        self.vCardAvatar = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:self.vCardModule];
        [self.vCardAvatar activate:self.stream];
        [self.vCardAvatar addDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        /**
         *  XMPPReconnect模块激活
         */
        self.reconnect = [[XMPPReconnect alloc] init];
        [self.reconnect activate:self.stream];
        
        /**
         *  XMPPRoster模块激活
         */
        self.rosterStorage = [XMPPRosterCoreDataStorage sharedInstance];
        self.roster = [[XMPPRoster alloc] initWithRosterStorage:self.rosterStorage];
        [self.roster activate:self.stream];
        
        /**
         *  XMPPMessageArchiving聊天模块激活
         */
        self.archivingStorage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
        self.messageArchiving = [[XMPPMessageArchiving alloc] initWithMessageArchivingStorage:self.archivingStorage dispatchQueue:dispatch_get_main_queue()];
        [self.messageArchiving activate:self.stream];
        
        // 允许后台Socket
        self.stream.enableBackgroundingOnSocket = YES;
    }
}

- (void)connectToServer {
    // 判断是否连接成功过
    if (![self.stream isConnected]) {
        // 连接到服务器
        NSError *error;
        [self.stream connectWithTimeout:XMPPStreamTimeoutNone error:&error];
        if (error) {
            NSLog(@"%@",error);
        } else {
            // 连接成功则会自动调用XMPPStreamDelegatexmppStreamDidConnect 代理方法
            // 然后在通过代理方法调用 XMPPStream的发送密码的方法authenticateWithPassword
            NSLog(@"连接成功");
        }
        // 状态1 表示正在连接
        [[NSNotificationCenter defaultCenter] postNotificationName:kLoginStateNotification object:nil userInfo:@{@"state":@"1"}];
    }
}

#pragma mark ******************************
#pragma mark -- 用户登陆,使用登陆JID用户名
- (void)xmppUserLogin:(UserSatateBlock)block {
    // block赋值给全局变量,在代理方法中调用block传递登陆信息
    self.block = block;
    
    // 不管登陆几次,每次登陆之前都要先把连接断开
    [self.stream disconnect];
    
    // 初始化XMPPPStream
    [self connect];
    
    /**
     *  因为在调用之前,在userDefault中存储的是登陆用户的名字
        所以在这里获取用户的名字
     */
    UserManager *user = [UserManager sharedmanager];
    [user readLoginInfo];
    // 设置XMPPStream的JID   : yoyu@127.0.0.1.iPhone
    self.stream.myJID = [XMPPJID jidWithUser:user.loginName domain:kHostName resource:@"iPhone"];
    
    // 通过读取UserDefault中的name连接服务器
    [self connectToServer];
}

#pragma mark -- 用户注册,使用注册JID用户名
- (void)xmppUserRegist:(UserSatateBlock)block {
    self.block = block;
    
    // 不管登陆几次,每次登陆之前都要先把连接断开
    [self.stream disconnect];
    
    // 初始化XMPPPStream
    [self connect];
    
    /**
     *  因为在调用之前,在userDefault中存储的是注册用户的名字
        所以在这里获取用户的名字
     */
    UserManager *user = [UserManager sharedmanager];
    [user readRegistInfo];
    // 设置XMPPStream的JID   : yoyu@127.0.0.1.iPhone
    self.stream.myJID = [XMPPJID jidWithUser:user.registName domain:kHostName resource:@"iPhone"];
    
    // 通过读取UserDefault中的name连接服务器
    [self connectToServer];
}

#pragma mark -- 用户注销
- (void)xmppUserLogout {
    // 发送离线状态
    [self sendOfflineMessage];
    
    // 断开连接
    [self.stream disconnect];
    
    // 跳转到登陆界面
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"LoginAndRegist" bundle:nil];
    window.rootViewController = [storyBoard instantiateInitialViewController];
}

#pragma mark -- 回调获得用户头像
- (void)xmppGetUserHeaderImage:(ImageBlock)block {
    self.imageBlock = block;
}

#pragma mark ******************************
#pragma mark -- XMPPStreamDelegate
/**
 *  登录的流程：
    xmpp的登录流程是， 传递 JID , Host , Port 先连接上服务器 ，连接成功了 再 发送密码到服务器 ，授权成功 或者 授权失败
 
    注册的流程：
    xmpp的注册流程是， 传递 JID , Host , Port 先连接上服务器 ，连接成功了 再 发送注册密码到服务器 ，注册成功 或者 失败
 
    共同点：
    不管你jid存不存在 都能连接到服务器。
 
    不同点:
    发送的是授权密码 还是 发送注册密码 就是决定你是登录还是注册

 */
/**
    通过JID连接成功
 *  连接成功则会自动调用XMPPStreamDelegatexmppStreamDidConnect 代理方法
    然后在通过代理方法调用 XMPPStream的发送密码的方法authenticateWithPassword
 */
#pragma mark -- 连接成功
- (void)xmppStreamDidConnect:(XMPPStream *)sender {
    NSLog(@"通过JID建立连接成功");
    /**
     *  发送密码进行授权登陆
        分登陆密码
        和注册密码
        需要判断
     */
    UserManager *user = [UserManager sharedmanager];
    //[user readUserInfo];
    NSError *error = nil;
    NSLog(@"%@",user.loginName);
    NSLog(@"---%@",user.registName);
    if (user.loginName) {
        // 发送登陆密码
        [self.stream authenticateWithPassword:user.loginPsw error:&error];
    } else {
        // 发送注册密码
        [self.stream registerWithPassword:user.registPsw error:&error];
    }
    
    // 发送通知:状态2表示连接服务器成功
    [[NSNotificationCenter defaultCenter] postNotificationName:kLoginStateNotification object:nil userInfo:@{@"state":@"2"}];
}

#pragma mark -- 连接失败,与服务器断开连接(例如网络原因)
- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error {
    NSLog(@"通过JID建立连接失败,与服务器断开连接");
    if (self.block) {
        self.block(XMPPUserStateTypeOther);
    }
    
    // 发送通知:状态2表示连接服务器失败
    [[NSNotificationCenter defaultCenter] postNotificationName:kLoginStateNotification object:nil userInfo:@{@"state":@"3"}];
}

/**
 *  属于登陆方面
 */
#pragma mark -- 授权登陆成功
-(void)xmppStreamDidAuthenticate:(XMPPStream *)sender{
    NSLog(@"授权登陆成功");
    if (self.block) {
        self.block(XMPPUserStateTypeSuccess);
    }
    
    // 授权登陆成功后,跳转到主界面
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    window.rootViewController = [storyBoard instantiateInitialViewController];
    
    // 同时要发送一个在线的信息
    [self sendOnlineMessage];
    
    
}

#pragma mark -- 授权登陆失败
-(void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error{
    NSLog(@"授权登陆失败");
    if (self.block) {
        self.block(XMPPUserStateTypeFaild);
    }
    
    
}

/**
 *  属于注册方面
 */
#pragma mark -- 注册成功
- (void)xmppStreamDidRegister:(XMPPStream *)sender{
    NSLog(@"注册成功");
    if (self.block) {
        self.block(XMPPUserStateTypeSuccess);
    }
}

#pragma mark -- 注册失败
- (void)xmppStream:(XMPPStream *)sender didNotRegister:(NSXMLElement *)error{
    NSLog(@"注册失败");
    if (self.block) {
        self.block(XMPPUserStateTypeFaild);
    }
}

// 收到消息调用这个 方法
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
    // 前台
    // 后台
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        // 后台
        if (message.body.length > 0) {
            static int messageCount = 1;
            [UIApplication sharedApplication].applicationIconBadgeNumber = messageCount;
            messageCount ++;
            
            // 本地通知
            UILocalNotification *localNote = [[UILocalNotification alloc] init];
            // 设置通知内容
            localNote.alertBody = [NSString stringWithFormat:@"%@\n%@",message.fromStr,message.body];
            // 设置时间
            localNote.fireDate = [NSDate date];
            // 设置声音
            localNote.soundName = @"default";
            // 执行
            [[UIApplication sharedApplication] scheduleLocalNotification:localNote];
        } else {
            
        }
        
        
    } else {
        // 前台:什么也不做
        
    }
}

#pragma mark ******************************
#pragma mark - 登陆成功后,给服务器发送一个在线消息:上线了
/**
    presence表示用户状态
 
   presence 的状态：
        available 上线
        away 离开
        do not disturb 忙碌
        unavailable 下线
 */
- (void)sendOnlineMessage {
    /**
     *  关于用户的上线和下线，需要用到一个类XMPPPresence 类。这个类是XMPPElement的子类，主要用来管理某些信息的展现。首先要实例化一个对象，这其中会用到一个presenceWithType 方法，有两个选择@"unavailable"代表下线，@"available"代表上线，一般情况上线的时候后面就可以直接省略。
     */
    XMPPPresence *pre = [XMPPPresence presenceWithType:@"available"];
    // XMPPPresence *pre = [XMPPPresence presence];
    [self.stream sendElement:pre];
}

#pragma mark - 离线时,给服务器发送一个在线消息:下线了
- (void)sendOfflineMessage {
    XMPPPresence *pre = [XMPPPresence presenceWithType:@"unavailable"];
    [self.stream sendElement:pre];
}

#pragma mark -- XMPPvCardTempModuleDelegate名片代理
/**
 *  当用户名片信息发生改变时,调用该方法
 */
- (void)xmppvCardTempModule:(XMPPvCardTempModule *)vCardTempModule
        didReceivevCardTemp:(XMPPvCardTemp *)vCardTemp
                     forJID:(XMPPJID *)jid {
    // 打印用户信息
    XMPPvCardTemp *temp = [self.vCardStorage vCardTempForJID:jid xmppStream:self.stream];
    //NSLog(@"%@",temp);
}

#pragma mark ******************************
#pragma mark -- XMPPvCardAvatarDelegate名片代理
/**
 *  当用户名片头像发生改变时,调用该方法
 */
- (void)xmppvCardAvatarModule:(XMPPvCardAvatarModule *)vCardTempModule
              didReceivePhoto:(UIImage *)photo
                       forJID:(XMPPJID *)jid {
    NSLog(@"头像发生变化");
    if (self.imageBlock) {
        self.imageBlock(photo);
    }
}

- (void)xmppStream:(XMPPStream *)sender didFailToSendMessage:(XMPPMessage *)message error:(NSError *)error {
    NSLog(@"发送失败");
}

- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message {
    NSLog(@"发送成功");
}


@end
