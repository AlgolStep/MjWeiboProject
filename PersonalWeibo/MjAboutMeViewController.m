//
//  MjAboutMeViewController.m
//  PersonalWeibo
//
//  Created by qingyun on 14-6-6.
//  Copyright (c) 2014年 hnqingyun. All rights reserved.
//

#import "MjAboutMeViewController.h"
#import "UIImageView+WebCache.h"
#import "XMLDictionary.h"
#import "MjCostumContentTableViewCell.h"
#import "MjEditViewController.h"
#import "MjFriendsStatusViewController.h"
#import "NSString+FrameHeight.h"
#import "MjAddFuncViewController.h"


enum AboutMeSection{
    kNewStatusInfoSection,
    kMoreStatusSection,
    kMoreSection,
    kAboutMeSecionNums
};

@interface MjAboutMeViewController ()

@end

@implementation MjAboutMeViewController
{
    UIView *detailUserInfoBgView;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        [self.tabBarItem initWithTitle:@"我" image:[UIImage imageNamed:@"tabbar_profile"] selectedImage:[UIImage imageNamed:@"tabbar_profile_selected"]];
        [self requestUserTimeLineFromSinaServer];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [MjNSDC addObserver:self selector:@selector(onLogOutNotification:) name:kMjNotificationNameLogout object:nil];
    self.tabBarController.tabBar.hidden = NO;

    
    //      根据tabbarcontroller取出homeViewController所在的导航控制器
    if (!self.bisHideTabbar) {
        UINavigationController *nav =(UINavigationController*)self.tabBarController.viewControllers[0];
        //      为了不发生与homeViewController的相互依赖关系，这里采用KVC机制，将homeViewController里从网
        //        络获取的当前个人用户信息
        self.mDictionary = (NSDictionary*)[nav.topViewController   valueForKey:@"currentUserInfo"];
    }else{
         self.navigationController.navigationBarHidden = NO;
    }
    CGRect headFrame = CGRectMake(0, 0, 320, 255);
    UIView *headView = [[UIView alloc]initWithFrame:headFrame];
    headView.backgroundColor = [UIColor whiteColor];
//    背景视图
    UIImageView *headImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, -100, 320, 250)];
    headImageView.image = [UIImage imageNamed:@"bg0.jpg"];
    
    headImageView.userInteractionEnabled = YES;
    [headView addSubview:headImageView];

    UIImageView *avaterImageView =[[ UIImageView alloc]initWithFrame:CGRectMake(20, 125, 60, 60)];
    [avaterImageView setImageWithURL:[NSURL URLWithString:[self.mDictionary objectForKey:@"avatar_hd"]]];
    [headView addSubview:avaterImageView];
    [avaterImageView release];
    
    UILabel *labelMeName = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(avaterImageView.frame) + 20, avaterImageView.frame.origin.y + 95, 100, 30)];
    labelMeName.text = [self.mDictionary objectForKey:@"screen_name"];
    labelMeName.textColor = [UIColor darkGrayColor];
    labelMeName.font = [UIFont systemFontOfSize:13.0];
    [headImageView addSubview:labelMeName];
    [labelMeName release];
    
