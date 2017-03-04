//
//  CourseTableViewController.m
//  XiaoYa
//
//  Created by commet on 16/10/11.
//  Copyright © 2016年 commet. All rights reserved.
//github有点迷

#import "CourseTableViewController.h"
#import "WeekSheet.h"
#import "CourseModel.h"
#import "BusinessModel.h"
#import "CourseButton.h"
#import "TimeViewCell.h"
#import "DayViewCell.h"
#import "Masonry.h"
#import "Utils.h"
#import "DateUtils.h"
#import "NSDate+Calendar.h"
#import "BusinessViewController.h"
#import "CourseViewController.h"
#import "BusinessCourseManage.h"

#import "DbManager.h"

#define kScreenWidth [UIApplication sharedApplication].keyWindow.bounds.size.width
#define kScreenHeight [UIApplication sharedApplication].keyWindow.bounds.size.height
@interface CourseTableViewController ()<UIScrollViewDelegate,WeekSheetDelegate,BusinessCourseManageDelegate,BusinessViewControllerDelegate>
@property (nonatomic ,weak) UIButton* navItemTitle;
@property (nonatomic ,weak) WeekSheet* weeksheet;//标题按钮下拉列表
@property (nonatomic ,weak) UIScrollView* timeView;//纵向表示时间段的scrollview
@property (nonatomic ,weak) UIScrollView* daysView;//横向表示日期周几的scrollview
@property (nonatomic ,weak) UIScrollView* classView;;//课程格子scrollview
@property (nonatomic ,weak) UIView *topLeftView;//左上角
@property (nonatomic ,weak) UIView *stripeView;//日期底部会滑动的横条
@property (nonatomic,weak) UIView *coverLayer;//半透明遮罩

@property (nonatomic ,strong)NSMutableArray *classSubViewArray;//classview上七个列向上的子view，用来控制某列所有课程格子的宽度
@property (nonatomic ,strong)NSMutableArray *allCourses;//存储一周所有课程数据模型的数组
@property (nonatomic ,strong)NSDate *firstDateOfTerm;
@property (nonatomic,strong) NSString *displayweek;//需要显示第几周的课程事务
@end

static BOOL flag = false ;
@implementation CourseTableViewController
{
    CGFloat topLeftViewWidth;//左上角view的宽
    CGFloat topLeftViewHeight;//左上角view的高
    CGFloat timeViewCellHeight;//时间段scrollview上的子view高
    CGFloat dayViewCellWidth;//日期scrollview上的子view宽
    NSInteger currentWeekDay;//当前是周几,0表示周一
    NSInteger currentDayIndex;//当前选中的是哪列
    NSInteger lastDayIndex;//上次选中的是哪列
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //-------
    NSDate *currentDate = [NSDate date];//当前日期。
    int weekday = [currentDate dayOfWeek];//周几，1表示周日，2表示周一
    if (weekday == 1){//转换，0表示周一，1表示周二......6表示周日
        currentWeekDay = 6;
    }else{
        currentWeekDay = weekday - 2;
    }
    currentDayIndex = currentWeekDay;
    
    //-------设置学期第一周周一是几号
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    self.firstDateOfTerm = [dateFormatter dateFromString:@"20160829"];
    
    //-------设置右上角加号
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"addItem"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(pushAddViewController)];
    //-------去掉导航栏下面那条黑线
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"NavBg"] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    //-------导航栏title设置
    self.edgesForExtendedLayout=UIRectEdgeNone;
    UIButton *navItemTitle = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 200, 40)];
    _navItemTitle = navItemTitle;
    _navItemTitle.titleLabel.font = [UIFont systemFontOfSize:17.0];
    NSInteger curDateDistance = [DateUtils dateDistanceFromDate:currentDate toDate:self.firstDateOfTerm];//当前日期距离学期第一天的天数
    NSInteger curWeek = curDateDistance / 7 + 1;//当前周
    [_navItemTitle setTitle:[NSString stringWithFormat:@"第%ld周",curWeek] forState:UIControlStateNormal];
    [_navItemTitle setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_navItemTitle addTarget:self action:@selector(popWeekSheet) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = _navItemTitle;
    
    //-------一些用到的距离
    topLeftViewWidth = 90.0 / 750.0 * kScreenWidth; //750是iphone6屏幕宽。乘除运算要带小数点，不然整数和整数相除结果也是整数
    topLeftViewHeight = 110.0 / 1334.0 * kScreenHeight;
    timeViewCellHeight = (kScreenHeight - 64 - 49 - topLeftViewHeight) / 10.0;
    dayViewCellWidth = (kScreenWidth - topLeftViewWidth)/6.0;//放大列为正常列两倍,相当于一屏有六列
    
    //-------
    [self dataBase];
    [self topLeftViewSetting];
    [self timeScrollViewSetting];
    [self classViewSetting];
    [self daysViewSetting:currentDate];
    [self bottomLineSetting];
    [self weekSheetInit];//最后加，加在最上一层

    [self loadLoacalData:(curWeek - 1)];
//	_displayweek = [NSString stringWithFormat:@"%ld",(long)curWeek];
    
}


