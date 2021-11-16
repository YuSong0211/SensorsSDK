//
//  UIControl+SensorsData.m
//  SensorsSDK
//
//  Created by 王玉松 on 2021/9/26.
//

#import "UIControl+SensorsData.h"
#import "NSObject+SASwizzler.h"
#import "SensorsAnalyticsSDK.h"
@implementation UIControl (SensorsData)

+ (void)load {
    
//    [UIControl sensorsdata_swizzleMethod:@selector(didMoveToSuperview) withMethod: @selector(sensorsdata_didMoveToSuperview)];
}

- (void)sensorsdata_didMoveToSuperview {
    // 调用交换前的原始方法实现
    [self sensorsdata_didMoveToSuperview];
    // 判断是否为一些特殊的控件
    if ([self isKindOfClass:UISwitch.class] ||
        [self isKindOfClass:UISegmentedControl.class] ||
        [self isKindOfClass:UIStepper.class] ||
        [self isKindOfClass:UISlider.class]
        ) {
        // 添加类型为UIControlEventValueChanged的一组Target-Action
        [self addTarget:self action:@selector(sensorsdata_valueChangedAction:event:) forControlEvents:UIControlEventValueChanged];
    } else {
        // 添加类型为UIControlEventTouchDown的一组Target-Action
        [self addTarget:self action:@selector(sensorsdata_touchDownAction:event:) forControlEvents:UIControlEventTouchDown];
    }
}

- (void)sensorsdata_valueChangedAction:(UIControl *)sender event:(UIEvent *)event {
    if ([sender isKindOfClass:UISlider.class] && event.allTouches.anyObject.phase != UITouchPhaseEnded) {
        return;
    }
    if ([self sensorsdata_isAddMultipleTargetActionsWithDefaultControlEvent:UIControlEventValueChanged]) {
        // 触发$AppClick事件
        [[SensorsAnalyticsSDK sharedInstance] trackAppClickWithView:sender properties:nil];
    }
}

- (void)sensorsdata_touchDownAction:(UIControl *)sender event:(UIEvent *)event {
    // 触发$AppClick事件
    if ([self sensorsdata_isAddMultipleTargetActionsWithDefaultControlEvent:UIControlEventTouchDown]) {
        // 触发$AppClick事件
        [[SensorsAnalyticsSDK sharedInstance] trackAppClickWithView:sender properties:nil];
    }
    
}

- (BOOL)sensorsdata_isAddMultipleTargetActionsWithDefaultControlEvent:(UIControlEvents)defaultControlEvent {
    // 如果有多个Target , 说明除了添加的Target , 还有其他
    // 那么返回YES , 触发$AppClick事件
    if (self.allTargets.count >= 2) {
        return YES;
    }
    // 如果控件本身为Target, 并且添加除了defaultControlEvent类型的Action
    // 说明开发者以控件本身为Target, 添加了多个Action
    // 那么返回YES, 触发$AppClick事件
    if ((self.allControlEvents & UIControlEventAllTouchEvents) != defaultControlEvent) {
        return YES;
    }
    // 如果控件本身为Target, 并且添加了两个以上的defaultControlEvent类型的Action
    // 说明开发者自行添加了Action
    // 那么返回YES, 触发$AppClick事件
    if ([self actionsForTarget:self forControlEvent:defaultControlEvent].count >= 2) {
        return YES;
    }
    return NO;
}


@end
