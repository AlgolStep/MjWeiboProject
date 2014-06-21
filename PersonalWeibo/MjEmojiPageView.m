//
//  MjEmojiPageView.m
//  PersonalWeibo
//
//  Created by qingyun on 14-6-16.
//  Copyright (c) 2014年 hnqingyun. All rights reserved.
//

#import "MjEmojiPageView.h"
#import "Emoji.h"

@interface MjEmojiPageView ()
@property (nonatomic, retain)NSArray *allEmojis;

@end

@implementation MjEmojiPageView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _allEmojis = [Emoji allEmoji];
    }
    return self;
}

//一个界面上显示4行9列
- (void)loadEmojiItem:(int)page size:(CGSize)size
{
    //    row number
    for (int i = 0; i < 4; i ++) {
        //列 数
        for (int y = 0; y < 9; y ++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setBackgroundColor:[UIColor clearColor]];
            [button setFrame:CGRectMake(y*size.width, i*size.height, size.width, size.height)];
            //            设置每个页面的最后的那个删除键
            if (i == 3 && y == 8) {
                [button setImage:[UIImage imageNamed:@"compose_emotion_delete_highlighted"] forState:UIControlStateNormal];
                button.tag = 1000;
            }else{
                [button.titleLabel setFont:[UIFont fontWithName:@"AppleColorEmoji" size:19.0]];
                [button setTitle:[_allEmojis objectAtIndex:i*9+y+(page*35)] forState:UIControlStateNormal];
                button.tag = i*9+y+(page*35);
            }
            
            [button addTarget:self action:@selector(selected:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:button];
        }
    }
}


- (void)selected:(UIButton*)sender
{
    if (sender.tag == 1000) {
        [_deleagte didSelectedEmojiItemView:@""];
    }else{
        NSString *str = [_allEmojis objectAtIndex:sender.tag];
        [_deleagte didSelectedEmojiItemView:str];
    }
}


+ (NSUInteger)pagesForAllEmoji:(int)countPerPage
{
    NSArray *emojis = [Emoji allEmoji];
    return  emojis.count/countPerPage;
}




/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
