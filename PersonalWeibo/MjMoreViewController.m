//
//  MjMoreViewController.m
//  PersonalWeibo
//
//  Created by qingyun on 14-6-15.
//  Copyright (c) 2014年 hnqingyun. All rights reserved.
//

#import "MjMoreViewController.h"
#import "MjEditViewController.h"


@interface MjMoreViewController ()
@property (retain, nonatomic) IBOutlet UIView *buttonView;

@end

@implementation MjMoreViewController
{
    CGRect oldFrame;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UIImage *image = [UIImage imageNamed:@"tabbar_compose_background_icon_add"];
        [self.tabBarItem initWithTitle:@""
                                 image:[image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                         selectedImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        oldFrame = self.buttonView.frame;
        CGRect frame = CGRectZero;
        self.buttonView.frame = frame;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    CGRect newFrame = CGRectMake(0, 0, 320, 568);
//    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationDuration:10.0];
//    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
//    self.buttonView.frame = newFrame;
//    [UIView commitAnimations];
    
    [UIView animateWithDuration:2.0
                          delay:2.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                            self.buttonView.frame = newFrame;
                        } completion:nil];

}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
    self.navigationController.navigationBarHidden = YES;
}
- (IBAction)onEdit:(id)sender {
    MjEditViewController *editViewController = [[MjEditViewController alloc]init];
    [self presentViewController:editViewController animated:YES completion:nil];
//    [self.navigationController pushViewController:editViewController animated:YES];
}
- (IBAction)onBackButton:(id)sender {
    
//    [self presentViewController:homeView animated:YES completion:nil];
    
    [MjViewControllerManager presentMjController:MjmainViewController];
    self.tabBarController.tabBar.hidden = NO;
    self.navigationController.navigationBarHidden = NO;

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_buttonView release];
    [super dealloc];
}
@end
