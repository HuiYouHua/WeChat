
//
//  ChatViewController.m
//  WeiChat
//
//  Created by haixuan on 16/8/11.
//  Copyright © 2016年 华惠友. All rights reserved.
//

#import "ChatViewController.h"
#import "UserManager.h"

#import "ChatFrameModel.h"
#import "ChatMessageModel.h"
#import "ChatTableViewCell.h"

#import "MWPhotoBrowser.h"

#import "popVoiceView.h"

#import <AVFoundation/AVFoundation.h>

#import "MoreFunctionView.h"

#define kRecordAudioFile @"myRecord.wav"

#define BackGround243Color [UIColor colorWithRed:243/255.0 green:243/255.0 blue:243/255.0 alpha:1]

#define kMoreInputViewOriFrame CGRectMake(0, [UIScreen mainScreen].bounds.size.height, CGRectGetWidth(self.view.bounds), 200)

@interface ChatViewController ()<UITextViewDelegate,UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource,NSFetchedResultsControllerDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate,MWPhotoBrowserDelegate,ChatCellDelegate,AVAudioRecorderDelegate,AVAudioPlayerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *myTab;
@property (weak, nonatomic) IBOutlet UITextView *chatTextView;
@property (weak, nonatomic) IBOutlet UIButton *sendVoiceBtn;
@property (weak, nonatomic) IBOutlet UIButton *sendFileBtn;
@property (weak, nonatomic) IBOutlet UIButton *emotionBtn;
@property (weak, nonatomic) IBOutlet UIButton *voiceBtn;
// 输入栏底部
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputViewBottonConstraint;

@property (weak, nonatomic) IBOutlet UIView *inputView;

// 存放聊天内容
@property (nonatomic, strong) NSMutableArray *chatMsgArray;
@property (nonatomic, strong) NSFetchedResultsController *resultController;
// 存放图片聊天内容
@property (nonatomic, strong) NSMutableArray *chatImageArray;
// 语音发送提示框
@property (nonatomic, strong) popVoiceView *voiceView;

// 录音机
@property (nonatomic, strong) AVAudioRecorder *audioRecorder;
// 音频播放器
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

// 更多视图
@property (nonatomic, strong) MoreFunctionView *moreView;

@end

@implementation ChatViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
    self.sendVoiceBtn.hidden = YES;
    
    [self moreView];
}

// 视图出现时,滚动到会话最底端
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self scrollToBottom];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self dissmissMoreInputViewWithAniation:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initWithTableView];
    [self initWithKeyboard];
    [self setAudioSession];
    [self initWithSendVoiceBtn];
}

// tableView的初始化操作
- (void)initWithTableView {
    self.myTab.backgroundColor = BackGround243Color;
    self.myTab.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.chatTextView.delegate = self;
    self.myTab.delegate = self;
    self.myTab.dataSource = self;
    
    [self.myTab registerClass:[ChatTableViewCell class] forCellReuseIdentifier: NSStringFromClass([self class])];
    
    // 获取聊天信息
    [self relodChatMessage];
}

- (void)initWithKeyboard {
    // 监听键盘弹出,对相应的布局做修改
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    //[self observerKeyboardFrameChange];
    
    // 点击空白地区收起键盘
    [self setupForTabelView];
}

- (void)initWithSendVoiceBtn {
    self.sendVoiceBtn.backgroundColor =  BackGround243Color;
    self.sendVoiceBtn.layer.borderWidth = 0.5;
    self.sendVoiceBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.sendVoiceBtn.layer.cornerRadius = 3;
}

#pragma mark ******************************
#pragma mark -- UITableViewDelegate,UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.chatMsgArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ChatTableViewCell *cell = [ChatTableViewCell cellWithTableView:tableView];
    cell.delegate = self;
    // frame模型中拥有数据模型,直接赋值frame模型即可
        // MVVM设置模式:两个模型类,剥离业务逻辑
    cell.chatFrame = self.chatMsgArray[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    ChatFrameModel *frameModel = self.chatMsgArray[indexPath.row];
    return frameModel.cellH;
}

