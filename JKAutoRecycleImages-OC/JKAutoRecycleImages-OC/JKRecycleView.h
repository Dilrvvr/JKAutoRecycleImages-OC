//
//  JKRecycleView.h
//  JKAutoRecycleImages-OC
//
//  Created by albert on 16/9/5.
//  Copyright © 2016年 albert. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JKRecycleView;

@protocol JKRecycleViewDelegate <NSObject>

@optional
/** 点击了轮播图 */
- (void)recycleView:(JKRecycleView *)recycleView didClickCurrentImageViewWithIndex:(int)index;

@end

@interface JKRecycleView : UIView
/** 自动滚动的时间间隔（单位为s）默认3s */
@property (nonatomic, assign) NSTimeInterval autoRecycleInterval;

/** 是否自动开始循环 默认YES */
@property (nonatomic, assign) BOOL isAutoRecycle;

/** 代理 */
@property (nonatomic, weak) id<JKRecycleViewDelegate> delegate;

/** 设置数据 */
- (void)setImageNames:(NSArray *)imageNames titles:(NSArray *)titles;

/** 添加定时器 */
- (void)addTimer;

/** 移除定时器 */
- (void)removeTimer;
@end