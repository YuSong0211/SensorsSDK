//
//  TargetProxy.h
//  Demo
//
//  Created by 王玉松 on 2021/9/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TargetProxy : NSProxy

- (instancetype)initWithObject1:(id)object1 object2:(id)object2;

- (void)testTargetProxy;

@end

NS_ASSUME_NONNULL_END
