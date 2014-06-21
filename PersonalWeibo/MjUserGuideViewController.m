//
//  PNUserGuideViewController.m
//  PNWeiBoClient
//
//  Created by zhangsf on 13-8-14.
//  Copyright (c) 2013年 zhangsf. All rights reserved.
//

#import "MjUserGuideViewController.h"
#import "MjViewControllerManager.h"

@interface MjUserGuideViewController ()

@end

@implementation MjUserGuideViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mScrollView.contentSize = CGSizeMake(320*5, 460);
    for (int i = 0;  i < 5; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(320*i, 0, 320, 460)];
        NSString *imgName = [NSString stringWithFormat:@"new_features_%d.jpg",i+1];
        imageView.image = [UIImage imageNamed:imgName];
        [self.mScrollView addSubview:imageView];
        [imageView release];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.navigationController.navigationBarHidden = YES;
}

- (void)dealloc {
    [_mScrollView release];
    [_mPageControl release];
    [super dealloc];
}

#pragma mark -
#pragma mark UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int offSet = 320*4+100;
    if (scrollView.contentOffset.x - offSet > 0) {
        [MjViewControllerManager presentMjController:MjloginViewController];
    }
}
@end
