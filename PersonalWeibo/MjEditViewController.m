//
//  MjEditViewController.m
//  PersonalWeibo
//
//  Created by qingyun on 14-6-12.
//  Copyright (c) 2014年 hnqingyun. All rights reserved.
//

#import "MjEditViewController.h"
#import "MjFriendsStatusViewController.h"
#import "MjEmojiPageView.h"
#import "SVProgressHUD.h"
#import "NSString+FrameHeight.h"
#import "UIImageView+WebCache.h"
#import "MjWeiBoDataEngine.h"

@interface MjEditViewController ()<EmojiViewDelegate,SinaWeiboRequestDelegate>
@property (retain, nonatomic) IBOutlet UITextView *textView;
@property (retain, nonatomic) IBOutlet UIButton *sendButton;
@property (nonatomic,retain)UISwipeGestureRecognizer *swipeGesture;
@property (nonatomic,retain)UIToolbar *toolBar;
@property (nonatomic,retain)NSMutableArray *postImages;
@property (nonatomic, retain)UIScrollView *emojiScrollView;
@end

@implementation MjEditViewController
{
    UIView *retweetBgView;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.isTextEdited = NO;
        self.isKeyBoardToolShow = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    当界面展示的时候， 直接弹出键盘
  
    self.textView.text = @"分享新鲜事...";
    
    self.toolBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0,
                                                              self.view.bounds.size.height,
                                                              self.view.bounds.size.width,
                                                              44)];
    self.toolBar.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin |
    UIViewAutoresizingFlexibleHeight;
    [self createKeyBoardTopBarItems];
    [self.view addSubview:self.toolBar];

}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.tabBarController.tabBar.hidden = YES;
    [self.textView becomeFirstResponder];
    [MjNSDC addObserver:self
               selector:@selector(keyboardWillShow:)
                   name:UIKeyboardWillShowNotification
                 object:nil];
    [MjNSDC addObserver:self
               selector:@selector(keyboardWillHide:)
                   name:UIKeyboardWillHideNotification
                 object:nil];
    if (self.textView.text.length == 0 || [self.textView.text isEqualToString:@"分享新鲜事..."]) {
        self.sendButton.enabled = NO;
        [self.sendButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        
    }
    [self showEditStatusView];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
    [MjNSDC removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [MjNSDC removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
}


- (void)showEditStatusView
{
    if (nil != self.mDicStatus) {
        self.textView.text = [self.mDicStatus objectForKey:kStatusText];
        
        CGFloat textViewheight = [self.textView.text initHeightWithFontSize:14.0f forViewWidth:300.0f];
        retweetBgView= [[UIView alloc]initWithFrame:CGRectMake(0, textViewheight + 10, 300, 80)];
        retweetBgView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        retweetBgView.layer.borderWidth = 0.5f;
        UIImageView *thumbImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 80, 80)];
        [retweetBgView addSubview:thumbImageView];
        
        UILabel *retweetUserName = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(thumbImageView.frame) + 10, 10, 200, 20)];
        [retweetBgView addSubview:retweetUserName];
        
        UILabel *retweetStatusText = [[UILabel alloc]initWithFrame:CGRectMake(retweetUserName.frame.origin.x, CGRectGetMaxY(retweetUserName.frame) + 5, 200, 40)];
        retweetStatusText.numberOfLines = 2;
        retweetStatusText.textColor = [UIColor lightGrayColor];
        retweetStatusText.font = [UIFont systemFontOfSize:13.0f];
        [retweetBgView addSubview:retweetStatusText];
        
        NSDictionary *dicRetweetStatus = [self.mDicStatus objectForKey:kStatusRetweetStatus];
        //      如果被转发的微博包含转发微博，那么当前转发内容需要附带被转发微博的转发微博
        if (nil != dicRetweetStatus) {
            // 如果被转发的微博转发的内容有图片，则提取出此图片，如果没有图片，则使用被转发用户的头像作为图片。
            NSArray *arrayPicUrl = [dicRetweetStatus objectForKey:kStatusPicUrls];
            if (nil != arrayPicUrl && arrayPicUrl.count > 0) {
                NSURL *imageUrl = [NSURL URLWithString:[[arrayPicUrl objectAtIndex:0] objectForKey:kStatusThumbnailPic ] ];
                UIImage *image = [[UIImage alloc]initWithData:[NSData dataWithContentsOfURL:imageUrl]];
                thumbImageView.image = image;
            }else{
                [thumbImageView setImageWithURL:[NSURL URLWithString:[[dicRetweetStatus objectForKey:kStatusUserInfo] objectForKey:kUserAvatarLarge]]];
            }
            retweetUserName.text = [[dicRetweetStatus objectForKey:kStatusUserInfo] objectForKey:kUserInfoScreenName];
            retweetStatusText.text = [dicRetweetStatus objectForKey:kStatusText];
        }else{
            if (nil == thumbImageView.image) {
                [thumbImageView setImageWithURL:[NSURL URLWithString:[[self.mDicStatus objectForKey:kStatusUserInfo] objectForKey:kUserAvatarLarge ]]];
            }
            retweetUserName.text = [[self.mDicStatus objectForKey:kStatusUserInfo] objectForKey:kUserInfoScreenName];
            retweetStatusText.text = [self.mDicStatus objectForKey:kStatusText];
        }
        [self.textView addSubview:retweetBgView];
          MjSafeRelease(thumbImageView);
          MjSafeRelease(retweetUserName);
          MjSafeRelease(retweetStatusText);
    }
}

