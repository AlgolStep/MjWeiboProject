//
//  MjMainViewController.m
//  PersonalWeibo
//
//  Created by qingyun on 14-6-6.
//  Copyright (c) 2014年 hnqingyun. All rights reserved.
//

#import "MjMainViewController.h"
#import "MjHomeViewController.h"
#import "MjMessageViewController.h"
#import "MjAboutMeViewController.h"
#import "MjPlazaViewController.h"
#import "MjMoreViewController.h"


@interface MjMainViewController ()

@end

@implementation MjMainViewController

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
    MjHomeViewController *homeVCtrl = [[MjHomeViewController alloc] initWithStyle:UITableViewStyleGrouped];

    MjMessageViewController *messageVCtrl = [[MjMessageViewController alloc] init];
    
    MjAboutMeViewController *aboutMeVCtrl = [[MjAboutMeViewController alloc] initWithStyle:UITableViewStyleGrouped];
    
    MjPlazaViewController *plazaVCtrl = [[MjPlazaViewController alloc] initWithCollectionViewLayout:[[UICollectionViewFlowLayout alloc] init ]];
    
    MjMoreViewController *moreVCtrl = [[MjMoreViewController alloc] init];
    
    NSArray *viewControllers = @[homeVCtrl,messageVCtrl,moreVCtrl,plazaVCtrl,aboutMeVCtrl];
    
    NSMutableArray *viewNavControlles = [[NSMutableArray alloc] initWithCapacity:6];
    for (UIViewController *vctrlItem in viewControllers) {
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vctrlItem];
        [viewNavControlles addObject:nav];
        [nav release];
    }
    self.viewControllers = viewNavControlles;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
