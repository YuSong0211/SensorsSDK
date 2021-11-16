//
//  UIApplication+SensorsData.m
//  SensorsSDK
//
//  Created by 王玉松 on 2021/9/24.
//

#import "UIApplication+SensorsData.h"
#import "SensorsAnalyticsSDK.h"
#import "NSObject+SASwizzler.h"
#import "UIView+SensorsData.h"

@implementation UIApplication (SensorsData)

+ (void)load {
    [UIApplication sensorsdata_swizzleMethod:@selector(sendAction:to:from:forEvent:) withMethod:@selector(sensorsdata_sendAction:to:from:forEvent:)];
}

- (BOOL)sensorsdata_sendAction:(SEL)action to:(nullable id)target from:(nullable id) sender forEvent:(nullable UIEvent *)event {
    //触发$AppClick事件
    if ([sender isKindOfClass:UISwitch.class] ||
           [sender isKindOfClass:UISegmentedControl.class] ||
           [sender isKindOfClass:UIStepper.class] ||
           event.allTouches.anyObject.phase == UITouchPhaseEnded) {
           // 触发$AppClick事件
           [[SensorsAnalyticsSDK sharedInstance] trackAppClickWithView:sender properties:nil];
    }
    // 调用原有实现, 即- sendAction:to:from:forEvent: 方法
    return [self sensorsdata_sendAction:action to:target from:sender forEvent:event];
}

@end
