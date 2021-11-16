//
//  UIGestureRecognizer+SensorsData.m
//  SensorsSDK
//
//  Created by 王玉松 on 2021/9/29.
//

#import "UIGestureRecognizer+SensorsData.h"
#import "NSObject+SASwizzler.h"
#import "SensorsAnalyticsSDK.h"
#pragma mark - UITapGestureRecognizer
@implementation UITapGestureRecognizer (SensorsData)
+ (void)load {
// Swizzle initWithTarget:action: 方法
[UITapGestureRecognizer sensorsdata_swizzleMethod:@selector(initWithTarget:
                                                            action:) withMethod:@selector(sensorsdata_initWithTarget:action:)];
// Swizzle addTarget:action: 方法
[UITapGestureRecognizer sensorsdata_swizzleMethod:@selector(addTarget:action:) withMethod:@selector(sensorsdata_addTarget:action:)];
}

- (instancetype)sensorsdata_initWithTarget:(id)target action:(SEL)action {
    // 调用原始的初始化方法进行对象初始化
    [self sensorsdata_initWithTarget:target action:action];
    // 调用添加Target-Action的方法, 添加埋点的Target-Action
    // 这里其实调用的是-sensorsdata_addTarget:action:的实现方法, 因为已经进行交换
    [self addTarget:target action:action];
    return self;
}

- (void)sensorsdata_addTarget:(id)target action:(SEL)action {
    // 调用原始的方法, 添加Target-Action
    [self sensorsdata_addTarget:target action:action];
    // 新增Target-Action , 用于触发$AppClick事件
    [self sensorsdata_addTarget:self action:@selector(sensorsdata_trackTapGestureAction:)];
}

- (void)sensorsdata_trackTapGestureAction:(UITapGestureRecognizer *)sender {
    // 获取手势识别器的控件
     UIView *view = sender.view;
     // 暂定只采集UILabel和UIImageView
     BOOL isTrackClass = [view isKindOfClass:UILabel.class] || [view isKindOfClass: UIImageView.class];
     if (!isTrackClass) {
         return;
     }

     // 触发$AppClick事件
    [[SensorsAnalyticsSDK sharedInstance] trackAppClickWithView:view properties:nil];
}

@end

#pragma mark - UILongPressGestureRecognizer
@implementation UILongPressGestureRecognizer (SensorsData)

+ (void)load {
    // Swizzle initWithTarget:action:方法
    [UILongPressGestureRecognizer sensorsdata_swizzleMethod:@selector(initWithTarget:action:) withMethod:@selector(sensorsdata_initWithTarget:action:)];
    // Swizzle addTarget:action:方法
    [UILongPressGestureRecognizer sensorsdata_swizzleMethod:@selector(addTarget:action:) withMethod:@selector(sensorsdata_addTarget:action:)];
}

- (instancetype)sensorsdata_initWithTarget:(id)target action:(SEL)action {
    // 调用原始的初始化方法进行对象初始化
    [self sensorsdata_initWithTarget:target action:action];
    // 调用添加Target-Action的方法, 添加埋点的Target-Action
    // 这里其实调用的是-sensorsdata_addTarget:action:的实现方法, 因为已经进行交换
    [self addTarget:target action:action];
    return self;
}

- (void)sensorsdata_addTarget:(id)target action:(SEL)action {
    // 调用原始的方法, 添加Target-Action
    [self sensorsdata_addTarget:target action:action];
    // 新增Target-Action, 用于埋点
    [self sensorsdata_addTarget:self action:@selector(sensorsdata_trackLongPressGestureAction:)];
}

- (void)sensorsdata_trackLongPressGestureAction:(UILongPressGestureRecognizer *)sender {
    // 手势处于UIGestureRecognizerStateEnded状态时, 才触发$AppClick事件
     if (sender.state != UIGestureRecognizerStateEnded) {
         return;
     }
    // 获取手势识别器的控件
    UIView *view = sender.view;
    // 暂定只支持UILabel 和UIImageView两种控件
    BOOL isTrackClass = [view isKindOfClass:UILabel.class] || [view isKindOfClass: UIImageView.class];
    if (!isTrackClass) {
        return;
    }

    // 触发$AppClick事件
    [[SensorsAnalyticsSDK sharedInstance] trackAppClickWithView:view properties:nil];
}


@end
