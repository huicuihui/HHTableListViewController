//
//  HHObjectListViewController.h
//  HHBaseController
//
//  Created by 崔辉辉 on 2020/3/27.
//  Copyright © 2020 huihui. All rights reserved.
//

#import "HHBaseObjectViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class HHObjectListViewController;
@protocol HHTableViewDelegate <NSObject>

@required

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

@optional

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;

/// 点击cell
/// @param tableView <#tableView description#>
/// @param indexPath <#indexPath description#>
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

/// 网络请求
/// @param listVC <#listVC description#>
/// @param tableView <#tableView description#>
/// @param refresh <#refresh description#>
- (void)fetchObjectWithListViewController:(HHObjectListViewController *)listVC
                                tableView:(UITableView *)tableView
                                  refresh:(BOOL)refresh;
@end

@interface HHObjectListViewController : HHBaseObjectViewController
@property(nonatomic, weak) id <HHTableViewDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
