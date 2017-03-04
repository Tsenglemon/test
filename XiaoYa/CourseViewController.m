//
//  CourseViewController.m
//  XiaoYa
//
//  Created by commet on 16/11/27.
//  Copyright © 2016年 commet. All rights reserved.
//课程管理

#import "CourseViewController.h"
#import "CourseTimeCell.h"
#import "Utils.h"
#import "Masonry.h"
#import "weekselectview.h"
#import "dayselectview.h"
#import "timeselecteview.h"
#import "DbManager.h"
//#import "CourseTimeCellModel.h"


#define kScreenWidth [UIApplication sharedApplication].keyWindow.bounds.size.width
#define kScreenHeight [UIApplication sharedApplication].keyWindow.bounds.size.height
#define scaletoheight [UIApplication sharedApplication].keyWindow.bounds.size.height/1334.0
#define scaletowidth [UIApplication sharedApplication].keyWindow.bounds.size.width/750.0
#define fontscale [UIApplication sharedApplication].keyWindow.bounds.size.width/375.0

@interface CourseViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,weekselectViewDelegate,dayselsctViewDelegate,timeselectViewDelegate>
@property (nonatomic,weak) UIView *courseView;
@property (nonatomic,weak) UIView *businessView;//父view

@property (nonatomic,weak) UISegmentedControl *coursebusiness_seg;

//上课的子view
@property (nonatomic,weak) UIView *coursefield_view;
@property (nonatomic,weak) UITextField * courseNameField;
@property (nonatomic,weak) UITableView *course_tableview;
//@property (nonatomic,weak) CourseTimeCell *coursetime_view;
@property (nonatomic,weak) UIButton *addcoursetime_btn;

//变暗的背景
@property (nonatomic,weak) UIButton *cover;
//浮窗view
@property (nonatomic,weak) weekselectview *weekselect_view;
@property (nonatomic,weak) dayselectview *dayselect_view;
@property (nonatomic,weak) timeselecteview *timeselect_view;

//标签数组
@property (nonatomic,strong) NSArray *timelabel;
@property (nonatomic,strong) NSArray *weekdaylabel;

@property (nonatomic,strong) NSMutableArray *courseview_array;//装coursetime_view里数据的array,里面都是CourseTimeCellmodel
@property (nonatomic,strong) NSMutableArray *tempDeleteCourseArray;//装着要临时删除的课程(编辑模式时用)
@property (nonatomic,strong) NSArray *toDeleteCourseID; //有覆盖课程时删除课程用

@end

@implementation CourseViewController


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    UIView *courseview = [[UIView alloc] init];
    _courseView = courseview;
    
    _timelabel = @[@"早间",@"1节",@"2节",@"3节",@"4节",@"午间",@"5节",@"6节",@"7节",@"8节",@"9节",@"10节",@"11节",@"12节",@"晚间"];
    _weekdaylabel = @[@"0",@"星期一",@"星期二",@"星期三",@"星期四",@"星期五",@"星期六",@"星期日"];
    
    if(!_courseview_array)
    {
        NSMutableArray * courseview_array = [[NSMutableArray alloc] init];
        _courseview_array = courseview_array;
        CourseTimeCellModel *cellModel = [[CourseTimeCellModel alloc] initWithDefaultValue];
        [_courseview_array addObject:cellModel];
    }
    
    NSArray * toDeleteCourseID = [[NSArray alloc] init];
    _toDeleteCourseID = toDeleteCourseID;
    
    
    //点击标签载入时有用
    self.navigationItem.title = @"课程";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"confirm"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(confirm)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"cancel"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(cancel)];
    
    
    [self setcourseview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setcourseview{
    //_courseSrollView.contentSize = CGSizeMake(kScreenWidth, (1334.0 )*scaletoheight);
    _courseView.backgroundColor = [Utils colorWithHexString:@"#F0F0F6"];
    [self.view addSubview:_courseView];
    //_courseSrollView.bounces = NO;
    //__weak typeof(self) weakself=self;
    [_courseView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top);
        make.width.mas_equalTo(kScreenWidth);
        make.height.mas_equalTo(1334.0 * scaletoheight);
    }];
    
    [self addcoursefield_view];
    
    [self addcoursetableview];
    
    [self add_addcoursetime_btn];
}


