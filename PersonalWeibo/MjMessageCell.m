//
//  MjMessageCell.m
//  PersonalWeibo
//
//  Created by qingyun on 14-6-26.
//  Copyright (c) 2014年 hnqingyun. All rights reserved.
//

#import "MjMessageCell.h"

@implementation MjMessageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return  self;
}

- (void)awakeFromNib
{
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.bounds = CGRectMake(0, 0, 50, 50);
}
@end
