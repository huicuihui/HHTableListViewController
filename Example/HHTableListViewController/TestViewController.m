//
//  TestViewController.m
//  HHTableListViewController
//
//  Created by 崔辉辉 on 2020/5/6.
//  Copyright © 2020 huihui. All rights reserved.
//

#import "TestViewController.h"
#import "HHObjectListViewController.h"
@interface TestViewController ()<HHTableViewDelegate>
@property (nonatomic, strong)HHObjectListViewController *listVC;
@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.translucent = NO;
    self.listVC = [[HHObjectListViewController alloc]init];
    self.listVC.delegate = self;
    [self addChildViewController:self.listVC];
    [self.view addSubview:self.listVC.view];
    self.listVC.view.frame = self.view.bounds;
    
    [self.listVC.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
}

#pragma mark - delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    cell.textLabel.text = self.listVC.objects[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 99;
}
- (void)fetchObjectWithListViewController:(HHObjectListViewController *)listVC
                                tableView:(UITableView *)tableView
                                  refresh:(BOOL)refresh
{
    //如果是刷新 offset设置为第一页 有的是1是第一页 有的是0是第一页
    if (refresh) {
         listVC.offset = 1;
     }

    
    //网络请求成功
    listVC.offset++;
    NSArray *responseArray = @[@"范德萨发",@"发送到",@"发送到",@"到发萨芬发",@"发发的是非得失",@"发送到",@"发发送到范德萨",@"范德萨",@"规范化发",@"发烫衣服",@"刚发的",@"规范地方法规",@"玉体u哦破"];
    if (refresh) {
        [listVC.objects removeAllObjects];
    }
    [listVC.objects addObjectsFromArray:responseArray];
    [tableView reloadData];
    
    //设置状态
    if (listVC.objects.count == 0) {
        listVC.lastCell.status = LastCellStatusEmpty;
        UILabel *lab = [[UILabel alloc]init];
        lab.text = @"暂无相关数据～";
        listVC.lastCell.emptyView.customView = lab;
        //设置lab的frame
    } else if (responseArray.count < 20) {
        listVC.lastCell.status = LastCellStatusFinished;
    } else {
        listVC.lastCell.status = LastCellStatusMore;
    }
    tableView.tableFooterView = listVC.lastCell;
    
    
    [listVC endRefreshing];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