//每次显示都需要重新加载
//-(void)viewWillAppear:(BOOL)animated{
//   //刷新表格中的课程数据
//    //    //清除原有数据
//    for(UIView *columview in self.classSubViewArray)
//    {
//        for(CourseButton *coursebtn in [columview subviews])
//        {
//            [coursebtn removeFromSuperview];
//        }
//    }
//    //加载新数据
//    _displayweek = _navItemTitle.titleLabel.text;
//    _displayweek = [_displayweek substringWithRange:NSMakeRange(1, _displayweek.length-2)];
//    [self loadDatafromSQL:_displayweek];
//    
//}

- (void)dataBase{
    //-------数据库
    DbManager *dbManger = [DbManager shareInstance];
    [dbManger openDb:@"eventData.sqlite"];
//    [dbManger executeNonQuery:@"drop table if exists t_201601"];
    NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS t_201601(                                                                                                         id INTEGER PRIMARY KEY AUTOINCREMENT,                                                                        description TEXT NOT NULL,                                                                                                comment TEXT,                                                                                                                                                week INTEGER NOT NULL,                                                                                                weekday INTEGER NOT NULL,                                                                                                date TEXT,                                                                                                                        time TEXT,                                                                                                                        repeat INTEGER,                                                                                                overlap INTEGER);"];
    [dbManger executeNonQuery:sql];

//	NSString *sql2 = [NSString stringWithFormat:@"create table if not exists course_table (id integer primary key autoincrement,weeks text not null,weekDay text not null,courseStart text not null,numberOfCourse text not null,courseName text not null,place text not null);"];
    
    //测试阶段，先每次开启都创建新的表格
    NSString *sql2 = [NSString stringWithFormat:@"create table exists course_table (id integer primary key autoincrement,weeks text not null,weekDay text not null,courseStart text not null,numberOfCourse text not null,courseName text not null,place text not null);"];
    [dbManger executeNonQuery:sql2];
}

- (void)popWeekSheet{
    if(!flag){
        self.weeksheet.hidden = NO;
        flag = true;
    }
    else
    {
        self.weeksheet.hidden = YES;
        flag = false;
    }
}

-(void)pushAddViewController{
    NSMutableArray *controllersArray = [NSMutableArray array];
    BusinessViewController *businessManage = [[BusinessViewController alloc]initWithfirstDateOfTerm:self.firstDateOfTerm businessModel:nil];
    businessManage.delegate = self;
    [controllersArray addObject:businessManage];
    CourseViewController *courseManage = [[CourseViewController alloc]init];
    [controllersArray addObject:courseManage];

    BusinessCourseManage *management = [[BusinessCourseManage alloc]initWithControllersArray:controllersArray firstDateOfTerm:self.firstDateOfTerm];
    management.delegate = self;
    management.hidesBottomBarWhenPushed = YES;//从下级vc开始，tabbar都隐藏掉
    [self.navigationController pushViewController:management animated:YES];
}

