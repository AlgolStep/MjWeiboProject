//
//  PNSmartTableViewCell.h
//  SmartTableCell
//
//  Created by mac on 13-11-5.
//  Copyright (c) 2013年 bjpowernode. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MjSmartTableViewCell : UITableViewCell

+(id)cellForTableViewWithIdentifer:(UITableView*)tableView;
+(NSString*)identifier;

- (id)initWithIdentifier:(NSString*)cellID;
@end
