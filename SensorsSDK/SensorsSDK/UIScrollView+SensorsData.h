//
//  UIScrollView+SensorsData.h
//  SensorsSDK
//
//  Created by 王玉松 on 2021/9/28.
//

#import <UIKit/UIKit.h>
#import "SensorsAnalyticsDelegateProxy.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIScrollView (SensorsData)
@property (nonatomic, strong) SensorsAnalyticsDelegateProxy *sensorsdata_delegateProxy;
@end

NS_ASSUME_NONNULL_END