//加载本地的模拟数据
- (void)loadLoacalData:(NSInteger )week{
//    static BOOL flag = YES;
//    NSString *coursePath;
//    if (flag) {
//        coursePath = [[NSBundle mainBundle] pathForResource:@"courses" ofType:@"json"];
//        flag = NO;
//    }else {
//        coursePath = [[NSBundle mainBundle] pathForResource:@"courses-1" ofType:@"json"];
//        flag = YES;
//    }
//    //对plist文件json数据的处理，转数据模型
//    NSData *data = [NSData dataWithContentsOfFile:coursePath];
//    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
//    NSString *status = [dict objectForKey:@"status"];
//    if (![@"200" isEqualToString:status]) {
//        NSLog(@"没有数据");
//        return;
//    }
//    NSArray *dataArray = [dict objectForKey:@"data"];
//    self.allCourses =[NSMutableArray array];
//    if (dataArray != nil && dataArray.count > 0) {
//        for (int i = 0; i < dataArray.count; i++) {
//            NSDictionary *dayDict = dataArray[i];//某天的数据字典，周几，课程数据
//            NSArray *dayCoursesArray = [dayDict objectForKey:@"data"];//某天的课程数组，数组中元素是课程字典
//            NSString *weekDay = [dayDict objectForKey:@"weekDay"];
//            NSString *weekNum;
//            //周几转化成数字（字符串）
//            if ([@"monday" isEqualToString:weekDay]) {
//                weekNum = @"1";
//            }else if ([@"tuesday" isEqualToString:weekDay]){
//                weekNum = @"2";
//            }else if ([@"wednesday" isEqualToString:weekDay]){
//                weekNum = @"3";
//            }else if ([@"thursday" isEqualToString:weekDay]){
//                weekNum = @"4";
//            }else if ([@"friday" isEqualToString:weekDay]){
//                weekNum = @"5";
//            }else if ([@"saturday" isEqualToString:weekDay]){
//                weekNum = @"6";
//            }else if([@"sunday" isEqualToString:weekDay]){
//                weekNum = @"7";
//            }else {
//                weekNum = @"1";
//            }
//            
//            for (int j = 0; j < dayCoursesArray.count ; j++) {
//                NSMutableDictionary *course = [NSMutableDictionary dictionaryWithDictionary:dayCoursesArray[j]];
//                [course setObject:weekNum forKey:@"weekDay"];//重新组装课程字典，添加上周几
//                CourseModel *weekCourse = [[CourseModel alloc] initWithDict:course];//转数据模型
//                weekCourse.weeks = week;
//                [self.allCourses addObject:weekCourse];
//            }
//        }
//    }
//    [self handleData:self.allCourses];

    //刷新表格中的课程数据
    //清除原有数据
    for(UIView *columview in self.classSubViewArray)
    {
        for(CourseButton *coursebtn in [columview subviews])
        {
            [coursebtn removeFromSuperview];
        }
    }
    
    NSDate *weekMonday = [DateUtils dateOfWeekMonday:week firstDateOfTrem:self.firstDateOfTerm];
    NSArray *data = [DateUtils getDatesOfCurrence:weekMonday];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    NSDateComponents *compt = [[NSDateComponents alloc] init];
    NSMutableArray * dateArray = [NSMutableArray arrayWithCapacity:7];
    for (int i = 0; i < 7; i ++) {
        [compt setYear:[data[i][0] integerValue]];
        [compt setMonth:[data[i][1] integerValue]];
        [compt setDay:[data[i][2] integerValue]];
        NSDate * tempDate = [gregorian dateFromComponents:compt];
        NSString *tempDateString = [dateFormatter stringFromDate:tempDate];
        [dateArray addObject:tempDateString];
    }    
    self.allCourses =[NSMutableArray array];
    DbManager *dbManger = [DbManager shareInstance];
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM t_201601 WHERE date = '%@' or date = '%@' or date = '%@' or date = '%@' or date = '%@' or date = '%@' or date = '%@' ;",dateArray[0],dateArray[1],dateArray[2],dateArray[3],dateArray[4],dateArray[5],dateArray[6]];
    NSArray *dataQuery = [dbManger executeQuery:sql];
    if (dataQuery.count > 0) {
        for (int j = 0; j < dataQuery.count ; j++) {
            NSMutableDictionary *busDict = [NSMutableDictionary dictionaryWithDictionary:dataQuery[j]];
            BusinessModel *model = [[BusinessModel alloc] initWithDict:busDict];//转数据模型
            [self.allCourses addObject:model];
        }
        [self handleData:self.allCourses];
    }
}

////从数据库加载课程数据
//-(void)loadDatafromSQL:(NSString *)week
//{
//    DbManager *dbManger = [DbManager shareInstance];
//    [dbManger openDb:@"eventcourse.sqlite"];
//    
//    NSString *sql = [NSString stringWithFormat:@"SELECT weeks,weekDay,courseStart,numberOfCourse,courseName,place FROM course_table WHERE weeks is '%@'",week];
//    NSArray *thisweekcourse = [[NSArray alloc] init];
//    thisweekcourse = [dbManger executeQuery:sql];
//    
//    //NSLog(@"%@",thisweekcourse);
//    
//    NSMutableArray *thisweekmodel = [[NSMutableArray alloc] init];
//    for(int i = 0; i<thisweekcourse.count; i++)
//    {
//        CourseModel *tempmodel = [[CourseModel alloc] initWithDict:thisweekcourse[i]];
//        [thisweekmodel addObject:tempmodel];
//    }
//    [self handleData:thisweekmodel];
//}

- (void)handleData:(NSArray *)courses
{
    if (courses.count > 0) {
        //处理周课表
        for (int i = 0; i<courses.count; i++) {
            BusinessModel *busModel = courses[i];
            [self addBussinessBtn:busModel];
        }
    }
}