#pragma mark ******************************
#pragma mark -- 获取聊天内容
- (void)relodChatMessage {
    XMPPManager *manager = [XMPPManager sharedmanager];
    NSManagedObjectContext *context = manager.archivingStorage.mainThreadManagedObjectContext;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPMessageArchiving_Message_CoreDataObject"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr=%@ AND bareJidStr=%@",[UserManager sharedmanager].jid,self.jidChatTo.jid.bare];
    
    NSSortDescriptor *timeSort = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    request.sortDescriptors = @[timeSort];
    request.predicate = predicate;
    
    self.resultController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    self.resultController.delegate = self;
    NSError *error = nil;
    if ([self.resultController performFetch:&error]) {
        NSLog(@"%@",error);
    }
    //NSLog(@"-----%@",self.resultController.fetchedObjects);
    [self getChatMsgArray];
}

#pragma mark - NSFetchedResultsControllerDelegate
// 代理方法,当数据发生变化时调用该方法
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(nullable NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(nullable NSIndexPath *)newIndexPath {
    [self relodChatMessage];
}

// 此处获取数据库中的会话数组,对模型类进行赋值,并且设置其单个会话的frame
/**
 *  采用MVVM的设计模式
    提供两个模型:
        >数据模型：存放文字数据\图片数据
        >frame模型：存放数据模型\所有子控件的frame\cell的高度
    其中cell直接拥有一个frame模型(不要直接拥有数据模型).即:使fram模型拥有数据模型
    在cell赋值的时候直接赋值frame模型
 */
- (void)getChatMsgArray {
    [self.chatMsgArray removeAllObjects];
    for (XMPPMessageArchiving_Message_CoreDataObject *msg in self.resultController.fetchedObjects) {
        
        ChatMessageModel *messageModel = [[ChatMessageModel alloc] init];
        // 将模型中的上一条信息的时间戳取出来放到数据模型中处理
        if (self.chatMsgArray.count) {
            ChatFrameModel *preChatFrameModel = self.chatMsgArray.lastObject;
            messageModel.preMsgDate = preChatFrameModel.msg.msg.timestamp;
        }
        // 数据模型的setter
        messageModel.msg = msg;
        
        ChatFrameModel *frameModel = [[ChatFrameModel alloc] init];
        // frame模型的setter
        frameModel.msg = messageModel;
        [self.chatMsgArray addObject:frameModel];
 
        // 图片浏览器
        if ([msg.message.body isEqualToString:@"image"]) {
            XMPPElement *node = msg.message.children.lastObject;
            // 取出消息的解码
            NSString *base64str = node.stringValue;
            NSData *data = [[NSData alloc]initWithBase64EncodedString:base64str options:0];
            UIImage *image = [[UIImage alloc]initWithData:data];
            [self.chatImageArray addObject:image];
        } 
    }
    [self.myTab reloadData];
    [self scrollToBottom];
}

#pragma mark ******************************
/**
 *  自定义类型,为以后接收信息时进行区分信息类型
    addAttributeWithName: stringValue:
 *  text:表示文本
 *  image:表示图片
 *  voice:表示音频
 *  video:表示视频
 */
#pragma mark - TextView的代理方法 点击renturn发送信息
#pragma mark 发送文字聊天信息
- (void)textViewDidChange:(UITextView *)textView {
    if ([textView.text hasSuffix:@"\n"]) {
        NSLog(@"已经发送消息");
        [self sendMessageWithText:textView.text bodyType:@"text"];
        textView.text = nil;
    }
}

- (void)sendMessageWithText:(NSString *)text bodyType:(NSString *)type {
//    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:self.jidChatTo.jid];
//    // 设置bodyType为text
//    [message addAttributeWithName:@"bodyType" stringValue:type];
//    [message addBody:text];
//    [[XMPPManager sharedmanager].stream sendElement:message];
    
    XMPPMessage* message = [[XMPPMessage alloc] initWithType:@"chat" to:self.jidChatTo.jid];
    
    [message addBody:type];
    
    // 设置节点内容
    XMPPElement *attachment = [XMPPElement elementWithName:@"attachment" stringValue:text];
    // 包含子节点
    [message addChild:attachment];
    [[XMPPManager sharedmanager].stream sendElement:message];
    
}

#pragma mark ******************************
#pragma mark - 发送语音聊天信息
- (IBAction)sendVoiceBtn:(UIButton *)sender {
    if (CGRectGetMaxY(self.moreView.frame) == [UIScreen mainScreen].bounds.size.height) {
        self.moreView.frame = kMoreInputViewOriFrame;
        [self.chatTextView resignFirstResponder];
    }
    if (self.inputViewBottonConstraint.constant == 200) {
        [self.chatTextView becomeFirstResponder];
        [self dissmissMoreInputViewWithAniation:YES];
    }
    if (!self.sendVoiceBtn.hidden) {
        [self.chatTextView becomeFirstResponder];
        //self.inputViewBottonConstraint.constant = 0;
    } else {
        if ([self.chatTextView isFirstResponder]) {
            [self.chatTextView resignFirstResponder];
        }
    }
    self.sendVoiceBtn.hidden = sender.selected;
    sender.selected = !sender.selected;
    UIImage *normalImage = sender.selected ? [UIImage imageNamed:@"ToolViewKeyboard"] : [UIImage imageNamed:@"ToolViewInputVoice"];
    UIImage *highlightImage = sender.selected ? [UIImage imageNamed:@"ToolViewKeyboardHL"] : [UIImage imageNamed:@"ToolViewInputVoiceHL"];
    [sender setImage:normalImage forState:UIControlStateNormal];
    [sender setImage:highlightImage forState:UIControlStateHighlighted];
}

// 在按钮上按下按钮开始录音
- (IBAction)sendTouchDown:(UIButton *)sender {
    NSLog(@"%s, line = %d", __FUNCTION__, __LINE__);
    self.sendVoiceBtn.backgroundColor = [UIColor lightGrayColor];
    // 设置提示框
    popVoiceView *voiceV = [popVoiceView voiceAlertPopView];
    voiceV.bounds = CGRectMake(0, 0, 150, 150);
    CGFloat centerX = [UIScreen mainScreen].bounds.size.width / 2.0;
    CGFloat centerY = [UIScreen mainScreen].bounds.size.height / 2.0;
    voiceV.center = CGPointMake(centerX, centerY);
    self.voiceView = voiceV;
    [self.view addSubview:self.voiceView];
    
    // 录音
    [self.audioRecorder record];
}

// 在按钮上抬起手指发送语音
- (IBAction)sendTouchUpInside:(UIButton *)sender {
    NSLog(@"%s, line = %d", __FUNCTION__, __LINE__);
    self.sendVoiceBtn.backgroundColor = BackGround243Color;
    NSTimeInterval time = self.audioRecorder.currentTime;
    
    if (time < 1.5) {
        // 时间小于1.5秒不发送,大于1.5秒才发送
        // 停止录音
        [self.audioRecorder stop];
        // 删除录音文件
        [self.audioRecorder deleteRecording];
        
        self.voiceView.voiceImageV.image = [UIImage imageNamed:@"QQ20160818-3"];
        self.voiceView.voiceTitleLab.text = @"说话时间太短";
        
    } else {
        // 停止录音
        [self.audioRecorder stop];
        
        // 发送语音
        NSString *urlStr = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        urlStr = [urlStr stringByAppendingPathComponent:kRecordAudioFile];
        NSData *voiceData = [NSData dataWithContentsOfFile:urlStr];
        [self sendVoiceMessageWithData:voiceData bodyType:@"voice" withDuringTime:time];
    }
    
    [self.voiceView removeFromSuperview];

}
- (void)sendVoiceMessageWithData:(NSData *)data bodyType:(NSString *)type withDuringTime:(NSTimeInterval)time{
    XMPPMessage* message = [[XMPPMessage alloc] initWithType:@"chat" to:self.jidChatTo.jid];
    // 将时间传过去
    NSString *timeStr = [NSString stringWithFormat:@"%f",time];
    [message addAttributeWithName:@"duringTime" stringValue:timeStr];
    [message addBody:type];

    NSString *base64str = [data base64EncodedStringWithOptions:0];

    XMPPElement *attachment = [XMPPElement elementWithName:@"attachment" stringValue:base64str];

    [message addChild:attachment];
    [[XMPPManager sharedmanager].stream sendElement:message];
}


// 手指拖到按钮外面将要取消录音
- (IBAction)sendDragOutside:(UIButton *)sender {
    NSLog(@"%s, line = %d", __FUNCTION__, __LINE__);
    self.voiceView.voiceImageV.image = [UIImage imageNamed:@"QQ20160818-2"];
    self.voiceView.voiceTitleLab.text = @"松开手指, 取消发送";
    self.voiceView.voiceTitleLab.backgroundColor = [UIColor colorWithRed:0.826 green:0.0 blue:0.0 alpha:1.0];
}

// 在按钮外面抬起手指取消录音
- (IBAction)sendTouchUpOutside:(UIButton *)sender {
    NSLog(@"%s, line = %d", __FUNCTION__, __LINE__);
    [self.voiceView removeFromSuperview];
    
    // 停止录音
    [self.audioRecorder stop];
    // 删除录音文件
    [self.audioRecorder deleteRecording];
}

// 设置音频保存路径
- (NSURL *)getSavePath {
    NSString *urlStr = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    urlStr = [urlStr stringByAppendingPathComponent:kRecordAudioFile];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    return url;
}

/**
 *  设置音频会话
    注意:一定要添加音频会话,不然真机上的录音时间不对,并且不能进行播放音频
 */
-(void)setAudioSession{
    AVAudioSession *audioSession=[AVAudioSession sharedInstance];
    //设置为播放和录音状态，以便可以在录制完之后播放录音
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [audioSession setActive:YES error:nil];
}

// 录音文件设置
- (NSDictionary *)getAudioSetting {
    NSMutableDictionary *dicM = [NSMutableDictionary dictionary];
    // 设置录音格式
    [dicM setObject:@(kAudioFormatLinearPCM) forKey:AVFormatIDKey];
    // 设置录音采样率,8000是电话采样率,对于一般录音已经够了
    [dicM setObject:@(8000) forKey:AVSampleRateKey];
    // 设置通道,这里采用单声道
    [dicM setObject:@(1) forKey:AVNumberOfChannelsKey];
    // 每个采样点位数,分别为8,16,24,32
    [dicM setObject:@(8) forKey:AVLinearPCMBitDepthKey];
    // 是否使用浮点数采样
    [dicM setObject:@(YES) forKey:AVLinearPCMIsFloatKey];
    // ...其他设置
    return dicM;
}

#pragma mark -- AVAudioRecorderDelegate
// 录音完成
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    //NSLog(@"录音完毕");
}
#pragma mark -- AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    NSLog(@"播放完毕");
}