//输入课程名称的view
-(void)addcoursefield_view{
    UIView *coursefield_view = [[UIView alloc] init];
    _coursefield_view = coursefield_view;
    _coursefield_view.backgroundColor = [Utils colorWithHexString:@"#FFFFFF"];
    _coursefield_view.backgroundColor = [UIColor whiteColor];
    _coursefield_view.layer.borderColor = [[Utils colorWithHexString:@"#D9D9D9"] CGColor];
    _coursefield_view.layer.borderWidth = 0.5;
    [_courseView addSubview:_coursefield_view];
    //_course_tableview.tableHeaderView = _coursefield_view;
    //__weak typeof(self) weakself = self;
    [_coursefield_view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(80.0 *scaletoheight );
        make.width.mas_equalTo(kScreenWidth);
    }];
    UITextField *namefield = [[UITextField alloc] init];
    _courseNameField = namefield;
    namefield.delegate = self;
    //namefield文本框的tag是0，classroom文本框的tag是1
    namefield.tag = 0;
    [namefield setBorderStyle:UITextBorderStyleRoundedRect];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[NSForegroundColorAttributeName] = [Utils colorWithHexString:@"#d9d9d9"];
    dict[NSFontAttributeName] = [UIFont systemFontOfSize:12.0];
    
    CourseTimeCellModel *cellModel = (CourseTimeCellModel*)_courseview_array[0];
    NSAttributedString *attribute = [[NSAttributedString alloc] initWithString:cellModel.courseName attributes:dict];
    [namefield setAttributedPlaceholder:attribute];
    namefield.font = [UIFont systemFontOfSize:12.0*fontscale];
    
   
    
    //namefield.placeholder = @"请输入你的课程";
    [_coursefield_view addSubview:namefield];
    [namefield mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_coursefield_view.mas_centerX);
        make.centerY.equalTo(_coursefield_view.mas_centerY);
        make.width.mas_equalTo(500 *scaletowidth);
        make.height.mas_equalTo(54 *scaletoheight);
    }];
    
    UIImageView *pen = [[UIImageView alloc] init];
    pen.image = [UIImage imageNamed:@"pencil"];
    [_coursefield_view addSubview:pen];
    [pen mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(namefield.mas_centerY);
        make.right.equalTo(namefield.mas_left).offset(-24*scaletowidth);
    }];
}



-(void)addcoursetableview
{
    
    //先随便设置一个frame
    UITableView *course_tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) style:UITableViewStyleGrouped];
    _course_tableview = course_tableview;
    _course_tableview.delegate = self;
    _course_tableview.dataSource = self;
    
    _course_tableview.backgroundColor = [UIColor clearColor];
    
    [_courseView addSubview:_course_tableview];
    [_course_tableview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(kScreenWidth);
        make.height.mas_equalTo(344.0*scaletoheight);
        make.centerX.equalTo(_courseView.mas_centerX);
        make.top.equalTo(self.coursefield_view.mas_bottom);
    }];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [_courseview_array count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 24.0*scaletoheight;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.000001;//不能直接设成0，所以设成很小来接近0
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ID = @"coursetimecell";
    CourseTimeCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        cell = [[CourseTimeCell alloc] initWithreuseIdentifier:ID];
        [cell.delete_btn addTarget:self action:@selector(deletecoursetime:) forControlEvents:UIControlEventTouchUpInside];
        [cell.weeks addTarget:self action:@selector(chooseweek:) forControlEvents:UIControlEventTouchUpInside];
        [cell.weekDay addTarget:self action:@selector(chooseday:) forControlEvents:UIControlEventTouchUpInside];
        [cell.courseTime addTarget:self action:@selector(choosetime:) forControlEvents:UIControlEventTouchUpInside];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.place.delegate = self;
        cell.place.tag = 1;
    }
    
    
    CourseTimeCellModel *loadModel = _courseview_array[indexPath.section];
    [cell.weeks setTitle:loadModel.weeks forState:UIControlStateNormal];
    [cell.weekDay setTitle:loadModel.weekDay forState:UIControlStateNormal];
    [cell.courseTime setTitle:loadModel.courseTime forState:UIControlStateNormal];
    cell.place.placeholder = loadModel.place;
    [cell.place setValue:[UIFont boldSystemFontOfSize:12] forKeyPath:@"_placeholderLabel.font"];
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 320.0*scaletoheight;
}