//添加单个事务格子
- (void)addBussinessBtn:(BusinessModel *)busModel{
    int rowNum = [busModel.time substringToIndex:1].intValue;//开始时第几节
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    NSDate *curDate = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@",busModel.date]];
    int colNum = [curDate dayOfWeek];//周几，1表示周日，2表示周一
    if (colNum == 1) {
        colNum = 6;
    }else{
        colNum = colNum - 2;
    }
//    int colNum = busModel.weekday.intValue;//周几
    NSInteger lessonsNum = busModel.time.length / 2;//持续多少节
    
    CourseButton *courseBtn = [[CourseButton alloc]init];   //课程格子btn
    courseBtn.businessModel = busModel;
    courseBtn.event.text = busModel.desc;
    
    if (currentDayIndex == colNum) {
        courseBtn.event.font = [UIFont systemFontOfSize:13];
        courseBtn.place.font = [UIFont systemFontOfSize:13];
        
        if (busModel.overlap.intValue == 0) {
            UIImage *curUnderlap = [UIImage imageNamed:@"当前未重叠"];
            curUnderlap = [curUnderlap resizableImageWithCapInsets:UIEdgeInsetsMake(2, 2, 2, 2) resizingMode:UIImageResizingModeStretch];
            [courseBtn setBackgroundImage:curUnderlap forState:UIControlStateNormal];
        }else{
            courseBtn.isOverlap = YES;
            UIImage *curUnderlap = [UIImage imageNamed:@"currentcourse"];
            curUnderlap = [curUnderlap resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) resizingMode:UIImageResizingModeStretch];
            [courseBtn setBackgroundImage:curUnderlap forState:UIControlStateNormal];
        }
    }else{
        if (busModel.overlap.intValue == 0) {
            UIImage *underlap = [UIImage imageNamed:@"未重叠"];
            underlap = [underlap resizableImageWithCapInsets:UIEdgeInsetsMake(2, 2, 2, 2) resizingMode:UIImageResizingModeStretch];
            [courseBtn setBackgroundImage:underlap forState:UIControlStateNormal];
        }else{
            courseBtn.isOverlap = YES;
            UIImage *curUnderlap = [UIImage imageNamed:@"course"];
            curUnderlap = [curUnderlap resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) resizingMode:UIImageResizingModeStretch];
            [courseBtn setBackgroundImage:curUnderlap forState:UIControlStateNormal];
        }
    }
    UIView *btnSuperView = self.classSubViewArray[colNum];  //课程格子btn的父view
    [courseBtn addTarget:self action:@selector(courseClick:) forControlEvents:UIControlEventTouchUpInside];
    [btnSuperView addSubview:courseBtn];
    [courseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(btnSuperView.mas_left);
        make.width.equalTo(btnSuperView.mas_width);
        make.height.mas_equalTo(timeViewCellHeight * lessonsNum);
        make.top.mas_equalTo(rowNum * timeViewCellHeight);
    }];
}

- (void)courseClick:(id)sender{
    CourseButton *courseBtn = (CourseButton *)sender;
    if (courseBtn.isOverlap) {
        //生成遮罩层
        UIView *coverLayer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
        coverLayer.backgroundColor = [UIColor colorWithRed:88/255.0 green:88/255.0  blue:88/255.0  alpha:0.5];
        _coverLayer = coverLayer;
        UIWindow *theWindow = [[UIApplication  sharedApplication] delegate].window;//全屏遮罩要加到window上
        [theWindow addSubview:_coverLayer];
    }else if (courseBtn.courseModel == nil){//如果只有事务
        BusinessViewController *businessManage = [[BusinessViewController alloc]initWithfirstDateOfTerm:self.firstDateOfTerm businessModel:courseBtn.businessModel];
        businessManage.hidesBottomBarWhenPushed = YES;//从下级vc开始，tabbar都隐藏掉
        [self.navigationController pushViewController:businessManage animated:YES];
    }else if (courseBtn.businessModel == nil){
//        [self pushAddViewController];
    }
}

//数据解析后，展示在UI上
//- (void)handleData:(NSArray *)courses
//{
//    for (UIView *view in self.classView.subviews) {
//        if ([view isKindOfClass:[CourseButton class]]) {
//            [view removeFromSuperview];     //清掉所有课程格子btn
//        }
//    }
//    
//    if (courses.count > 0) {
//        //处理周课表
//        for (int i = 0; i<courses.count; i++) {
//            CourseModel *courseModel = courses[i];
//            [self addCourseBtn:courseModel];
//        }
//    }
//}
//
////添加单个课程格子
//- (void)addCourseBtn:(CourseModel *)courseModel{
//    int rowNum = courseModel.courseStart.intValue;
//    int colNum = courseModel.weekday.intValue - 1;
//    int lessonsNum = courseModel.numberOfCourse.intValue;
//    
//    CourseButton *courseBtn = [[CourseButton alloc]init];   //课程格子btn
//    courseBtn.courseModel = courseModel;                    //内容
//    if (currentDayIndex == colNum) {
//        courseBtn.event.font = [UIFont systemFontOfSize:13];
//        courseBtn.place.font = [UIFont systemFontOfSize:13];
//        
//        UIImage *curUnderlap = [UIImage imageNamed:@"当前未重叠"];
//        curUnderlap = [curUnderlap resizableImageWithCapInsets:UIEdgeInsetsMake(2, 2, 2, 2) resizingMode:UIImageResizingModeStretch];
//        [courseBtn setBackgroundImage:curUnderlap forState:UIControlStateNormal];
//    }else{
//        UIImage *underlap = [UIImage imageNamed:@"未重叠"];
//        underlap = [underlap resizableImageWithCapInsets:UIEdgeInsetsMake(2, 2, 2, 2) resizingMode:UIImageResizingModeStretch];
//        [courseBtn setBackgroundImage:underlap forState:UIControlStateNormal];
//    }
//    UIView *btnSuperView = self.classSubViewArray[colNum];  //课程格子btn的父view
//    //            [courseButton addTarget:self action:@selector(courseClick:) forControlEvents:UIControlEventTouchUpInside];
//    [btnSuperView addSubview:courseBtn];
//    [courseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(btnSuperView.mas_left);
//        make.width.equalTo(btnSuperView.mas_width);
//        make.height.mas_equalTo(timeViewCellHeight * lessonsNum);
//        //处理top的约束，主要是存在“早间”“午间”“晚间”的问题，需要跟pm落实
//        if (rowNum < 5) {
//            make.top.mas_equalTo(rowNum * timeViewCellHeight);
//        }else{
//            make.top.mas_equalTo((rowNum + 1) * timeViewCellHeight);
//        }
//    }];
//}


