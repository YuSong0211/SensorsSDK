//
//  UICollectionView+SensorsData.m
//  SensorsSDK
//
//  Created by 王玉松 on 2021/9/29.
//

#import "UICollectionView+SensorsData.h"
#import "NSObject+SASwizzler.h"
#import "SensorsAnalyticsDelegateProxy.h"
#import "UIScrollView+SensorsData.h"

  @implementation UICollectionView (SensorsData)

  + (void)load {
      [UICollectionView sensorsdata_swizzleMethod:@selector(setDelegate:) withMethod:@selector(sensorsdata_setDelegate:)];
}


- (void)sensorsdata_setDelegate:(id<UICollectionViewDelegate>)delegate {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
      self.sensorsdata_delegateProxy = nil;
#pragma clang diagnostic pop
    if (delegate) {
        SensorsAnalyticsDelegateProxy *proxy = [SensorsAnalyticsDelegateProxy proxyWithCollectionViewDelegate:delegate];
        self.sensorsdata_delegateProxy = proxy;
        [self sensorsdata_setDelegate:proxy];
    } else {
        [self sensorsdata_setDelegate:nil];
    }
}

@end
