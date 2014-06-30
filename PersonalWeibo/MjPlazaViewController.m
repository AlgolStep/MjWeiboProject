//
//  MjPlazaViewController.m
//  PersonalWeibo
//
//  Created by qingyun on 14-6-6.
//  Copyright (c) 2014年 hnqingyun. All rights reserved.
//

#import "MjPlazaViewController.h"
#import "MjCollectionViewCellOne.h"
#import "MjCollectionViewCellFour.h"
#import "MjCollectionViewCellThree.h"
#import "MjCollectionViewCellTwo.h"



#define ONE_CELL_IDENTIFIER @"CollectionViewCellSectionOne"
#define TWO_CELL_IDENTIFIER @"CollectionViewCellSectionTwo"
#define THREE_CELL_IDENTIFIER @"CollectionViewCellSectionThree"
#define FOUR_CELL_IDENTIFIER @"CollectionViewCellSectionFour"

enum{
    kMjCollectionViewCellSectionOne,
    kMjCollectionViewCellSectionTwo,
    kMjCollectionViewCellSectionThree,
    kMjCollectionViewCellSectionFour,
    kMjCollectionViewCellSectionNums
};
@interface MjPlazaViewController ()<SinaWeiboRequestDelegate>

@property (nonatomic, retain)UICollectionViewLayout *layout;
@property (nonatomic, retain)NSArray *sectionOneImages;
@property (nonatomic, retain)NSArray *sectionLabelName;
@property (nonatomic, retain)NSArray *sectionTrend;
@end

@implementation MjPlazaViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        [self.tabBarItem initWithTitle:@"发现" image:[UIImage imageNamed:@"tabbar_discover"] selectedImage:[UIImage imageNamed:@"tabbar_discover_selected"]];
        self.title = @"广场";
        self.sectionOneImages = @[@"contacts_findfriends_icon",@"messages_comment_icon",@"contacts_findfriends_icon",@"messages_comment_icon"];
        self.sectionLabelName = @[@"扫一扫",@"找朋友",@"会员",@"周边"];
        [self requestTrendsFromSinaServer];
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    UISearchBar *searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    searchBar.placeholder = @"搜索";
    self.navigationItem.titleView = searchBar;
    [self registerMjCustomCollectionView];
    self.collectionView.backgroundColor = [UIColor groupTableViewBackgroundColor];
}

- (void)requestTrendsFromSinaServer
{
    SinaWeibo *sinaweibo = appDelegate.sinaWeibo;
    [sinaweibo requestWithURL:@"trends/hourly.json"
                       params:[NSMutableDictionary dictionaryWithObject:sinaweibo.userID forKey:@"uid"]
                   httpMethod:@"GET"
                     delegate:self];
}

- (void)registerMjCustomCollectionView
{
    [self.collectionView registerClass:[MjCollectionViewCellOne class]
            forCellWithReuseIdentifier:ONE_CELL_IDENTIFIER];
    
    [self.collectionView registerClass:[MjCollectionViewCellTwo class]
            forCellWithReuseIdentifier:TWO_CELL_IDENTIFIER];
    
    [self.collectionView registerClass:[MjCollectionViewCellThree class]
            forCellWithReuseIdentifier:THREE_CELL_IDENTIFIER];
    
    [self.collectionView registerClass:[MjCollectionViewCellFour class]
            forCellWithReuseIdentifier:FOUR_CELL_IDENTIFIER];
    
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return kMjCollectionViewCellSectionNums;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    int num = 0;
    switch (section) {
        case kMjCollectionViewCellSectionOne:
            num = 4;
            break;
        case kMjCollectionViewCellSectionTwo:
            num = 1;
            break;
        case kMjCollectionViewCellSectionThree:
            num = 4;
            break;
        case kMjCollectionViewCellSectionFour:
            num = 16;
            break;
        default:
            break;
    }
    return num;
}


- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = nil;
    
    switch (indexPath.section) {
        case kMjCollectionViewCellSectionOne:
        {
            MjCollectionViewCellOne *collectionViewOne = (MjCollectionViewCellOne*)[collectionView dequeueReusableCellWithReuseIdentifier:ONE_CELL_IDENTIFIER forIndexPath:indexPath];
            
            collectionViewOne.imageView.image = [UIImage imageNamed:self.sectionOneImages[indexPath.item]];
            collectionViewOne.label.text = self.sectionLabelName[indexPath.item];
            cell = collectionViewOne;
        }
            break;
            case kMjCollectionViewCellSectionTwo:
        {
            MjCollectionViewCellTwo *collectionViewTwo = (MjCollectionViewCellTwo*)[collectionView dequeueReusableCellWithReuseIdentifier:TWO_CELL_IDENTIFIER forIndexPath:indexPath];
            collectionViewTwo.imageView.image = [UIImage imageNamed:@"messagescenter_comments"];
            collectionViewTwo.titleLabel.text = @"title";
            collectionViewTwo.subTitleLabel.text = @"subTitle";
            cell = collectionViewTwo;
        }
            break;
            case kMjCollectionViewCellSectionThree:
        {
            MjCollectionViewCellThree *collectionViewThree = (MjCollectionViewCellThree*)[collectionView dequeueReusableCellWithReuseIdentifier:THREE_CELL_IDENTIFIER forIndexPath:indexPath];
            collectionViewThree.mDicTrends = self.sectionTrend[0][indexPath.item];
            cell = collectionViewThree;
        }
            break;
            case kMjCollectionViewCellSectionFour:
        {
            MjCollectionViewCellFour *collectionViewFour = (MjCollectionViewCellFour*)[collectionView dequeueReusableCellWithReuseIdentifier:FOUR_CELL_IDENTIFIER forIndexPath:indexPath];
            cell = collectionViewFour;
        }
            break;
            
        default:
            break;
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size;
    switch (indexPath.section) {
        case kMjCollectionViewCellSectionOne:
            size = CGSizeMake(140, 44);
            break;
        case kMjCollectionViewCellSectionTwo:
            size = CGSizeMake(300, 80);
            break;
        case kMjCollectionViewCellSectionThree:
            size = CGSizeMake(140, 40);
            break;
            case kMjCollectionViewCellSectionFour:
            size = CGSizeMake(57, 70);
            break;
        default:
            break;
    }
    return size;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    self.sectionTrend = [[result objectForKey:@"trends"] allValues];
    [self.collectionView reloadData];
}


@end
