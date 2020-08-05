# HHTableListViewController
封装tableView基类

## BaseObjectViewController
列表tableVIewController基类
- `needCache`第一次显示时是否需要加载上次缓存，需要的话在viewDidLoad中使用afn自带的缓存机制加载缓存数据。默认为NO。
    注：POST请求尽量不要使用AFN自带的缓存。
- `refTime` 时间戳，列表最后一条数据的时间戳。
不同的列表的数据源的model模型不同，所以把`refTime`定义在外面，从子类去赋值。
- `ObjectsPerPage` 分页加载，每页数据的个数。在自动加载更多中要判断是否有更多数据。
- `@property (nonatomic, copy)NSString *(^generateURL)(NSUInteger offset);` : GET请求的个数，在基类中改变，刷新时变为初始值0 加载更多时添加，在子类`init`方法中实现`self.generateURL`方法，在里面添加请求地址的时候使用。

#### 使用：
1. 定义子类 继承`BaseObjectViewController`。
2. 子类的`- (instancetype)init`方法中去给各个参数赋值。
    ```
    - (instancetype)init {
    self = [super init];
    if (self) {
    self.refTime = 0;
    
    WEAKSELF
    self.generateURL = ^NSString * (NSUInteger offset) {
    //先定义baseUrl ？之前的
    NSString *baseUrl = [NSString stringWithFormat:@"%@%@", @"", @""];
    
    //请求地址`？`之后的 GET请求的参数
    NSString *parameters = [NSString stringWithFormat:@"par=%@&pageSize=%d&", @"canshuyi", 20];
    
    if (weakSelf.refTime > 0) {
    parameters = [NSString stringWithFormat:@"%@lteTime=%lu&", parameters, (unsigned long)weakSelf.refTime];
    }
    
    return [NSString stringWithFormat:@"%@?%@", baseUrl, parameters];
    };
    
    //POST请求 body参数
    self.generateParameters = ^NSDictionary * (NSUInteger offset) {

    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
    @(offset), @"start",
    @(ObjectsPerPage), @"limit",
    typeDesp, @"type",
    UserDefaultValueForKey(@"token"), @"token", nil];
    
    if (weakSelf.refTime > 0) {
    [parameters setObject:@(weakSelf.refTime) forKey:@"lteTime"];
    }
    
    return parameters;
    };
    
    self.willBeginRefresh = ^void () {
    weakSelf.refTime = 0;
    };
    
    self.didAddObjects = ^void () {
    QuestionModel *model = weakSelf.objects.lastObject;
    weakSelf.refTime = model.updateTime;
    };
    
    //POST请求
    self.useGetMethod = NO;
    //GET请求
    self.needCache = YES;
    self.needRefreshAnimation = NO;
    
    self.needAutoRefresh = YES;
    self.refreshInterval = 600;
    self.kLastRefreshTime = [NSString stringWithFormat:@"RefreshInterval%@", @"hhh"];
    }
    return self;
    }
    ```
3. 解析请求回来的数据
    ```
    - (NSArray *)parseJSON:(id)responseObject {
    NSMutableArray *objects = [NSMutableArray array];
    NSArray *data = responseObject[@"data"];
    for (NSDictionary *object in data) {
    QuestionModel *model = [[QuestionModel alloc] init];
    [model setValuesForKeysWithDictionary:object];
    [objects addObject:model];
    }
    return objects;
    }
    ```
4. 注册cell
    ```
    - (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[QuestionCell class] forCellReuseIdentifier:@"cell"];
    self.tableView.backgroundColor = [UIColor backgroundColor];
    self.lastCell.emptyMessage = @"暂无问题";
    }
    ```
5. 实现tableView的代理方法
    - `- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;`
    -  `- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;`
    -  `- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;`
    
#####   刷新加载
1. 自动刷新功能
    viewWillAppear方法中判断是否需要自动刷新
    如果需要自动刷新则判断现在的时间距离上次刷新的时间是否超过规定的刷新间隔
    如果超过了刷新的时间间隔，则调用刷新方法进行列表的刷新
2. 自动加载更多
    是否加载更多请求需要下面两个判断：
    1. `LastCell`的状态。
        请求接口之前要把`LastCell`状态改为加载中的状态。
    2. `.m`中定义一个BOOL属性`shouldFetch`来判断是否可以加载更多。
    
    ### LastCell
    有如下几个状态：
    - LastCellStatusNotVisible：默认的状态
    - LastCellStatusMore：可以加载更多
    - LastCellStatusLoading：正在加载中
    - LastCellStatusError：加载失败
    - LastCellStatusFinished：加载完所有数据，没有更多数据
    - LastCellStatusEmpty：没有数据，数据为空

    `shouldResponseToTouch`:只读属性，get方法中判断status，如果是`LastCellStatusMore`或`LastCellStatusError` 返回YES，其它状态返回NO。
    只有当status是上面两种状态时，才可以加载更多，其它状态不能加载。
    
    `lastCell`的默认`status`是`LastCellStatusNotVisible`，这种状态是不可以加载更多的，也就是第一次进入页面，还没有数据的时候，只能刷新，不能加载更多。不然会有问题。
    
    在网络请求中，要设置`lastCell`的`status`
    1. 数据源总个数为空 一条都没有。
    `weakSelf.lastCell.status = LastCellStatusEmpty;`
    2. 数据个数小于一页或数据总数不小于后台数据总数，则加载完所有数据，没有更多。
    `weakSelf.lastCell.status = LastCellStatusFinished;`
    3. 其他情况包括请求成功或失败，都设置为可以加载更多。还可以加载。
    `weakSelf.lastCell.status = LastCellStatusMore;`
    
    #####ErrorView
    ErrorView：包含两部分，图片和文字。
    当列表数据个数为空的时候，lastCell的emptyView的hidden为NO，显示一个无内容图片。

#####   使用
如果是简单的tableView列表 没有其他的视图，就可以直接使用。
如果有其他的视图，可以创建一个父控制器，在父控制器中添加子控制器和视图。
