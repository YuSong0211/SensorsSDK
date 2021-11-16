//
//  SensorsAnalyticsDelegateProxy.h
//  SensorsSDK
//
//  Created by 王玉松 on 2021/9/28.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface SensorsAnalyticsDelegateProxy : NSProxy<UITableViewDelegate>
+ (instancetype)proxyWithTableViewDelegate:(id<UITableViewDelegate>)delegate;
/**
 初始化委托对象, 用于拦截UICollectionView控件的选中cell事件

 @param delegate UICollectionView控件的代理
 @return初始化对象
 */
+ (instancetype)proxyWithCollectionViewDelegate:(id<UICollectionViewDelegate>)delegate;
@end

NS_ASSUME_NONNULL_END