//    个人信息旁边的两个按钮
    UIImage *writeImage = [UIImage imageNamed:@"userinfo_relationship_indicator_compose"];
    CGRect writeFrame = CGRectMake(CGRectGetMaxX(avaterImageView.frame) + 15, 160, 100, 25);
    UIButton *buttonWrite =[self createButton:writeImage Title:@"写微博" Frame:writeFrame];
    [buttonWrite addTarget:self action:@selector(onWriteBtn:) forControlEvents:UIControlEventTouchUpInside];
    [headView addSubview:buttonWrite];
    
    UIImage *friendListImage = [UIImage imageNamed:@"userinfo_relationship_indicator_friends"];
    CGRect friendFrame = CGRectMake(CGRectGetMaxX(buttonWrite.frame)+10, 160, 100, 25);
    UIButton *buttonFriends = [self createButton:friendListImage Title:@"好友列表" Frame:friendFrame];
    [buttonFriends addTarget:self action:@selector(onFriendList:) forControlEvents:UIControlEventTouchUpInside];
    [headView addSubview:buttonFriends];
    
    UIButton *buttonDesp = [[UIButton alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(buttonFriends.frame)+5, 300, 20)];
    buttonDesp.titleLabel.font = [UIFont systemFontOfSize:12.0f];
    [buttonDesp setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [buttonDesp setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    NSString *title = [self.mDictionary objectForKey:@"verified_reason"];
    if (nil == title || title.length == 0) {
        title = [self.mDictionary objectForKey:@"description"];
    }
    [buttonDesp setTitle:title forState:UIControlStateNormal];
    [headView addSubview:buttonDesp];
    
    UIImageView *lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(buttonDesp.frame)+5, 320, 1)];
    lineImageView.image = [UIImage imageNamed:@"settings_statistic_form_background_line"];
    [headView addSubview:lineImageView];
    
    detailUserInfoBgView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(lineImageView.frame), 320, 40)];
    detailUserInfoBgView.backgroundColor = [UIColor whiteColor];
    NSString *statusCount = [NSString stringWithFormat:@" %@\n微博",[self.mDictionary objectForKey:@"statuses_count"]];
    NSString *friendsCount = [NSString stringWithFormat:@" %@\n关注",[self.mDictionary objectForKey:@"friends_count"]];
    NSString *followersCount = [NSString stringWithFormat:@" %@\n粉丝",[self.mDictionary objectForKey:@"followers_count"]];
    NSArray *detailUserInfoTitles = @[@"详细\n资料",statusCount,friendsCount,followersCount,@"更多"];
    for (int i = 0 ; i < detailUserInfoTitles.count; i++) {
        NSString *title = detailUserInfoTitles[i];
        [self createDetailUserInfoItem:title Frame:CGRectMake(i * 64, 0, 64, 40)];
    }
    
    [headView addSubview:detailUserInfoBgView];
    self.tableView.tableHeaderView = headView;
}



- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [MjNSDC removeObserver:self name:kMjNotificationNameLogout object:nil];
}

#pragma mark - Notification call back function
- (void)onLogOutNotification:(NSNotification*)notification
{
    [MjViewControllerManager presentMjController:MjloginViewController];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    UIAlertView *alterView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"确定销毁此账号" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"OK", nil];
    [alterView show];
    [alterView release];
}

#pragma mark -
#pragma mark UIAlterViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1) {
        [appDelegate.sinaWeibo logOut];
    }
}

- (void)onWriteBtn:(UIButton *)writeBtn
{
    MjEditViewController *editViewController = [[MjEditViewController alloc]init];
    [self presentViewController:editViewController animated:YES completion:nil];
    self.tabBarController.tabBar.hidden = YES;
    [editViewController release];
}

- (void)onFriendList:(UIButton*)friendSender
{
    MjFriendsStatusViewController *friendStatusViewController = [[MjFriendsStatusViewController alloc]init];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:friendStatusViewController];
    [self presentViewController:nav animated:YES completion:nil];
    [friendStatusViewController release];
}

