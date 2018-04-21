//
//  ViewController.m
//  JKAutoRecycleImages-OC
//
//  Created by albert on 16/9/6.
//  Copyright © 2016年 albert. All rights reserved.
//

#import "ViewController.h"
#import "JKRecycleView.h"

@interface ViewController () <JKRecycleViewDelegate>
@property (weak, nonatomic) IBOutlet JKRecycleView *recycleView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.recycleView.delegate = self;
    
    [self.recycleView setDataSource:@[
                                      @{JKRecycleImageUrlKey : @"kenan01.jpg", JKRecycleTitleKey : @"kenan01-柯兰"},
                                      @{JKRecycleImageUrlKey : @"kenan02.jpg", JKRecycleTitleKey : @"kenan02-柯哀"},
                                      @{JKRecycleImageUrlKey : @"kenan03.jpg", JKRecycleTitleKey : @"kenan03-柯兰"},
                                      @{JKRecycleImageUrlKey : @"kenan04.jpg", JKRecycleTitleKey : @"kenan04-新兰"},
                                      @{JKRecycleImageUrlKey : @"kenan05.jpg", JKRecycleTitleKey : @"kenan05-全家福"}]];
}

#pragma mark - 按钮点击

- (IBAction)start:(id)sender {
    
    [self.recycleView addTimer];
}

- (IBAction)stop:(id)sender {
    
    [self.recycleView removeTimer];
}

#pragma mark - JKRecycleViewDelegate

- (void)recycleView:(JKRecycleView *)recycleView didClickImageWithDict:(NSDictionary *)dict{
    
    NSString *message = [NSString stringWithFormat:@"%@", dict[JKRecycleTitleKey]];
    
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:(UIAlertControllerStyleAlert)];
    
    [alertVc addAction:[UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:nil]];
    
    [self presentViewController:alertVc animated:YES completion:nil];
}
@end
