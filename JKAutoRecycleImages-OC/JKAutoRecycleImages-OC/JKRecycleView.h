//
//  JKRecycleView.h
//  JKAutoRecycleImages-OC
//
//  Created by albert on 16/9/5.
//  Copyright © 2016年 albert. All rights reserved.
//

#import <UIKit/UIKit.h>

/** 图片 */
static NSString * const JKRecycleImageUrlKey = @"JKRecycleImageUrlKey";

/** 标题 */
static NSString * const JKRecycleTitleKey = @"JKRecycleTitleKey";

/** 其他数据 */
static NSString * const JKRecycleOtherDictKey = @"JKRecycleOtherDictKey";

@class JKRecycleView;

@protocol JKRecycleViewDelegate <NSObject>

@optional

/** 点击了轮播图 */
- (void)recycleView:(JKRecycleView *)recycleView didClickImageWithDict:(NSDictionary *)dict;
@end

@interface JKRecycleView : UIView

/** 自动滚动的时间间隔（单位为s）默认3s 不可小于1s */
@property (nonatomic, assign) NSTimeInterval autoRecycleInterval;

/** 是否自动循环 */
@property (nonatomic, assign, getter=isAutoRecycle) BOOL autoRecycle;

/** contentView */
@property (nonatomic, weak, readonly) UIView *contentView;

/** flowlayout */
@property (nonatomic, strong, readonly) UICollectionViewFlowLayout *flowlayout;

/** pageControl */
@property (nonatomic, strong) UIPageControl *pageControl;

/** 是否有缩放动画 默认没有 */
@property (nonatomic, assign) BOOL scaleAnimated;

/** 代理 */
@property (nonatomic, weak) id<JKRecycleViewDelegate> delegate;

/** 监听图片点击的block */
@property (nonatomic, copy) void (^imageClickBlock)(NSDictionary *dict);

+ (instancetype)recycleViewWithFrame:(CGRect)frame;

/**
 * 设置数据
 * 数组中每个元素应是NSDictionary类型
 * NSDictionary必须有一个图片urlkey JKRecycleImageUrlKey
 * JKRecycleTitleKey和JKRecycleOtherDictKey可有可无
 */
- (void)setDataSource:(NSArray <NSDictionary *> *)dataSource;

/** 添加定时器 */
- (void)addTimer;

/** 移除定时器 */
- (void)removeTimer;
@end



#pragma mark - -------------cell-------------

@interface JKRecycleCell : UICollectionViewCell

- (void)bindDict:(NSDictionary *)dict;
@end
