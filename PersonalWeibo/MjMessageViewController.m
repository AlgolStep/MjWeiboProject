//
//  MjMessageViewController.m
//  PersonalWeibo
//
//  Created by qingyun on 14-6-6.
//  Copyright (c) 2014年 hnqingyun. All rights reserved.
//

#import "MjMessageViewController.h"
#import "MjSmartTableViewCell.h"
#import "MjMessageCell.h"

@interface MjMessageViewController ()<SinaWeiboRequestDelegate>

@property (nonatomic, retain)NSMutableArray *message;
@property (nonatomic, retain)NSMutableArray *mImageNames;
@property (nonatomic, retain)NSArray  *bilTimeLineList;
@end

@implementation MjMessageViewController
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        [self.tabBarItem initWithTitle:@"消息" image:[UIImage imageNamed:@"tabbar_message_center"] selectedImage:[UIImage imageNamed:@"tabbar_message_center_selected"]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSArray *msg = @[@"提到我的",@"评论",@"赞",@"新浪新闻",@"未关注的私信"];
    self.message = [msg mutableCopy];
    
    NSArray *images = @[@"messagescenter_at",@"messagescenter_comments",@"messagescenter_good",@"messagescenter_at",@"messagescenter_at"];
    self.mImageNames = [images mutableCopy];
    
}

- (void)requestDataFromSinaServer
{
    SinaWeibo *sinaweibo = appDelegate.sinaWeibo;
    [sinaweibo requestWithURL:@"statuses/bilateral_timeline.json"
                       params:[NSMutableDictionary dictionaryWithObject:sinaweibo.userID forKey:@"uid"]
                   httpMethod:@"GET"
                     delegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

return self.bilTimeLineList.count + self.message.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MjSmartTableViewCell *cell = nil;
    switch (indexPath.row) {
        case 0:
        case 1:
        case 2:
        case 3:
        case 4:
        {
            cell = [MjSmartTableViewCell cellForTableViewWithIdentifer:tableView withCellStyle:UITableViewCellStyleDefault];
            cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
            cell.imageView.image = [UIImage imageNamed:self.mImageNames[indexPath.row]];
            cell.textLabel.text = self.message[indexPath.row];
        }
            break;
        default:
            cell = [MjMessageCell cellForTableViewWithIdentifer:tableView withCellStyle:UITableViewCellStyleSubtitle];
            cell.imageView.bounds = CGRectMake(0, 0, 50, 50);
            cell.accessoryType = UITableViewCellAccessoryNone;
            if (indexPath.row < self.bilTimeLineList.count) {
                NSDictionary *userInfo = self.bilTimeLineList[indexPath.row][kStatusUserInfo];
                NSURL *url = [NSURL URLWithString:userInfo[kUserAvatarLarge]];
                UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
                cell.imageView.image = image;
                cell.textLabel.text = userInfo[kUserInfoScreenName];
                cell.detailTextLabel.text = self.bilTimeLineList[indexPath.row][kStatusText];
            }
            break;
    }
    cell.textLabel.font = [UIFont systemFontOfSize:14.0f];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
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
    self.bilTimeLineList = [result objectForKey:@"statuses"];
    [self.tableView reloadData];
}

@end
