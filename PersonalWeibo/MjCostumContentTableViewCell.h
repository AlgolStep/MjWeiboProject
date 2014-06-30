//
//  MjCostumContentTableViewCell.h
//  ShareDogs
//
//  Created by qingyun on 14-5-27.
//  Copyright (c) 2014年 hnqingyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MjRichTextView.h"

@class MjCostumContentTableViewCell;
@protocol MjTableViewCellDelegate <NSObject>

- (void)statusTableCell:(MjCostumContentTableViewCell*)cell AvatarImageDidSelected:(UIGestureRecognizer*)gesture;
- (void)statusTableCell:(MjCostumContentTableViewCell*)cell StatusImageDidSelected:(UIGestureRecognizer*)gesture;
- (void)statusTableCell:(MjCostumContentTableViewCell*)cell RetStatusImageDidSelected:(UIGestureRecognizer*)gesture;

@end

@interface MjCostumContentTableViewCell : UITableViewCell<TQRichTextViewDelegate>
@property (nonatomic,retain)UIImageView *avatarImageView;
@property (nonatomic,retain)UILabel *labelScreenName;
@property (nonatomic,retain)UILabel *labelCreateTime;
@property (nonatomic,retain)UILabel *labelChannel;

//原创微博内容
@property (nonatomic,retain)MjRichTextView *labelStatus;

//原创微博内的图片
@property (nonatomic,retain)UIView *stImageViewBg;

//微博用户视图
@property (nonatomic,retain)UIView *personView;
//转发微博内容
@property (nonatomic,retain)UILabel *labelRetweetStatus;
//转发微博内的图片
@property (nonatomic,strong)UIView *retStImageViewBg;

@property (nonatomic,retain)NSDictionary *cellData;
@property (nonatomic, retain)NSDictionary *cellUserData;

//声明一个delegate，属性用assign。如果是ARC环境的话用weak
@property (nonatomic, assign)id <MjTableViewCellDelegate>delegate;

@end
