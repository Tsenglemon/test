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
    self.navigationItem.rightBarButtonItem.enabled = NO;//在编辑框有输入时才允许点击
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"cancel"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(cancel)];
}

//课程和事务公用这两个按钮
- (void)confirm{
    if (_segCtrl.selectedSegmentIndex == 0) {//如果是事务界面
        DbManager *dbManger = [DbManager shareInstance];
//        NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS t_201601(id INTEGER PRIMARY KEY AUTOINCREMENT,description TEXT NOT NULL,comment TEXT,week INTEGER NOT NULL,weekday INTEGER NOT NULL,date TEXT,time TEXT,repeat INTEGER,overlap INTEGER);"];
        NSInteger dateDistance = [DateUtils dateDistanceFromDate:_bsVc.currentDate toDate:self.firstDateOfTerm];
        NSInteger week = dateDistance / 7;//存入数据库的week从0-n；
        if (week < 0 || week > 23) {
            week = -1;
        }
        
        int weekday = [_bsVc.currentDate dayOfWeek];
        if (weekday == 1) {//存入数据库的weekday从0-6，周一为0
            weekday = 6;
        }else {
            weekday = weekday - 2;
        }
        
        NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyyMMdd"];
        NSString *currentDateString = [dateFormatter stringFromDate:_bsVc.currentDate];
        
        NSInteger timeArrCount = [_bsVc.sections count];
        for (int i = 0; i <timeArrCount; i ++) {
            NSMutableArray *section = _bsVc.sections[i];
            NSInteger count = section.count;
            NSMutableString *timeStr = [[NSMutableString alloc] initWithCapacity:10];
            for (int j = 0; j < count; j++) {
                [timeStr appendFormat:@"%@、",section[j]];
            }
            NSString *sql = [NSString stringWithFormat:@"INSERT INTO t_201601 (description,comment,week,weekday,date,time,repeat,overlap) VALUES ('%@','%@',%ld,%d,'%@','%@',%ld ,0)",_bsVc.busDescription.text,_bsVc.commentInfo,week,weekday,currentDateString,timeStr,_bsVc.repeatIndex];//注意VALUES字符串赋值要有单引号
            [dbManger executeNonQuery:sql];
        }        
        [self.navigationController popViewControllerAnimated:YES];
    }else{//如果是课程界面
   
    }
}

- (void)cancel{
    if (_segCtrl.selectedSegmentIndex == 0) {//如果是事务界面
        if ([_bsVc.busDescription.text isEqualToString:@""]) {
            [self.navigationController popViewControllerAnimated:YES];//返回主界面
        }else{
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确认退出？" message:@"一旦退出，编辑将不会保存" preferredStyle:UIAlertControllerStyleAlert];
//            [self alertTitleAppearance:alert title:@"确认退出？" hexColor:@"#333333"];
//            [self alertMessageAppearance:alert message:@"一旦退出，编辑将不会保存" hexColor:@"#333333"];
            [alert alertTitleAppearance_title:@"确认退出？" hexColor:@"#333333"];
            [alert alertMessageAppearance_message:@"一旦退出，编辑将不会保存" hexColor:@"#333333"];
            
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            UIAlertAction *confirmlAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self.navigationController popViewControllerAnimated:YES];
            }];
            //            NSLog(@"********所有变量/值:\n%@", [self getAllIvar:cancelAction]);
            
            [alert addActionTarget:cancelAction hexColor:@"#00A7FA"];
            [alert addActionTarget:confirmlAction hexColor:@"#00A7FA"];
            // 会更改UIAlertController中所有字体的内容（此方法有个缺点，会修改所有字体的样式）
            UILabel *appearanceLabel = [UILabel appearanceWhenContainedIn:UIAlertController.class, nil];
            UIFont *font = [UIFont systemFontOfSize:13];
            [appearanceLabel setAppearanceFont:font];
            
            [self presentViewController:alert animated:YES completion:nil];
        }
    }else{//如果是课程界面
        
    }
}

////提示框按钮样式设置
//- (void)addActionTarget:(UIAlertController *)alertController action:(UIAlertAction*)action hexColor:(NSString *)color{
//    [action setValue:[Utils colorWithHexString:color] forKey:@"titleTextColor"];
//    [alertController addAction:action];
//}
//
////提示框title样式设置
//- (void)alertTitleAppearance:(UIAlertController *)alertController title:(NSString *)title hexColor:(NSString *)color{
//    NSInteger length = [title length];
//    NSMutableAttributedString *alertControllerStr = [[NSMutableAttributedString alloc] initWithString:title];
//    [alertControllerStr addAttribute:NSForegroundColorAttributeName value:[Utils colorWithHexString:color] range:NSMakeRange(0, length - 1)];
//    [alertController setValue:alertControllerStr forKey:@"attributedTitle"];
//}
////提示框Message样式设置
//- (void)alertMessageAppearance:(UIAlertController *)alertController message:(NSString *)message hexColor:(NSString *)color{
//    NSInteger length = [message length];
//    NSMutableAttributedString *alertControllerStr = [[NSMutableAttributedString alloc] initWithString:message];
//    [alertControllerStr addAttribute:NSForegroundColorAttributeName value:[Utils colorWithHexString:color] range:NSMakeRange(0, length - 1)];
//    [alertController setValue:alertControllerStr forKey:@"attributedMessage"];
//}


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