//点击课程格子	btn的方法，卉馨你添加courseBtn的时候帮忙addtarget一下
-(void)editCourse:(id)sender
{
    CourseButton *clickCourseBtn = (CourseButton *)sender;
    
    //NSLog(@"clickCourseBtn.courseModel:%@,%@,%@,%@,%@,%@",clickCourseBtn.courseModel.weeks,clickCourseBtn.courseModel.weekday,clickCourseBtn.courseModel.courseName,clickCourseBtn.courseModel.courseStart,clickCourseBtn.courseModel.numberOfCourse,clickCourseBtn.courseModel.place);
    //NSLog(@"clickCourseBtn:%@,%@",clickCourseBtn.event,clickCourseBtn.place);
    
    CourseViewController *editCourseController = [[CourseViewController alloc] init];
    
    [self.navigationController pushViewController:editCourseController animated:YES];
    
    [editCourseController setCourseCellModelFromCourseModel:clickCourseBtn.courseModel];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark BusinessCourseMangerDelegate
- (void)BusinessCourseManage:(BusinessCourseManage *)viewController week:(NSInteger )selectedWeek{
    [_navItemTitle setTitle:[NSString stringWithFormat:@"第%ld周",selectedWeek + 1] forState:UIControlStateNormal];
    NSDate *weekMonday = [DateUtils dateOfWeekMonday:selectedWeek firstDateOfTrem:self.firstDateOfTerm];
    [self daysViewSetting:weekMonday];
    [self loadLoacalData:selectedWeek];
    [self.view bringSubviewToFront:_weeksheet];
}

#pragma mark BusinessViewControllerDelegate
- (void)BusinessViewController:(BusinessViewController *)viewController week:(NSInteger)selectedWeek{
    [_navItemTitle setTitle:[NSString stringWithFormat:@"第%ld周",selectedWeek + 1] forState:UIControlStateNormal];
    NSDate *weekMonday = [DateUtils dateOfWeekMonday:selectedWeek firstDateOfTrem:self.firstDateOfTerm];
    [self daysViewSetting:weekMonday];
    [self loadLoacalData:selectedWeek];
    [self.view bringSubviewToFront:_weeksheet];
}

#pragma mark weekSheetDelegate
- (void)refreshNavItemTitle:(WeekSheet *)weeksheet content:(NSInteger)weekSheetRow{
    [_navItemTitle setTitle:[NSString stringWithFormat:@"第%ld周",weekSheetRow + 1] forState:UIControlStateNormal];
//    //加载新数据
//    [self loadDatafromSQL:[NSString stringWithFormat:@"%ld",weekSheetRow + 1]];
    self.weeksheet.hidden = YES;
    NSDate *weekMonday = [DateUtils dateOfWeekMonday:weekSheetRow firstDateOfTrem:self.firstDateOfTerm];
    [self daysViewSetting:weekMonday];
    [self loadLoacalData:weekSheetRow];
    [self.view bringSubviewToFront:_weeksheet];
    flag = false;
}

#pragma mark scrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView == _classView) {
        [self.daysView setContentOffset:CGPointMake(self.classView.contentOffset.x, 0) animated:NO];
        [self.timeView setContentOffset:CGPointMake(0, self.classView.contentOffset.y) animated:NO];

    }
}

#pragma mark subviewsInit
- (void)weekSheetInit{
    WeekSheet *weeksheet = [[WeekSheet alloc]init];
    _weeksheet = weeksheet;
    _weeksheet.delegate = self;
    [self.view addSubview:_weeksheet];
    
    __weak typeof(self) weakself = self;
    [_weeksheet mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(162);
        make.height.mas_equalTo(178);
        make.centerX.equalTo(weakself.view.mas_centerX);
        make.top.equalTo(weakself.view.mas_top);
    }];
    _weeksheet.hidden = YES;
}

