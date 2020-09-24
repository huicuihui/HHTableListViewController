//
//  HHBaseObjectViewController.m
//  HHBaseController
//
//  Created by 崔辉辉 on 2018/12/10.
//  Copyright © 2018 huihui. All rights reserved.
//

#import "HHBaseObjectViewController.h"
#import "AFNetworking.h"
#import "MJRefresh.h"

#define WEAKSELF                        __weak __typeof(self) weakSelf = self;

// 常量
#define UrlRequestTimeOutInterval       10.0

@interface HHBaseObjectViewController ()
@property (nonatomic, strong) AFHTTPSessionManager *manager;
@property (nonatomic, strong) NSUserDefaults *userDefaults;
@property (nonatomic, strong) NSDate *lastRefreshTime;
@property (nonatomic, assign) BOOL shouldFetch;
@end

@implementation HHBaseObjectViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        _objects = [NSMutableArray new];
        _offset = 0;
        
        _useGetMethod = YES;
        _shouldFetchDataAfterLoaded = YES;
        _needRefreshAnimation = YES;
        _needCache = NO;
        _refreshInterval = 600;
        _shouldFetch = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    self.tableView.sectionHeaderHeight = 0.1;
    self.tableView.sectionFooterHeight = 0.1;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //调用reloadData方法页面跳动问题 需在创建tableview时添加下面三行代码
    self.tableView.estimatedSectionFooterHeight = 0;
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    
    self.tableView.mj_header = ({
        MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refresh)];
        header.lastUpdatedTimeLabel.hidden = YES;
        header.stateLabel.hidden = YES;
        header;
    });
    
    _manager = [AFHTTPSessionManager manager];
    _manager.requestSerializer.timeoutInterval = UrlRequestTimeOutInterval;
    if (_needCache) {
        _manager.requestSerializer.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
        [self fetchObjectAfterOffset:0 refresh:YES];
    }
    
    if (!_shouldFetchDataAfterLoaded) {return;}
    if (_needRefreshAnimation) {
        [self.tableView.mj_header beginRefreshing];
        [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentOffset.y - self.refreshControl.frame.size.height) animated:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    /*** 自动刷新 ***/
    if (_needAutoRefresh) {
        _userDefaults = [NSUserDefaults standardUserDefaults];
        _lastRefreshTime = [_userDefaults objectForKey:_kLastRefreshTime];
        
        if (!_lastRefreshTime) {
            _lastRefreshTime = [NSDate dateWithTimeIntervalSince1970:0];
        }
        
        NSDate *currentTime = [NSDate date];
        if ([currentTime timeIntervalSinceDate:_lastRefreshTime] > _refreshInterval) {
            NSLog(@"\n=======================auto refresh=======================\n");
            [self refresh];
        }
    }
}

#pragma mark - tableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _objects.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.tableViewDelegate && [self.tableViewDelegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)]) {
        return [self.tableViewDelegate tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    return CGFLOAT_MIN;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    if (self.tableViewDelegate && [self.tableViewDelegate respondsToSelector:@selector(tableView:cellForRowAtIndexPath:)]) {
            return [self.tableViewDelegate tableView:tableView cellForRowAtIndexPath:indexPath];
    } else {
        NSAssert(false, @"Implement the proxy method");
        return nil;;
    }
    // Configure the cell...
    
//    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.tableViewDelegate && [self.tableViewDelegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
        [self.tableViewDelegate tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}


#pragma mark - 刷新
- (void)refresh
{
    if (self.willBeginRefresh) {
        self.willBeginRefresh();
    }
    WEAKSELF
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        weakSelf.manager.requestSerializer.cachePolicy = NSURLRequestUseProtocolCachePolicy;
        [self fetchObjectAfterOffset:0 refresh:YES];
    });
    
    if (_needAutoRefresh) {
        _lastRefreshTime = [NSDate date];
        [_userDefaults setObject:_lastRefreshTime forKey:_kLastRefreshTime];
    }
    
    //刷新时，增加另外的网络请求功能
    if (self.anotherNetWorking) {
        self.anotherNetWorking();
    }
}

#pragma mark - 上拉加载更多
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.didScroll) {
        self.didScroll();
    }
    
    if (!_lastCell.shouldResponseToTouch || !_shouldFetch) {
        return;
    }
    if (scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.frame.size.height - 100) {
        [self fetchMore];
    }
}

