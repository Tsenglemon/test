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
        self.controllersArray = [controllersArray mutableCopy];
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
    if (_segCtrl.selectedSegmentIndex == 0) {//如果是事务界面。在这个类文件里面执行的，都是直接插入数据而不是修改原有数据的
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            DbManager *dbManger = [DbManager shareInstance];
//        NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS t_201601(id INTEGER PRIMARY KEY AUTOINCREMENT,description TEXT NOT NULL,comment TEXT,week INTEGER NOT NULL,weekday INTEGER NOT NULL,date TEXT,time TEXT,repeat INTEGER,overlap INTEGER);"];
        NSInteger dateDistance = [DateUtils dateDistanceFromDate:_bsVc.currentDate toDate:self.firstDateOfTerm];
        NSInteger week = dateDistance / 7;//存入数据库的week从0-n；
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
            
            //储存往后五年的时间
            NSMutableArray *dateString = [Utils dateStringArrayFromDate:_bsVc.currentDate yearDuration:5 repeatIndex:_bsVc.repeatIndex];
            //修改覆盖数据
            if (_bsVc.sectionArray.count > 0) {
//                找出将要被覆盖的事务
                NSMutableString *sqlTime = [NSMutableString string];
                for (int i = 0; i < _bsVc.sectionArray.count; i++) {
                    [sqlTime appendString:[NSString stringWithFormat:@"time LIKE '%%%d%%' or ",[_bsVc.sectionArray[i] intValue]]];
                }
                sqlTime = (NSMutableString*)[sqlTime substringToIndex:sqlTime.length - 3];
//                [dbManger beginTransaction];
                //往后五年的每一条数据都要拿出来剔除覆盖
                for (int i = 0; i < dateString.count; i ++) {
                    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM t_201601 WHERE date = '%@' and (%@);",dateString[i],sqlTime];
                    NSArray *dataQuery = [dbManger executeQuery:sql];
                    if (dataQuery.count > 0) {
                        for (int j = 0; j < dataQuery.count ; j++) {
                            //转换成模型
                            NSMutableDictionary *busDict = [NSMutableDictionary dictionaryWithDictionary:dataQuery[j]];
                            BusinessModel *model = [[BusinessModel alloc] initWithDict:busDict];
                            //每条事务数据，删去重复的时间段（被覆盖掉了）得到新的事务时间段
                            NSMutableArray *tempArray = [model.timeArray mutableCopy];
                            for (int k = 0 ; k < _bsVc.sectionArray.count; k++) {
                                if ([tempArray containsObject:_bsVc.sectionArray[k]]) {
                                    [tempArray removeObject:_bsVc.sectionArray[k]];
                                }
                            }
                            if (tempArray.count != 0) {//tempArray.count=0意味着现事务把原事务整个都覆盖掉了，所以原事务直接删
                                //对新的事务节数时间段进行连续性分割
                                NSMutableArray *sections = [Utils subSectionArraysFromArray:tempArray];
                                //然后插入更新后的事务
                                [dbManger beginTransaction];
                                for (int k = 0; k < sections.count; k++) {
                                    NSMutableArray *newSection = sections[k];
                                    NSMutableString *newTimeStr = [[NSMutableString alloc] initWithCapacity:5];
                                    for (int l = 0; l < newSection.count; l++) {
                                        [newTimeStr appendFormat:@"%@、",newSection[l]];
                                    }
                                    NSString *sql = [NSString stringWithFormat:@"INSERT INTO t_201601 (description,comment,week,weekday,date,time,repeat,overlap) VALUES ('%@','%@','','','%@','%@',6 ,0);",model.desc,model.comment,dateString[i],newTimeStr];//一律改成不重复
                                    [dbManger executeNonQuery:sql];
                                }
                                [dbManger commitTransaction];
                            }
                        }
                        //删除旧的事务数据
                        NSString *deleteSql = [NSString stringWithFormat:@"DELETE FROM t_201601 WHERE date = '%@' and (%@);",dateString[i],sqlTime];
                        [dbManger executeNonQuery:deleteSql];
                    }
                }
//                [dbManger commitTransaction];
            }
            
            //插入新事务
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
                [self.delegate BusinessCourseManage:self week:week];
                [self.navigationController popViewControllerAnimated:YES];
            });
        });
    }else{//如果是课程界面
        //数据存储
        NSInteger storeResult = [_courseVc DataStore] ;
        switch (storeResult) {
            case 0:
            {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"警告" message:@"课程时间冲突" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
                [alertController addAction:okAction];
                [self presentViewController:alertController animated:YES completion:nil];
                break;
            }
            case 1:
            {UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"警告" message:@"课程信息不完整" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
                [alertController addAction:okAction];
                [self presentViewController:alertController animated:YES completion:nil];
                break;
            }
            default:
            {
                //退出当前视图(数据成功存储才退出当前控制器)
                [self.navigationController popViewControllerAnimated:YES];
                break;
            }
                
        }
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
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"确认退出？" message:@"一旦退出，编辑将不会保存" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController popViewControllerAnimated:YES];
        }];
        [alertController addAction:okAction];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancelAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
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