//设置左上角的一个方块
- (void)topLeftViewSetting{
    UIView *topLeftView = [[UIView alloc]init];
    _topLeftView = topLeftView;
    self.topLeftView.backgroundColor = [Utils colorWithHexString:@"#f0f0f6"];
    [self.view addSubview:_topLeftView];
    __weak typeof(self) weakself = self;
    [_topLeftView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(weakself.view);
        make.width.mas_equalTo(topLeftViewWidth);
        make.height.mas_equalTo(topLeftViewHeight);
    }];
    
    UIImageView *calendar = [[UIImageView alloc]init];
    calendar.image = [UIImage imageNamed:@"calendar"];
    [_topLeftView addSubview:calendar];
    [calendar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_topLeftView.mas_right).offset(-10);
        make.centerY.equalTo(_topLeftView.mas_centerY);
    }];
}

//设置节数信息scrollview
-(void)timeScrollViewSetting{
    UIScrollView *timeScrollView = [[UIScrollView alloc]init];
    _timeView = timeScrollView;
    _timeView.backgroundColor = [UIColor whiteColor];
    _timeView.bounces = NO;
    _timeView.scrollEnabled = NO;
    _timeView.contentSize = CGSizeMake(0, timeViewCellHeight * 15);//横向不能滚动
    [self.view addSubview:_timeView];
    __weak typeof(self) weakself = self;
    [_timeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakself.view);
        make.top.equalTo(_topLeftView.mas_bottom);
        make.width.equalTo(_topLeftView.mas_width);
        make.height.mas_equalTo(kScreenHeight - 64 - 49 - topLeftViewHeight);
    }];
    
    NSArray *timeData = @[@[@"早间"],@[@"8:00",@"1"],@[@"8:55",@"2"],@[@"10:00",@"3"],@[@"10:55",@"4"],@[@"午间"],@[@"14:30",@"5"],@[@"15:25",@"6"],@[@"16:20",@"7"],@[@"17:15",@"8"],@[@"19:00",@"9"],@[@"19:55",@"10"],@[@"20:50",@"11"],@[@"21:45",@"12"],@[@"晚间"]];
    NSInteger index = 0;
    for (NSArray *dataArray in timeData) {
        
        UIView *bottomline = [[UIView alloc]init];
        [_timeView addSubview:bottomline];
        bottomline.backgroundColor = [Utils colorWithHexString:@"#d9d9d9"];
        [bottomline mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(weakself.view);
            make.width.equalTo(_timeView.mas_width);
            make.top.mas_equalTo(timeViewCellHeight*(index+1));
            make.height.mas_equalTo(1);
        }];
        
        
        if (dataArray.count == 1) {
            UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(0, index * timeViewCellHeight, topLeftViewWidth, timeViewCellHeight)];
            lab.text = [dataArray firstObject];
            lab.font = [UIFont systemFontOfSize:10];
            lab.textAlignment = NSTextAlignmentCenter;
            lab.textColor = [Utils colorWithHexString:@"#4c4c4c"];
            lab.opaque = NO;
//            lab.backgroundColor = [UIColor whiteColor];
            [_timeView addSubview:lab];
        }
        else{
            TimeViewCell *timeCell = [[TimeViewCell alloc]initWithFrame:CGRectMake(0, index * timeViewCellHeight, topLeftViewWidth, timeViewCellHeight)];
            timeCell.time.text = [dataArray firstObject];
            timeCell.number.text = [dataArray lastObject];
            timeCell.opaque = NO;
            [_timeView addSubview:timeCell];
        }
        index ++;
    }
}

