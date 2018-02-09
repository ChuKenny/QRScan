//
//  QRScanViewController.m
//  QYZbar
//
//  Created by qunye zhu on 2018/2/9.
//  Copyright © 2018年 qunye zhu. All rights reserved.
//

#import "QRScanViewController.h"
#define KTOPHEIGHT 100
#define IOS_7                   (([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)? (YES):(NO))
#define SCREEN_WIDTH            [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT            ([UIScreen mainScreen].bounds.size.height)
#define SCREEN_HEIGHT_BAR        (IOS_7?([UIScreen mainScreen].bounds.size.height)-64:([UIScreen mainScreen].bounds.size.height)-44)

@interface QRScanViewController ()
@property (strong, nonatomic) AVCaptureDeviceInput *input;//输入
@property (strong, nonatomic) AVCaptureMetadataOutput *output;//输出
@property (strong, nonatomic) AVCaptureSession *session;//会话
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;//预览图层
@property (strong, nonatomic) UIImageView *imgview;/**  扫面区域的图片  */
@property (strong, nonatomic) UIImageView *imgLine;/**  扫描线  */

@end

@implementation QRScanViewController

- (void)setUp {
    //设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //输入
    NSError *error = nil;
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (error) {
        [UIAlertController alertControllerWithTitle:@"提示" message:@"该设备不支持二维码扫描" preferredStyle:(UIAlertControllerStyleAlert)];
        return;
    }
    //输出
    self.output = [[AVCaptureMetadataOutput alloc]init];
    [self.output setRectOfInterest:CGRectMake(KTOPHEIGHT/SCREEN_HEIGHT, ((SCREEN_WIDTH-220)/2)/SCREEN_WIDTH,220/SCREEN_HEIGHT ,220/SCREEN_WIDTH)];
    //会话
    self.session = [[AVCaptureSession alloc]init];
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([self.session canAddInput:self.input]) {
        [self.session addInput:self.input];
    }
    if ([self.session canAddOutput:self.output]) {
        [self.session addOutput:self.output];
    }
    [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [self.output setMetadataObjectTypes:@[//AVMetadataObjectTypeQRCode,//二维码
                                          //以下为条形码，如果项目只需要扫描条形码，下面都不要写
                                          AVMetadataObjectTypeEAN13Code,
                                          AVMetadataObjectTypeEAN8Code,
                                          AVMetadataObjectTypeUPCECode,
                                          AVMetadataObjectTypeCode39Code,
                                          AVMetadataObjectTypeCode39Mod43Code,
                                          AVMetadataObjectTypeCode93Code,
                                          AVMetadataObjectTypeCode128Code,
                                          AVMetadataObjectTypePDF417Code
                                          ]];
    //预览图层
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.previewLayer setFrame:self.view.bounds];
    [self.view.layer insertSublayer:self.previewLayer atIndex:0];
    //会话启动
    [self.session startRunning];
    [self addImage];
    [self addDrawLine];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"扫描";
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        if (granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setUp];
            });
        } else {
            [UIAlertController alertControllerWithTitle:@"提示" message:@"无权限访问相机" preferredStyle:(UIAlertControllerStyleAlert)];
        }
    }];
}

#pragma mark - 扫面区域的图片设置
- (UIImageView *)imgview {
    if (!_imgview) {
        _imgview = [[UIImageView alloc] initWithFrame:self.view.bounds];
    }
    return _imgview;
}

- (void)addImage {
    CGRect rect = CGRectMake((SCREEN_WIDTH-220)/2, KTOPHEIGHT, 220, 220);
    UIGraphicsBeginImageContext(self.imgview.frame.size);
    [[UIColor colorWithWhite:0 alpha:0.5] set];
    UIRectFill(self.view.bounds);
    [[UIColor clearColor] set];
    UIRectFill(rect);
    [[UIColor whiteColor] setStroke];
    UIRectFrame(rect);
    
    NSString *str = @"将二维码放到框内，即可自动扫描";
    CGRect rect1 = CGRectMake((SCREEN_WIDTH-220)/2, KTOPHEIGHT+220+10, 220, 220);
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc]init];
    style.alignment = NSTextAlignmentCenter;
    [str drawInRect:rect1 withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14], NSForegroundColorAttributeName:[UIColor whiteColor], NSParagraphStyleAttributeName:style}];
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.imgview.image = img;
    [self.view addSubview:self.imgview];
}

#pragma mark - 扫描动画
- (void)addDrawLine {
    self.imgLine = [[UIImageView alloc]initWithFrame:CGRectMake((SCREEN_WIDTH - 220) / 2, KTOPHEIGHT, 220, 1)];
    [_imgLine setBackgroundColor:[UIColor greenColor]];
    [self.view addSubview:_imgLine];
    
    [self runDrawLine:_imgLine];
}

- (void)runDrawLine:(UIView *)imgview {
    imgview.frame = CGRectMake((SCREEN_WIDTH - 220) / 2, KTOPHEIGHT, 220, 1);
    [UIView animateWithDuration:3.0 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        imgview.frame = CGRectMake((SCREEN_WIDTH - 220) / 2, KTOPHEIGHT + 220, 220, 1);
    } completion:^(BOOL finished) {
        [self runDrawLine:imgview];
    }];
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate  扫面完成
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    //会话结束
    [self.session stopRunning];
    //删除预览图层
    [self.previewLayer removeFromSuperlayer];
    //扫描完成处理数据
    if (metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];
        NSString *resultStr = [obj stringValue];
        if (resultStr && [self.delegate respondsToSelector:@selector(handleScanData:)]) {
            [self dismissViewControllerAnimated:YES completion:^{
                [self.delegate handleScanData:resultStr];
            }];
        }
    }
}

@end