//底部“增加上课时间段”的按钮
-(void)add_addcoursetime_btn{
    UIButton *addcoursetime_btn = [[UIButton alloc] init];
    _addcoursetime_btn = addcoursetime_btn;
    _addcoursetime_btn.backgroundColor = [UIColor whiteColor];
    _addcoursetime_btn.layer.borderColor = [[Utils colorWithHexString:@"#D9D9D9"] CGColor];
    _addcoursetime_btn.layer.borderWidth = 0.5;
    
    [addcoursetime_btn setTitle:@"增加上课时间段" forState:UIControlStateNormal];
    [addcoursetime_btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [addcoursetime_btn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    addcoursetime_btn.titleLabel.font = [UIFont systemFontOfSize:14*fontscale];
    [addcoursetime_btn setImage:[UIImage imageNamed:@"加圆"] forState:UIControlStateNormal];
    [addcoursetime_btn addTarget:self action:@selector(addcoursetime) forControlEvents:UIControlEventTouchUpInside];
    [_courseView addSubview:addcoursetime_btn];
    [addcoursetime_btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(80.0 *scaletoheight );
        make.width.mas_equalTo(kScreenWidth);
        make.top.equalTo(_course_tableview.mas_bottom).offset(24.0*scaletoheight);
    }];
}
//---------------------------------------------按钮点击事件------------------------------------------
//点击低端增加上课时间段按钮后
-(void)addcoursetime{
//    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"1-16周",@"weeksnum",@"周一",@"weekday",@"1-2节",@"coursenum",@"",@"classroom",nil];
    CourseTimeCellModel *cellModel = [[CourseTimeCellModel alloc] initWithDefaultValue];
    if(_courseview_array.count>0)
    {
        CourseTimeCellModel *firstone = (CourseTimeCellModel *)_courseview_array[0];
        cellModel.courseName = firstone.courseName;
    }
    
    [_courseview_array addObject:cellModel];
    
    NSInteger addone = _courseview_array.count-1;
    NSIndexSet *index= [[NSIndexSet alloc] initWithIndex:addone];
    [_course_tableview insertSections:index withRowAnimation:UITableViewRowAnimationRight];
    [_course_tableview reloadData];
    
    CGFloat makesureY = _addcoursetime_btn.frame.origin.y;
    if(makesureY + (80.0+320.0)*scaletoheight < kScreenHeight){
        _course_tableview.frame = CGRectMake(_course_tableview.frame.origin.x, _course_tableview.frame.origin.y, _course_tableview.frame.size.width, _course_tableview.frame.size.height+320.0*scaletoheight);
        _addcoursetime_btn.frame =CGRectMake(_addcoursetime_btn.frame.origin.x, _addcoursetime_btn.frame.origin.y+320.0*scaletoheight, _addcoursetime_btn.frame.size.width, _addcoursetime_btn.frame.size.height);
    }
    
}

//点击上课时间coursetime_view里的删除按钮
-(void)deletecoursetime:(id)sender{
    
    CourseTimeCell *cell = (CourseTimeCell *)[sender superview];//获取被点击的button所在的cell
    NSIndexPath *indexPathselect = [_course_tableview indexPathForCell:cell];
    
    NSUInteger deleteone =(long)indexPathselect.section;
    NSLog(@"%lu",(unsigned long)deleteone);
    if(_courseview_array.count>=1)
    {
        [_courseview_array removeObjectAtIndex:deleteone];
        NSIndexSet *index= [[NSIndexSet alloc] initWithIndex:deleteone];
        [_course_tableview deleteSections:index withRowAnimation:UITableViewRowAnimationMiddle];
        [_course_tableview reloadData];
        
        CGFloat makesureY = _addcoursetime_btn.frame.origin.y;
        if(makesureY - (320.0)*scaletoheight >0 && _courseview_array.count<3){
            _course_tableview.frame = CGRectMake(_course_tableview.frame.origin.x, _course_tableview.frame.origin.y, _course_tableview.frame.size.width, _course_tableview.frame.size.height-320.0*scaletoheight);
            _addcoursetime_btn.frame =CGRectMake(_addcoursetime_btn.frame.origin.x, _addcoursetime_btn.frame.origin.y-320.0*scaletoheight, _addcoursetime_btn.frame.size.width, _addcoursetime_btn.frame.size.height);
        }
        
    }
}


-(void)addcover{
    UIButton *cover = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    _cover = cover;
    _cover.backgroundColor = [UIColor blackColor];
    _cover.alpha = 0;
    //背景慢慢变暗
    [self.view.window addSubview:_cover];
    [UIWindow animateWithDuration:0.5 animations:^{
        _cover.alpha = 0.3;
        //_cover.backgroundColor = [UIColor blackColor];
    }];
}


-(void)removeCover{
    [UIWindow animateWithDuration:0.5 animations:^{
        [_cover removeFromSuperview];
        
    }];
}


//---------------------------点击cell里的第一个按钮，周数选择按钮 系列事件--------------------------------
-(void)chooseweek:(id)sender
{
    CourseTimeCell *btnfromcell = (CourseTimeCell *)[sender superview];
    NSIndexPath *btnindex = [_course_tableview indexPathForCell:btnfromcell];
    
    CourseTimeCellModel *loadModel = _courseview_array[btnindex.section];
    
    [self addcover];
    
    CGFloat X = kScreenWidth/2-(530.0/2*scaletowidth);
    CGFloat Y = kScreenHeight/2-(601.0/2*scaletoheight);
    weekselectview *weekselect_view = [[weekselectview alloc] initWithFrame:CGRectMake(X, Y, 530.0*scaletowidth, 601.0*scaletoheight)andWeekSelect:loadModel.weeksArray];
    _weekselect_view = weekselect_view;

    //用whichSection来传递是哪一个section
    _weekselect_view.whichSection = [NSString stringWithFormat:@"%ld", (long)btnindex.section ];
    _weekselect_view.delegate = self;
    [self.view.window addSubview:_weekselect_view];
}

#pragma mark weekselectviewdeleaget
-(void)setWeekSelectResult:(NSMutableArray *)weekselected inSection:(NSInteger)section
{
    CourseTimeCellModel *loadModel = _courseview_array[section];
    loadModel.weeksArray = weekselected;
    //NSLog(@"controller:%@",showstring);
    [loadModel weeksArraytoWeeksString];
    [_course_tableview reloadData];
}



//-----------------------------点击cell里的第二个按钮，星期几选择系列事件----------------------------------
-(void)chooseday:(id)sender
{
    CourseTimeCell *btnfromcell = (CourseTimeCell *)[sender superview];
    NSIndexPath *btnindex = [_course_tableview indexPathForCell:btnfromcell];
    
    CourseTimeCellModel *loadModel = _courseview_array[btnindex.section];
    
    [self addcover];
    
    CGFloat X = kScreenWidth/2-(530.0/2*scaletowidth);
    CGFloat Y = kScreenHeight/2-(635.0/2*scaletoheight);
    dayselectview *dayselect_view = [[dayselectview alloc] initWithFrame:CGRectMake(X, Y, 530.0*scaletowidth, 635.0*scaletoheight) andDayString:loadModel.weekDayNum];
    _dayselect_view = dayselect_view;
    
    //用whichSection来传递是哪一个section
    _dayselect_view.whichSection = [NSString stringWithFormat:@"%ld", (long)btnindex.section ];
    _dayselect_view.delegate = self;
    [self.view.window addSubview:_dayselect_view];
}

#pragma mark dayselectviewdelegate
-(void)setDayString:(NSString *)dayString inSection:(NSInteger)section
{
    CourseTimeCellModel *loadModel = _courseview_array[section];
    loadModel.weekDayNum = dayString;
    [loadModel weekDayNumtoWeekDay];
    [_course_tableview reloadData];
}



//-----------------------------点击cell里的第三个按钮，时间选择系列事件----------------------------------

-(void)choosetime:(id)sender
{
    CourseTimeCell *btnfromcell = (CourseTimeCell *)[sender superview];
    NSIndexPath *btnindex = [_course_tableview indexPathForCell:btnfromcell];
    
    CourseTimeCellModel *loadModel = _courseview_array[btnindex.section];
    
    [self addcover];
    
    CGFloat X = kScreenWidth/2-(650/2*scaletowidth);
    CGFloat Y = kScreenHeight/2-(700/2*scaletoheight);
    timeselecteview *timeselect_view = [[timeselecteview alloc] initWithFrame:CGRectMake(X, Y, 650*scaletowidth, 700*scaletoheight)andCellModel:loadModel];
    _timeselect_view = timeselect_view;
    
    //用whichSection来传递是哪一个section
    _timeselect_view.whichSection = [NSString stringWithFormat:@"%ld", (long)btnindex.section ];
    _timeselect_view.delegate = self;
    [self.view.window addSubview:_timeselect_view];
    
}

#pragma mark timeselectviewdelegate
-(void)setCourseTimeArray:(NSMutableArray *)courseTimeArray andtoDeleteID:(NSArray *)toDeleteID inSection:(NSInteger)section
{
    CourseTimeCellModel *loadModel = _courseview_array[section];
    loadModel.courseTimeArray = courseTimeArray;
    [loadModel courseTimeArraytoCourseTimeString];
    _toDeleteCourseID = toDeleteID;
    //NSLog(@"_toDeleteCourseID:%@",_toDeleteCourseID);
    [_course_tableview reloadData];

}



//---------------------------------textfield代理方法-------------------------------
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    //返回一个BOOL值，指明是否允许在按下回车键时结束编辑
    //如果允许要调用resignFirstResponder 方法，这回导致结束编辑，而键盘会被收起
    [textField resignFirstResponder];
    return YES;
}