//设置日期信息scrollview
-(void)daysViewSetting:(NSDate *)date{
    [_daysView removeFromSuperview];
    
    UIScrollView *dayScrollView = [[UIScrollView alloc] init];
    _daysView = dayScrollView;
    _daysView.backgroundColor = [Utils colorWithHexString:@"#f0f0f6"];
    _daysView.bounces = NO;
    _daysView.scrollEnabled = NO;
    _daysView.delegate = self;
    _daysView.contentSize = CGSizeMake(8 * dayViewCellWidth, 0);//7+1放大列
    [self.view addSubview:_daysView];
    __weak typeof(self) weakself = self;
    [_daysView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_topLeftView.mas_right);
        make.top.equalTo(weakself.view);
        make.width.mas_equalTo(kScreenWidth - topLeftViewWidth);
        make.height.mas_equalTo(topLeftViewHeight);
    }];
    //添加数据
    NSArray *data = [DateUtils getDatesOfCurrence:date];
    NSMutableArray * dateArray = [NSMutableArray arrayWithCapacity:7];
    for (int i = 0; i < 7; i ++) {
        [dateArray addObject:[NSString stringWithFormat:@"%@.%@",data[i][1],data[i][2]]];
    }
    NSArray *weekArray = @[@"周一",@"周二",@"周三",@"周四",@"周五",@"周六",@"周日"];
    NSMutableArray *viewArray = [NSMutableArray arrayWithCapacity:weekArray.count];//存放日期子view的数组
    //子view内容设置
    for (int i = 0; i < weekArray.count ; i ++) {
        DayViewCell *dayCell = [[DayViewCell alloc]init];
        dayCell.weekday.text = weekArray[i];
        dayCell.date.text = dateArray[i];
        dayCell.tag = 100 + i;//tag从100开始
        [viewArray addObject:dayCell];
        [_daysView addSubview:dayCell];
        
        [dayCell addTarget:self action:@selector(dayCellClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    //子view布局
    DayViewCell *lastView;
    for (int i = 0; i < viewArray.count; i ++) {
        DayViewCell *subview = viewArray[i];
        [subview mas_makeConstraints:^(MASConstraintMaker *make) {
            if (i == 0) {
                make.left.equalTo(_daysView.mas_left);
            }else{
                make.left.equalTo(lastView.mas_right);
            }
            make.top.equalTo(_daysView.mas_top);
            make.height.mas_equalTo(topLeftViewHeight);
            if(i == currentWeekDay){
                make.width.mas_equalTo(dayViewCellWidth * 2);
            }else{
                make.width.mas_equalTo(dayViewCellWidth);
            }
        }];
        
        lastView = subview;
        
        //竖分割线
        UIView *sepratorLine = [[UIView alloc]init];
        sepratorLine.backgroundColor = [Utils colorWithHexString:@"#d9d9d9"];
        [subview addSubview:sepratorLine];
        [sepratorLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(subview.mas_left);
            make.centerY.equalTo(subview.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(1, 30));//宽度1像素，所以应该是0.5，但0.5会不会太细？
        }];
    }
    
    lastDayIndex = currentWeekDay;
    //马上更新视图约束
    [self.view updateConstraintsIfNeeded];
    [self.view layoutIfNeeded];
    //底部滑动的indicator
    UIView *stripeView = [[UIView alloc]initWithFrame:CGRectMake(currentWeekDay * dayViewCellWidth, self.daysView.frame.size.height - 2, dayViewCellWidth *2, 2)];
    stripeView.backgroundColor = [Utils colorWithHexString:@"#00a7fa"];
    _stripeView = stripeView;
    [self.daysView addSubview:_stripeView];
    
//    int weekday = [date dayOfWeek];//这里先这样处理吧，暂时不清楚切换周数时界面要如何调整
    int weekday = [[NSDate date] dayOfWeek];
    if (weekday >= 6 || weekday <= 1) {//是星期五、六、日,显示周三到周日
        [self.daysView setContentOffset:CGPointMake(dayViewCellWidth * 2, 0) animated:NO];
        [self.classView setContentOffset:CGPointMake(dayViewCellWidth * 2, 0) animated:NO];
    }else{
        [self.daysView setContentOffset:CGPointMake(0, 0) animated:NO];
        [self.classView setContentOffset:CGPointMake(0, 0) animated:NO];
    }
}

//设置课程信息scrollview
-(void)classViewSetting{
    UIScrollView *classView = [[UIScrollView alloc]init];
    _classView = classView;
    _classView.backgroundColor = [UIColor whiteColor];
    _classView.bounces = NO;
    _classView.delegate = self;
    _classView.showsVerticalScrollIndicator = NO;
    _classView.showsHorizontalScrollIndicator = NO;
    _classView.contentSize = CGSizeMake(8 * dayViewCellWidth, timeViewCellHeight * 15);
    [self.view addSubview:_classView];
    __weak typeof(self) weakself = self;
    [_classView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_timeView.mas_right);
        make.top.equalTo(_topLeftView.mas_bottom);
        make.width.mas_equalTo(kScreenWidth - topLeftViewWidth);
        make.bottom.equalTo(weakself.view.mas_bottom);
    }];
    for(int i=0;i<15;i++){
        UIView *bottomline = [[UIView alloc]init];
        [_classView addSubview:bottomline];
        bottomline.backgroundColor = [Utils colorWithHexString:@"#d9d9d9"];
        [bottomline mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_classView.mas_left);
            make.width.mas_equalTo(_classView.contentSize.width);
            make.top.mas_equalTo(timeViewCellHeight*(i+1));
            make.height.mas_equalTo(1);
        }];
    }
    
    
    //classview上七个列向上的子view
    self.classSubViewArray = [NSMutableArray arrayWithCapacity:7];
    for (int i = 0 ; i < 7 ; i++) {
        UIView *classSubView = [[UIView alloc]init];
        classSubView.tag = 200 +i;
        classSubView.opaque = NO;
        [self.classSubViewArray addObject:classSubView];
        [_classView addSubview:classSubView];
    }
    UIView *lastView;
    for (int i = 0; i < self.classSubViewArray.count; i ++) {
        UIView *subview = self.classSubViewArray[i];
        //约束，左上高宽
        [subview mas_makeConstraints:^(MASConstraintMaker *make) {
            if (i == 0) {
                make.left.equalTo(_classView.mas_left);
            }else{
                make.left.equalTo(lastView.mas_right);
            }
            make.top.equalTo(_classView.mas_top);
            make.height.mas_equalTo(timeViewCellHeight * 15);
            if(i == currentWeekDay){
                make.width.mas_equalTo(dayViewCellWidth * 2);
            }else{
                make.width.mas_equalTo(dayViewCellWidth);
            }
        }];
        lastView = subview;
    }
}