- (void)createDetailUserInfoItem:(NSString*)title Frame:(CGRect)frame
{
    UIButton * userDetailBtn = [[UIButton alloc] initWithFrame:frame];
    userDetailBtn.titleLabel.font = [UIFont systemFontOfSize:13.0f];
    userDetailBtn.titleLabel.numberOfLines = 2;
    userDetailBtn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [userDetailBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [userDetailBtn setTitle:title forState:UIControlStateNormal];
    [userDetailBtn setTitle:title forState:UIControlStateHighlighted];
    [detailUserInfoBgView addSubview:userDetailBtn];
    [userDetailBtn release];
}

- (UIButton*)createButton:(UIImage*)image Title:(NSString*)title Frame:(CGRect)frame
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    button.layer.borderColor = [UIColor lightGrayColor].CGColor;
    button.layer.borderWidth = 1.0f;
    button.layer.cornerRadius = 3.0f;
    button.titleLabel.font = [UIFont systemFontOfSize:13.0];
    [button setImage:image forState:UIControlStateNormal] ;
    button.titleLabel.numberOfLines = 2;
    button.titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
    [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateHighlighted];
    [button setImageEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 60)];
    [button setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
    button.backgroundColor = [UIColor whiteColor];
    return button;
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
    NSLog(@"%d",kAboutMeSecionNums);
    return kAboutMeSecionNums;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    int retRowNumbers = 0;
    switch (section) {
        case kNewStatusInfoSection:
        case kMoreStatusSection:
        case kMoreSection:
            retRowNumbers = 1;
            break;
            
        default:
            break;
    }
    return retRowNumbers;
}


//设置tableView的Cell的header
static CGFloat fontSize = 14.0f;

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellHeight = 0.0;
    switch (indexPath.section) {
        case kNewStatusInfoSection:
        {
           cellHeight = [self heightForNewStatusCell:indexPath];
            NSLog(@"%f",[self heightForNewStatusCell:indexPath]);
        }
            break;
            case kMoreStatusSection:
            case kMoreSection:
            cellHeight = 56.0;
        default:
            break;
    }
    return cellHeight;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"statusCell";
    UITableViewCell *normalCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (nil == normalCell) {
        normalCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    switch (indexPath.section) {
        case kNewStatusInfoSection:
        {
            MjCostumContentTableViewCell *cell =[[MjCostumContentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.cellData = self.userTimeLines[0];
            return cell;
        }
            break;
        case kMoreSection:
        {
            UIButton *moreBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 10, 320, 20)];
            [moreBtn setTitle:@"更多" forState:UIControlStateNormal];
            [moreBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [moreBtn addTarget:self action:@selector(onMoreButton:) forControlEvents:UIControlEventTouchUpInside];
            [normalCell.contentView addSubview:moreBtn];
        }
        default:
            break;
    }
    return normalCell;
}


- (CGFloat)heightForNewStatusCell:(NSIndexPath*)indexPath
{
    //    用户头部信息高度
    CGFloat height4Header = 40.0;
    //    原创微博文本内容所占高度
    CGFloat statusTextHeight = 0.0;
    //    原创微博如果有图片的话， 图片所占的高度
    CGFloat statusImageViewHeight = 0.0;
    //    转发微博文本内容所占高度
    CGFloat retweetStatusTextHeight = 0.0;
    
    NSDictionary *statusInfo = self.userTimeLines[0];
    
    NSString *content = [statusInfo objectForKey:@"text"];
    statusTextHeight = [content initHeightWithFontSize:fontSize forViewWidth:310.f];
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
    return (height4Header + statusTextHeight + statusImageViewHeight + retweetStatusTextHeight + 50);

}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == kNewStatusInfoSection) {
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 35.0f)];
        footerView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        footerView.layer.borderWidth = 0.5f;
        
        UIButton *retsweetBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 2.5, 100, 30)];
        [retsweetBtn setImage:[UIImage imageNamed:@"timeline_icon_retweet"] forState:UIControlStateNormal];
        [retsweetBtn setImage:[UIImage imageNamed:@"timeline_icon_retweet"] forState:UIControlStateHighlighted];
        NSString *retweetButtonTitle =[NSString stringWithFormat:@"%@",[self.statusDataList[section]
                                                                        objectForKey:kStatusRepostsCount]];
        [retsweetBtn setTitle: retweetButtonTitle forState:UIControlStateNormal];
        [retsweetBtn setTitle:retweetButtonTitle forState:UIControlStateHighlighted];
        [retsweetBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 50)];
        [retsweetBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 20)];
        retsweetBtn.titleLabel.font = [UIFont systemFontOfSize:13.0f];
        [retsweetBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [retsweetBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
//        [retsweetBtn addTarget:self action:@selector(onRetsweetBtn:) forControlEvents:UIControlEventTouchUpInside];
        retsweetBtn.tag = section;
        [footerView addSubview:retsweetBtn];
        
        UIButton *commentBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(retsweetBtn.frame)+10, 2.5, 100, 30)];
        [commentBtn setImage:[UIImage imageNamed:@"timeline_icon_comment"] forState:UIControlStateNormal];
        [commentBtn setImage:[UIImage imageNamed:@"timeline_icon_comment"] forState:UIControlStateHighlighted];
        NSString *commentButtonTitle =[NSString stringWithFormat:@"%@",[self.statusDataList[section]
                                                                        objectForKey:kStatusCommentsCount]];
        
        [commentBtn setTitle: commentButtonTitle forState:UIControlStateNormal];
        [commentBtn setTitle:commentButtonTitle forState:UIControlStateHighlighted];
        [commentBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 50)];
        [commentBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 20)];
        commentBtn.titleLabel.font = [UIFont systemFontOfSize:fontSize];
        [commentBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [commentBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
        [footerView addSubview:commentBtn];
        
        UIButton *attitudesBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(commentBtn.frame),2.5,100,30)];
        [attitudesBtn setImage:[UIImage imageNamed:@"timeline_icon_unlike"] forState:UIControlStateNormal];
        [attitudesBtn setImage:[UIImage imageNamed:@"timeline_icon_like"] forState:UIControlStateHighlighted];
        NSString *attitudesButtonTitle =[NSString stringWithFormat:@"%@",[self.statusDataList[section]
                                                                          objectForKey:kStatusAttitudesCount]];
        [attitudesBtn setTitle: attitudesButtonTitle forState:UIControlStateNormal];
        [attitudesBtn setTitle:attitudesButtonTitle forState:UIControlStateHighlighted];
        [attitudesBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 50)];
        [attitudesBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)];
        attitudesBtn.titleLabel.font = [UIFont systemFontOfSize:fontSize];
        [attitudesBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [attitudesBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
        [footerView addSubview:attitudesBtn];
        return footerView;
    }
    
    return nil;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    switch (section) {
        case kNewStatusInfoSection:
            return 35.0f;
            break;
            
        default:
            break;
    }
    return 10.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10.0f;
}

