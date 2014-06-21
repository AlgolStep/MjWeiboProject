//
//  PNUserGuideViewController.h
//  PNWeiBoClient
//
//  Created by zhangsf on 13-8-14.
//  Copyright (c) 2013年 zhangsf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MjUserGuideViewController : UIViewController <UIScrollViewDelegate>
@property (retain, nonatomic) IBOutlet UIScrollView *mScrollView;
@property (retain, nonatomic) IBOutlet UIPageControl *mPageControl;

@end
