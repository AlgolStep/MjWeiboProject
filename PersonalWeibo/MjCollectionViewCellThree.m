//
//  MjCollectionViewCellThree.m
//  PersonalWeibo
//
//  Created by qingyun on 14-6-23.
//  Copyright (c) 2014年 hnqingyun. All rights reserved.
//

#import "MjCollectionViewCellThree.h"

@implementation MjCollectionViewCellThree

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        _labelTrend = [[UILabel alloc]initWithFrame:CGRectZero];
        _labelTrend.textAlignment = NSTextAlignmentCenter;
        _labelTrend.font = [UIFont systemFontOfSize:14.0f];
        [self.contentView addSubview:_labelTrend];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGRect frame = CGRectMake(0, 0, 140, 40);
    self.labelTrend.frame = frame;
    self.labelTrend.text = [NSString stringWithFormat:@"#%@#",[self.mDicTrends objectForKey:@"name"]];
}


@end