#pragma mark ******************************
#pragma mark -- 发送表情聊天信息
- (IBAction)sendEmoticonBtn:(UIButton *)sender {
    
}

#pragma mark ******************************
#pragma mark -- 发送文件信息
/**
 *  发送文件:点击发送文件按钮,在键盘位置弹出一个MoreView,显示7个小模块,分别对应不同的功能.
 1.自定义一个FunctionBtn继承自UIButon的类,目的用于显示MoreView中的小单元格.在该类中添加一个imageView和一个Label,用来显示单元格内容.
 2.自定义一个MoreFunctionView用来显示MoreView中的内容,在该类用利用FunctionBtn创建对应的7个按钮,并进行赋值和布局.
 3.在该控制器内创建MoreView进行展示.
 
 其中对于键盘位置的处理:MoreView的高度为200
 1.创建MoreView,先将其frame放到屏幕外面,并放在键盘的视图上
 2.点击添加文件按钮时需要注意以下几点:
    1)首先输入框的下边的约束inputViewBottonConstraint为0,当点击添加文件按钮时,弹出MoreView,inputViewBottonConstraint变为200;
    2)再次点击添加文件按钮时,需修改moreView的frame,同时输入框变为第一响应者,键盘弹出,可以输入相应内容.
    3)第三次点击添加文件按钮时,取消输入框的第一响应者,键盘收回,同时MoreView弹出,状态跟1)中一样.
    4)在三的步骤后,如果点击输入框,同样出现2)中的现象,键盘弹出,moreView坐标改变.
    5)同时,无论是键盘出现还是moreView出现,当点击语音按钮时,所有的视图都应收回,显示按住说话这个button.
    6)点击空白地方时同5)
    7)具体内容变测试边修改.
    8)对于其状态的判断可以使用inputViewBottonConstraint,moreView的最大Y坐标等内容进行区分状态.

 */
