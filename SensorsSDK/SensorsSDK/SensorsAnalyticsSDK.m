//
//  SensorsAnalyticsSDK.m
//  SensorsSDK
//
//  Created by 王玉松 on 2021/9/15.
//

#import "SensorsAnalyticsSDK.h"
#include <sys/sysctl.h>
#include <objc/runtime.h>
#import "UIView+SensorsData.h"
#import "SensorsAnalyticsKeychainItem.h"
#import "SensorsAnalyticsFileStore.h"
#import "SensorsAnalyticsDatabase.h"


static NSString * const SensorsAnalyticsVersion = @"1.0.0";

@interface SensorsAnalyticsSDK ()

/// 由SDK默认自动采集的事件属性即预置属性
@property (nonatomic, strong) NSDictionary<NSString *, id> *automaticProperties;
/// 标记应用程序是否已收到UIApplicationWillResignActiveNotification本地通知
@property (nonatomic) BOOL applicationWillResignActive;
@property (nonatomic, getter=isLaunchedPassively) BOOL launchedPassively;

/// 登录ID
@property (nonatomic, copy) NSString *loginId;

/// 事件开始发生的时间戳
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSDictionary *> *trackTimer;

/// 保存进入后台时未暂停的事件名称
@property (nonatomic, strong) NSMutableArray<NSString *> *enterBackgroundTrackTimerEvents;

/// 文件缓存事件数据对象
@property (nonatomic, strong) SensorsAnalyticsFileStore *fileStore;


/// 数据库存储对象
@property (nonatomic, strong) SensorsAnalyticsDatabase *database;

@end

static NSString * const SensorsAnalyticsAnonymousId = @"cn.sensorsdata.anonymous_id";
static NSString * const SensorsAnalyticsKeychainService = @"cn.sensorsdata.SensorsAnalytics.id";
static NSString * const SensorsAnalyticsLoginId = @"cn.sensorsdata.login_id";




static NSString * const SensorsAnalyticsEventBeginKey = @"event_begin";

static NSString * const SensorsAnalyticsEventDurationKey = @"event_duration";
static NSString * const SensorsAnalyticsEventIsPauseKey = @"is_pause";

@implementation SensorsAnalyticsSDK{
    NSString *_anonymousId;

}

+ (SensorsAnalyticsSDK *)sharedInstance {
    static dispatch_once_t onceToken;
    static SensorsAnalyticsSDK *sdk = nil;
    dispatch_once(&onceToken, ^{
      sdk = [[SensorsAnalyticsSDK alloc] init];
    });
    return sdk;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _automaticProperties = [self collectAutomaticProperties];
        _launchedPassively = UIApplication.sharedApplication.backgroundTimeRemaining != UIApplicationBackgroundFetchIntervalNever;
        _loginId = [[NSUserDefaults standardUserDefaults] objectForKey:SensorsAnalyticsLoginId];
        _trackTimer = [NSMutableDictionary dictionary];
        
        _enterBackgroundTrackTimerEvents = [NSMutableArray array];

        _fileStore = [[SensorsAnalyticsFileStore alloc] init];
        // 初始化SensorsAnalyticsDatabase 类的对象, 使用默认路径
         _database = [[SensorsAnalyticsDatabase alloc] init];
        
         // 添加应用程序状态监听
        [self setupListeners];
    }
    return self;
}

#pragma mark - Properties
- (NSDictionary<NSString *, id> *)collectAutomaticProperties {
  NSMutableDictionary *properties = [NSMutableDictionary dictionary];
  //操作系统类型
  properties[@"$os"] = @"iOS";
  // SDK平台类型
  properties[@"$lib"] = @"iOS";
  //设备制造商
  properties[@"$manufacturer"] = @"Apple";
  //SDK版本号
  properties[@"$lib_version"] = SensorsAnalyticsVersion;
  //手机型号
  properties[@"$model"] = [self deviceModel];
  //操作系统版本号
  properties[@"$os_version"] = UIDevice.currentDevice.systemVersion;

  //应用程序版本号
  properties[@"$app_version"] = NSBundle.mainBundle.infoDictionary[@"CFBundleShortVersionString"];
  return [properties copy];
}

