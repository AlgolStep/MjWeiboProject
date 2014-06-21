//
//  MjHomeViewController.m
//  PersonalWeibo
//
//  Created by qingyun on 14-6-6.
//  Copyright (c) 2014年 hnqingyun. All rights reserved.
//

#import "MjHomeViewController.h"
#import "MjPlaySound.h"
#import "UIImageView+WebCache.h"
#import "MjCostumContentTableViewCell.h"
#import "SVProgressHUD.h"
#import "XMLDictionary.h"
#import "NSString+FrameHeight.h"
#import "MjAboutMeViewController.h"
#import "MjWeiBoDataEngine.h"

@interface MjHomeViewController ()<MjTableViewCellDelegate>
@property  (nonatomic, assign)BOOL isTransmited;

@end

@implementation MjHomeViewController
- (id)initWithStyle:(UITableViewStyle)style
{
   self = [super initWithStyle:style];
    if (self) {
        UIImage *image = [UIImage imageNamed:@"tabbar_home_highlighted"];
        self.title = @"首页";
        [self.tabBarItem initWithTitle:@"首页"
                                 image:[image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                         selectedImage:[UIImage imageNamed:@"tabbar_home" ]];
        self.statusDataList = [[MjWeiBoDataEngine shareInstance] queryTimeLinesFromDataBase];
        if (nil == _statusDataList) {
            [self onRefreshControl:nil];
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    [self.tableView registerClass:[MjCostumContentTableViewCell class] forCellReuseIdentifier:@"statusCell"];
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc]init];
    refreshControl.tintColor = [UIColor orangeColor];
    [refreshControl addTarget:self action:@selector(onRefreshControl:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
//    [self onRefreshControl:nil];
    [refreshControl release];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
}
//每次下拉刷新的回调
- (void)onRefreshControl:(UIRefreshControl *)refreshControl
{
    MjPlaySound *playSound = [[MjPlaySound alloc] initForPlayingSoundEffectWith:@"msgcome.wav"];
    if (nil != refreshControl) {
        [playSound play];
    }else{
        [SVProgressHUD show];
    }
//    [playSound release];
    [self requestUserInfoFromSinaServer];
    [self requestTimeLineFromServer];
}

- (void)requestUserInfoFromSinaServer
{
    SinaWeibo *sinaWeibo = appDelegate.sinaWeibo;
    [sinaWeibo requestWithURL:@"users/show.json"
                       params:[NSMutableDictionary dictionaryWithObject:sinaWeibo.userID forKey:@"uid"]
                   httpMethod:@"GET"
                     delegate:self];
}

- (void)requestTimeLineFromServer
{
    SinaWeibo *sinaWeibo = appDelegate.sinaWeibo;
    [sinaWeibo requestWithURL:@"statuses/home_timeline.json"
                       params:[NSMutableDictionary dictionaryWithObject:sinaWeibo.userID forKey:@"uid"]
                   httpMethod:@"GET"
                     delegate:self];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return self.statusDataList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 35.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5.0f;
}

CGFloat fontSize = 14.0f;

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    用户头部信息高度
    CGFloat height4Header = 40.0;
    //    原创微博文本内容所占高度
    CGFloat statusTextHeight = 0.0;
    //    原创微博如果有图片的话， 图片所占的高度
    CGFloat statusImageViewHeight = 0.0;
    //    转发微博文本内容所占高度
    CGFloat retweetStatusTextHeight = 0.0;
    NSDictionary *statusInfo = self.statusDataList[indexPath.section];
    NSString *content = [statusInfo objectForKey:@"text"];
    statusTextHeight = [ content initHeightWithFontSize:fontSize forViewWidth:310.f];
    NSDictionary *retweetStatus = [statusInfo objectForKey:@"retweeted_status"];
    //    当retweetStatus为空的时候， 表示当前是一条原创微博
    if (nil == retweetStatus) {
        //      如果这条微博带的有图片，则计算图片的高度
        NSArray *picUrls = [statusInfo objectForKey:@"pic_urls"];
        if (picUrls.count == 1) {
            NSDictionary *dic = picUrls[0];
            NSString *strPicUrls = [dic objectForKey:@"thumbnail_pic"];
            UIImage *weiboImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:strPicUrls]]];
            statusImageViewHeight += weiboImage.size.height;
        }else if(picUrls.count > 1)
        {
            int picLineCount = ceilf(picUrls.count / 3.0);
            statusImageViewHeight += (80 * picLineCount);
        }
    }else
    {
        NSString *retContent = [retweetStatus objectForKey:@"text"];
        retweetStatusTextHeight = [retContent initHeightWithFontSize:fontSize forViewWidth:310.f];
        NSArray *retPicUrls = [retweetStatus objectForKey:@"pic_urls"];
        if (retPicUrls.count == 1) {
            NSDictionary *dic = retPicUrls[0];
            NSString *strPicUrls = [dic objectForKey:@"thumbnail_pic"];
            UIImage *weiboImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:strPicUrls]]];
            statusImageViewHeight += weiboImage.size.height;
        }else if(retPicUrls.count > 1)
        {
            int picLineCount = ceilf(retPicUrls.count / 3.0);
            statusImageViewHeight += (80 * picLineCount);
        }
        
        
    }
    return (height4Header + statusTextHeight + statusImageViewHeight + retweetStatusTextHeight + 40);
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"statusCell";
    MjCostumContentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (nil == cell) {
        cell = [[MjCostumContentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                   reuseIdentifier:cellIdentifier];
        cell.delegate = self;
    }
    cell.cellData = self.statusDataList[indexPath.section];
    return cell;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 35.0f)];
    footerView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    footerView.layer.borderWidth = 0.5f;
    
    UIButton *retsweetBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 2.5, 90, 30)];
    [retsweetBtn setImage:[UIImage imageNamed:@"timeline_icon_retweet_os7"] forState:UIControlStateNormal];
    NSString *retweetButtonTitle =[NSString stringWithFormat:@"%@",[self.statusDataList[section]
                                                                    objectForKey:kStatusRepostsCount]];
    [retsweetBtn setTitle: retweetButtonTitle forState:UIControlStateNormal];
    [retsweetBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 50)];
    [retsweetBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 20)];
    retsweetBtn.titleLabel.font = [UIFont systemFontOfSize:13.0f];
    retsweetBtn.titleLabel.textColor = [UIColor darkGrayColor];
    retsweetBtn.tag = section;
    [footerView addSubview:retsweetBtn];
    
    UIButton *commentBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(retsweetBtn.frame)+10, 2.5, 90, 30)];
    [commentBtn setImage:[UIImage imageNamed:@"timeline_icon_comment_os7"] forState:UIControlStateNormal];
    NSString *commentButtonTitle =[NSString stringWithFormat:@"%@",[self.statusDataList[section]
                                                                    objectForKey:kStatusCommentsCount]];
    
    [commentBtn setTitle: commentButtonTitle forState:UIControlStateNormal];
    [commentBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 50)];
    [commentBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 20)];
    commentBtn.titleLabel.font = [UIFont systemFontOfSize:fontSize];
    commentBtn.titleLabel.textColor = [UIColor darkGrayColor];
    [footerView addSubview:commentBtn];
    
    UIButton *attitudesBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(commentBtn.frame) + 10,2.5,90,30)];
    [attitudesBtn setImage:[UIImage imageNamed:@"timeline_icon_unlike_os7"] forState:UIControlStateNormal];
    NSString *attitudesButtonTitle =[NSString stringWithFormat:@"%@",[self.statusDataList[section]
                                                                      objectForKey:kStatusAttitudesCount]];
    [attitudesBtn setTitle: attitudesButtonTitle forState:UIControlStateNormal];
    [attitudesBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 50)];
    [attitudesBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)];
    attitudesBtn.titleLabel.font = [UIFont systemFontOfSize:fontSize];
    attitudesBtn.titleLabel.textColor = [UIColor groupTableViewBackgroundColor];
    [footerView addSubview:attitudesBtn];
    
    return footerView;
    
}



