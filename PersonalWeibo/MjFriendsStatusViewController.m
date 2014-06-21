//
//  MjFriendsStatusViewController.m
//  PersonalWeibo
//
//  Created by qingyun on 14-6-13.
//  Copyright (c) 2014年 hnqingyun. All rights reserved.
//

#import "MjFriendsStatusViewController.h"
#import "ChineseToPinyin.h"
#import "UIImageView+WebCache.h"

#define kTableView 1000
#define kContactsImageView 10001
#define kContactsLabel 10002

static NSString *friendId = @"friendIdentifier";


@interface MjFriendsStatusViewController ()
@property (nonatomic, retain)UISearchBar *searchBar;
@property (nonatomic, retain)NSArray *orginalFriendContacts;
@property (nonatomic, retain)NSArray *indexKeys;
@property (nonatomic, retain)NSArray *modifiedFriendContacts;
@property (nonatomic, retain)NSMutableDictionary *showContacts;
@property (nonatomic, retain)NSMutableDictionary *showAllContacts;
@property (nonatomic, retain)NSArray *sectionTitle;
@property (nonatomic, retain)NSArray *allSectionTitle;



@end

@implementation MjFriendsStatusViewController
{
    UISearchDisplayController *searchDisplayController;
    NSMutableArray *filterdNames;
   
}
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"联系人";
        self.showContacts = [[NSMutableDictionary alloc] initWithCapacity:10];
        self.showAllContacts = [[NSMutableDictionary alloc]initWithCapacity:10];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.tag = kTableView;
    self.searchBar.delegate = self;
    
    self.searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 20, 320, 44)];
    self.tableView.tableHeaderView = self.searchBar;
    
    filterdNames = [[NSMutableArray alloc]initWithCapacity:4];
    searchDisplayController = [[UISearchDisplayController alloc ]initWithSearchBar:self.searchBar
                                                                contentsController:self];
    searchDisplayController.delegate = self;
    searchDisplayController.searchResultsDataSource = self;
    
    
    UIBarButtonItem *cancel2Back = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"navigationbar_back"]
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self action:@selector(onCancel2Back:)];
    UIBarButtonItem *refreshItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"navigationbar_refresh"]
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self action:@selector(onRefreshItem:)];
    self.navigationItem.leftBarButtonItem = cancel2Back;
    self.navigationItem.rightBarButtonItem = refreshItem;
//    访问新浪的服务器
    [self requestFriendContactsFromServer];
}

//    展示所有联系人界面的取消按钮
- (void)onCancel2Back:(UIBarButtonItem *)cancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

//    展示所有联系人的刷新按钮
- (void)onRefreshItem:(UIBarButtonItem *)refreshItem
{
    [self requestFriendContactsFromServer];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

//    向服务器请求数据
- (void)requestFriendContactsFromServer
{
    
    SinaWeibo *sinaweibo = appDelegate.sinaWeibo;
    [sinaweibo requestWithURL:@"friendships/friends.json"
                       params:[NSMutableDictionary dictionaryWithObject:sinaweibo.userID forKey:@"uid"]
                   httpMethod:@"GET"
                     delegate:self];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark UITableViewDelegate



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == searchDisplayController.searchResultsTableView) {
         return self.showContacts.allKeys.count;
    }else{
        return self.showAllContacts.allKeys.count;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == searchDisplayController.searchResultsTableView) {
        NSString *key = self.sectionTitle[section];
        NSArray *friends = self.showContacts[key];
        return friends.count;
    }else{
        NSString *key = self.allSectionTitle[section];
        NSArray *friends = self.showAllContacts[key];
        return friends.count;

    }
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == searchDisplayController.searchResultsTableView) {
        return self.sectionTitle[section];
    }else{
        return self.allSectionTitle[section];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:friendId];
        if (nil == cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:friendId];
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 2, 35, 35)];
            imageView.tag = kContactsImageView;
            UILabel *contactsLabel = [[UILabel alloc]initWithFrame:CGRectMake(imageView.bounds.size.height + 5, 2, 200, 35)];
            contactsLabel.tag = kContactsLabel;
            [cell.contentView addSubview:imageView];
            [cell.contentView addSubview:contactsLabel];
        }
    if (tableView == searchDisplayController.searchResultsTableView) {
        UIImageView *imgView = (UIImageView*)[cell.contentView viewWithTag:kContactsImageView];
        UILabel *contactLabel = (UILabel*)[cell.contentView viewWithTag:kContactsLabel];
        NSString *key = self.sectionTitle[indexPath.section];
        NSArray *friends = self.showContacts[key];
        NSDictionary *cellData = friends[indexPath.row];
        [imgView setImageWithURL:[NSURL URLWithString:[cellData objectForKey:@"avatar_hd"]]];
        contactLabel.text = [cellData objectForKey:@"screen_name"];

    }else{
        UIImageView *imgView = (UIImageView*)[cell.contentView viewWithTag:kContactsImageView];
        UILabel *contactLabel = (UILabel*)[cell.contentView viewWithTag:kContactsLabel];
        NSString *key = self.allSectionTitle[indexPath.section];
        NSArray *friends = self.showAllContacts[key];
        NSDictionary *cellData = friends[indexPath.row];
        [imgView setImageWithURL:[NSURL URLWithString:[cellData objectForKey:@"avatar_hd"]]];
        contactLabel.text = [cellData objectForKey:@"screen_name"];
    }
    return cell;
}