- (IBAction)sendFileBtn:(UIButton *)sender {
    
    
    if (!self.sendVoiceBtn.hidden) {
        self.sendVoiceBtn.hidden = !self.voiceBtn.hidden;
    }
    if (self.inputViewBottonConstraint.constant == 0) {
        [self popMoreView];
    }else
    {
        if (self.inputViewBottonConstraint.constant == 200) {
            [self dissmissMoreInputViewWithAniation:YES];
            
            [self.chatTextView becomeFirstResponder];
        } else {
            [self.chatTextView resignFirstResponder];
            [self popMoreView];
        }
    }
    
}

- (void)popMoreView {
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        CGFloat moreViewH = 200;
        self.inputViewBottonConstraint.constant = moreViewH;
        
        CGFloat moreViewY = [UIScreen mainScreen].bounds.size.height  - moreViewH;
        CGFloat moreViewW = [UIScreen mainScreen].bounds.size.width;
        self.moreView.frame = CGRectMake(0, moreViewY, moreViewW, moreViewH);
        
        [self scrollToBottom];
        //
    } completion:^(BOOL finished) {
        //
    }];
}

#pragma mark -- UINavigationControllerDelegate, UIImagePickerControllerDelegate
// 进入UIImagePickerController选择图片,选择好后发送图片
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    NSData *imageData = UIImagePNGRepresentation(image);
    [self sendMessageWithData:imageData bodyType:@"image"];
    [self dismissViewControllerAnimated:YES completion:nil];
}

