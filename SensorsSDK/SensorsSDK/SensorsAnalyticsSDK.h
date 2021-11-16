//
//  SensorsAnalyticsSDK.h
//  SensorsSDK
//
//  Created by 王玉松 on 2021/9/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SensorsAnalyticsSDK : NSObject
/**
@abstract
获取SDK实例

@return返回单例
*/
+ (SensorsAnalyticsSDK *)sharedInstance;

/// 设备ID (匿名ID)
@property (nonatomic, copy) NSString *anonymousId;

/**
用户登录, 设置登录ID

@param loginId 用户的登录ID
*/
- (void)login:(NSString *)loginId;


@end

#pragma mark - Track
@interface SensorsAnalyticsSDK (Track)

  /**
@abstract
调用Track接口, 触发事件
@discussion
properties是一个NSDictionary(字典)。
其中, key是属性的名称, 必须是NSString类型；value则是属性的内容
@param eventName      事件名称
@param properties     事件属性
*/
- (void)track:(NSString *)eventName properties:(nullable NSDictionary<NSString *, id> *)properties;

/**
触发$AppClick事件
@param view 触发事件的控件
@param properties自定义事件属性
*/
- (void)trackAppClickWithView:(UIView *)view properties:(nullable NSDictionary <NSString *, id> *)properties;

/**
支持UITableView触发$AppClick事件

@param tableView触发事件的UITableView视图
@param indexPath在UITableView中点击的位置
@param properties自定义事件属性
*/
- (void)trackAppClickWithTableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath properties:(nullable NSDictionary<NSString *, id> *)properties;


/**
支持UICollectionView触发$AppClick事件

@param collectionView触发事件的UICollectionView视图
@param indexPath在UICollectionView中点击的位置
@param properties自定义事件属性
*/
- (void)trackAppClickWithCollectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath properties:(nullable NSDictionary<NSString *, id> *)properties;




@end

#pragma mark - Timer
@interface SensorsAnalyticsSDK (Timer)
/**
 开始统计事件时长

 调用这个接口时, 并不会真正触发一次事件, 只是开始计时

 @param event 事件名
 */
- (void)trackTimerStart:(NSString *)event;

/**
 结束事件时长统计, 计算时长

 事件发生时长是从调用-trackTimerStart:方法开始, 一直到调用-trackTimerEnd:properties:方法结束。
 如果多次调用-trackTimerStart:方法, 则从最后一次调用开始计算。
 如果没有调用-trackTimerStart:方法, 就直接调用trackTimerEnd:properties:方法, 则触发一次
 普通事件, 不带时长属性。

 @param event 事件名, 与开始时事件名一一对应
 @param properties 事件属性
 */
- (void)trackTimerEnd:(NSString *)event properties:(nullable NSDictionary *)properties;

/**
 暂停统计事件时长

 如果该事件未开始, 即没有调用-trackTimerStart: 方法, 则不做任何操作。

 @param event 事件名
 */
- (void)trackTimerPause:(NSString *)event;

/**
 恢复统计事件时长

 如果该事件并未暂停, 即没有调用-trackTimerPause:方法, 则没有影响。

 @param event 事件名
 */
- (void)trackTimerResume:(NSString *)event;

@end

NS_ASSUME_NONNULL_END
