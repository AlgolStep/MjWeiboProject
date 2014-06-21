//
//  MjWeiBoDataEngine.m
//  PersonalWeibo
//
//  Created by qingyun on 14-6-20.
//  Copyright (c) 2014年 hnqingyun. All rights reserved.
//

#import "MjWeiBoDataEngine.h"
#import "FMDatabase.h"


@interface MjWeiBoDataEngine ()
@property (nonatomic, retain)FMDatabase *mDb;

@end

@implementation MjWeiBoDataEngine

/*
 dispatch_once
 Executes a block object once and only once for the lifetime of an application.
 
 void dispatch_once(
 dispatch_once_t *predicate,
 dispatch_block_t block);
 Parameters
 predicate
 A pointer to a dispatch_once_t structure that is used to test whether the block has completed or not.
 block
 The block object to execute once.
 Discussion
 This function is useful for initialization of global data (singletons) in an application. Always call this function before using or testing any variables that are initialized by the block.
 
 If called simultaneously from multiple threads, this function waits synchronously until the block has completed.
 
 The predicate must point to a variable stored in global or static scope. The result of using a predicate with automatic or dynamic storage (including Objective-C instance variables) is undefined.
 

 */
+ (instancetype)shareInstance
{
    static MjWeiBoDataEngine *dbEngine = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dbEngine = [[self alloc]init];
    });
    return dbEngine;
}
- (id)init
{
    if (self = [super init]) {
        NSString *dbName = [NSString stringWithFormat:@"%@.sqlite",kMjWeiboDataBaseName];
        NSString *dbPath = [self copyFile2Documents:dbName];
        self.mDb = [FMDatabase databaseWithPath:dbPath];
        if (![self.mDb open]) {
            NSLog(@"open %@ error,error msg is %@",dbPath,[self.mDb lastErrorMessage]);
        }
    }
    return self;
}

//将数据库文件从资源库剪切到Documents目录，由于在沙盒里只有Documents目录是可以读写的
- (NSString *)copyFile2Documents:(NSString*)fileName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    得到沙盒的Document目录
    NSString *documentsDirectory = [path objectAtIndex:0];
    
//    将数据库文件追加到目录的后面，stringByAppendingPathComponent自动加上目录分隔符
    NSString *destPath = [documentsDirectory stringByAppendingPathComponent:fileName];
    if (![fileManager fileExistsAtPath:destPath]) {
        NSString *sourcePath = [[NSBundle mainBundle]pathForResource:kMjWeiboDataBaseName ofType:@"sqlite"];
        [fileManager copyItemAtPath:sourcePath toPath:destPath error:&error];
    }
    return destPath;
}

//将单条微博保存到数据库
- (void)saveStatusToDataBase:(NSDictionary *)dicStatus
{
    NSString *tableName = @"T_STATUS";
    NSString *oneSpace = @" ";
    NSMutableString  *sql = [[NSMutableString alloc]initWithString:@"INSERT INTO"];
    [sql appendString:oneSpace];
    [sql appendString:tableName];
    
//    对于第一个id我们可以将其设置为null，这样数据库会对id进行自动计数
    [sql appendString:@"(id,status_id,created_at,text,source,thumbnail_pic,\
    original_pic,user_id,retweeted_status_id,reposts_count,\
    comments_count,attitudes_count) VALUES \
     (null,?,?,?,?,?,?,?,?,?,?,?)"];
    BOOL isOK = [self.mDb executeUpdate:sql,
                  [dicStatus objectForKey:kStatusID],
                  [dicStatus objectForKey:kStatusCreateTime],
                  [dicStatus objectForKey:kStatusText],
                  [dicStatus objectForKey:kStatusSource],
                  [dicStatus objectForKey:kStatusThumbnailPic],
                  [dicStatus objectForKey:kStatusOriginalPic],
                  [[dicStatus objectForKey:kStatusUserInfo] objectForKey:kUserID],
                  [[dicStatus objectForKey:kStatusRetweetStatus] objectForKey:kStatusID],
                  [dicStatus objectForKey:kStatusRepostsCount],
                 [dicStatus objectForKey:kStatusCommentsCount],
                 [dicStatus objectForKey:kStatusAttitudesCount]];
    if (!isOK) {
        NSLog(@"save stauts data error%@",[self.mDb lastErrorMessage]);
        return;
    }
//    如果当前微博有转发微博的话，需要递归一次，将转发微博的信息也保存在数据库
    NSDictionary *dicRetweetStatus = [dicStatus objectForKey:kStatusRetweetStatus];
    if (dicRetweetStatus != nil) {
        [self saveStatusToDataBase:dicRetweetStatus];
    }else
    {
        NSLog(@"Warning:save data parameter is empty");
    }
}

