//
//  MjWeiBoDataEngine.h
//  PersonalWeibo
//
//  Created by qingyun on 14-6-20.
//  Copyright (c) 2014年 hnqingyun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MjWeiBoDataEngine : NSObject


//由于考虑到数据库的使用，一个对象就可以满足需求，所以声明一个单例对象
+ (instancetype)shareInstance;

//将单条微博数据保存到数据库
- (void)saveStatusToDataBase:(NSDictionary*)dicStatus;

//将获取的所有的微博保存到数据库中
- (void)saveTimeLinesToDataBase:(NSArray*)timeLines;

//将用户信息保存到数据库
- (void)saveUserInfoToDataBase:(NSDictionary*)dicUserInfo withStatusID:(NSString*)statusID;


//将编辑信息保存到草稿箱
- (void)saveTempStatusToDrafts:(NSDictionary*)tempStatus;

//从数据库查询微博信息
- (NSArray*)queryTimeLinesFromDataBase;

//从数据查询用户信息
- (NSArray*)queryUserInfoFromDataBase;

//从数据库中查询草稿箱的信息
- (NSArray*)queryTempStatusFromDataBase;
@end
