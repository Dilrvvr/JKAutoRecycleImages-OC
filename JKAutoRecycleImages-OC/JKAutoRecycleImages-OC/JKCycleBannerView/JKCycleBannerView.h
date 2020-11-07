//
//  JKCycleBannerView.h
//  JKAutoRecycleImages-OC
//
//  Created by albert on 16/9/5.
//  Copyright © 2016年 albert. All rights reserved.
//

#import <UIKit/UIKit.h>

/** 图片 value对应NSString类型 可传imageName 内部默认[UIImage ImageNamed:] */
static NSString * const JKCycleBannerImageUrlKey = @"JKCycleBannerImageUrlKey";

/** 占位图片 value对应UIImage类型 */
static NSString * const JKCycleBannerPlaceholderImageKey = @"JKCycleBannerPlaceholderImageKey";

/** 标题 value对应NSString类型 */
static NSString * const JKCycleBannerTitleKey = @"JKCycleBannerTitleKey";

/** 其他数据 value对应任意类型 */
static NSString * const JKCycleBannerDataKey = @"JKCycleBannerDataKey";

@class JKCycleBannerView;

@protocol JKCycleBannerViewDelegate <NSObject>

@optional

/** 自定义加载图片 */
- (void)cycleBannerView:(JKCycleBannerView *)cycleBannerView loadImageWithImageView:(UIImageView *)imageView dict:(NSDictionary *)dict;

/** 点击了轮播图 */
- (void)cycleBannerView:(JKCycleBannerView *)cycleBannerView didClickImageWithDict:(NSDictionary *)dict;
@end

@interface JKCycleBannerView : UIView

/** 是否自动循环 default is YES */
@property (nonatomic, assign, getter=isAutoRecycle) BOOL autoRecycle;

/** 自动滚动的时间间隔（单位为s）默认3s 不可小于1s */
@property (nonatomic, assign) NSTimeInterval autoRecycleInterval;

/** 是否有缩放动画 默认没有 */
@property (nonatomic, assign) BOOL scaleAnimated;

/** 图片内缩的大小 */
@property (nonatomic, assign) UIEdgeInsets contentInset;

/** 图片的圆角大小 */
@property (nonatomic, assign) CGFloat cornerRadius;

/** 代理 */
@property (nonatomic, weak) id<JKCycleBannerViewDelegate> delegate;

/** 监听图片点击的block */
@property (nonatomic, copy) void (^imageClickBlock)(NSDictionary *dict);

/** 自定义加载图片 */
@property (nonatomic, copy) void (^loadImageBlock)(UIImageView *imageView, NSDictionary *dict);

/** contentView */
@property (nonatomic, weak, readonly) UIView *contentView;

/** flowlayout */
@property (nonatomic, strong, readonly) UICollectionViewFlowLayout *flowlayout;

/** pageControl */
@property (nonatomic, strong, readonly) UIPageControl *pageControl;

/** 是否让pageControl位于contentInset.bottom高度的中间 */
@property (nonatomic, assign) BOOL pageControlInBottomInset;

/** 是否手动设置pageControl的frame */
@property (nonatomic, assign) BOOL manualPageControlFrame;

/** 构造函数 */
+ (instancetype)recycleViewWithFrame:(CGRect)frame;

/**
 * 设置数据
 * 数组中每个元素应是NSDictionary类型
 * NSDictionary必须有一个图片url的key JKCycleBannerImageUrlKey
 * JKCycleBannerTitleKey和JKCycleBannerOtherDictKey可有可无
 */
- (void)setDataSource:(NSArray <NSDictionary *> *)dataSource;

/** 添加定时器 */
- (void)addTimer;

/** 移除定时器 */
- (void)removeTimer;
@end
