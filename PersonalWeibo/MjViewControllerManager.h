//
//  MjViewControllerManager.h
//  PersonalWeibo
//
//  Created by qingyun on 14-6-6.
//  Copyright (c) 2014年 hnqingyun. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, MjViewControllerType) {
    MjuserGuideViewController,
    MjloginViewController,
    MjmainViewController
};

@interface MjViewControllerManager : NSObject

+ (void)presentMjController:(MjViewControllerType)controllerType;

@end