//- (void)showDataWithTitle:(NSArray *)sectionTitle andContacts:(NSMutableDictionary*)contacts onTableViewCell:(UITableViewCell*)cell
//{
//    UIImageView *imgView = (UIImageView*)[cell.contentView viewWithTag:kContactsImageView];
//    UILabel *contactLabel = (UILabel*)[cell.contentView viewWithTag:kContactsLabel];
//    NSString *key = self.allSectionTitle[indexPath.section];
//    NSArray *friends = self.showAllContacts[key];
//    NSDictionary *cellData = friends[indexPath.row];
//    [imgView setImageWithURL:[NSURL URLWithString:[cellData objectForKey:@"avatar_hd"]]];
//    contactLabel.text = [cellData objectForKey:@"screen_name"];
//
//}

- (NSArray*)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (tableView == searchDisplayController.searchResultsTableView) {
        return self.sectionTitle;

    }else{
        return self.allSectionTitle;
    }
}


#pragma mark -
#pragma mark Search Display Delegate Method

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    if (searchString.length > 0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"screen_name CONTAINS[c] %@",searchString];
        self.modifiedFriendContacts = [self.orginalFriendContacts filteredArrayUsingPredicate:predicate];
        [self createShowDataStruct];
        [searchDisplayController.searchResultsTableView reloadData];
    }else
    {
        [self createShowAllDataStruct];
        [self.tableView reloadData];
    }
    return YES;
}

//    搜索结束的时候按cancel 按钮的时候调用这个事件
- (void) searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    [self createShowAllDataStruct];
    [self.tableView reloadData];
}


#pragma mark -
#pragma mark SinaWeiboRequestDelegate

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
    self.orginalFriendContacts = [result objectForKey:@"users"];
    self.modifiedFriendContacts = [self.orginalFriendContacts copy];
    [self createShowAllDataStruct];
    [self.tableView reloadData];
}

- (NSString *) getPinYinNameFirstLetter:(NSString*)username
{
	if ([username canBeConvertedToEncoding: NSASCIIStringEncoding]) {
        //如果是英语
		return [[NSString stringWithFormat:@"%c",[username characterAtIndex:0]] uppercaseString];
	}
	else {
        //如果是汉子的名字，则取汉子的拼音首字母
		return [[NSString stringWithFormat:@"%c",pinyinFirstLetter([username characterAtIndex:0])] uppercaseString];
	}
}

//    创建搜索后的结果数据
- (void)createShowDataStruct
{
    NSMutableDictionary *contactDictionary = [[NSMutableDictionary alloc] init];
    for (NSDictionary *dicContact in self.modifiedFriendContacts)
    {
        NSString *friendName = [dicContact objectForKey:@"screen_name"];
        NSString *nameFirstLetter = [self getPinYinNameFirstLetter:friendName];
        
        //判断nameFirstLeter是不是一个英文字符
        if (!isalpha([nameFirstLetter characterAtIndex:0])) {
            nameFirstLetter = @"#";
        }
        NSMutableArray  *tempContactArray = [contactDictionary objectForKey:nameFirstLetter];
        if (nil == tempContactArray) {
            tempContactArray = [[NSMutableArray alloc] init];
            [tempContactArray addObject:dicContact];
            [contactDictionary setObject:tempContactArray forKey:nameFirstLetter];
            [tempContactArray release];
        }
//        else{
//            [tempContactArray addObject:dicContact];
//        }
    }
    self.showContacts = contactDictionary;
    
    //将字典所有的key按字母进行排序（不区大小写）
    NSMutableArray *titlesArry = [[[contactDictionary allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]mutableCopy];
    
    NSInteger indexOfJing = [titlesArry indexOfObject:@"#"];
    if(indexOfJing != NSNotFound){
        [titlesArry removeObjectAtIndex:indexOfJing];
        [titlesArry addObject:@"#"];
    }
    self.sectionTitle = titlesArry;
    [titlesArry release];
}

//创建所有人的数据
- (void)createShowAllDataStruct
{
    NSMutableDictionary *contactDictionary = [[NSMutableDictionary alloc] init];
    for (NSDictionary *dicContact in self.orginalFriendContacts)
    {
        NSString *friendName = [dicContact objectForKey:@"screen_name"];
        NSString *nameFirstLetter = [self getPinYinNameFirstLetter:friendName];
        
        //判断nameFirstLeter是不是一个英文字符
        if (!isalpha([nameFirstLetter characterAtIndex:0])) {
            nameFirstLetter = @"#";
        }
        NSMutableArray  *tempContactArray = [contactDictionary objectForKey:nameFirstLetter];
        if (nil == tempContactArray) {
            tempContactArray = [[NSMutableArray alloc] init];
            [tempContactArray addObject:dicContact];
            [contactDictionary setObject:tempContactArray forKey:nameFirstLetter];
            [tempContactArray release];
        }
        else{
            [tempContactArray addObject:dicContact];
        }
    }
    self.showAllContacts = contactDictionary;
    
    //将字典所有的key按字母进行排序（不区大小写）
    NSMutableArray *titlesArry = [[[contactDictionary allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]mutableCopy];
    
    NSInteger indexOfJing = [titlesArry indexOfObject:@"#"];
    if(indexOfJing != NSNotFound){
        [titlesArry removeObjectAtIndex:indexOfJing];
        [titlesArry addObject:@"#"];
    }
    self.allSectionTitle = titlesArry;
    [titlesArry release];
}



@end
