//
//  MjAppDelegate.h
//  PersonalWeibo
//
//  Created by qingyun on 14-6-4.
//  Copyright (c) 2014年 hnqingyun. All rights reserved.
//

#import <UIKit/UIKit.h>

//@class SinaWeibo;
@interface MjAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic,retain) SinaWeibo *sinaWeibo;

@end
