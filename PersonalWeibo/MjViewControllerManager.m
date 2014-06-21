//
//  MjViewControllerManager.m
//  PersonalWeibo
//
//  Created by qingyun on 14-6-6.
//  Copyright (c) 2014年 hnqingyun. All rights reserved.
//

#import "MjViewControllerManager.h"
#import "MjLoginViewController.h"
#import "MjUserGuideViewController.h"
#import "MjMainViewController.h"



@implementation MjViewControllerManager

+ (void)presentMjController:(MjViewControllerType)controllerType
{
    UIViewController *controller = [[[self alloc] init] controllerByType:controllerType];
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    window.rootViewController = controller;
}

- (UIViewController *)controllerByType:(MjViewControllerType)type
{
    UIViewController *controller = nil;
    
    switch (type) {
        case MjuserGuideViewController:
            controller = [self userGuideViewController];
            break;
        case MjloginViewController:
            controller = [self loginViewController];
            break;
        case MjmainViewController:
            controller = [self mainViewController];
            break;
            
        default:
            break;
    }
    
    return controller;
}

- ( MjLoginViewController*)loginViewController
{
    MjLoginViewController *login = [[MjLoginViewController alloc] init];
    return login;
}

- (MjUserGuideViewController *)userGuideViewController
{
    MjUserGuideViewController *userGuide = [[MjUserGuideViewController alloc] init];
    return userGuide;
}

- (MjMainViewController *)mainViewController
{
    MjMainViewController *main = [[MjMainViewController alloc] init];
    return main;
}
@end
