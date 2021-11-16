//
//  TargetProxy.m
//  Demo
//
//  Created by 王玉松 on 2021/9/28.
//

#import "TargetProxy.h"

@implementation TargetProxy {
    // 保存需要将消息转发到的第一个真实对象
    // 第一个真实对象的方法调用优先级会比第二个真实对象的方法调用优先级高
    id _realObject1;
    // 保存需要将消息转发到的第二个真实对象
    id _realObject2;
}

/**
 初始化方法
 保存两个真实对象

 @param object1 第一个真实对象
 @param object2 第二个真实对象
 @return 初始化对象
 */
- (instancetype)initWithObject1:(id)object1 object2:(id)object2 {
    _realObject1 = object1;
    _realObject2 = object2;
    return self;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    // 获取_realObject1 中aSelector的方法签名
    NSMethodSignature *signature = [_realObject1 methodSignatureForSelector:aSelector];
    // 如果在_realObject1中有该方法, 那么返回该方法的签名
    // 如果没有, 则查看_realObject2
    if (signature) {
        return signature;
    }
    // 获取_realObject2中aSelector的方法签名
    signature = [_realObject2 methodSignatureForSelector:aSelector];
    return signature;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    // 获取拥有该方法的真实对象
    id target = [_realObject1 methodSignatureForSelector:[invocation selector]] ? _realObject1 : _realObject2;
    // 执行方法
    [invocation invokeWithTarget:target];
}


- (void)testTargetProxy {
    // 创建一个NSMutableString的对象
    NSMutableString *string = [NSMutableString string];
    // 创建一个NSMutableArray的对象
    NSMutableArray *array = [NSMutableArray array];

    // 创建一个委托对象来包装真实的对象
    id proxy = [[TargetProxy alloc] initWithObject1:string object2:array];
    // 通过委托对象调用NSMutableString类的方法
    [proxy appendString:@"This "];
    [proxy appendString:@"is "];
    // 通过委托对象调用NSMutableArray类的方法
    [proxy addObject:string];
    [proxy appendString:@"a "];
    [proxy appendString:@"test!"];

    // 使用valueForKey: 方法获取字符串的长度
    NSLog(@"The string's length is: %@", [proxy valueForKey:@"length"]);

    NSLog(@"count should be 1, it is: %ld", [proxy count]);

    if ([[proxy objectAtIndex:0] isEqualToString:@"This is a test!"]) {
        NSLog(@"Appending successful.");
    } else {
        NSLog(@"Appending failed, got: '%@'", proxy);
    }
}

@end
