//
//  UITableView+SensorsData.m
//  SensorsSDK
//
//  Created by 王玉松 on 2021/9/27.
//

#import "UITableView+SensorsData.h"
#import "NSObject+SASwizzler.h"
#import <objc/message.h>
#import "SensorsAnalyticsSDK.h"
#import "SensorsAnalyticsDynamicDelegate.h"
#import "SensorsAnalyticsDelegateProxy.h"
#import "UIScrollView+SensorsData.h"



@implementation UITableView (SensorsData)

+ (void)load {
    
    [UITableView sensorsdata_swizzleMethod:@selector(setDelegate:) withMethod:@selector(sensorsdata_setDelegate:)];
}

- (void)sensorsdata_setDelegate:(id<UITableViewDelegate>)delegate {
//    [self sensorsdata_setDelegate:delegate];
//    // 方案一：方法交换
//   // 交换delegate对象中的tableView:didSelectRowAtIndexPath:方法
//   [self sensorsdata_swizzleDidSelectRowAtIndexPathMethodWithDelegate:delegate];
    
    // 方案二：动态子类
    // 调用原始的设置代理的方法
//    [self sensorsdata_setDelegate:delegate];
//    // 设置delegate对象的动态子类
//    [SensorsAnalyticsDynamicDelegate proxyWithTableViewDelegate:delegate];
    
    // 方案三：NSProxy消息转发
      // 销毁保存的委托对象
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
      self.sensorsdata_delegateProxy = nil;
#pragma clang diagnostic pop

      if (delegate) {
          SensorsAnalyticsDelegateProxy *proxy = [SensorsAnalyticsDelegateProxy
  proxyWithTableViewDelegate:delegate];
          // 保存委托对象
          self.sensorsdata_delegateProxy = proxy;
          // 调用原始方法, 将代理设置为委托对象
          [self sensorsdata_setDelegate:proxy];
      } else {
          // 调用原始方法, 将代理设置为nil
          [self sensorsdata_setDelegate:nil];
      }
    
}

static void sensorsdata_tableViewDidSelectRow(id object, SEL selector, UITableView *tableView, NSIndexPath *indexPath) {
    
    SEL destinationSelector = NSSelectorFromString(@"sensorsdata_tableView:didSelectRowAtIndexPath:");
    // 通过消息发送, 调用原始的tableView:didSelectRowAtIndexPath:方法实现
    ((void(*)(id, SEL, id, id))objc_msgSend)(object, destinationSelector, tableView, indexPath);

    // TODO: 触发$AppClick事件
    [[SensorsAnalyticsSDK sharedInstance] trackAppClickWithTableView:tableView didSelectRowAtIndexPath:indexPath properties:nil];
}

- (void)sensorsdata_swizzleDidSelectRowAtIndexPathMethodWithDelegate:(id)delegate {
  // 获取delegate对象的类
  Class delegateClass = [delegate class];
  // 方法名
  SEL sourceSelector = @selector(tableView:didSelectRowAtIndexPath:);
  // 当delegate 对象中没有实现tableView:didSelectRowAtIndexPath: 方法时, 直接返回
  if (![delegate respondsToSelector:sourceSelector]) {
    return;
  }

  SEL destinationSelector = NSSelectorFromString(@"sensorsdata_tableView:didSelectRowAtIndexPath:");
  // 当delegate对象中已经存在了sensorsdata_tableView:didSelectRowAtIndexPath:方法,说明已经进行交换, 因此可以直接返回
  if ([delegate respondsToSelector:destinationSelector]) {
    return;
  }

  Method sourceMethod = class_getInstanceMethod(delegateClass, sourceSelector);
  const char * encoding = method_getTypeEncoding(sourceMethod);
  // 当该类中已经存在相同的方法, 则添加方法失败。但是前面已经判断过是否存在, 因此, 此处一定会添加成功
    if (!class_addMethod([delegate class], destinationSelector, (IMP)sensorsdata_tableViewDidSelectRow, encoding)) {
      NSLog(@"Add %@ to %@ error", NSStringFromSelector(sourceSelector), [delegate class]);
      return;
    }
    // 方法添加成功之后, 进行方法交换
    [delegateClass sensorsdata_swizzleMethod:sourceSelector withMethod:destinationSelector];
  }
    
@end
