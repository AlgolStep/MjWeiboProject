//
//  MjEditViewController.h
//  PersonalWeibo
//
//  Created by qingyun on 14-6-12.
//  Copyright (c) 2014年 hnqingyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MjEditViewController : UIViewController<UITextViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate>
@property (nonatomic, assign)BOOL isTextEdited;
@property (nonatomic, assign)BOOL isKeyBoardToolShow;
@property (nonatomic, retain)NSDictionary *mDicStatus;
@end
