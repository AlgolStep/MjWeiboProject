//
//  MjQRCodeViewController.h
//  PersonalWeibo
//
//  Created by qingyun on 14-6-24.
//  Copyright (c) 2014年 hnqingyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface MjQRCodeViewController : UIViewController<AVCaptureMetadataOutputObjectsDelegate>
{
    int num;
    BOOL upOrDown;
    NSTimer *timer;
}

//相当于物理设备
@property (nonatomic, strong)AVCaptureDevice *device;
@property (nonatomic, strong)AVCaptureDeviceInput *input;
@property (nonatomic, strong)AVCaptureMetadataOutput *output;
@property (nonatomic, strong)AVCaptureSession *session;
@property (nonatomic, strong)AVCaptureVideoPreviewLayer *preview;
@property (nonatomic, strong)UIImageView *line;

@end
