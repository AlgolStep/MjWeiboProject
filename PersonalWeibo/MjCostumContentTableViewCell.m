//
//  MjCostumContentTableViewCell.m
//  ShareDogs
//
//  Created by qingyun on 14-5-27.
//  Copyright (c) 2014年 hnqingyun. All rights reserved.
//

#import "MjCostumContentTableViewCell.h"
#import "XMLDictionary.h"
#import "UIImageView+WebCache.h"
#import "NSString+FrameHeight.h"


@implementation MjCostumContentTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        CGFloat fontSize = 14.0f;
        
        //        好友微博的头像
        _avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 35, 35)];
        //       因为UIImageView默认情况下是不能交互， 也就是默认情况下放在其上的控件不能点击，手势也不起作用
        _avatarImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTapAvatarImage:)];
        [self.avatarImageView addGestureRecognizer:gesture];
        [self.contentView addSubview:_avatarImageView];
        //        微博好友的昵称
        _labelScreenName = [[UILabel alloc] initWithFrame:CGRectZero];
        _labelScreenName.font = [UIFont systemFontOfSize:fontSize];
        [self.contentView addSubview:_labelScreenName];
        
        //        微博内容的创建时间
        _labelCreateTime = [[UILabel alloc] initWithFrame:CGRectZero];
        _labelCreateTime.font = [UIFont systemFontOfSize:fontSize];
        [self.contentView addSubview:_labelCreateTime];
        
        //        微博来源
        _labelChannel = [[UILabel alloc] initWithFrame:CGRectZero];
        _labelChannel.font = [UIFont systemFontOfSize:fontSize];
        [self.contentView addSubview:_labelChannel];
        
        //        微博正文
        _labelStatus = [[UILabel alloc] initWithFrame:CGRectZero];
        _labelStatus.font = [UIFont systemFontOfSize:fontSize];
        _labelStatus.numberOfLines = 0;
       
        [self.contentView addSubview:_labelStatus];
        
        //        创建原创微博图片视图
        _stImageViewBg = [[UIView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:_stImageViewBg];
        
        //         转发微博内容的正文
        _labelRetweetStatus = [[UILabel alloc] initWithFrame:CGRectZero];
        _labelRetweetStatus.font = [UIFont systemFontOfSize:fontSize];
        _labelRetweetStatus.numberOfLines = 0;
        _labelRetweetStatus.backgroundColor = [UIColor lightGrayColor];
        [self.contentView addSubview:_labelRetweetStatus];
        
        //        转发微博的图片视图
        _retStImageViewBg = [[UIView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:_retStImageViewBg];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)reLoadViewFrame
{
    self.labelStatus.frame = CGRectZero;
    self.labelRetweetStatus.frame = CGRectZero;
    self.stImageViewBg.frame = CGRectZero;
    self.retStImageViewBg.frame = CGRectZero;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self reLoadViewFrame];
    NSDictionary *dicUserInfo = [self.cellData objectForKey:@"user"];
    NSDictionary *statusInfo = self.cellData;
    NSUInteger widthSpace = 5;
    CGFloat fontSize = 14.0f;

    //    好友微博的头像
    NSURL *imgURL = [NSURL URLWithString:[dicUserInfo objectForKey:@"profile_image_url"]];
    [self.avatarImageView setImageWithURL:imgURL];
    
    //    微博用户名称
    self.labelScreenName.frame = CGRectMake(CGRectGetMaxX(self.avatarImageView.frame)+widthSpace, 2, 100, 20);
    self.labelScreenName.text = [dicUserInfo objectForKey:@"screen_name"];
    
    //    微博创建时间
    self.labelCreateTime.frame = CGRectMake(CGRectGetMaxX(self.avatarImageView.frame)+widthSpace,CGRectGetHeight(_labelScreenName.frame)+ 2,150,20);
    NSString *strDate = [statusInfo objectForKey:@"created_at"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEE MMM dd HH:mm:ss ZZZ yyyy"];
    NSDate *dateFromString = [dateFormatter dateFromString:strDate];
    NSTimeInterval interval = [dateFromString timeIntervalSinceNow];
    if (abs((int)interval/60) < 1.0) {
        self.labelCreateTime.text = @"刚刚";
    }else{
        self.labelCreateTime.text = [NSString stringWithFormat:@"%d分钟之前",abs((int)interval/60)];
    }
    
    //    微博来源
    self.labelChannel.frame = CGRectMake(CGRectGetMaxX(self.labelCreateTime.frame), CGRectGetHeight(_labelScreenName.frame)+2, 150, 20);
    NSString *xmlSourceString = [statusInfo objectForKey:@"source"];
    NSDictionary *dicSource = [NSDictionary  dictionaryWithXMLString:xmlSourceString];
    self.labelChannel.text = [dicSource objectForKey:@"__text"];
    
    //    微博正文
    NSString *statusText = [statusInfo objectForKey:@"text"];
    self.labelStatus.text = statusText;
    CGRect newFrame = CGRectMake(widthSpace, CGRectGetMaxY(self.labelChannel.frame)+widthSpace, 310, [statusText initHeightWithFontSize:fontSize forViewWidth:310.f]);
    self.labelStatus.frame = newFrame;
    
    for (UIView *retView in [self.retStImageViewBg subviews]) {
        [retView removeFromSuperview];
    }
    self.labelRetweetStatus.frame = CGRectZero;
    
    for (UIView *stView in [self.stImageViewBg subviews]) {
        [stView removeFromSuperview];
    }
    
    NSUInteger statusImageWidth = 80.0f;
    NSUInteger statusImageHeight = 80.0f;
    NSDictionary *retweetStatusInfo = [self.cellData objectForKey:@"retweeted_status"];
    //  当这条微博是一条转发微博
    if (retweetStatusInfo != nil) {
        //    转发微博正文
        NSString *statusText = [retweetStatusInfo objectForKey:@"text"];
        self.labelRetweetStatus.text = statusText;
        CGRect newFrame = CGRectMake(widthSpace, CGRectGetMaxY(self.labelStatus.frame)+widthSpace, 310, [statusText initHeightWithFontSize:fontSize forViewWidth:310.f]);
        self.labelRetweetStatus.frame = newFrame;
        
        //   转发微博正文附带图片
        NSArray *retStatusPicUrls = [retweetStatusInfo objectForKey:@"pic_urls"];
        if (retStatusPicUrls.count > 1) {
            self.retStImageViewBg.frame = CGRectMake(widthSpace, CGRectGetMaxY(self.labelRetweetStatus.frame), 310, statusImageWidth * ceilf(retStatusPicUrls.count /3.0f));
            for (int i = 0 ; i < retStatusPicUrls.count; i++) {
                UIImageView *stImgView = nil;
                UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTapRetImage:)];
                
                if (retStatusPicUrls.count == 4) {
                    stImgView = [[UIImageView alloc] initWithFrame:CGRectMake(5+statusImageWidth*(i%2), statusImageHeight*ceil(i/2), statusImageWidth, statusImageHeight)];
                }else
                {
                    stImgView = [[UIImageView alloc] initWithFrame:CGRectMake(5+statusImageWidth*(i%3), statusImageHeight*ceil(i/3), statusImageWidth, statusImageHeight)];
                }
                
                 stImgView.userInteractionEnabled = YES;
                if (stImgView.userInteractionEnabled) {
                        [stImgView addGestureRecognizer:tapGesture];
                }
                
                
                NSString *strPicUrls = [retStatusPicUrls[i] objectForKey:@"thumbnail_pic"];
                [stImgView setImageWithURL:[NSURL URLWithString:strPicUrls]];
                [self.retStImageViewBg addSubview:stImgView];
            }
        }else if (retStatusPicUrls.count == 1)
        {
            
            NSString *strPicUrls = [retStatusPicUrls[0] objectForKey:@"thumbnail_pic"];
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:strPicUrls]]];
            
            UIImageView *stImgView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, image.size.width, image.size.height)];
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTapRetImage:)];
            stImgView.userInteractionEnabled = YES;
            [stImgView addGestureRecognizer:tapGesture];
            [stImgView setImage:image];
            
            [self.retStImageViewBg addSubview:stImgView];
            self.retStImageViewBg.frame = CGRectMake(widthSpace, CGRectGetMaxY(self.labelRetweetStatus.frame), image.size.width, image.size.height);
        }
        
        
    }else
    {
        //   微博正文附带图片
        NSArray *statusPicUrls = [statusInfo objectForKey:@"pic_urls"];
        if (statusPicUrls.count > 1) {
            self.stImageViewBg.frame = CGRectMake(0, CGRectGetMaxY(self.labelStatus.frame), 310, 80 * ceilf(statusPicUrls.count /3.0f));
            for (int i = 0 ; i < statusPicUrls.count; i++) {
                UIImageView *stImgView = nil;
                if (statusPicUrls.count == 4) {
                    stImgView = [[UIImageView alloc] initWithFrame:CGRectMake(5+statusImageWidth*(i%2), statusImageHeight*ceil(i/2), statusImageWidth, statusImageHeight)];
                }else
                {
                    stImgView = [[UIImageView alloc] initWithFrame:CGRectMake(5+statusImageWidth*(i%3), statusImageHeight*ceil(i/3), statusImageWidth, statusImageHeight)];
                }
                
                NSString *strPicUrls = [statusPicUrls[i] objectForKey:@"thumbnail_pic"];
                [stImgView setImageWithURL:[NSURL URLWithString:strPicUrls]];
                [self.stImageViewBg addSubview:stImgView];
            }
        }else if (statusPicUrls.count == 1)
        {
            
            NSString *strPicUrls = [statusPicUrls[0] objectForKey:@"thumbnail_pic"];
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:strPicUrls]]];
            UIImageView *stImgView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, image.size.width, image.size.height)];
            NSLog(@"%@",strPicUrls);
            [stImgView setImage:image];
            [self.stImageViewBg addSubview:stImgView];
            self.stImageViewBg.frame = CGRectMake(widthSpace, CGRectGetMaxY(self.labelStatus.frame), image.size.width, image.size.height);
        }
    }
}

- (void)onTapAvatarImage:(UITapGestureRecognizer*)gesture
{
    if ([self.delegate respondsToSelector:@selector(statusTableCell:AvatarImageDidSelected:)]) {
        [self.delegate statusTableCell:self AvatarImageDidSelected:gesture];
    }
}

- (void)onTapRetImage:(UITapGestureRecognizer*)gesture
{
    if ([self.delegate respondsToSelector:@selector(statusTableCell:RetStatusImageDidSelected:)]) {
        [self.delegate statusTableCell:self RetStatusImageDidSelected:gesture];
    }
}

//- (void)dealloc
//{
//    
//   
//    [super dealloc];
//}

@end