#pragma mark -
#pragma mark SinaWeiboRequestDelegate
- (void)request:(SinaWeiboRequest *)request didReceiveResponse:(NSURLResponse *)response
{
    
}
- (void)request:(SinaWeiboRequest *)request didReceiveRawData:(NSData *)data
{
    
}
- (void)request:(SinaWeiboRequest *)request didFailWithError:(NSError *)error
{
    if (nil != error) {
      NSLog(@"load data error:%@",error);
    }
    return;
}
- (void)request:(SinaWeiboRequest *)request didFinishLoadingWithResult:(id)result
{
    NSURL *url = [NSURL URLWithString:request.url];
    NSString *indentifierUrl = [[url pathComponents] lastObject];
    if ([indentifierUrl isEqualToString:@"home_timeline.json"]) {
        self.statusDataList = [result objectForKey:@"statuses"];
        [[MjWeiBoDataEngine shareInstance] saveTimeLinesToDataBase:self.statusDataList];
        [SVProgressHUD dismiss];
    }else if([indentifierUrl isEqualToString:@"show.json"]){
        self.currentUserInfo = (NSDictionary *)result;
        UIButton *navTitleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [navTitleBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [navTitleBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
        NSString *title = [self.currentUserInfo objectForKey:@"screen_name"];
        [navTitleBtn setTitle:title forState:UIControlStateNormal];
        [navTitleBtn setTitle:title forState:UIControlStateHighlighted];
        self.navigationItem.titleView = navTitleBtn;
    }
    if ([self.refreshControl isRefreshing]) {
        [self.refreshControl endRefreshing];
    }else{
        [SVProgressHUD dismiss];
        self.statusDataList = [result objectForKey:@"statuses"];
    }
    
    [self.tableView reloadData];
    
}

#pragma mark -
#pragma mark MjTableViewCellDelegate

- (void)statusTableCell:(MjCostumContentTableViewCell*)cell AvatarImageDidSelected:(UIGestureRecognizer*)gesture
{
    MjAboutMeViewController *aboutMeViewController = [[MjAboutMeViewController alloc]initWithStyle:UITableViewStyleGrouped];
    aboutMeViewController.hidesBottomBarWhenPushed = YES;
    
//    这三行是为了获取用户所点击的位置信息，并通过这个位置信息得到tableView的中的cell的indexPath.section
//    CGPoint currentPoint = [gesture locationInView:self.tableView];
//    NSIndexPath *currentPath = [self.tableView indexPathForRowAtPoint:currentPoint];
//    NSDictionary *usrInfo = [self.statusDataList objectAtIndex:currentPath.section];
   
    
    NSDictionary *usrInfo = cell.cellData;
    aboutMeViewController.mDictionary = [usrInfo objectForKey:@"user"];
    aboutMeViewController.userID = [NSString stringWithFormat:@"%@",[usrInfo objectForKey:@"id"]];
    aboutMeViewController.userTimeLines = [NSArray arrayWithObject:usrInfo];
    aboutMeViewController.bisHideTabbar = YES;
    
    [self.navigationController pushViewController:aboutMeViewController animated:YES];
}
- (void)statusTableCell:(MjCostumContentTableViewCell*)cell StatusImageDidSelected:(UIGestureRecognizer*)gesture
{
    
}
- (void)statusTableCell:(MjCostumContentTableViewCell*)cell RetStatusImageDidSelected:(UIGestureRecognizer*)gesture
{
    NSDictionary *currentStatus = [cell.cellData objectForKey:@"retweeted_status"];
    NSString *originalPic = [currentStatus objectForKey:@"original_pic"];
    if (originalPic != nil) {
        [self showFullViewWith:originalPic];
    }
}

- (void)showFullViewWith:(NSString*)imageName
{
    UIWindow *window = [[UIApplication sharedApplication]keyWindow];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:(CGRect){10,40,300,440}];
    imageView.tag = 100000;
    imageView.multipleTouchEnabled = YES;
    imageView.userInteractionEnabled = YES;
    NSData *imagData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:imageName]];
    UIImage *image = [UIImage imageWithData:imagData];
    imageView.image = image;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onFullImageViewTapped:)];
    [imageView addGestureRecognizer:tapGesture];
    
    UIScrollView *picImageBgView = [[UIScrollView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    picImageBgView.delegate = self;
    picImageBgView.multipleTouchEnabled = YES;
    picImageBgView.contentSize = image.size;
    picImageBgView.backgroundColor = [UIColor blackColor];
    picImageBgView.minimumZoomScale = 0.5f;
    picImageBgView.maximumZoomScale = 3.0f;
    [picImageBgView addSubview:imageView];
    
    [window addSubview:picImageBgView];
    window.userInteractionEnabled = YES;
    window.multipleTouchEnabled = YES;

}

- (void)onFullImageViewTapped:(UITapGestureRecognizer*)tapGesture
{
    [UIView animateWithDuration:2.25f animations:^{
        [tapGesture.view.superview removeFromSuperview];
    }];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    window.userInteractionEnabled = NO;
    window.multipleTouchEnabled = NO;
}

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return [scrollView viewWithTag:100000];
}

@end
