//
//  MjCollectionViewCellFour.m
//  PersonalWeibo
//
//  Created by qingyun on 14-6-23.
//  Copyright (c) 2014年 hnqingyun. All rights reserved.
//

#import "MjCollectionViewCellFour.h"

@interface MjCollectionViewCellFour ()
@property (nonatomic, retain)UILabel *labelTrend;

@end

@implementation MjCollectionViewCellFour
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        _labelTrend = [[UILabel alloc]initWithFrame:CGRectZero];
        [self.contentView addSubview:_labelTrend];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGRect frame = CGRectMake(10, 10, 57, 70);
    self.labelTrend.frame = frame;
}

@end