-(void)textFieldDidEndEditing:(UITextField *)textField
{
    CourseTimeCell *fieldfrom = (CourseTimeCell *)[textField superview];
    NSIndexPath *index = [_course_tableview indexPathForCell:fieldfrom];
    CourseTimeCellModel *loadModel = _courseview_array[index.section];
    
    if(textField.tag == 0){
    //课程名称
        for(int i = 0 ; i<_courseview_array.count ;i ++)
        {
            CourseTimeCellModel *courseCellModel = (CourseTimeCellModel *)_courseview_array[i];
            courseCellModel.courseName = textField.text;
        }

        loadModel.courseName = textField.text;
    }
    else{
    //上课教室
        CourseTimeCell *fieldfrom = (CourseTimeCell *)[textField superview];
        NSIndexPath *index = [_course_tableview indexPathForCell:fieldfrom];
        CourseTimeCellModel *loadModel = _courseview_array[index.section];
        
        loadModel.place = textField.text;
    }
}

//---------------------------------保存当前页数据的方法-------------------------------
//-(BOOL)DataStore
//{
//    __block BOOL success = NO;
//    success = YES;//标记数据是否成功写入数据库
//    
//    NSMutableArray *model_array = [[NSMutableArray alloc] init];
//    //dictionary: tomodel 在当前页的数据完整时会返回yes
//    if([self Dictionary:_courseview_array toModel:model_array]){
//        //数据完整，检查是否与原有的课程时间冲突
//        NSArray *conflictid = [self checkifconflict:model_array];
//        //NSLog(@"conflictid:%@",conflictid);
//        if(conflictid.count>0)
//        {//有冲突
//            UIAlertController *alertview = [UIAlertController alertControllerWithTitle:@"时间冲突" message:@"是否覆盖原有课程" preferredStyle:UIAlertControllerStyleAlert];
//            [self presentViewController:alertview animated:YES completion:nil];
//            // __weak typeof (alertview) weekAlert=alertview;
//            UIAlertAction *cancelaction = [UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//                success = NO;//没有成功保存数据
//            }];
//            
//            UIAlertAction *okaction = [UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                //删除冲突的课程
//                DbManager *dbManger = [DbManager shareInstance];
//                [dbManger openDb:@"eventcourse.sqlite"];
//                for(int i=0;i<conflictid.count;i++)
//                {
//                    NSString *sql = [NSString stringWithFormat:@"DELETE FROM course_table WHERE id is '%@'",conflictid[i]];
//                    NSLog(@"sql:%@",sql);
//                    [dbManger executeNonQuery:sql];
//                }
//                
//                for(int i=0;i<model_array.count;i++)
//                {
//                    CourseModel *gonnatosave = model_array[i];
//                    [self writeCourseModeltoSQL:gonnatosave];
//                }
//                success = YES;//成功保存数据
//            }];
//            [alertview addAction:cancelaction];
//            [alertview addAction:okaction];
//            
//            
//        }
//        else{
//        //数据完整且无冲突
//            for(int i=0;i<model_array.count;i++)
//            {
//                CourseModel *gonnatosave = model_array[i];
//                [self writeCourseModeltoSQL:gonnatosave];
//            }
//            success = YES;//成功保存数据
//        }
//    }
//    else{
//        //数据不完整，提示完善输入
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"警告" message:@"请完善课程信息" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"好的", nil];
//        [alertView show];
//        success = NO;
//    }
//    NSLog(@"success:%d",success);
//    return success;
//}
-(NSInteger)DataStore
{
    //保存数据
    
    //先检查是否有冲突
    if([self checkIfConflict]) return 0;
    
    NSMutableArray *courseModelArray = [[NSMutableArray alloc] init];
    for(CourseTimeCellModel *cellModel in _courseview_array)
    {
        NSMutableArray *tempCourseModelArray = [[NSMutableArray alloc] init];
        if(![cellModel CourseCellModeltoCourseModelinArray:tempCourseModelArray])
        {
            //数据不完整
            return 1;
        }
        [courseModelArray addObjectsFromArray:[tempCourseModelArray copy]];
    }
    
    //NSLog(@"courseModelArray:%@",courseModelArray);
    
    for(int i = 0 ; i<courseModelArray.count ;i ++)
    {
        CourseModel *courseMl = (CourseModel *)courseModelArray[i];
        [self writetoSQLwithCourseModel:courseMl];
    }
    
    if(_toDeleteCourseID.count>0)
    {
        for(int i=0;i<_toDeleteCourseID.count;i++)
        {
            NSString * courseID = (NSString *)_toDeleteCourseID[i];
            [self deleteCourseModeltfromSQLwithID:courseID];
        }
    }
    //成功存储，返回
    return 2;
}


