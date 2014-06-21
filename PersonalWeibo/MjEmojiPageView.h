//
//  MjEmojiPageView.h
//  PersonalWeibo
//
//  Created by qingyun on 14-6-16.
//  Copyright (c) 2014年 hnqingyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Emoji.h"

@protocol EmojiViewDelegate

- (void)didSelectedEmojiItemView:(NSString*)str;

@end
@interface MjEmojiPageView : UIView
@property (nonatomic,assign)id<EmojiViewDelegate>deleagte;

- (void)loadEmojiItem:(int)page size:(CGSize)size;
+ (NSUInteger)pagesForAllEmoji:(int)countPerPage;

@end
