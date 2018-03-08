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
    [self.recycleView setImageUrls:@[@"kenan01.jpg", @"kenan02.jpg", @"kenan03.jpg", @"kenan04.jpg", @"kenan05.jpg"] titles:@[@"kenan01-柯兰", @"kenan02-柯哀", @"kenan03-柯兰", @"kenan04-新兰", @"kenan05-全家福"] otherDataDicts:nil];
}

#pragma mark - 按钮点击
- (IBAction)start:(id)sender {
    [self.recycleView addTimer];
}

- (IBAction)stop:(id)sender {
    [self.recycleView removeTimer];
}

#pragma mark - <JKRecycleViewDelegate>
- (void)recycleView:(JKRecycleView *)recycleView didClickImageWithIndex:(int)index otherDataDict:(NSDictionary *)otherDataDict{
    NSString *message = [NSString stringWithFormat:@"点击了第%d张图片", index + 1];
    
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:(UIAlertControllerStyleAlert)];
    
    [alertVc addAction:[UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:nil]];
    
    [self presentViewController:alertVc animated:YES completion:nil];
}
@end
