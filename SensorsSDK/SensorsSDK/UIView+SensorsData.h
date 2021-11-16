//
//  UIView+SensorsData.h
//  SensorsSDK
//
//  Created by 王玉松 on 2021/9/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (SensorsData)

@property (nonatomic, copy, readonly) NSString *sensorsdata_elementType;
@property (nonatomic, copy, readonly) NSString *sensorsdata_elementContent;
@property (nonatomic, readonly) UIViewController *sensorsdata_viewController;


@end

#pragma mark - UIButton
@interface UIButton (SensorsData)

@end

#pragma mark - UILabel
@interface UILabel (SensorsData)

@end

#pragma mark - UISwitch
@interface UISwitch (SensorsData)

@end

#pragma mark - UISlider
@interface UISlider (SensorsData)

@end

#pragma mark - UISegmentedControl
@interface UISegmentedControl (SensorsData)

@end

#pragma mark - UIStepper
@interface UIStepper (SensorsData)

@end

NS_ASSUME_NONNULL_END
