//
//  HHBaseObjectViewController.h
//  HHBaseController
//
//  Created by 崔辉辉 on 2018/12/10.
//  Copyright © 2018 huihui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HHLastCell.h"

#define ObjectsPerPage                  10

NS_ASSUME_NONNULL_BEGIN

@class HHBaseObjectViewController;
@protocol FetchObjectDelegate <NSObject>
@optional
/// 网络请求
/// @param listVC <#listVC description#>
/// @param tableView <#tableView description#>
/// @param refresh <#refresh description#>
- (void)fetchObjectWithListViewController:(HHBaseObjectViewController *)listVC
                                tableView:(UITableView *)tableView
                                  refresh:(BOOL)refresh;
@end

@protocol HHTableViewDelegate <NSObject>
@required
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
@optional
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
/// 点击cell
/// @param tableView <#tableView description#>
/// @param indexPath <#indexPath description#>
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
@end

@interface HHBaseObjectViewController : UITableViewController

@property (nonatomic, assign)BOOL useGetMethod;
@property (nonatomic, assign)BOOL shouldFetchDataAfterLoaded;
@property (nonatomic, assign)BOOL needRefreshAnimation;
@property (nonatomic, assign)BOOL needCache;

@property (nonatomic, assign)BOOL needAutoRefresh;
@property (nonatomic, copy)NSString *kLastRefreshTime;
@property (nonatomic, assign) NSTimeInterval refreshInterval;

@property (nonatomic, copy)void (^anotherNetWorking)(void);
@property (nonatomic, copy)NSString *(^generateURL)(NSUInteger offset);
@property (nonatomic, copy)NSDictionary *(^generateParameters)(NSUInteger offset);
@property (nonatomic, copy)void (^willBeginRefresh)(void);
@property (nonatomic, copy)void (^didRefreshSucceed)(void);
@property (nonatomic, copy)void (^didAddObjects)(void);
@property (nonatomic, copy)void (^tableWillReload)(NSUInteger responseObjectsCount);
@property (nonatomic, copy)void (^didScroll)(void);
@property (nonatomic, copy)void (^tapLastCell)(void);

@property (nonatomic, assign)NSUInteger offset;
@property (nonatomic, assign)NSUInteger refTime;
@property (nonatomic, strong)NSMutableArray *objects;
@property (nonatomic, assign)int allCount;
@property (nonatomic, strong)HHLastCell *lastCell;

@property(nonatomic, weak) id <HHTableViewDelegate> tableViewDelegate;
@property(nonatomic, weak) id <FetchObjectDelegate> fetchObjectDelegate;

- (NSArray *)parseJSON:(id)responseObject;

- (void)fetchMore;

- (void)refresh;

- (void)endRefreshing;

@end

NS_ASSUME_NONNULL_END
