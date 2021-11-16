//
//  ViewController.m
//  Demo
//
//  Created by 王玉松 on 2021/9/15.
//

#import "ViewController.h"
#import "firstViewController.h"
#import "DataTableViewController.h"
#import "TargetProxy.h"
#import <SensorsSDK/SensorsSDK.h>
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIButton * btn = [[UIButton alloc]initWithFrame:CGRectMake(100, 100, 100, 50)];
    btn.backgroundColor = [UIColor orangeColor];
    [btn setTitle:@"登录" forState:(UIControlStateNormal)];
    [btn setTitleColor:[UIColor blackColor] forState:(UIControlStateNormal)];
    [btn addTarget:self action:@selector(loginbBtnOnclick) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:btn];
    
    UISwitch *switch1 = [[UISwitch alloc]initWithFrame:CGRectMake(100, 150, 100, 50)];
    [switch1 addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:switch1];
    
    UISlider *slider = [[UISlider alloc]initWithFrame:CGRectMake(100, 200, 100, 50)];
    [slider addTarget:self action:@selector(sliderbutton:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:slider];
    
    UISegmentedControl * segment=[[UISegmentedControl alloc]initWithItems:@[@"最新",@"最热",@"经典"]];
    segment.frame = CGRectMake(100, 260, 200, 50);
    segment.tintColor=[UIColor redColor];
    segment.selectedSegmentIndex=0;
    [segment addTarget:self action:@selector(segmentbutton) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:segment];
    
    
    // 创建 UIStepper 实例对象
    UIStepper *stepper = [[UIStepper alloc] initWithFrame:CGRectMake(230, 100, 94, 29)];
    // 用户交互时实时更新步进值
    stepper.continuous = YES; // default = YES
    // 用户持续按住，自动增加或减少
    stepper.autorepeat = YES; // default = YES
    // 如果设置为 YES, 值会在 min <-> max 之间循环
    stepper.wraps = NO; // default = NO
    stepper.minimumValue = 0;   // default 0
    stepper.maximumValue = 100; // default 100
    stepper.stepValue    = 1;   // default 1
    // 设置 Target-Action
    [stepper addTarget:self
                action:@selector(stepperValueChanged:)
      forControlEvents:UIControlEventValueChanged];
    // 添加到视图
    [self.view addSubview:stepper];
    
    [self testTargetProxy];
    
    
    NSMutableArray *contents = [NSMutableArray array];
    [contents addObject:@"ssjoieoi"];
    [contents addObject:@"ssjoieyoangyusogoi"];
    [contents addObject:@"ssjoieyoangyusogoi"];

    NSLog(@"%@",[contents componentsJoinedByString:@"----"]);
    [self addimageView];
}

-(void)addimageView{
    // 默认为NO, 忽略用户触摸产生的事件
       self.imageView.userInteractionEnabled = YES;

       // 创建一个UITapGestureRecognizer手势识别器, 并将Target设置为self, 响应方法设置为tapAction:方法
       UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];

    // 添加一个Target-Action, Target为self, Action为tapAction:方法
    // [tapGestureRecognizer addTarget:self action:@selector(tapAction:)];
    // 将手势识别器与UIImageView控件进行绑定
    [self.imageView addGestureRecognizer:tapGestureRecognizer];

    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressAction:)];
    [self.imageView addGestureRecognizer:longPressGestureRecognizer];
}

- (void)tapAction:(UITapGestureRecognizer *)sender {
  NSLog(@"UITapGestureRecognizer");
}

- (void)longPressAction:(UILongPressGestureRecognizer *)sender {
NSLog(@"UILongPressGestureRecognizer");
}

- (void)stepperValueChanged:(UIStepper *)stepper {
    // 获取步进值
    NSString *value = [NSString stringWithFormat:@"%f",stepper.value];
    NSLog(@"---------%@",value);

}

-(void)segmentbutton{
    NSLog(@"---------");

}

    
//slider的事件
-(void)sliderbutton:(id)sender{

    //强制转化
    UISlider *slider=(UISlider*)sender;
    NSLog(@"%f",slider.value);
   
}

- (void) switchAction:(UISwitch *) s1 {
    if (s1.on == YES) {
        NSLog(@"开");
    }else{
        NSLog(@"关");
    }

}

-(void)loginbBtnOnclick{
    [[SensorsAnalyticsSDK sharedInstance] login:@"1234567890"];
    NSLog(@"登录");
}

- (IBAction)clickDatatableView:(id)sender {
    
    DataTableViewController * vc = [DataTableViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onBtnClick:(id)sender {
    
    firstViewController * vc = [firstViewController new];
//    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
//    [self presentViewController:vc animated:YES completion:nil];
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (IBAction)trackTimerBeginOnClick:(id)sender {
    [[SensorsAnalyticsSDK sharedInstance] trackTimerStart:@"doSomething"];
}

- (IBAction)trackTimerEndOnClick:(id)sender {
    [[SensorsAnalyticsSDK sharedInstance] trackTimerEnd:@"doSomething" properties:nil];
}

- (IBAction)trackTimerPauseOnClick:(id)sender {
    [[SensorsAnalyticsSDK sharedInstance] trackTimerPause:@"doSomething"];
}

- (IBAction)trackTimerResumeOnClick:(id)sender {
    [[SensorsAnalyticsSDK sharedInstance] trackTimerResume:@"doSomething"];
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
