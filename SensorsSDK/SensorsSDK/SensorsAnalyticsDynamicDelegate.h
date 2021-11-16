//
//  SensorsAnalyticsDynamicDelegate.h
//  SensorsSDK
//
//  Created by 王玉松 on 2021/9/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SensorsAnalyticsDynamicDelegate : NSObject

+ (void)proxyWithTableViewDelegate:(id<UITableViewDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
