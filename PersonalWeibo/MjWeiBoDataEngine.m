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
    if (dicStatus != nil) {
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
    [self saveUserInfoToDataBase:[dicStatus objectForKey:kStatusUserInfo] withStatusID:[dicStatus objectForKey:kStatusID]];
//    如果当前微博有转发微博的话，需要递归一次，将转发微博的信息也保存在数据库
    NSDictionary *dicRetweetStatus = [dicStatus objectForKey:kStatusRetweetStatus];
    if (dicRetweetStatus != nil) {
        [self saveStatusToDataBase:dicRetweetStatus];
    }else
    {
        NSLog(@"Warning:save data parameter is empty");
    }
}

}
#pragma mark - 将获取到的所有微博信息保存到数据库
-(void)saveTimeLinesToDataBase:(NSArray *)timeLines
{
    if (timeLines != nil && timeLines.count != 0) {
        for (NSDictionary *statusInfo in timeLines) {
            [self saveStatusToDataBase:statusInfo];
        }
    }
}
- (void)saveUserInfoToDataBase:(NSDictionary *)dicUserInfo withStatusID:(NSString *)statusID
{
//    防御性编程，确保传入参数是合法的
    if (dicUserInfo != nil) {
        NSString *sql = @"INSERT INTO T_USER \
        (id,user_id,screen_name,name,status_id,avatar_large,statuses_count,friends_count,followers_count) \
        VALUES (null,?,?,?,?,?,?,?,?)";
        BOOL isOK = [self.mDb executeUpdate:sql,[dicUserInfo objectForKey:kUserID],
                     [dicUserInfo objectForKey:kUserInfoScreenName],
                     [dicUserInfo objectForKey:kUserInfoName],
                     kStatusID,
                     [dicUserInfo objectForKey:kUserAvatarLarge],
                     [dicUserInfo objectForKey:kStatuses_count],
                     [dicUserInfo objectForKey:kFriends_count],
                     [dicUserInfo objectForKey:kFollowers_count]];
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
    where created_at < ? limit 20";
    
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
                                  kStatusRepostsCount:[resultSet objectForColumnIndex:8],
                                  kStatusCommentsCount:[resultSet objectForColumnIndex:9],
                                  kStatusAttitudesCount:[resultSet objectForColumnIndex:10],
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
                                  kStatusRepostsCount:[resultSet objectForColumnIndex:8],
                                  kStatusCommentsCount:[resultSet objectForColumnIndex:9],
                                  kStatusAttitudesCount:[resultSet objectForColumnIndex:10],
                                  kStatusUserInfo : userInfo,
                                  }];
        }
    }
    return arrayRet;
}

- (NSDictionary*)queryUserInfoFromDataBase:(NSString*)userID
{
    NSString *sql = @"SELECT user_id,screen_name,name,avatar_large,statuses_count,friends_count,followers_count FROM t_user where user_id = ?";
    FMResultSet *userInfo = [self.mDb executeQuery:sql,userID];
    NSDictionary *decRet = nil;
    while ([userInfo next]) {
        decRet = @{kUserID: [userInfo objectForColumnIndex:0],
                   kUserInfoScreenName:[userInfo objectForColumnIndex:1],
                   kUserInfoName:[userInfo objectForColumnIndex:2],
                   kUserAvatarLarge:[userInfo objectForColumnIndex:3],
                   kStatuses_count:[userInfo objectForColumnIndex:4],
                   kFriends_count:[userInfo objectForColumnIndex:5],
                   kFollowers_count:[userInfo objectForColumnIndex:6]
                   };
    }
    return decRet;
}


- (NSDictionary*)queryStatusFromDataBase:(NSString*)statusID
{
    NSString *sql = @"SELECT created_at,text,source,thumbnail_pic,original_pic\
    reposts_count,comments_count,attitudes_count FROM t_status where status_id = ?";
    FMResultSet *statusInfo = [self.mDb executeQuery:sql,statusID];
    NSDictionary *decRet = nil;
    while ([statusInfo next]) {
        decRet = @{kStatusID:statusID,
                   kStatusCreateTime: [statusInfo objectForColumnIndex:0],
                   kStatusText:[statusInfo objectForColumnIndex:1],
                   kStatusSource:[statusInfo objectForColumnIndex:2],
                   kStatusThumbnailPic:[statusInfo objectForColumnIndex:3],
                   kStatusOriginalPic:[statusInfo objectForColumnIndex:4],
                   kStatusRepostsCount:[statusInfo objectForColumnIndex:5],
                   kStatusCommentsCount:[statusInfo objectForColumnIndex:6],
                   kStatusAttitudesCount:[statusInfo objectForColumnIndex:7]};
    }
    return decRet;
}


//往草稿箱的数据表中存放数据
- (void)saveTempStatusToDrafts:(NSDictionary *)tempStatus
{
    NSString *statusText = [tempStatus objectForKey:kStatusText];
    UIImage *image = [tempStatus objectForKey:@"image"];
    NSString *sql = nil;
    if (nil != image) {
        sql = @"INSERT INTO T_DRAFTS (id,text,image) VALUES(null,?,?)";
        //       我们将image转换成二进制数据，然后保存到数据库
        NSData *imageData = UIImagePNGRepresentation(image);
        BOOL isOK = [self.mDb executeUpdate:sql,imageData];
        if (!isOK) {
            NSLog(@"insert into t_drafts error.");
        }else{
            sql = @"INSERT INTO t_drafts (id,text) values(null,?)";
            BOOL iOk = [self.mDb executeUpdate:sql,statusText];
            if (!iOk) {
                NSLog(@"insert into t_drafts with status text error");
            }
        }
    }
}

- (NSArray*)queryTempStatusFromDataBase
{
    NSString *sql = @"SELECT text,image from T_DRAFTS";
    FMResultSet *statusInfo = [self.mDb executeQuery:sql];
    NSMutableArray *resultArray = [[NSMutableArray alloc]initWithCapacity:20];
    
    while ([statusInfo next]) {
        NSData *imageData = [statusInfo dataForColumnIndex:1];
        NSDictionary *dicInfo = nil;
        if (nil != imageData) {
            dicInfo = @{kStatusText: [statusInfo objectForColumnIndex:0],
                        @"image":[statusInfo objectForColumnIndex:1]};
            
        }else{
            dicInfo = [statusInfo objectForColumnIndex:0];
        }
        [resultArray addObject:dicInfo];
    }
    return resultArray;
}
@end