- (void)tapLastCellAction
{
    if (self.tapLastCell) {
        self.tapLastCell();
    }
    
    if (_lastCell.status == LastCellStatusFinished) {
        return;
    }
    [self fetchMore];
}

- (void)fetchMore
{
    if ([self.tableView.mj_header isRefreshing]) {return;}
    
    _lastCell.status = LastCellStatusLoading;
    //    _manager.requestSerializer.cachePolicy = NSURLRequestUseProtocolCachePolicy;
    
    [self fetchObjectAfterOffset:_offset refresh:NO];
    
}

#pragma mark - 请求数据
- (void)fetchObjectAfterOffset:(NSUInteger)offset refresh:(BOOL)refresh {
    if (self.fetchObjectDelegate && [self.fetchObjectDelegate respondsToSelector:@selector(fetchObjectWithListViewController:tableView:refresh:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.fetchObjectDelegate fetchObjectWithListViewController:self tableView:self.tableView refresh:refresh];
        });
        return;
    }
    
    WEAKSELF
    id successCallback = ^void (NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject[@"status"] intValue] == 1) {
            NSDictionary *dataObj = responseObject[@"data"];
            NSArray *objArr = [self parseJSON:dataObj];
            
            weakSelf.allCount = [dataObj[@"total"] intValue];
            if (refresh) {
                weakSelf.offset = 0;
                [weakSelf.objects removeAllObjects];
                if (weakSelf.didRefreshSucceed) {
                    weakSelf.didRefreshSucceed();
                }
            }
            
            BOOL hasObj = NO;
            for (NSObject *newObj in objArr) {
                BOOL shouldBeAdded = YES;
                for (NSObject *baseObj in weakSelf.objects) {
                    if ([newObj isEqual:baseObj]) {
                        shouldBeAdded = NO;
                        break;
                    }
                }
                if (shouldBeAdded) {
                    hasObj = YES;
                    [weakSelf.objects addObject:newObj];
                }
            }
            
            weakSelf.offset = weakSelf.offset + objArr.count;
            if (hasObj && self.didAddObjects) {
                self.didAddObjects();
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.tableWillReload) {self.tableWillReload(objArr.count);}
                else {
                    if (weakSelf.offset == 0 && objArr.count == 0) {
                       weakSelf.lastCell.status = LastCellStatusEmpty;
                    } else if (objArr.count < ObjectsPerPage || weakSelf.objects.count >= weakSelf.allCount) {
                        weakSelf.lastCell.status = LastCellStatusFinished;
                    } else {
                        weakSelf.lastCell.status = LastCellStatusMore;
                    }
                }
                self.tableView.tableFooterView = weakSelf.lastCell;
                [self.tableView reloadData];
            });
            
        } else {
            [self loadError];
            NSLog(@"%@",responseObject[@"message"]);
        }
        [self endRefreshing];
    };
    
    id failureCallback = ^void (NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"failureCallback");
        [self loadError];
        [self endRefreshing];
    };
    
    if (self.useGetMethod) {
        [_manager GET:self.generateURL(offset) parameters:nil headers:nil progress:nil success:successCallback failure:failureCallback];
    } else {
        [_manager POST:self.generateURL(offset) parameters:self.generateParameters(offset) headers:nil progress:nil success:successCallback failure:failureCallback];
    }
}

- (void)loadError {
    _lastCell.status = LastCellStatusMore;
    self.shouldFetch = NO;
    if (self.objects.count > 0 && self.didAddObjects) {
        self.didAddObjects();
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        self.shouldFetch = YES;
    });
}

- (void)endRefreshing
{
    if (self.tableView.mj_header.isRefreshing) {
        [self.tableView.mj_header endRefreshing];
    }
}

- (NSArray *)parseJSON:(id)responseObject {
    NSAssert(false, @"Override in subclasses");
    return nil;
}

#pragma mark - lazy load
- (HHLastCell *)lastCell
{
    if (!_lastCell) {
        self.lastCell = [[HHLastCell alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, TableLastCellHeight)];
        [self.lastCell addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapLastCellAction)]];
        self.tableView.tableFooterView = self.lastCell;
    }
    return _lastCell;
}

@end
