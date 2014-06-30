//
//  MjDraftsViewController.m
//  PersonalWeibo
//
//  Created by qingyun on 14-6-21.
//  Copyright (c) 2014年 hnqingyun. All rights reserved.
//

#import "MjDraftsViewController.h"
#import "MjEditViewController.h"
#import "MjSmartTableViewCell.h"
#import "MjWeiBoDataEngine.h"

@interface MjDraftsViewController ()

@end

@implementation MjDraftsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    if (self = [super initWithStyle:style]) {
        self.title = @"草稿箱";
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.draftStatus = [[MjWeiBoDataEngine shareInstance] queryTimeLinesFromDataBase];
//    if (nil != self.draftStatus && 0 < self.draftStatus.count) {
//        <#statements#>
//    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.draftStatus.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MjSmartTableViewCell *cell = [ MjSmartTableViewCell cellForTableViewWithIdentifer:tableView withCellStyle:UITableViewCellStyleDefault];
    cell.textLabel.text = [self.draftStatus[indexPath.row] objectForKey:kStatusText];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MjEditViewController *editViewController = [[MjEditViewController alloc]init];
    editViewController.mDicStatus = self.draftStatus[indexPath.row];
    [self.navigationController pushViewController:editViewController animated:YES];
    MjSafeRelease(editViewController);
}

@end
