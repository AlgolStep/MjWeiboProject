//
//  MjAboutMeViewController.h
//  PersonalWeibo
//
//  Created by qingyun on 14-6-6.
//  Copyright (c) 2014年 hnqingyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MjAboutMeViewController : UITableViewController<SinaWeiboRequestDelegate>
@property (nonatomic, retain)NSDictionary *mDictionary;

@property (nonatomic, copy)NSArray *statusDataList;
@property (nonatomic, retain)NSArray *userTimeLines;
@property (nonatomic, retain)NSArray *fullUsrTimeLines;
@property (nonatomic, retain)NSString *userID;
@property (nonatomic, assign) BOOL bisHideTabbar;

//@property (nonatomic, assign)BOOL  *bIsHideTabbar;
@end