//创建键盘上的工具栏
- (void)createKeyBoardTopBarItems
{
//    创建灵活可变的空格Item
    UIBarButtonItem *flexItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
//   照相机
    UIBarButtonItem *cameraItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"compose_camerabutton_background"] style:UIBarButtonItemStyleBordered target:self action:@selector(onCameraBarItemTapped:)];
    //图片库
    UIBarButtonItem *photoItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"compose_toolbar_picture"] style:UIBarButtonItemStyleBordered target:self action:@selector(onPhotoBarItemTapped:)];
    //联系人列表
    UIBarButtonItem *atContactItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"compose_mentionbutton_background"] style:UIBarButtonItemStyleBordered target:self action:@selector(onAtContactItemTapped:)];
    //表情库
    UIBarButtonItem *emotionItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"compose_emoticonbutton_background"] style:UIBarButtonItemStyleBordered target:self action:@selector(onEmotionItemTapped:)];
                                    
    //更多
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(onAddItemTapped:)];
    
    [self.toolBar setItems:@[cameraItem,flexItem,photoItem,flexItem,atContactItem,flexItem,emotionItem,flexItem,addItem]];
    [cameraItem release];
    [flexItem release];
    [photoItem release];
    [atContactItem release];
    [emotionItem release];
    [addItem release];
    
}

#pragma mark -
#pragma mark UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView
{
    if ((!self.isTextEdited) && self.postImages.count == 0 ) {
        self.sendButton.enabled = NO;
        [self.sendButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    }else{
        self.sendButton.enabled = YES;
        [self.sendButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    }
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    NSRange range;
    range.location = 0;
    range.length = 0;
    textView.selectedRange = range;
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (([self.textView.text isEqualToString:@"分享新鲜事..."]) && (!self.isTextEdited)) {
        self.textView.text = @"";
    }
    self.isTextEdited = YES;
    return YES;
}

#pragma mark -
#pragma mark KeyBoard top toolbar item callback method
- (void)onEmotionItemTapped:(UIBarButtonItem*)sender
{
    self.isKeyBoardToolShow = YES;
    [self.textView resignFirstResponder];
    if (self.emojiScrollView != nil) {
        [self.emojiScrollView removeFromSuperview];
        self.emojiScrollView = nil;
        [self.textView becomeFirstResponder];
    }else
    {
        self.emojiScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - 216, 320, 216)];
        self.emojiScrollView.backgroundColor = [UIColor lightGrayColor];
        
        int nPageCount = [MjEmojiPageView pagesForAllEmoji:35];
        self.emojiScrollView.contentSize = CGSizeMake(320*nPageCount, 216);
        self.emojiScrollView.pagingEnabled = YES;
        
        for (int i = 0; i < nPageCount; i ++) {
            MjEmojiPageView *emojiPageView = [[MjEmojiPageView alloc]initWithFrame:CGRectMake(10 + 320*i, 15, 300, 170)];
            emojiPageView.deleagte = self;
            [emojiPageView setBackgroundColor:[UIColor clearColor]];
            [emojiPageView loadEmojiItem:i size:CGSizeMake(33, 43)];
            [self.emojiScrollView addSubview:emojiPageView];
        }
    }
    [[UIApplication sharedApplication].keyWindow addSubview:self.emojiScrollView];
}
- (void)onAtContactItemTapped:(UIBarButtonItem*)sender
{
    self.isKeyBoardToolShow = NO;
    MjFriendsStatusViewController *friendStatusViewController = [[MjFriendsStatusViewController alloc] initWithStyle:UITableViewStyleGrouped];
    UINavigationController *friendStatusNav = [[UINavigationController alloc]initWithRootViewController:friendStatusViewController];
    [self presentViewController:friendStatusNav animated:YES completion:nil];
    [self.emojiScrollView removeFromSuperview];
}

- (void)onCameraBarItemTapped:(UIBarButtonItem*)sender
{
    [self getMediaFromSource:UIImagePickerControllerSourceTypeCamera];
    [self.emojiScrollView removeFromSuperview];

}


