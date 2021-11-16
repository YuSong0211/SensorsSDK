//
//  DataCollectionViewController.h
//  Demo
//
//  Created by 王玉松 on 2021/9/29.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SensorDataCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@interface DataCollectionViewController : UIViewController

@end

NS_ASSUME_NONNULL_END