/// 获取手机型号
- (NSString *)deviceModel {
  size_t size;
  sysctlbyname("hw.machine", NULL, &size, NULL, 0);
  char answer[size];
  sysctlbyname("hw.machine", answer, &size, NULL, 0);
  NSString *results = @(answer);
    return results;
  }


- (void)printEvent:(NSDictionary *)event {
    #if DEBUG
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:event options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
      return NSLog(@"JSON Serialized Error: %@", error);
    }
    NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"[Event]: %@", json);
    #endif
  }
  

- (void)setupListeners {
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];

    // 注册监听UIApplicationDidEnterBackgroundNotification本地通知
    // 即当应用程序进入后台后, 调用通知方法
    [center addObserver:self
        selector:@selector(applicationDidEnterBackground:)
                name:UIApplicationDidEnterBackgroundNotification
            object:nil];

    // 注册监听UIApplicationDidBecomeActiveNotification本地通知
    // 即当应用程序进入前台并处于活动状态之后, 调用通知方法
    [center addObserver:self
        selector:@selector(applicationDidBecomeActive:)
                name:UIApplicationDidBecomeActiveNotification
            object:nil];
    
    // 注册监听UIApplicationWillResignActiveNotification本地通知
      [center addObserver:self
                 selector:@selector(applicationWillResignActive:)
                     name:UIApplicationWillResignActiveNotification
                   object:nil];
    
    // 注册监听UIApplicationDidFinishLaunchingNotification本地通知
      [center addObserver:self
                 selector:@selector(applicationDidFinishLaunching:)
                     name:UIApplicationDidFinishLaunchingNotification
                   object:nil];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    NSLog(@"Application did enter background.");

    self.applicationWillResignActive = NO;
    // 触发$AppEnd事件
    [self track:@"$AppEnd" properties:nil];
    
    [self trackTimerEnd:@"$AppEnd" properties:nil];

    // 暂停所有事件时长统计
    [self.trackTimer enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSDictionary * _Nonnull obj, BOOL * _Nonnull stop) {
        if (![obj[SensorsAnalyticsEventIsPauseKey] boolValue]) {
            [self.enterBackgroundTrackTimerEvents addObject:key];
            [self trackTimerPause:key];
        }
    }];
}


- (void)applicationDidBecomeActive:(NSNotification *)notification {
    NSLog(@"Application did become active.");
    
    //还原标记
    if (self.applicationWillResignActive) {
        self.applicationWillResignActive = NO;
        return;
    }
//    将被动启动标记设置NO,正常记录事件
    self.launchedPassively = NO;
    
    // 恢复所有事件时长统计
    for (NSString *event in self.enterBackgroundTrackTimerEvents) {
        [self trackTimerResume:event];
    }
    
    // 触发$AppStart事件
    [self track:@"$AppStart" properties:nil];
    
    // 开始$AppEnd事件计时
    [self trackTimerStart:@"$AppEnd"];
    
}

- (void)applicationWillResignActive:(NSNotification *)notification {
    NSLog(@"Application will resign active.");

    //标记已接收到UIApplicationWillResignActiveNotification本地通知
    self.applicationWillResignActive = YES;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    NSLog(@"Application did finish launching.");

    // 当应用程序在后台运行时, 触发被动启动事件
     if (self.isLaunchedPassively) {
         // 触发被动启动事件
         [self track:@"$AppStartPassively" properties:nil];
     }
}

- (void)saveAnonymousId:(NSString *)anonymousId {
  // 保存设备ID
  [[NSUserDefaults standardUserDefaults] setObject:anonymousId forKey:SensorsAnalyticsAnonymousId];
  [[NSUserDefaults standardUserDefaults] synchronize];
    
 SensorsAnalyticsKeychainItem *item = [[SensorsAnalyticsKeychainItem alloc] initWithService:SensorsAnalyticsKeychainService key:SensorsAnalyticsAnonymousId];
    if (anonymousId) {
      // 当设备ID(匿名ID)不为空时, 将其保存在Keychain中
      [item update:anonymousId];
    } else {
      // 当设备ID(匿名ID)为空时, 删除Keychain中的值
      [item remove];
    }
}

