//
//  firstViewController.m
//  Demo
//
//  Created by 王玉松 on 2021/9/23.
//

#import "firstViewController.h"

@interface firstViewController ()

@end

@implementation firstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"firstvc";
    self.title = @"标题1";
    self.navigationItem.title = @"标题2";

    UILabel *customTitleView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    customTitleView.text = @"标题3";
    customTitleView.font = [UIFont systemFontOfSize:18];
    customTitleView.textColor = [UIColor blackColor];
    //设置位置在中心
    customTitleView.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = customTitleView;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Do any additional setup after loading the view.
    UIButton * btn = [[UIButton alloc]initWithFrame:CGRectMake(100, 100, 100, 50)];
    btn.backgroundColor = [UIColor orangeColor];
    [btn setTitle:@"登录" forState:(UIControlStateNormal)];
    [btn setTitleColor:[UIColor blackColor] forState:(UIControlStateNormal)];
    [btn addTarget:self action:@selector(loginbBtnOnclick) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:btn];
    
  

}

-(void)loginbBtnOnclick{
    NSLog(@"登录");
}




@end
