//
//  NSObject+SASwizzler.h
//  SensorsSDK
//
//  Created by 王玉松 on 2021/9/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (SASwizzler)

//交换方法名为originalSEL和方法名为alternateSEL两个方法的实现
//@param originalSEL原始方法名
//@param alternateSEL要交换的方法名称
+ (BOOL)sensorsdata_swizzleMethod:(SEL)originalSEL withMethod:(SEL)alternateSEL;

@end

NS_ASSUME_NONNULL_END