- (void)onPhotoBarItemTapped:(UIBarButtonItem*)sender
{
    self.isKeyBoardToolShow = NO;
    [self.emojiScrollView removeFromSuperview];
    [self getMediaFromSource:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (void)onAddItemTapped:(UIBarButtonItem*)sender
{
    
}


#pragma mark -
#pragma mark Camera picker
- (void)getMediaFromSource:(UIImagePickerControllerSourceType)sourceType
{
    //  用于判断当前设备是否支持相机或者图片库
    if ([UIImagePickerController isSourceTypeAvailable:sourceType]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.videoQuality = UIImagePickerControllerQualityTypeLow;
        picker.sourceType = sourceType;

        //      展示模态控制器，在此处必须使用这种方式，不能使用导航控制器
        [self presentViewController:picker animated:YES completion:nil];
        
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error accessing media" message:@"Device doesn't support that media source." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
}

#pragma mark -
#pragma mark UIImagePickerControllerDelegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:12.0f]};
    CGSize size = [self.textView.text sizeWithAttributes:attributes];
    CGFloat textViewHeight =ceilf(size.width / self.view.bounds.size.width)*size.height;
    
    UIImage *chosenImage = [info objectForKey:UIImagePickerControllerEditedImage];
    UIImageView *wbImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, textViewHeight+20, 80, 100)];
    wbImageView.image = chosenImage;
    [self.textView addSubview:wbImageView];
//    [wbImageView release];
    if (self.postImages == nil) {
        self.postImages = [[NSMutableArray alloc] init];
    }
    [self.postImages addObject:chosenImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}



//键盘出现事件回调
- (void)keyboardWillShow:(NSNotification*)notification
{
    self.swipeGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self
                                                                action:@selector(onSwipeGesture:)];
    self.swipeGesture.direction = UISwipeGestureRecognizerDirectionDown;
    [self.textView addGestureRecognizer:self.swipeGesture];
    
    NSDictionary *userInfo = notification.userInfo;
    CGRect keyBoardFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat intermalTime = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    UIViewAnimationOptions animationOpiton = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    CGRect kbTopBarViewShowFrame = (CGRect){keyBoardFrame.origin.x,keyBoardFrame.origin.y-44,320,44};
    [UIView animateWithDuration:intermalTime
                          delay: 0.0
                        options: animationOpiton
                     animations:^{
                         self.toolBar.frame = kbTopBarViewShowFrame;
                     }
                     completion:nil];
}

//键盘隐藏事件回调
- (void)keyboardWillHide:(NSNotification *)notification
{
    [self.textView removeGestureRecognizer:self.swipeGesture];
    
    if (self.emojiScrollView == nil&&(self.isKeyBoardToolShow)) {
        return;
    }
    
    NSDictionary *userInfo = notification.userInfo;
    CGFloat timerInterval = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    UIViewAnimationOptions animationOptions = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    CGRect keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [UIView animateWithDuration:timerInterval
                          delay: 0.0
                        options: animationOptions
                     animations:^{
                         self.toolBar.frame = CGRectMake(0, CGRectGetMinY(keyboardFrame)-44,320,44);
                     }
                     completion:nil];

}

//隐藏键盘的手势回调
- (void)onSwipeGesture:(UISwipeGestureRecognizer*)swipeGesture
{
    self.isKeyBoardToolShow = NO;
    [self.textView resignFirstResponder];
    
}

- (IBAction)onCancel:(id)sender {
    if ((self.textView.text.length != 0 || self.postImages.count != 0) && self.isTextEdited) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@""
                                                                delegate:self
                                                       cancelButtonTitle:@"取消"
                                                  destructiveButtonTitle:@"不保存"
                                                       otherButtonTitles:@"保存草稿", nil];
        [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
        
    }else{
        if (self.navigationController != nil) {
            [self.navigationController popViewControllerAnimated:YES];
            [self.emojiScrollView removeFromSuperview];
        }else{
            
            [self dismissViewControllerAnimated:YES completion:nil];
            [self.emojiScrollView removeFromSuperview];
        }
    }
    
}

- (IBAction)onSenderBtn:(id)sender {
    
   
    [SVProgressHUD showWithStatus:@"正在发送..."];
    if (nil == self.postImages || self.postImages.count == 0) {
        [appDelegate.sinaWeibo requestWithURL:@"statuses/update.json"
                                       params:[NSMutableDictionary dictionaryWithObjectsAndKeys:self.textView.text, @"status",nil]
                                   httpMethod:@"POST"
                                     delegate:self];
       
    }else{
        UIImage *image = [self.postImages lastObject];
        [appDelegate.sinaWeibo requestWithURL:@"statuses/upload.json"
                                       params:[NSMutableDictionary dictionaryWithObjectsAndKeys:self.textView.text,@"status",image,@"pic", nil]
                                   httpMethod:@"POST"
                                     delegate:self];
    }
    if ([SVProgressHUD isVisible]) {
        
    }else{
        [SVProgressHUD dismissWithSuccess:nil];
    }
    [MjViewControllerManager presentMjController:MjmainViewController];
}
#pragma mark -
#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        case 1:
        {
//            [[MjWeiBoDataEngine shareInstance] saveTempStatusToDrafts:@{@"text": self.textView.text}];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - 
#pragma mark EmojiViewDelegate

- (void)didSelectedEmojiItemView:(NSString *)str
{
    self.textView.text = str;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_textView release];
    [_sendButton release];
    [self.toolBar release];
    [_emojiScrollView release];
    [_swipeGesture release];
    [super dealloc];
}
@end