// 发送图片
#warning 传送图片需将发送的图片上传至服务器,返回一个URL,通过传URL的方式传图片,接收方获得URL后进行下载即可
/**
 *  发送图片,语音,视频消息有两种方式:
    1.发送消息只需要调用xmpp的sendElement:方法，由于xmpp只支持文本，所以假如你想发送二进制的文件，比如语音图片等，可以先压缩然后用base64编码，接收方收到再做解码工作，比如语音可以压缩成amr格式，amr格式安卓可以直接播放，iOS需要在解压成wav格式.

    2.但是采用这种方式会造成XML携带的数据量太大,对openFire服务器造成的压力太大,所以一般都选择一个文件服务器,首先将文件上传到文件服务器,然后文件服务器把存储路径返回,然后再把文件路径上传到openFire服务器,上传文件用put方法,好处是上传路径急是保存路径,为了不让路径重复,这里使用时间具体到秒然后再加上用户名,而不管上传图片还是语音,文件都是NSData,所以只需要把相应的数据编程data即可,为了区别加上bodytype来判断
 */
- (void)sendMessageWithData:(NSData *)data bodyType:(NSString *)type {
    XMPPMessage* message = [[XMPPMessage alloc] initWithType:@"chat" to:self.jidChatTo.jid];
    // 设置bodyType类型值为image
    //[message addAttributeWithName:@"bodyType" stringValue:type];
#warning 此处采用图片,语音等传输方式为XML携带信息,所以传输速度慢,因为未搭建文件服务器,所以采用该种办法,建议采用文件服务器方式,传递URL
    // 该处设置message的body为文件类型,后面对文件类型的判断由body来实现,其中尝试使用[message addAttributeWithName:@"bodyType" stringValue:type];来实现文件类型的判断但未成功,原因暂时未知
    [message addBody:type];
    
    // 转换成base64的编码
    NSString *base64str = [data base64EncodedStringWithOptions:0];
    
    // 设置节点内容
    XMPPElement *attachment = [XMPPElement elementWithName:@"attachment" stringValue:base64str];
    
    // 包含子节点
    [message addChild:attachment];

#warning 此处采用的是文件服务器方式传输,但由于未建立文件服务器,所以传输对象为写死的一图片,语音等文件的url,仅供测试使用
    //[message addBody:@"http://img5.duitang.com/uploads/item/201407/24/20140724054410_5ctE2.jpeg"];
    // 发送图片消息
    [[XMPPManager sharedmanager].stream sendElement:message];
}


