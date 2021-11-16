//
//  UIView+SensorsData.m
//  SensorsSDK
//
//  Created by 王玉松 on 2021/9/24.
//

#import "UIView+SensorsData.h"

@implementation UIView (SensorsData)

- (NSString *)sensorsdata_elementType {
    return NSStringFromClass([self class]);
}

- (NSString *)sensorsdata_elementContent {
    // 如果是隐藏控件, 不获取控件内容
    if (self.isHidden || self.alpha == 0) {
        return nil;
    }
    // 初始化数组, 用于保存子控件的内容
    NSMutableArray *contents = [NSMutableArray array];
    for (UIView *view in self.subviews) {
        // 获取子控件的内容
        // 如果子类有内容, 例如UILabel的text, 获取到的就是text属性
        // 如果子类没有内容, 就递归调用该方法, 获取其子控件的内容
        NSString *content = view.sensorsdata_elementContent;
        if (content.length > 0) {
            // 当该子控件有内容时, 保存在数组中
            [contents addObject:content];
        }
    }
    // 当未获取到子控件内容时, 返回nil。如果获取到多个子控件内容时, 使用"-"拼接
    return contents.count == 0 ? nil : [contents componentsJoinedByString:@"-"];
}

- (UIViewController *)sensorsdata_viewController {
    UIResponder *responder = self;
    while ((responder = [responder nextResponder])) {
        if ([responder isKindOfClass: [UIViewController class]]){
            return (UIViewController *)responder;
        }
    }
    // 如果没有找到, 返回nil
    return nil;
}

@end

#pragma mark - UIButton
@implementation UIButton (SensorsData)

- (NSString *)sensorsdata_elementContent {
    return self.currentTitle ?: super.sensorsdata_elementContent;
}
@end

#pragma mark - UILabel
@implementation UILabel (SensorsData)

- (NSString *)sensorsdata_elementContent {
    return self.text ?: super.sensorsdata_elementContent;
}

@end

#pragma mark - UISwitch
@implementation UISwitch (SensorsData)

- (NSString *)sensorsdata_elementContent {
    return self.on ? @"checked" : @"unchecked";
}

@end

#pragma mark - UISlider
@implementation UISlider (SensorsData)

- (NSString *)sensorsdata_elementContent {
    return [NSString stringWithFormat:@"%.2f", self.value];
}

@end

#pragma mark - UISegmentedControl
@implementation UISegmentedControl (SensorsData)

- (NSString *)sensorsdata_elementContent {
    return [self titleForSegmentAtIndex:self.selectedSegmentIndex];
}
@end

#pragma mark - UIStepper
@implementation UIStepper (SensorsData)

- (NSString *)sensorsdata_elementContent {
    return [NSString stringWithFormat:@"%g", self.value];
}

@end
