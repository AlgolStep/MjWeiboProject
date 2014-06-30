//
//  MjQRCodeViewController.m
//  PersonalWeibo
//
//  Created by qingyun on 14-6-24.
//  Copyright (c) 2014年 hnqingyun. All rights reserved.
//

#import "MjQRCodeViewController.h"

@interface MjQRCodeViewController ()

@end

@implementation MjQRCodeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];
    UIButton *scanButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [scanButton setTitle:@"取消" forState:UIControlStateNormal];
    scanButton.frame = CGRectMake(100, 420, 120, 40);
    [scanButton addTarget:self action:@selector(backButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:scanButton];
    
    UILabel *labelIntroduction = [[UILabel alloc]initWithFrame:CGRectMake(15, 40, 290, 50)];
    labelIntroduction.backgroundColor = [UIColor clearColor];
    labelIntroduction.numberOfLines = 2;
    labelIntroduction.textColor = [UIColor whiteColor];
    labelIntroduction.text = @"将二维码图像置于矩形方框内，离手机摄像头10CM左右，系统会自动识别。";
    [self.view addSubview:labelIntroduction];
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 100, 300, 300)];
    imageView.image = [UIImage imageNamed:@"pick_bg"];
    [self.view addSubview:imageView];
    
    upOrDown = NO;
    num = 0;
    
    _line  = [[UIImageView alloc]initWithFrame:CGRectMake(50, 110, 220, 2)];
    _line.image = [UIImage imageNamed:@"line"];
    [self.view addSubview:_line];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(animationOne) userInfo:nil repeats:YES];
    
}
#define ANIMATION_DOWN NO
- (void)animationOne
{
    if (upOrDown == ANIMATION_DOWN ) {
        num ++;
        _line.frame = CGRectMake(50, 110+2*num, 220, 2);
        if (2*num == 280) {
            upOrDown = YES;
        }
    }else{
        num --;
        _line.frame = CGRectMake(50, 110+2*num, 220, 2);
        if (num == 0) {
            upOrDown = NO;
        }
    }
}

- (void)backButton
{
    [self dismissViewControllerAnimated:YES completion:^{
        [timer invalidate];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self setupCamera];
}

- (void)setupCamera
{
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    _output = [[AVCaptureMetadataOutput alloc]init];
    
    
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    _session = [[AVCaptureSession alloc]init];
    
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([_session canAddInput:self.input]) {
        [_session addInput:self.input];
    }
    if ([_session canAddOutput:self.output]) {
        [_session addOutput:self.output];
    }
    
//    preview
    _preview = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    
    _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    _preview.frame = CGRectMake(20, 110, 280, 280);
    
    [self.view.layer insertSublayer:self.preview atIndex:0];
    
    _output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];

    [_session startRunning];
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    NSString *stringValue;
    if ([metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataMachine = [metadataObjects objectAtIndex:0];
        stringValue = metadataMachine.stringValue;
    }
    
    [_session stopRunning];
    [self dismissViewControllerAnimated:YES completion:^{
        [timer invalidate];
        UIAlertView *alterView = [[UIAlertView alloc]initWithTitle:@"content" message:stringValue delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alterView show];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
