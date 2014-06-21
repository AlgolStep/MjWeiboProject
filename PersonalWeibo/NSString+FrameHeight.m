//
//  NSString+FrameHeight.m
//  PersonalWeibo
//
//  Created by qingyun on 14-6-19.
//  Copyright (c) 2014年 hnqingyun. All rights reserved.
//

#import "NSString+FrameHeight.h"

@implementation NSString (FrameHeight)

 - (CGFloat)initHeightWithFontSize:(CGFloat)fontSize forViewWidth:(CGFloat)viewWidth
{
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]};
    CGSize size = [self sizeWithAttributes:attributes];
    NSUInteger wordPerLine = floor(viewWidth/fontSize);
    CGFloat widthPerLine = fontSize*wordPerLine;
    NSUInteger nLines = ceil(size.width/widthPerLine);
    CGFloat height = nLines*(size.height);
    return height;
}
@end
