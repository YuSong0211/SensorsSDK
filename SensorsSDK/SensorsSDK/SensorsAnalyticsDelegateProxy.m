//
//  SensorsAnalyticsDelegateProxy.m
//  SensorsSDK
//
//  Created by 王玉松 on 2021/9/28.
//

#import "SensorsAnalyticsDelegateProxy.h"
#import "SensorsAnalyticsSDK.h"


@interface SensorsAnalyticsDelegateProxy ()

/// 保存delegate对象
@property (nonatomic, weak) id delegate;

@end

@implementation SensorsAnalyticsDelegateProxy

+ (instancetype)proxyWithTableViewDelegate:(id<UITableViewDelegate>)delegate {
    SensorsAnalyticsDelegateProxy *proxy = [SensorsAnalyticsDelegateProxy alloc];
    proxy.delegate = delegate;
    return proxy;
}

+ (instancetype)proxyWithCollectionViewDelegate:(id<UICollectionViewDelegate>)delegate {
    SensorsAnalyticsDelegateProxy *proxy = [SensorsAnalyticsDelegateProxy alloc];
    proxy.delegate = delegate;
    return proxy;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    // 返回delegate对象中对应的方法签名
    return [(NSObject *)self.delegate methodSignatureForSelector:selector];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    // 先执行delegate对象中的方法
      [invocation invokeWithTarget:self.delegate];
      // 判断是否是cell点击事件的代理方法
      if (invocation.selector == @selector(tableView:didSelectRowAtIndexPath:)) {
          // 将方法修改为进行数据采集的方法, 即本类中的实例方法：sensorsdata_tableView:did-
   SelectRowAtIndexPath:
          invocation.selector = NSSelectorFromString(@"sensorsdata_tableView:did-SelectRowAtIndexPath:");
          // 执行数据采集相关的方法
          [invocation invokeWithTarget:self];
      } else if (invocation.selector == @selector(collectionView:didSelectItemAtIndexPath:)) {
          // 将方法修改为进行数据采集的方法, 即本类中的实例方法：sensorsdata_collectionView:
   didSelectRowAtIndexPath:
          invocation.selector = NSSelectorFromString(@"sensorsdata_collectionView:didSelectItemAtIndexPath:");
          // 执行数据采集相关的方法
          [invocation invokeWithTarget:self];
      }
}

- (void)sensorsdata_tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [[SensorsAnalyticsSDK sharedInstance] trackAppClickWithTableView:tableView
didSelectRowAtIndexPath:indexPath properties:nil];
    
}

- (void)sensorsdata_collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [[SensorsAnalyticsSDK sharedInstance] trackAppClickWithCollectionView:collectionView didSelectItemAtIndexPath:indexPath properties:nil];
}




@end