//把_courseview_array里的字典转成一个个模型放入新的数组,返回值YES表示数据完整
//-(BOOL)Dictionary:(NSMutableArray *)Dict toModel:(NSMutableArray *)Model
//{
//    //NSLog(@"%@",Dict);
//    
//    for(int i = 0;i<Dict.count;i++)
//    {
//        NSDictionary *dealdict = Dict[i];
//        //1.周数处理
//        NSString *originweek = [NSString stringWithString:[dealdict valueForKey:@"weeksnum"]];
//        NSString *weeks = [originweek substringWithRange:NSMakeRange(1, originweek.length-2)];
//        NSArray *weeksnum = [weeks componentsSeparatedByString:@","];
//        //NSLog(@"weeksnum:%@",weeksnum);
//        
//        //2.时段处理
//        //2.1获取时段array
//
//        NSString *time = [NSString stringWithString:[dealdict valueForKey:@"coursenum"]];
//        NSArray *temp = [time componentsSeparatedByString:@","];
//        NSMutableArray *coursenumtemp = [[NSMutableArray alloc] init];
//        for(int j = 0;j<temp.count;j++)
//        {
//            NSString *timenode = temp[j];
//            NSNumber *position = [NSNumber numberWithUnsignedInteger:[_timelabel indexOfObject:timenode]];
//            [coursenumtemp addObject:position];
//        }
//        //2.2连续性识别
//        //NSLog(@"coursenumtemp:%@",coursenumtemp);
//        NSArray *coursenum = [[self consecutivejude:coursenumtemp] copy];
//        
//        //3.课室，星期几
//        NSString *classroom = [dealdict valueForKey:@"classroom"];
//        NSString *tempweekday = [dealdict valueForKey:@"weekday"];
//        NSString *weekday = [NSString stringWithFormat:@"%ld",[_weekdaylabel indexOfObject:tempweekday]];
//        
//        
//        //检查处理后的数据是否完整，不完整则返回，完整则继续
//        if(weeksnum.count==0 || coursenum.count == 0 || classroom.length==0 || weekday.length == 0 || coursename.length == 0)
//            return NO;//数据不完整
//        
//        
//        for(int j = 0;j<coursenum.count;j++)
//        {
//            NSArray *course_startlast = coursenum[j];
//            for(int k=0;k<weeksnum.count;k++)
//            {
//                CourseModel *datamodel = [[CourseModel alloc] init];
//                datamodel.place = classroom;
//                datamodel.courseName = coursename;
//                datamodel.weekday = weekday;
//                datamodel.weeks = weeksnum[k];
//                NSNumber *start = course_startlast[0];
//                NSNumber *last = course_startlast[1];
//                datamodel.courseStart = start.description;
//                datamodel.numberOfCourse = last.description;
//                NSLog(@"model:%@,%@,%@,%@,%@,%@",datamodel.place,datamodel.courseName,datamodel.weekday,datamodel.weeks,datamodel.courseStart,datamodel.numberOfCourse);
//                [Model addObject:datamodel];
//            }
//        }
//        
//    }
//    return YES;
//}

