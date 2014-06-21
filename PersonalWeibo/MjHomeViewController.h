//
//  MjHomeViewController.h
//  PersonalWeibo
//
//  Created by qingyun on 14-6-6.
//  Copyright (c) 2014年 hnqingyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MjHomeViewController : UITableViewController<SinaWeiboRequestDelegate>

@property (nonatomic,copy)NSArray *statusDataList;
@property (nonatomic, retain) NSDictionary *currentUserInfo;
@property (nonatomic, assign)BOOL *isSendedContent;
@end