#pragma mark ******************************
#pragma mark --ChatCellDelegate
- (void)getCurrentChatCell:(ChatTableViewCell *)cell withCurrentChatFrame:(ChatFrameModel *)chatFrameModel {
    //NSString *chatType = [chatFrameModel.msg.msg.message attributeStringValueForName:@"bodyType"];
    if ([chatFrameModel.msg.msg.message.body isEqualToString:@"image"]) {
        MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
        NSUInteger index = 0;
        // 如果当前单元格中的url存在,则在数组中找到与之匹配的,并找出其序号
        if (chatFrameModel.msg.msg.body) {
            index = [self.chatImageArray indexOfObject:chatFrameModel.msg.msg.body];
        }
        // 设置图片查看器当前查看的位置
        [browser setCurrentPhotoIndex:index];
        // 跳转到图片查看器
        [self.navigationController pushViewController:browser animated:YES];
    } else if ([chatFrameModel.msg.msg.message.body isEqualToString:@"voice"]) {
        if (self.audioPlayer.isPlaying) {
            [self.audioPlayer stop];
        }
        
        XMPPElement *node = chatFrameModel.msg.msg.message.children.lastObject;
        // 取出消息的解码
        NSString *base64str = node.stringValue;
        NSData *data = [[NSData alloc]initWithBase64EncodedString:base64str options:0];
        
        self.audioPlayer = [[AVAudioPlayer alloc] initWithData:data error:NULL];
        self.audioPlayer.delegate = self;
        [self.audioPlayer play];
    }
    
}

#pragma mark ******************************
#pragma mark -- MWPhotoBrowserDelegate
// 一共展示多少图片
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser
{
    return self.chatImageArray.count;
}
// 返回展示的详细图片MWPhoto对象
- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index
{
    UIImage *image = self.chatImageArray[index];
    MWPhoto *photo = [MWPhoto photoWithImage:image];
    
    return photo;
}

#pragma mark ******************************
#pragma mark -- 懒加载
- (NSMutableArray *)chatMsgArray {
    if (!_chatMsgArray) {
        _chatMsgArray = [NSMutableArray array];
    }
    return _chatMsgArray;
}

- (NSMutableArray *)chatImageArray {
    if (!_chatImageArray) {
        _chatImageArray = [NSMutableArray array];
    }
    return _chatImageArray;
}

