//
//  MjSinaDelegate.m
//  PersonalWeibo
//
//  Created by qingyun on 14-6-6.
//  Copyright (c) 2014年 hnqingyun. All rights reserved.
//

#import "MjSinaDelegate.h"

static NSString * const kSinaWeiBoAuthData = @"SinaWeiboAuthData";
@implementation MjSinaDelegate

- (void)sinaweiboDidLogIn:(SinaWeibo *)sinaweibo
{
    NSLog(@"sinaweiboDidLogIn userID = %@ accesstoken = %@ expirationDate = %@ refresh_token = %@", sinaweibo.userID, sinaweibo.accessToken, sinaweibo.expirationDate,sinaweibo.refreshToken);
    [self storeAuthData:sinaweibo];
    [MjNSDC postNotificationName:kMjNotificationNameLogin object:nil];
}

- (void)storeAuthData:(SinaWeibo*)sinaweibo
{
    NSDictionary *authData = [NSDictionary dictionaryWithObjectsAndKeys:
                              sinaweibo.accessToken, @"AccessTokenKey",
                              sinaweibo.expirationDate, @"ExpirationDateKey",
                              sinaweibo.userID, @"UserIDKey",
                              sinaweibo.refreshToken, @"refresh_token", nil];
    [NSUD setObject:authData forKey:kSinaWeiBoAuthData];
    [NSUD synchronize];
}


- (void)removeAuthData:(SinaWeibo*)sinaweibo
{
    [NSUD removeObjectForKey:kSinaWeiBoAuthData];
    [NSUD synchronize];
}
- (void)sinaweiboDidLogOut:(SinaWeibo *)sinaweibo
{
    [MjNSDC postNotificationName:kMjNotificationNameLogout object:nil];
    [self removeAuthData:sinaweibo];
}

@end