//-(NSArray *)checkifconflict:(NSArray *)Model
//{
//    //对每一个课程模型进行遍历，检查已有的课程，查看是否有冲突，有冲突则询问是否覆盖
//    DbManager *dbManger = [DbManager shareInstance];
//    [dbManger openDb:@"eventcourse.sqlite"];
//    
//    NSMutableArray *conflictid = [[NSMutableArray alloc] init];//用来装冲突的课程id，删除课程时用
//    for(int l = 0;l<Model.count;l++)
//    {
//        CourseModel *datamodel = Model[l];
//        NSString *sql = [NSString stringWithFormat:@"SELECT id,courseStart,numberOfCourse FROM course_table WHERE weeks is '%@' and weekDay is '%@'",datamodel.weeks,datamodel.weekday];
//        
//        NSArray *datafromsql = [[NSArray alloc] init];
//        datafromsql = [dbManger executeQuery:sql];
//        
//        if(datafromsql.count == 0) continue;//没有数据则说明这一天肯定不会有重复了
//        
//        //idsign用作标记时间段的课程id,若该时间段没课则标记0，有课则标记课程的id
//        NSMutableArray *idsign = [NSMutableArray arrayWithCapacity:_timelabel.count];
//        for (int m=0; m<_timelabel.count; m++) {
//            [idsign addObject:@"0"];
//        }
//        
//        for(int m=0;m<datafromsql.count;m++){
//            NSDictionary *course = datafromsql[m];
//            NSString *courseid = [course valueForKey:@"id"];
//            int coursestart = [[course valueForKey:@"courseStart"] intValue];
//            int numberofcourse = [[course valueForKey:@"numberOfCourse"] intValue];
//            
//            for(int n=coursestart;n<(coursestart+numberofcourse);n++)
//            {
//                idsign[n] = courseid;
//            }
//        }
//        //NSLog(@"idsign:%@",idsign);
//        
//        for(int m = datamodel.courseStart.intValue;m<(datamodel.courseStart.intValue + datamodel.numberOfCourse.intValue);m++){
//            if(![idsign[m] isEqualToString:@"0"]){
//                //有冲突
//                if(![conflictid containsObject:idsign[m]]) //冲突的课程的id还没加进去
//                    [conflictid addObject:idsign[m]];
//            }
//            
//        }
//    }
//    NSLog(@"conflictid0:%@",conflictid);
//    return [conflictid copy];
//}