- (AVAudioRecorder *)audioRecorder {
    if (!_audioRecorder) {
        NSURL *url = [self getSavePath];
        NSDictionary *setting = [self getAudioSetting];
        NSError *error = nil;
        _audioRecorder = [[AVAudioRecorder alloc] initWithURL:url settings:setting error:&error];
        _audioRecorder.delegate = self;
        if (error) {
            NSLog(@"创建录音机对象时发生错误,错误信息:%@",error.localizedDescription);
            return nil;
        }
    }
    return _audioRecorder;
}

- (MoreFunctionView *)moreView {
    if (!_moreView) {
        _moreView = [[MoreFunctionView alloc] initWithFrame:kMoreInputViewOriFrame];
        [[UIApplication sharedApplication].keyWindow addSubview: _moreView];
        [UIApplication sharedApplication].keyWindow.backgroundColor = BackGround243Color;
        __weak typeof(self) weakSelf = self;
        _moreView.indexBolck = ^(NSInteger index) {
            [weakSelf.view endEditing:YES];
            [weakSelf dissmissMoreInputViewWithAniation:YES];
            switch (index) {
                case 0: {
                    // 照片
                    NSLog(@"照片");
                    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
                    ipc.delegate = weakSelf;
                    [weakSelf presentViewController:ipc animated:YES completion:nil];
                }
                    break;
                case 1: {
                    // 拍摄
                    
                }
                    break;
                case 2: {
                    // 小视频
                    
                }
                    break;
                case 3: {
                    // 位置
                    
                }
                    break;
                case 4: {
                    // 收藏
                    
                }
                    break;
                case 5: {
                    // 个人名片
                    
                }
                    break;
                case 6: {
                    // 语音输入
                    
                }
                    break;
                    
                default:
                    break;
            }
            
        };
        [self.view addSubview:_moreView];
    }
    return _moreView;
}

#pragma mark ******************************
#pragma mark -- 滚到会话最底端
-(void)scrollToBottom {
    if (!self.chatMsgArray.count) {
        return;
    }
    NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:self.chatMsgArray.count-1 inSection:0];
    [self.myTab scrollToRowAtIndexPath:lastIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

#pragma mak -- 更改键盘高度
- (void)keyboardFrameChange:(NSNotification *)sender {
    // 获得键盘改变后的frame
    NSValue *keyboardFrame = sender.userInfo[UIKeyboardFrameEndUserInfoKey];
    CGRect rect = [keyboardFrame CGRectValue];
    CGFloat height = CGRectGetHeight(rect);
    // 计算聊天窗口的底部偏移量
    if (rect.origin.y == [UIScreen mainScreen].bounds.size.height) {
        self.inputViewBottonConstraint.constant = 0;
    } else {
        self.inputViewBottonConstraint.constant = height;
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    }];
    [self scrollToBottom];
}

#pragma mark -- 点击空白地方收起键盘
- (void)setupForTabelView {
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tableViewClick:)];
    [self.myTab addGestureRecognizer:singleTap];
}

- (void)tableViewClick:(UITapGestureRecognizer *)gesture {
    if (self.inputViewBottonConstraint.constant == 200) {
        
        self.inputViewBottonConstraint.constant = 0;
    }
    [self dissmissMoreInputViewWithAniation:YES];
    [self.view endEditing:YES];
}

#pragma mark - UIScorllViewDelegate 滑动tableview收起键盘
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
    [self dissmissMoreInputViewWithAniation:YES];
}

- (void)dissmissMoreInputViewWithAniation:(BOOL)hasAnima
{
    // 将moreInput恢复到原样
    if (hasAnima) {
        
        [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
            //
            self.view.frame = self.view.bounds;
            self.moreView.frame = kMoreInputViewOriFrame;
        } completion:^(BOOL finished) {
            //
        }];
    }
    self.inputViewBottonConstraint.constant = 0;
    self.moreView.frame = kMoreInputViewOriFrame;
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