#pragma mark -
#pragma mark Request data from server
//根据用户id获取当前用户发布的微博
- (void)requestUserTimeLineFromSinaServer
{
    SinaWeibo *sinaweibo = appDelegate.sinaWeibo;
    if (self.userID == nil) {
        self.userID = sinaweibo.userID;
    }
    [sinaweibo requestWithURL:@"statuses/user_timeline.json"
                       params:[NSMutableDictionary dictionaryWithObject:self.userID forKey:@"uid"]
                   httpMethod:@"GET"
                     delegate:self];
}

#pragma mark - SinaWeiboRequestDelegate

- (void)request:(SinaWeiboRequest *)request didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"%s:%@",__func__,response);
}

- (void)request:(SinaWeiboRequest *)request didReceiveRawData:(NSData *)data
{
    NSLog(@"%s",__func__);
}
- (void)request:(SinaWeiboRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"%s:%@",__func__,error);
}

- (void)request:(SinaWeiboRequest *)request didFinishLoadingWithResult:(id)result
{
    NSLog(@"%s,%@",__func__,result);
    self.fullUsrTimeLines = [result objectForKey:@"statuses"];
    if (self.userTimeLines == nil) {
        self.userTimeLines =[NSArray arrayWithObject:[self.fullUsrTimeLines objectAtIndex:0]];
        [self.tableView reloadData];
    }
}

#pragma mark -
#pragma mark Button call back
- (void)onMoreButton:(UIButton*)sender
{
    MjAddFuncViewController *addFuncViewController = [[MjAddFuncViewController alloc]initWithStyle:UITableViewStyleGrouped];
    addFuncViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:addFuncViewController animated:YES];
}


@end
