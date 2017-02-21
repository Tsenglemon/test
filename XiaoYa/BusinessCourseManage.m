//
//  BusinessCourseManage.m
//  XiaoYa
//
//  Created by commet on 16/11/28.
//  Copyright © 2016年 commet. All rights reserved.
//

#import "BusinessCourseManage.h"
#import "BusinessViewController.h"
#import "CourseViewController.h"
#import "Utils.h"
#import "Masonry.h"
#import "UILabel+AlertActionFont.h"
#import <objc/runtime.h>
#import "DbManager.h"
#import "DateUtils.h"
#import "NSDate+Calendar.h"
#import "UIAlertController+Appearance.h"

#define kScreenWidth [UIApplication sharedApplication].keyWindow.bounds.size.width
@interface BusinessCourseManage ()<UIScrollViewDelegate>
@property (nonatomic ,weak)UISegmentedControl *segCtrl;
@property (nonatomic ,weak)UIScrollView *mainScrollView;

@property (nonatomic ,strong)NSArray *controllersArray;//子控制器数组
@property (nonatomic ,strong)NSDate *firstDateOfTerm;
@property (nonatomic ,strong)BusinessViewController *bsVc;
@property (nonatomic ,strong)CourseViewController *courseVc;

@end

@implementation BusinessCourseManage

- (instancetype)initWithControllersArray:(NSArray *)controllersArray firstDateOfTerm:(NSDate *)firstDateOfTerm{
    if(self = [super init]){
        self.controllersArray = controllersArray;
        self.firstDateOfTerm = firstDateOfTerm;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self initViews];
    [self setupChildViewControllers];
    _bsVc = self.controllersArray[0];
    _courseVc = self.controllersArray[1];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"confirm"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(confirm)];
    //self.navigationItem.rightBarButtonItem.enabled = NO;//在编辑框有输入时才允许点击
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"cancel"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(cancel)];
}