//点击日期信息一栏宽度会改变
- (void)dayCellClicked:(id)sender{
    DayViewCell *currentDayBtn = (DayViewCell *)sender;
    currentDayIndex = currentDayBtn.tag - 100;
    //如果这一次和上一次点击的是同一个，不做任何操作
    if(currentDayIndex == lastDayIndex)
        return;
    //更新日期一栏的视图约束
    [currentDayBtn mas_updateConstraints:^(MASConstraintMaker *make) {//当前
        make.width.mas_equalTo(dayViewCellWidth * 2);
    }];
    DayViewCell *lastDayBtn = [self.view viewWithTag:lastDayIndex + 100];//上一个
    [lastDayBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(dayViewCellWidth);
    }];
    //更新课程信息板块的视图约束
    UIView *curClassColumn = self.classSubViewArray[currentDayIndex];//当前列
    [curClassColumn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(dayViewCellWidth * 2);
    }];
    for (UIView *colView in [curClassColumn subviews]) {//获得按钮
        for (UIView *view in [colView subviews]) {//获得按钮上的label
            if ([view isKindOfClass:[UILabel class]]) {
                UILabel *subview = (UILabel*) view;
                subview.font = [UIFont systemFontOfSize:13];
            }
        }
        if ([colView isKindOfClass:[UIButton class]]){
            CourseButton *subview = (CourseButton *) colView;
            if (subview.isOverlap) {
                UIImage *curUnderlap = [UIImage imageNamed:@"currentcourse"];
                curUnderlap = [curUnderlap resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) resizingMode:UIImageResizingModeStretch];
                [subview setBackgroundImage:curUnderlap forState:UIControlStateNormal];
            }else{
                UIImage *curUnderlap = [UIImage imageNamed:@"当前未重叠"];
                curUnderlap = [curUnderlap resizableImageWithCapInsets:UIEdgeInsetsMake(2, 2, 2, 2) resizingMode:UIImageResizingModeStretch];
                [subview setBackgroundImage:curUnderlap forState:UIControlStateNormal];
            }
        }
    }
    UIView *lastClassColumn = self.classSubViewArray[lastDayIndex];//上一列
    [lastClassColumn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(dayViewCellWidth);
    }];
    for (UIView *colView in [lastClassColumn subviews]) {
        for (UIView *view in [colView subviews]) {
            if ([view isKindOfClass:[UILabel class]]) {
                UILabel *subview = (UILabel*) view;
                subview.font = [UIFont systemFontOfSize:11];
            }
        }
        if ([colView isKindOfClass:[UIButton class]]){
            CourseButton *subview = (CourseButton *) colView;
            if (subview.isOverlap) {
                UIImage *curUnderlap = [UIImage imageNamed:@"course"];
                curUnderlap = [curUnderlap resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) resizingMode:UIImageResizingModeStretch];
                [subview setBackgroundImage:curUnderlap forState:UIControlStateNormal];
            }else{
                UIImage *underlap = [UIImage imageNamed:@"未重叠"];
                underlap = [underlap resizableImageWithCapInsets:UIEdgeInsetsMake(2, 2, 2, 2) resizingMode:UIImageResizingModeStretch];
                [subview setBackgroundImage:underlap forState:UIControlStateNormal];
            }
        }
    }
    
    lastDayIndex = currentDayIndex;
    
    //更新底部indicator位置
    [UIView animateWithDuration:0.2 animations:^{
        [self.stripeView setFrame:CGRectMake(currentDayIndex *dayViewCellWidth , self.daysView.frame.size.height - 2, dayViewCellWidth *2, 2)];
    }];
}

- (void)bottomLineSetting{
    //底部灰线
    __weak typeof(self) weakself = self;
    UIView *bottomLine = [[UIView alloc]init];
    bottomLine.backgroundColor = [Utils colorWithHexString:@"#d9d9d9"];
    [self.view addSubview:bottomLine];
    [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakself.view);
        make.bottom.equalTo(_topLeftView.mas_bottom);
        make.width.mas_equalTo(kScreenWidth);
        make.height.mas_equalTo(1);//或0.5
    }];
}

@end
