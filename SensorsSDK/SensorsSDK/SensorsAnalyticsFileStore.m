//
//  SensorsAnalyticsFileStore.m
//  SensorsSDK
//
//  Created by 王玉松 on 2021/10/15.
//

#import "SensorsAnalyticsFileStore.h"

@interface  SensorsAnalyticsFileStore()

@property (nonatomic, strong) NSMutableArray<NSDictionary *> *events;

@property (nonatomic, copy, readonly) NSArray<NSDictionary *> *allEvents;


/// 串行队列
@property (nonatomic, strong) dispatch_queue_t queue;

@end
// 默认文件名
static NSString * const SensorsAnalyticsDefaultFileName = @"SensorsAnalyticsData.plist";

@implementation SensorsAnalyticsFileStore

- (instancetype)init {
    self = [super init];
    if (self) {
        
        _maxLocalEventCount = 10000;
        
        // 初始化默认的事件数据存储地址
         _filePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:SensorsAnalyticsDefaultFileName];
//        // 初始化事件数据, 后面会先读取本地保存的事件数据
//        _events = [[NSMutableArray alloc] init];
        // 初始化队列的唯一标识
        NSString *label = [NSString stringWithFormat:@"cn.sensorsdata.serialQueue.%p", self];
        // 创建一个serial类型的queue, 即FIFO
        _queue = dispatch_queue_create([label UTF8String], DISPATCH_QUEUE_SERIAL);
        
        // 从文件路径中读取数据
        [self readAllEventsFromFilePath:_filePath];
    }
    return self;
}

- (void)saveEvent:(NSDictionary *)event {
    dispatch_async(self.queue, ^{
    // 如果当前事件条数超过最大值, 删除最旧的事件
          if (self.events.count >= self.maxLocalEventCount) {
              [self.events removeObjectAtIndex:0];
          }
          // 在数组中直接添加事件数据
          [self.events addObject:event];
          // 将事件数据保存在文件中
          [self writeEventsToFile];
    });
}

- (void)writeEventsToFile {
    // JSON解析错误信息
    NSError *error = nil;
    // 将字典数据解析成JSON数据
    NSData *data = [NSJSONSerialization dataWithJSONObject:self.events options:
    NSJSONWritingPrettyPrinted error:&error];
    if (error) {
    return NSLog(@"The json object's serialization error: %@", error);
    }
    // 将数据写入文件
    [data writeToFile:self.filePath atomically:YES];
}

- (void)readAllEventsFromFilePath:(NSString *)filePath {
    dispatch_async(self.queue, ^{
        // 从文件路径中读取数据
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        // 解析在文件中读取的JSON数据
        NSMutableArray *allEvents = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        // 将文件中的数据保存在内存中
        self.events = allEvents ?: [NSMutableArray array];
    });
    
}

- (NSArray<NSDictionary *> *)allEvents {
    __block NSArray<NSDictionary *> *allEvents = nil;
        dispatch_sync(self.queue, ^{
            allEvents = [self.events copy];
        });
        return allEvents;
    
}

- (void)deleteEventsForCount:(NSInteger)count {
    dispatch_async(self.queue, ^{
        // 删除前count条事件数据
        [self.events removeObjectsInRange:NSMakeRange(0, count)];
        // 将删除后剩余的事件数据保存到文件中
        [self writeEventsToFile];
    });
}

@end