//课程和事务公用这两个按钮
- (void)confirm{
    if (_segCtrl.selectedSegmentIndex == 0) {//如果是事务界面
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            DbManager *dbManger = [DbManager shareInstance];
//        NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS t_201601(id INTEGER PRIMARY KEY AUTOINCREMENT,description TEXT NOT NULL,comment TEXT,week INTEGER NOT NULL,weekday INTEGER NOT NULL,date TEXT,time TEXT,repeat INTEGER,overlap INTEGER);"];
//        NSInteger dateDistance = [DateUtils dateDistanceFromDate:_bsVc.currentDate toDate:self.firstDateOfTerm];
//        NSInteger week = dateDistance / 7;//存入数据库的week从0-n；
//        if (week < 0 || week > 23) {
//            week = -1;
//        }
//        
//        int weekday = [_bsVc.currentDate dayOfWeek];
//        if (weekday == 1) {//存入数据库的weekday从0-6，周一为0
//            weekday = 6;
//        }else {
//            weekday = weekday - 2;
//        }
            
            NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyyMMdd"];
//            NSString *currentDateString = [dateFormatter stringFromDate:_bsVc.currentDate];
            NSCalendar * gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            NSDateComponents *components = [gregorian components:NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:_bsVc.currentDate];
            //储存往后五年的时间
            int timeDuration = 5;//五年
            NSMutableArray *dateString = [NSMutableArray arrayWithCapacity:5];
            switch (_bsVc.repeatIndex) {
                case 0://每天
                    [dateString addObject:[dateFormatter stringFromDate:_bsVc.currentDate]];
                    for (int i = 1; i < timeDuration * 365; i ++) {
                        components.day += 1;
                        NSDate *tempDate = [gregorian dateFromComponents:components];
                        [dateString addObject:[dateFormatter stringFromDate:tempDate]];
                    }
                    break;
                case 1://每两天
                    [dateString addObject:[dateFormatter stringFromDate:_bsVc.currentDate]];
                    for (int i = 1; i < timeDuration * 365 / 2; i ++) {
                        components.day += 2;
                        NSDate *tempDate = [gregorian dateFromComponents:components];
                        [dateString addObject:[dateFormatter stringFromDate:tempDate]];
                    }
                    break;
                case 2://每周
                    [dateString addObject:[dateFormatter stringFromDate:_bsVc.currentDate]];
                    for (int i = 1; i < timeDuration * 52; i ++) {
                        components.day += 7;
                        NSDate *tempDate = [gregorian dateFromComponents:components];
                        [dateString addObject:[dateFormatter stringFromDate:tempDate]];
                    }
                    break;
                case 3://每月
                    [dateString addObject:[dateFormatter stringFromDate:_bsVc.currentDate]];
                    for (int i = 1; i < timeDuration * 12; i ++) {
                        components.month += 1;
                        NSDate *tempDate = [gregorian dateFromComponents:components];
                        NSDateComponents *components1 = [gregorian components:NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:tempDate];
                        if(components1.day != components.day){
                            continue;
                        }else{
                            [dateString addObject:[dateFormatter stringFromDate:tempDate]];
                        }
                    }
                    break;
                case 4://每年
                    [dateString addObject:[dateFormatter stringFromDate:_bsVc.currentDate]];
                    if (components.month == 2 && components.day == 29) {//保存的这一天是闰日
                        components.year += 4;//判断四年后还是不是闰年
                        NSDate * tempDate = [gregorian dateFromComponents:components];//加一年后的日期,如果刚好是闰年，就会变成2016.2.29 -》2017.2.29=2017.3.1
                        NSDateComponents *components1 = [gregorian components:NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:tempDate];
                        if(components1.month == components.month){//如果四年后还是闰年
                            [dateString addObject:[dateFormatter stringFromDate:tempDate]];
                        }
                    }else{//2月29以外的任何日期
                        for (int i = 1; i < timeDuration; i ++) {
                            components.year += 1;
                            NSDate * tempDate = [gregorian dateFromComponents:components];
                            [dateString addObject:[dateFormatter stringFromDate:tempDate]];
                        }
                    }
                    break;
                case 5://工作日
                    [dateString addObject:[dateFormatter stringFromDate:_bsVc.currentDate]];
                    for (int i = 1; i < timeDuration * 365; i ++) {
                        components.day += 1;
                        NSDate *tempDate = [gregorian dateFromComponents:components];
                        int weekday = [tempDate dayOfWeek];//1表示周日，2表示周一
                        if (weekday > 1 && weekday < 7) {
                            [dateString addObject:[dateFormatter stringFromDate:tempDate]];
                        }
                    }
                    break;
                case 6://不重复
                    [dateString addObject:[dateFormatter stringFromDate:_bsVc.currentDate]];
                    break;
                default:
                    break;
            }
            
            [dbManger beginTransaction];
            NSInteger timeArrCount = [_bsVc.sections count];
            for (int i = 0; i <timeArrCount; i ++) {
                NSMutableArray *section = _bsVc.sections[i];
                NSMutableString *timeStr = [[NSMutableString alloc] initWithCapacity:10];
                for (int j = 0; j < section.count; j++) {
                    [timeStr appendFormat:@"%@、",section[j]];
                }
                for (int k = 0; k < dateString.count; k ++) {
                    NSString *sql = [NSString stringWithFormat:@"INSERT INTO t_201601 (description,comment,week,weekday,date,time,repeat,overlap) VALUES ('%@','%@','','','%@','%@',%ld ,0);",_bsVc.busDescription.text,_bsVc.commentInfo,dateString[k],timeStr,_bsVc.repeatIndex];//注意VALUES字符串赋值要有单引号
                    [dbManger executeNonQuery:sql];
                }
            }
            [dbManger commitTransaction];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
        });
    }else{//如果是课程界面
		NSLog(@"comfirm");
        //警告窗
        
        //数据存储
        if([_courseVc DataStore])
            //退出当前视图(数据成功存储才退出当前控制器)
            [self.navigationController popViewControllerAnimated:YES];
    }
}
- (void)cancel{
    if (_segCtrl.selectedSegmentIndex == 0) {//如果是事务界面
        if ([_bsVc.busDescription.text isEqualToString:@""]) {//如果描述没有输入就直接返回
            [self.navigationController popViewControllerAnimated:YES];//返回主界面
        }else{
            void (^otherBlock)(UIAlertAction *action) = ^(UIAlertAction *action){
                [self.navigationController popViewControllerAnimated:YES];
            };
            NSArray *otherBlocks = @[otherBlock];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确认退出？" message:@"一旦退出，编辑将不会保存" preferredStyle:UIAlertControllerStyleAlert cancelTitle:@"取消" cancelBlock:nil otherTitles:@[@"确定"] otherBlocks:otherBlocks];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }else{//如果是课程界面
        
    }
}

//kvc 获取所有key值
- (NSArray *)getAllIvar:(id)object
{
    NSMutableArray *array = [NSMutableArray array];
    
    unsigned int count;
    Ivar *ivars = class_copyIvarList([object class], &count);
    for (int i = 0; i < count; i++) {
        Ivar ivar = ivars[i];
        const char *keyChar = ivar_getName(ivar);
        NSString *keyStr = [NSString stringWithCString:keyChar encoding:NSUTF8StringEncoding];
        @try {
            id valueStr = [object valueForKey:keyStr];
            NSDictionary *dic = nil;
            if (valueStr) {
                dic = @{keyStr : valueStr};
            } else {
                dic = @{keyStr : @"值为nil"};
            }
            [array addObject:dic];
        }
        @catch (NSException *exception) {}
    }
    return [array copy];
}

//初始化视图
- (void)initViews{
    [self settingSegmentedControl];
    [self settingMainScrollView];
}

//初始化子控制器
- (void)setupChildViewControllers{
    for (UIViewController *vc in self.controllersArray) {
        [self addChildViewController:vc];
    }
}

//分段控件
- (void)settingSegmentedControl{
    UISegmentedControl *segCtrl = [[UISegmentedControl alloc]initWithItems:@[@"事务",@"课程"]];
    _segCtrl = segCtrl;
    _segCtrl.frame = CGRectMake(0, 0, 166, 30);
    _segCtrl.layer.masksToBounds = YES;
    _segCtrl.layer.cornerRadius = 0.1;
    _segCtrl.selectedSegmentIndex = 0;
    _segCtrl.tintColor = [Utils colorWithHexString:@"#00a7fa"];
    [_segCtrl setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:17], NSFontAttributeName, nil] forState:UIControlStateNormal];
    [_segCtrl setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:17], NSFontAttributeName, nil] forState:UIControlStateSelected];
    
    [_segCtrl addTarget:self action:@selector(change:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = _segCtrl;
}

//点击不同分段有不同的事件响应
- (void)change:(UISegmentedControl *)sender
{
    CGPoint offset = self.mainScrollView.contentOffset;
    offset.x = sender.selectedSegmentIndex * self.mainScrollView.frame.size.width;
    [self.mainScrollView setContentOffset:offset animated:YES];
}

- (void)settingMainScrollView {
    UIScrollView *mainScrollView = [[UIScrollView alloc]init];
    _mainScrollView =  mainScrollView;
    _mainScrollView.bounces = NO;
    _mainScrollView.showsHorizontalScrollIndicator = NO;
    _mainScrollView.showsVerticalScrollIndicator = NO;
    _mainScrollView.pagingEnabled = YES;
    _mainScrollView.contentSize = CGSizeMake(kScreenWidth * 2, 0);
    _mainScrollView.delegate = self;
    [self.view addSubview:_mainScrollView];
    
    __weak typeof(self)weakself = self;
    [_mainScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakself.view);
    }];
    
    [self.view updateConstraintsIfNeeded];
    [self.view layoutIfNeeded];
    
    //push进来默认选中第一个 添加第一个控制器的view
    UIViewController *pageOneVC = self.controllersArray[0];
    pageOneVC.view.frame = CGRectMake(0, 0, _mainScrollView.frame.size.width, _mainScrollView.frame.size.height);
    [_mainScrollView addSubview:pageOneVC.view];
}

#pragma mark UIScrollViewDelegate
/**
 *  滚动完毕就会调用,如果不是人为拖拽scrollView导致滚动完毕，才会调用这个方法.由setContentOffset:animated: 或者 scrollRectToVisible:animated: 方法触发
 */
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    int index = scrollView.contentOffset.x / _mainScrollView.frame.size.width;
    UIViewController *willShowChildVc = self.controllersArray[index];
    
    // 如果这个子控制器的view已经添加过了，就直接返回
    if (willShowChildVc.isViewLoaded) return;
    
    // 未添加过，添加子控制器的view
    willShowChildVc.view.frame = CGRectMake(scrollView.contentOffset.x, 0, _mainScrollView.frame.size.width, _mainScrollView.frame.size.height);
    [scrollView addSubview:willShowChildVc.view];
}

/**
 *  滚动完毕就会调用.如果是人为拖拽scrollView导致滚动完毕，才会调用这个方法
 */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSInteger pageNum = scrollView.contentOffset.x / _mainScrollView.frame.size.width;
    _segCtrl.selectedSegmentIndex = pageNum;//选中segment对应的某项
    // 添加子控制器的view
    [self scrollViewDidEndScrollingAnimation:scrollView];
}

@end