-(void)saveTimeLinesToDataBase:(NSArray *)timeLines
{
    for (NSDictionary *statusInfo in timeLines) {
        [self saveStatusToDataBase:statusInfo];
    }
}
- (void)saveUserInfoToDataBase:(NSDictionary *)dicUserInfo withStatusID:(NSString *)statusID
{
//    防御性编程，确保传入参数是合法的
    if (dicUserInfo != nil) {
        NSString *sql = @"INSERT INTO T_USER \
        (id,user_id,screen_name,name,status_id,avatar_large) \
        VALUES (null,?,?,?,?,?)";
        BOOL isOK = [self.mDb executeUpdate:sql,[dicUserInfo objectForKey:kUserID],
                     [dicUserInfo objectForKey:kUserInfoScreenName],
                     [dicUserInfo objectForKey:kUserInfoName],
                     kStatusID,
                     [dicUserInfo objectForKey:kUserAvatarLarge]];
        if (!isOK) {
            NSLog(@"save user info to db failed.ERROR%@",[self.mDb lastErrorMessage]);
            return;
        }
    }
}

- (NSArray*)queryTimeLinesFromDataBase
{
    NSString *sql = @"SELECT status_id,created_at,text,source, thumbnail_pic,\
    original_pic,user_id,retweeted_status_id, reposts_count,comments_count,attitudes_count\
    FROM t_status \
    WHERE created_at > ? limit 20";
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"EEE MMM dd HH:mm:ss ZZZ yyyy"];
    NSString *currentDate = [dateFormatter stringFromDate:[NSDate date]];
    FMResultSet *resultSet = [self.mDb executeQuery:sql,currentDate];
    NSMutableArray *arrayRet = [[NSMutableArray alloc]initWithCapacity:20];
    while ([resultSet next]) {
        NSDictionary *userInfo = [self queryUserInfoFromDataBase:[resultSet objectForColumnIndex:6]];
        if (nil == userInfo) {
            return nil;
        }
        NSDictionary *statusInfo = [self queryStatusFromDataBase:[resultSet objectForColumnIndex:7]];
//       如果有转发微博的话就要构建
        if (nil != statusInfo) {
            [arrayRet addObject:@{kStatusID: [resultSet objectForColumnIndex:0],
                        kStatusCreateTime : [resultSet objectForColumnIndex:1],
                              kStatusText : [resultSet objectForColumnIndex:2],
                            kStatusSource : [resultSet objectForColumnIndex:3],
                      kStatusThumbnailPic : [resultSet objectForColumnIndex:4],
                       kStatusOriginalPic : [resultSet objectForColumnIndex:5],
                          kStatusUserInfo : userInfo,
                     kStatusRetweetStatus : statusInfo,
                                 }];
        }else
        {
            [arrayRet addObject:@{kStatusID: [resultSet objectForColumnIndex:0],
                                  kStatusCreateTime : [resultSet objectForColumnIndex:1],
                                  kStatusText : [resultSet objectForColumnIndex:2],
                                  kStatusSource : [resultSet objectForColumnIndex:3],
                                  kStatusThumbnailPic : [resultSet objectForColumnIndex:4],
                                  kStatusOriginalPic : [resultSet objectForColumnIndex:5],
                                  kStatusUserInfo : userInfo,
                                  }];
        }
    }
    return arrayRet;
}

- (NSDictionary*)queryUserInfoFromDataBase:(NSString*)userID
{
    NSString *sql = @"SELECT user_id,screen_name,name,avatar_image FROM t_user WHERE user_id = ?";
    FMResultSet *userInfo = [self.mDb executeQuery:sql,userID];
    NSDictionary *decRet = nil;
    while ([userInfo next]) {
        decRet = @{kUserID: [userInfo objectForColumnIndex:0],
                   kUserInfoScreenName:[userInfo objectForColumnIndex:1],
                   kUserInfoName:[userInfo objectForColumnIndex:2],
                   kUserAvatarLarge:[userInfo objectForColumnIndex:3]};
    }
    return decRet;
}

- (NSDictionary*)queryStatusFromDataBase:(NSString*)statusID
{
    NSString *sql = @"SELECT created_at,text,source,thumbnail_pic,original_pic\
    reposts_count,comments_count,attitudes_count FROM t_status WHERE status_id = ?";
    FMResultSet *statusInfo = [self.mDb executeQuery:sql,statusID];
    NSDictionary *decRet = nil;
    while ([statusInfo next]) {
        decRet = @{kStatusID:statusID,
                   kStatusCreateTime: [statusInfo objectForColumnIndex:0],
                   kStatusSource:[statusInfo objectForColumnIndex:1],
                   kStatusThumbnailPic:[statusInfo objectForColumnIndex:2],
                   kStatusOriginalPic:[statusInfo objectForColumnIndex:3],
                   kStatusRepostsCount:[statusInfo objectForColumnIndex:4],
                   kStatusCommentsCount:[statusInfo objectForColumnIndex:5],
                   kStatusAttitudesCount:[statusInfo objectForColumnIndex:6]};
    }
    return decRet;
}

//- (NSArray*)queryUserInfoFromDataBase
//{
//    
//}
@end
