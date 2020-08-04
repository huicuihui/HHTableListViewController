//
//  HHViewController.m
//  HHTableListViewController
//
//  Created by 805988356@qq.com on 08/04/2020.
//  Copyright (c) 2020 805988356@qq.com. All rights reserved.
//

#import "HHViewController.h"
#import "TestViewController.h"

@interface HHViewController ()

@end

@implementation HHViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor redColor];
    button.frame = CGRectMake(100, 200, 100, 80);
    [self.view addSubview:button];
    [button addTarget:self action:@selector(test) forControlEvents:UIControlEventTouchUpInside];
}
- (void)test
{
    TestViewController *vc = [[TestViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
