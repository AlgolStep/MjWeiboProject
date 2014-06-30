//
//  MjLoginViewController.m
//  PersonalWeibo
//
//  Created by qingyun on 14-6-6.
//  Copyright (c) 2014年 hnqingyun. All rights reserved.
//

#import "MjLoginViewController.h"

@interface MjLoginViewController ()

@end

@implementation MjLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)onLogin:(id)sender {
    [appDelegate.sinaWeibo logIn];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [MjNSDC addObserver:self selector:@selector(onLoginNotification:) name:kMjNotificationNameLogin object:nil];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
    [MjNSDC removeObserver:self name:kMjNotificationNameLogin object:nil];
}

- (void)onLoginNotification:(NSNotification*)notification
{
    [MjViewControllerManager presentMjController:MjmainViewController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