//检查_courseview_array里的课程是否有冲突（两两进行对比）
//返回YES是有冲突，NO是没冲突
-(BOOL)checkIfConflict
{
    if(_courseview_array.count == 1) return NO;
    for(int i = 0;i < _courseview_array.count -1;i++)
    {
        CourseTimeCellModel *firstCellModel = (CourseTimeCellModel *)_courseview_array[i];
        for(int j = i + 1;j < _courseview_array.count;j++)
        {
            CourseTimeCellModel *secondCellModel = (CourseTimeCellModel *)_courseview_array[j];
            if([firstCellModel checkIfConflictComparetoAnotherCellModel:secondCellModel])
                return YES;
        }
    }
    return NO;
}



//把一个模型写入数据库
-(void)writetoSQLwithCourseModel:(CourseModel *)model
{
    DbManager *dbManger = [DbManager shareInstance];
    [dbManger openDb:@"eventcourse.sqlite"];
    
    NSString *sql = [NSString stringWithFormat:@"insert into course_table (weeks,weekDay,courseStart,numberOfCourse,courseName,place) values (%@,'%@',%@,%@,'%@','%@')",model.weeks,model.weekday,model.courseStart,model.numberOfCourse,model.courseName,model.place];
    
    //NSLog(@"sql:%@",sql);
    [dbManger executeNonQuery:sql];
}