- (void)setAnonymousId:(NSString *)anonymousId {
  _anonymousId = anonymousId;
  // 保存设备ID(匿名ID)
  [self saveAnonymousId:anonymousId];
}

- (NSString *)anonymousId {
    if (_anonymousId) {
      return _anonymousId;
    }
    // 从NSUserDefaults中读取设备ID
    _anonymousId = [[NSUserDefaults standardUserDefaults] objectForKey:SensorsAnalyticsAnonymousId];
    if (_anonymousId) {
      return _anonymousId;
    }

    SensorsAnalyticsKeychainItem *item = [[SensorsAnalyticsKeychainItem alloc] initWithService:SensorsAnalyticsKeychainService key:SensorsAnalyticsAnonymousId];
    // 从 Keychain 中读取设备 ID
    _anonymousId = [item value];
    
    // 获取IDFA
    Class cls = NSClassFromString(@"ASIdentifierManager");
    if (cls) {
      #pragma clang diagnostic push
      #pragma clang diagnostic ignored "-Wundeclared-selector"
      // 获取ASIdentifierManager的单例对象
      id manager = [cls performSelector:@selector(sharedManager)];
      SEL selector = NSSelectorFromString(@"isAdvertisingTrackingEnabled");
      BOOL (*isAdvertisingTrackingEnabled)(id, SEL) = (BOOL (*)(id, SEL))[manager methodForSelector:selector];
      if (isAdvertisingTrackingEnabled(manager, selector)) {
        // 使用IDFA作为设备ID
        _anonymousId = [(NSUUID *)[manager performSelector:@selector(advertisingIdentifier)] UUIDString];
      }
      #pragma clang diagnostic pop
    }
    if (!_anonymousId) {
      // 使用IDFV作为设备ID
      _anonymousId = UIDevice.currentDevice.identifierForVendor.UUIDString;
    }
    if (!_anonymousId) {
      // 使用UUID作为设备ID
      _anonymousId = NSUUID.UUID.UUIDString;
    }

    // 保存设备ID(匿名ID)
    [self saveAnonymousId:_anonymousId];

    return _anonymousId;
}


- (NSString *)anonymousIds {
    if (_anonymousId) {
      return _anonymousId;
    }
    // 从NSUserDefaults中读取设备ID
    _anonymousId = [[NSUserDefaults standardUserDefaults] objectForKey:SensorsAnalyticsAnonymousId];
    if (_anonymousId) {
        return _anonymousId;
    }

    // 获取IDFA
    Class cls = NSClassFromString(@"ASIdentifierManager");
        if (cls) {
      #pragma clang diagnostic push
      #pragma clang diagnostic ignored "-Wundeclared-selector"
      // 获取ASIdentifierManager的单利对象
      id manager = [cls performSelector:@selector(sharedManager)];
      SEL selector = NSSelectorFromString(@"isAdvertisingTrackingEnabled");
      BOOL (*isAdvertisingTrackingEnabled)(id, SEL) = (BOOL (*)(id, SEL))[manager methodForSelector:selector];
      if (isAdvertisingTrackingEnabled(manager, selector)) {
        // 使用IDFA作为设备ID
        _anonymousId = [(NSUUID *)[manager performSelector:@selector(advertisingIdentifier)] UUIDString];
      }
    #pragma clang diagnostic pop
   }
    if (!_anonymousId) {
      // 使用IDFV作为设备ID
      _anonymousId = UIDevice.currentDevice.identifierForVendor.UUIDString;
    }
    if (!_anonymousId) {
      // 使用UUID作为设备ID
      _anonymousId = NSUUID.UUID.UUIDString;
    }

    // 保存设备ID(匿名ID)
    [self saveAnonymousId:_anonymousId];

    return _anonymousId;
}

