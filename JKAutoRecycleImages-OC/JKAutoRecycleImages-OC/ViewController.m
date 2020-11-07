//
//  ViewController.m
//  JKAutoRecycleImages-OC
//
//  Created by albert on 16/9/6.
//  Copyright © 2016年 albert. All rights reserved.
//

#import "ViewController.h"
#import "JKCycleBannerView.h"

@interface ViewController () <JKCycleBannerViewDelegate>

@property (weak, nonatomic) IBOutlet JKCycleBannerView *recycleView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.recycleView.delegate = self;
    
    self.recycleView.backgroundColor = [UIColor lightGrayColor];
    
    self.recycleView.cornerRadius = 8;
    self.recycleView.contentInset = UIEdgeInsetsMake(10, 10, 10, 10);
    
    //self.recycleView.scaleAnimated = YES;
    
    [self.recycleView setDataSource:@[
        @{JKCycleBannerImageUrlKey : @"kenan01.jpg", JKCycleBannerTitleKey : @"kenan01-柯兰"},
        @{JKCycleBannerImageUrlKey : @"kenan02.jpg", JKCycleBannerTitleKey : @"kenan02-柯哀"},
        @{JKCycleBannerImageUrlKey : @"kenan03.jpg", JKCycleBannerTitleKey : @"kenan03-柯兰"},
        @{JKCycleBannerImageUrlKey : @"kenan04.jpg", JKCycleBannerTitleKey : @"kenan04-新兰"},
        @{JKCycleBannerImageUrlKey : @"kenan05.jpg", JKCycleBannerTitleKey : @"kenan05-全家福"}]
     ];
}

#pragma mark - 按钮点击

- (IBAction)start:(id)sender {
    
    [self.recycleView addTimer];
}

- (IBAction)stop:(id)sender {
    
    [self.recycleView removeTimer];
}

#pragma mark - JKCycleBannerViewDelegate

- (void)cycleBannerView:(JKCycleBannerView *)cycleBannerView didClickImageWithDict:(NSDictionary *)dict{
    
    NSString *message = [NSString stringWithFormat:@"%@", dict[JKCycleBannerTitleKey]];
    
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:(UIAlertControllerStyleAlert)];
    
    [alertVc addAction:[UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:nil]];
    
    [self presentViewController:alertVc animated:YES completion:nil];
}
@end