//从数据库删除id为ID的记录
-(void)deleteCourseModeltfromSQLwithID:(NSString *)courseID
{
    DbManager *dbManger = [DbManager shareInstance];
    [dbManger openDb:@"eventcourse.sqlite"];
    
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM course_table WHERE id IS '%@'",courseID];
    
    //NSLog(@"sql:%@",sql);
    [dbManger executeNonQuery:sql];
}



-(void)setCourseTimeCellModelFromCourseModel:(CourseModel *)courseMDL
{
    //NSLog(@"courseMDL:%@,%@,%@,%@,%@,%@",courseMDL.weeks,courseMDL.weekday,courseMDL.courseName,courseMDL.courseStart,courseMDL.numberOfCourse,courseMDL.place);
    
    DbManager *dbManger = [DbManager shareInstance];
    [dbManger openDb:@"eventcourse.sqlite"];
    NSString *sql = [NSString stringWithFormat:@"SELECT id,weeks,weekDay,courseStart,numberOfCourse,courseName,place FROM course_table WHERE courseName is '%@' and courseStart is '%@' and numberOfCourse is '%@' and weekDay is '%@'",courseMDL.courseName,courseMDL.courseStart,courseMDL.numberOfCourse,courseMDL.weekday];
    
    NSArray *dataFromSQL = [[NSArray alloc] init];
    dataFromSQL = [dbManger executeQuery:sql];
    
    //把临时删除的课程数据放起来。在取消编辑的时候再存回去
    if(!_tempDeleteCourseArray)
    {
        _tempDeleteCourseArray = [[NSMutableArray alloc] init];
    }
    [_tempDeleteCourseArray addObjectsFromArray:dataFromSQL];
    //NSLog(@"dataFromSQL:%@",dataFromSQL);
    
    //临时删除课程
    for(NSDictionary *tempdelteDict in _tempDeleteCourseArray)
    {
        NSString *tempDeleteCourseID = [tempdelteDict valueForKey:@"id"];
        [self deleteCourseModeltfromSQLwithID:tempDeleteCourseID];
    }
    
    
    CourseTimeCellModel *loadCellModel = [[CourseTimeCellModel alloc] init];
    loadCellModel.courseName = courseMDL.courseName;
    loadCellModel.place = courseMDL.place;
    loadCellModel.weekDayNum = courseMDL.weekday;
    [loadCellModel weekDayNumtoWeekDay];
    _courseNameField.text = loadCellModel.courseName;
    
    
    for(int i = 0;i<courseMDL.numberOfCourse.intValue;i++)
    {
        [loadCellModel.courseTimeArray addObject:[NSString stringWithFormat:@"%d",courseMDL.courseStart.intValue + i]];
    }
    [loadCellModel courseTimeArraytoCourseTimeString];
    
    
    for(NSDictionary *loaddict in dataFromSQL)
    {
        NSString *weeks = [loaddict valueForKey:@"weeks"];
        [loadCellModel.weeksArray addObject:weeks];
    }
    [loadCellModel weeksArraytoWeeksString];
    
    //NSLog(@"loadCellModel:%@,%@,%@,%@,%@",loadCellModel.weeks,loadCellModel.courseName,loadCellModel.place,loadCellModel.courseTime,loadCellModel.weekDay);
    if(!_courseview_array)
    {
        _courseview_array = [[NSMutableArray alloc] init];
    }
    [_courseview_array addObject:loadCellModel];
    
    //NSLog(@"_courseview_array:%@",_courseview_array);
    
    //[_course_tableview reloadData];
    
    
}


-(void)cancel
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"警告" message:@"是否放弃修改" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController popViewControllerAnimated:YES];
        
        //放弃修改需要将临时删除的课程再写回去
        for(NSDictionary *rewriteCourseDict in _tempDeleteCourseArray)
        {
            CourseModel *rewriteCourseModel = [[CourseModel alloc] initWithDict:rewriteCourseDict];
            [self writetoSQLwithCourseModel:rewriteCourseModel];
        }
    }];
    [alertController addAction:okAction];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)confirm
{
    NSInteger storeResult = [self DataStore] ;
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

@end
