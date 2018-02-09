//
//  ViewController.m
//  QYZbar
//
//  Created by qunye zhu on 2018/2/9.
//  Copyright © 2018年 qunye zhu. All rights reserved.
//

#import "ViewController.h"
#import "QRScanViewController.h"

#define KTOPHEIGHT 100
#define SCREEN_WIDTH            [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT            ([UIScreen mainScreen].bounds.size.height)
#define SCREEN_HEIGHT_BAR        (IOS_7?([UIScreen mainScreen].bounds.size.height)-64:([UIScreen mainScreen].bounds.size.height)-44)

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource, QRScanDataDelegate>

@property (weak, nonatomic) IBOutlet UIButton *scanButton;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *dataArray;/**  扫描数据  */

@end

@implementation ViewController
- (IBAction)scanQR:(id)sender {
    QRScanViewController *scanVc= [[QRScanViewController alloc] init];
    scanVc.delegate = self;
    [self presentViewController:scanVc animated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"扫描二维码";
    self.dataArray = [@[] mutableCopy];
}


- (void)handleScanData:(NSString *)resultStr {
    if (![self.dataArray containsObject:resultStr]) {
        [self.dataArray addObject:resultStr];
        [self.tableView reloadData];
    }
}


#pragma mark - UITableViewDelegate


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *rid = @"UITableViewCell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:rid];
    if(cell==nil){
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:rid];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%ld,   %@",indexPath.row+1, self.dataArray[indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (IBAction)submit:(id)sender {
    NSLog(@"do submit request");
}

@end
