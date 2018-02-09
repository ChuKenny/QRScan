//
//  QRScanViewController.h
//  QYZbar
//
//  Created by qunye zhu on 2018/2/9.
//  Copyright © 2018年 qunye zhu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@protocol QRScanDataDelegate <NSObject>
- (void)handleScanData:(NSString *)resultStr;
@end
@interface QRScanViewController : UIViewController<AVCaptureMetadataOutputObjectsDelegate>
@property (weak, nonatomic) id<QRScanDataDelegate> delegate;
@end