#pragma mark - Login
- (void)login:(NSString *)loginId {
    self.loginId = loginId;
    // 在本地保存登录ID
    [[NSUserDefaults standardUserDefaults] setObject:loginId forKey:SensorsAnalyticsLoginId];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Property
+ (double)currentTime {
  return [[NSDate date] timeIntervalSince1970] * 1000;
}


+ (double)systemUpTime {
  return NSProcessInfo.processInfo.systemUptime * 1000;
}

@end

@implementation SensorsAnalyticsSDK (Track)

- (void)track:(NSString *)eventName properties:(NSDictionary<NSString *,id> *)properties {
    NSMutableDictionary *event = [NSMutableDictionary dictionary];
    // 设置事件发生的时间戳, 单位为毫秒
    event[@"time"] = [NSNumber numberWithLong:NSDate.date.timeIntervalSince1970 * 1000];
    
    // 设置事件的distinct_id, 用于唯一标识一个用户
    event[@"distinct_id"] = self.loginId ?: self.anonymousId;
    // 设置事件名称
    event[@"event"] = eventName;
    // 设置事件发生的时间戳, 单位为毫秒
    event[@"time"] = [NSNumber numberWithLong:NSDate.date.timeIntervalSince1970 * 1000];

    NSMutableDictionary *eventProperties = [NSMutableDictionary dictionary];
    // 添加预置属性
    [eventProperties addEntriesFromDictionary:self.automaticProperties];
    // 添加自定义属性
    [eventProperties addEntriesFromDictionary:properties];
    // 判断是否为被动启动状态
    if (self.isLaunchedPassively) {
      // 添加应用程序状态属性
      eventProperties[@"$app_state"] = @"background";
    }
    // 设置事件属性
    event[@"properties"] = eventProperties;
    // 在Xcode控制台中打印事件日志
    [self printEvent:event];
//    [self.fileStore saveEvent:event];
    [self.database insertEvent:event];

}

- (void)trackAppClickWithView:(UIView *)view properties:(nullable NSDictionary <NSString *, id> *)properties {

    NSMutableDictionary *eventProperties = [NSMutableDictionary dictionary];
    // 获取控件类型
    eventProperties[@"$element_type"] = view.sensorsdata_elementType;
    // 获取控件显示文本
    eventProperties[@"$element_content"] = view.sensorsdata_elementContent;
    
    // 获取控件所在的UIViewController
    UIViewController *vc = view.sensorsdata_viewController;
    // 设置页面相关属性
    eventProperties[@"$screen_name"] = NSStringFromClass(vc.class);
    
    // 添加自定义属性
    [eventProperties addEntriesFromDictionary:properties];
    // 触发$AppClick事件
    [[SensorsAnalyticsSDK sharedInstance] track:@"$AppClick" properties: eventProperties];
}


- (void)trackAppClickWithTableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath properties:(nullable NSDictionary<NSString *, id> *)properties {
    NSMutableDictionary *eventProperties = [NSMutableDictionary dictionary];

    // TODO:获取用户点击的UITableViewCell控件对象
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    // TODO:设置被用户点击的UITableViewCell控件上的内容($element_content)
    eventProperties[@"$element_content"] = cell.sensorsdata_elementContent;
    // TODO:设置被用户点击的UITableViewCell控件所在的位置($element_position)
    eventProperties[@"$element_position"] = [NSString stringWithFormat: @"%ld:%ld", (long)indexPath.section, (long)indexPath.row];
    
  // 添加自定义属性
  [eventProperties addEntriesFromDictionary:properties];
  // 触发$AppClick事件
  [[SensorsAnalyticsSDK sharedInstance] trackAppClickWithView:tableView properties:eventProperties];
    
}

- (void)trackAppClickWithCollectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath properties:(nullable NSDictionary<NSString *, id> *)properties {
  NSMutableDictionary *eventProperties = [NSMutableDictionary dictionary];

  // 获取用户点击的UICollectionViewCell控件对象
  UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
  // 设置被用户点击的UICollectionViewCell控件上的内容($element_content)
  eventProperties[@"$element_content"] = cell.sensorsdata_elementContent;
  // 设置被用户点击的UICollectionViewCell控件所在的位置($element_position)
  eventProperties[@"$element_position"] = [NSString stringWithFormat: @"%ld:%ld", (long)indexPath.section, (long)indexPath.row];

  // 添加自定义属性
  [eventProperties addEntriesFromDictionary:properties];
  // 触发$AppClick事件
  [[SensorsAnalyticsSDK sharedInstance] trackAppClickWithView:collectionView properties:eventProperties];
}


@end



#pragma mark - Timer
@implementation SensorsAnalyticsSDK (Timer)

- (void)trackTimerStart:(NSString *)event {
  // 记录事件开始时间
  self.trackTimer[event] = @{SensorsAnalyticsEventBeginKey: @([SensorsAnalyticsSDK systemUpTime])};
}


- (void)trackTimerEnd:(NSString *)event properties:(NSDictionary *)properties {
  NSDictionary *eventTimer = self.trackTimer[event];
  if (!eventTimer) {
    return [self track:event properties:properties];
  }

  NSMutableDictionary *p = [NSMutableDictionary dictionaryWithDictionary:properties];
  // 移除
  [self.trackTimer removeObjectForKey:event];

  if ([eventTimer[SensorsAnalyticsEventIsPauseKey] boolValue]) {
    // 获取事件时长
    double eventDuration = [eventTimer[SensorsAnalyticsEventDurationKey] doubleValue];
                // 设置事件时长属性
      p[@"$event_duration"] = @([[NSString stringWithFormat:@"%.3lf", eventDuration] floatValue]);
    } else {
      // 事件开始时间
      double beginTime = [(NSNumber *)eventTimer[SensorsAnalyticsEventBeginKey] doubleValue];
      // 获取当前时间-> 获取当前系统启动时间
      double currentTime = [SensorsAnalyticsSDK systemUpTime];
      // 计算事件时长
      double eventDuration = currentTime - beginTime + [eventTimer[SensorsAnalyticsEventDurationKey] doubleValue];
      // 设置事件时长属性
      p[@"$event_duration"] = @([[NSString stringWithFormat:@"%.3lf", eventDuration] floatValue]);
    }
    // 触发事件
    [self track:event properties:p];
}


- (void)trackTimerPause:(NSString *)event {
  NSMutableDictionary *eventTimer = [self.trackTimer[event] mutableCopy];
  // 如果没有开始, 直接返回
  if (!eventTimer) {
    return;
  }
  // 如果该事件时长统计已经暂停, 直接返回, 不做任何处理
  if ([eventTimer[SensorsAnalyticsEventIsPauseKey] boolValue]) {
    return;
  }
  // 获取当前系统启动时间
  double systemUpTime = [SensorsAnalyticsSDK systemUpTime];
  // 获取开始时间
  double beginTime = [eventTimer[SensorsAnalyticsEventBeginKey] doubleValue];
  // 计算暂停前统计的时长
  double duration = [eventTimer[SensorsAnalyticsEventDurationKey] doubleValue] + systemUpTime - beginTime;
  eventTimer[SensorsAnalyticsEventDurationKey] = @(duration);
  // 事件处于暂停状态
  eventTimer[SensorsAnalyticsEventIsPauseKey] = @(YES);
  self.trackTimer[event] = eventTimer;
}

- (void)trackTimerResume:(NSString *)event {
  NSMutableDictionary *eventTimer = [self.trackTimer[event] mutableCopy];
  // 如果没有开始, 直接返回
  if (!eventTimer) {
    return;
  }
  // 如果该事件时长统计没有暂停, 直接返回, 不做任何处理
  if (![eventTimer[SensorsAnalyticsEventIsPauseKey] boolValue]) {
    return;
  }
  // 获取当前系统启动时间
  double systemUpTime = [SensorsAnalyticsSDK systemUpTime];
  // 重置事件开始时间
  eventTimer[SensorsAnalyticsEventBeginKey] = @(systemUpTime);
  // 将事件暂停标记设置为NO
  eventTimer[SensorsAnalyticsEventIsPauseKey] = @(NO);
  self.trackTimer[event] = eventTimer;
}

@end
