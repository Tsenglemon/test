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
#import "CourseModel.h"
#import "UIAlertController+Appearance.h"

#define kScreenWidth [UIApplication sharedApplication].keyWindow.bounds.size.width
#define kScreenHeight [UIApplication sharedApplication].keyWindow.bounds.size.height
#define scaletoheight [UIApplication sharedApplication].keyWindow.bounds.size.height/1334.0
#define scaletowidth [UIApplication sharedApplication].keyWindow.bounds.size.width/750.0
#define fontscale [UIApplication sharedApplication].keyWindow.bounds.size.width/375.0

@interface CourseViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,weekselectViewDelegate,dayselsctViewDelegate,timeselectViewDelegate>
//上课的子view
@property (nonatomic,weak) UIView *coursefield_view;
@property (nonatomic,weak) UITextField * courseNameField;
@property (nonatomic,weak) UITableView *course_tableview;
@property (nonatomic,weak) UIButton *addcoursetime_btn;

//变暗的背景
@property (nonatomic,weak) UIButton *cover;
//浮窗view
@property (nonatomic,weak) weekselectview *weekselect_view;
@property (nonatomic,weak) dayselectview *dayselect_view;
@property (nonatomic,weak) timeselecteview *timeselect_view;

//@property (nonatomic,strong) NSMutableArray *courseview_array;//装coursetime_view里数据的array,里面都是Coursemodel
@property (nonatomic ,strong) NSMutableArray *originTimeIndexArray;//原始节数选择数组
@property (nonatomic ,strong) NSMutableArray *originWeekdayArray;//原始周几 选择数组
@property (nonatomic ,strong) NSString *originCourseName;
@end

@implementation CourseViewController
- (instancetype)initWithCourseModel:(NSMutableArray *)modelArray{
    if(self = [super init]){
        self.courseview_array = [modelArray mutableCopy];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.originCourseName = [NSString string];
    if (self.courseview_array != nil && self.courseview_array.count != 0) {
        CourseModel * model =  self.courseview_array[0];
        self.originCourseName = model.courseName;
    }else{
        _courseview_array = [NSMutableArray array];
        CourseModel *defaultModel = [CourseModel defaultModel];
        [self.courseview_array addObject:defaultModel];
    }
    self.originWeekdayArray = [NSMutableArray array];
    self.originTimeIndexArray = [NSMutableArray array];
    for (int i = 0; i < self.courseview_array.count; i++) {
        CourseModel * model =  self.courseview_array[i];
        [self.originTimeIndexArray addObject:model.timeArray];
        [self.originWeekdayArray addObject:model.weekday];
    }
    
    //点击标签载入时有用
    self.navigationItem.title = @"课程";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"confirm"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(confirm)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"cancel"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(cancel)];
    
    [self courseViewSetting];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)courseViewSetting{
    self.view.backgroundColor = [Utils colorWithHexString:@"#F0F0F6"];
    [self addcoursefield_view];
    [self addcoursetableview];
    [self add_addcoursetime_btn];
}

//输入课程名称的view
-(void)addcoursefield_view{
    UIView *coursefield_view = [[UIView alloc] init];
    _coursefield_view = coursefield_view;
    _coursefield_view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_coursefield_view];
    __weak typeof(self) weakself = self;
    [_coursefield_view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(80.0 *scaletoheight );
        make.width.mas_equalTo(kScreenWidth);
        make.top.equalTo(weakself.view);
        make.centerX.equalTo(weakself.view.mas_centerX);
    }];
    
    //文本框
    UITextField *namefield = [[UITextField alloc] init];
    //边框
    _courseNameField = namefield;
    _courseNameField.layer.borderColor = [[Utils colorWithHexString:@"#d9d9d9"]CGColor];
    _courseNameField.layer.borderWidth = 0.5f;
    _courseNameField.layer.cornerRadius = 2.0f;
    //placeholder颜色、大小
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[NSForegroundColorAttributeName] = [Utils colorWithHexString:@"#d9d9d9"];
    dict[NSFontAttributeName] = [UIFont systemFontOfSize:12.0];
    NSAttributedString *attribute = [[NSAttributedString alloc] initWithString:@"请输入课程名称" attributes:dict];
    [_courseNameField setAttributedPlaceholder:attribute];
    //文本颜色、大小
    _courseNameField.textColor = [Utils colorWithHexString:@"#333333"];
    _courseNameField.font = [UIFont systemFontOfSize:12.0];
    //文本框内的文字距离左边框的距离
    _courseNameField.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 8, 1)];
    _courseNameField.leftViewMode = UITextFieldViewModeAlways;
//    CourseModel *model = self.courseview_array[0];
    _courseNameField.text = self.originCourseName;
    [_coursefield_view addSubview:_courseNameField];
    [_courseNameField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_coursefield_view.mas_centerX);
        make.centerY.equalTo(_coursefield_view.mas_centerY);
        make.width.mas_equalTo(500 * scaletowidth);
        make.height.mas_equalTo(54 * scaletoheight);
    }];
    _courseNameField.delegate = self;//修改namefield值要修改courseview array中的每个model的courseNAme
    //namefield文本框的tag是0，classroom文本框的tag是1
    _courseNameField.tag = 0;
    
    UIImageView *pen = [[UIImageView alloc] init];
    pen.image = [UIImage imageNamed:@"pencil"];
    [_coursefield_view addSubview:pen];
    [pen mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_courseNameField.mas_centerY);
        make.right.equalTo(_courseNameField.mas_left).offset(-24*scaletowidth);
    }];
    
    //顶部底部两条灰线
    UIView *line1 = [[UIView alloc]init];
    line1.backgroundColor = [Utils colorWithHexString:@"d9d9d9"];
    [_coursefield_view addSubview:line1];
    [line1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.left.equalTo(weakself.view);
        make.height.mas_equalTo(0.5);
        make.top.equalTo(_coursefield_view.mas_top);
    }];
    UIView *line2 = [[UIView alloc]init];
    line2.backgroundColor = [Utils colorWithHexString:@"d9d9d9"];
    [_coursefield_view addSubview:line2];
    [line2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.left.equalTo(weakself.view);
        make.height.mas_equalTo(0.5);
        make.bottom.equalTo(_coursefield_view.mas_bottom);
    }];
}

-(void)addcoursetableview
{
    UITableView *course_tableview;
    if (64 + (320.0+24)*scaletoheight*_courseview_array.count+(80 + 24 + 80)*scaletoheight<kScreenHeight) {
        course_tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 80.0 *scaletoheight, kScreenWidth, 344.0*scaletoheight*_courseview_array.count) style:UITableViewStyleGrouped];
    }else{//最多不是两个section就是三个，plus机型可以显示三个
        if (64 + (320.0+24)*scaletoheight*3+(80 + 24 + 80)*scaletoheight>kScreenHeight) {
            course_tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 80.0 *scaletoheight, kScreenWidth, 344.0*scaletoheight*2) style:UITableViewStyleGrouped];
        }else{
            course_tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 80.0 *scaletoheight, kScreenWidth, 344.0*scaletoheight*3) style:UITableViewStyleGrouped];
        }
    }
    _course_tableview = course_tableview;
    _course_tableview.delegate = self;
    _course_tableview.dataSource = self;    
    _course_tableview.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_course_tableview];
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
    CourseTimeCell *cell = [CourseTimeCell CourseTimeCellWithTableView:tableView];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    CourseModel *loadModel = _courseview_array[indexPath.section];
    cell.model = loadModel;
    [cell.delete_btn addTarget:self action:@selector(deletecoursetime:) forControlEvents:UIControlEventTouchUpInside];
    [cell.weeks addTarget:self action:@selector(chooseweek:) forControlEvents:UIControlEventTouchUpInside];
    [cell.weekDay addTarget:self action:@selector(chooseday:) forControlEvents:UIControlEventTouchUpInside];
    [cell.courseTime addTarget:self action:@selector(choosetime:) forControlEvents:UIControlEventTouchUpInside];
    cell.place.delegate = self;
    cell.place.tag = 1;
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
    [_addcoursetime_btn setTitle:@"增加上课时间段" forState:UIControlStateNormal];
    [_addcoursetime_btn setTitleColor:[Utils colorWithHexString:@"#333333"] forState:UIControlStateNormal];
    _addcoursetime_btn.titleLabel.font = [UIFont systemFontOfSize:14*fontscale];
    [_addcoursetime_btn setImage:[UIImage imageNamed:@"加圆"] forState:UIControlStateNormal];
    [_addcoursetime_btn addTarget:self action:@selector(addcoursetime) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addcoursetime_btn];
    __weak typeof(self) weakself = self;
    [_addcoursetime_btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kScreenWidth,80.0 *scaletoheight));
        make.top.equalTo(_course_tableview.mas_bottom).offset(24.0*scaletoheight);
        make.centerX.equalTo(weakself.view.mas_centerX);
    }];
    
    //顶部底部两条灰线
    UIView *line1 = [[UIView alloc]init];
    line1.backgroundColor = [Utils colorWithHexString:@"d9d9d9"];
    [_addcoursetime_btn addSubview:line1];
    [line1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.left.equalTo(weakself.view);
        make.height.mas_equalTo(0.5);
        make.top.equalTo(_addcoursetime_btn.mas_top);
    }];
    UIView *line2 = [[UIView alloc]init];
    line2.backgroundColor = [Utils colorWithHexString:@"d9d9d9"];
    [_addcoursetime_btn addSubview:line2];
    [line2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.left.equalTo(weakself.view);
        make.height.mas_equalTo(0.5);
        make.bottom.equalTo(_addcoursetime_btn.mas_bottom);
    }];
}

//---------------------------------------------按钮点击事件------------------------------------------
//点击低端增加上课时间段按钮后
-(void)addcoursetime{
    CourseModel *defaultModel = [CourseModel defaultModel];//不太确定添加的默认显示是什么，是和上一个格子一样吗？先用默认model
    defaultModel.courseName = self.courseNameField.text;
    [_courseview_array addObject:defaultModel];
    [self.originTimeIndexArray addObject:defaultModel.timeArray];
    [self.originWeekdayArray addObject:defaultModel.weekday];
    
    NSInteger addone = _courseview_array.count-1;
    NSIndexSet *index= [[NSIndexSet alloc] initWithIndex:addone];
    [_course_tableview insertSections:index withRowAnimation:UITableViewRowAnimationNone];
    [_course_tableview reloadData];
    CGFloat makesureY = _addcoursetime_btn.frame.origin.y;
    if(64 + makesureY + (24 + 320.0 + 80)*scaletoheight < kScreenHeight){//80是底部按钮
        _course_tableview.frame = CGRectMake(0, _course_tableview.frame.origin.y, kScreenWidth, _course_tableview.frame.size.height + ( 320.0+24 )*scaletoheight);
    }
    NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:0 inSection:_courseview_array.count-1];
    [self.course_tableview scrollToRowAtIndexPath:scrollIndexPath
                            atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

//点击上课时间coursetime_view里的删除按钮
-(void)deletecoursetime:(id)sender{
    CourseTimeCell *cell = (CourseTimeCell *)[sender superview];//获取被点击的button所在的cell
    NSIndexPath *indexPathselect = [_course_tableview indexPathForCell:cell];
    NSUInteger deleteone =(long)indexPathselect.section;

    if(_courseview_array.count >= 1){
        [_courseview_array removeObjectAtIndex:deleteone];
        [self.originTimeIndexArray removeObjectAtIndex:deleteone];
        [self.originWeekdayArray removeObjectAtIndex:deleteone];
        NSIndexSet *index= [[NSIndexSet alloc] initWithIndex:deleteone];
        [_course_tableview deleteSections:index withRowAnimation:UITableViewRowAnimationNone];
        [_course_tableview reloadData];
        if( 64 + (320.0+24)*scaletoheight*_courseview_array.count+(80 + 24 + 80)*scaletoheight<kScreenHeight){//80底部按钮，80课程描述，24底部按钮与tableview的间距，64状态栏+导航栏
            _course_tableview.frame = CGRectMake(0, _course_tableview.frame.origin.y, kScreenWidth,(320.0+24)*scaletoheight*_courseview_array.count);
        }
    }
}

-(void)addcover{
    UIButton *cover = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    _cover = cover;
    _cover.backgroundColor = [UIColor blackColor];
    _cover.alpha = 0.5;
    [self.view.window addSubview:_cover];
}

//---------------------------点击cell里的第一个按钮，周数选择按钮 系列事件--------------------------------
-(void)chooseweek:(id)sender
{
    CourseTimeCell *btnfromcell = (CourseTimeCell *)[sender superview];
    NSIndexPath *btnindex = [_course_tableview indexPathForCell:btnfromcell];
    CourseModel *loadModel = _courseview_array[btnindex.section];
    
    [self addcover];    
    CGFloat X = kScreenWidth/2-(530.0/2*scaletowidth);
    CGFloat Y = kScreenHeight/2-(601.0/2*scaletoheight);
    weekselectview *weekselect_view = [[weekselectview alloc] initWithFrame:CGRectMake(X, Y, 530.0*scaletowidth, 601.0*scaletoheight) andWeekSelect:loadModel.weekArray indexSection:btnindex.section];
    _weekselect_view = weekselect_view;
    _weekselect_view.delegate = self;
    [self.view.window addSubview:_weekselect_view];
}

#pragma mark weekselectviewdelegate
-(void)setWeekSelectResult:(NSMutableArray *)weekselected inSection:(NSInteger)section
{//传回的weekselected是所选择的周数（字符串）数组，已经从小到大排好,从0开始
    [_cover removeFromSuperview];
    CourseModel *loadModel = _courseview_array[section];
    loadModel.weekArray = weekselected;
    [_course_tableview reloadSections:[[NSIndexSet alloc] initWithIndex:section] withRowAnimation:UITableViewRowAnimationNone];
}

-(void)weekSelectCancelAction:(weekselectview*)weekSelectView{
    [_cover removeFromSuperview];
}

//-----------------------------点击cell里的第二个按钮，星期几选择系列事件----------------------------------
-(void)chooseday:(id)sender
{
    CourseTimeCell *btnfromcell = (CourseTimeCell *)[sender superview];
    NSIndexPath *btnindex = [_course_tableview indexPathForCell:btnfromcell];
    CourseModel *loadModel = _courseview_array[btnindex.section];
    
    [self addcover];
    CGFloat X = kScreenWidth/2-(530.0/2*scaletowidth);
    CGFloat Y = kScreenHeight/2-(635.0/2*scaletoheight);
    dayselectview *dayselect_view = [[dayselectview alloc] initWithFrame:CGRectMake(X, Y, 530.0*scaletowidth, 635.0*scaletoheight) andDayString:loadModel.weekday indexSection:btnindex.section];
    _dayselect_view = dayselect_view;    
    _dayselect_view.delegate = self;
    [self.view.window addSubview:_dayselect_view];
}

#pragma mark dayselectviewdelegate
- (void)daySelectComfirmAction:(dayselectview *)sectionSelector selectedIndex:(NSInteger)index inSection:(NSInteger)section{//传回的index +1就是星期几
    [_cover removeFromSuperview];
    CourseModel *loadModel = _courseview_array[section];
    loadModel.weekday = [NSString stringWithFormat:@"%ld",index];
    [_course_tableview reloadSections:[[NSIndexSet alloc] initWithIndex:section]  withRowAnimation:UITableViewRowAnimationNone];
}

- (void)daySelectCancelAction:(dayselectview *)sectionSelector{
    [_cover removeFromSuperview];
}

//-----------------------------点击cell里的第三个按钮，时间选择系列事件----------------------------------
-(void)choosetime:(id)sender
{
    CourseTimeCell *btnfromcell = (CourseTimeCell *)[sender superview];
    NSIndexPath *btnindex = [_course_tableview indexPathForCell:btnfromcell];
    CourseModel *loadModel = _courseview_array[btnindex.section];
    [self addcover];
    
    CGFloat X = kScreenWidth/2-(650/2*scaletowidth);
    CGFloat Y = kScreenHeight/2-(700/2*scaletoheight);
    timeselecteview *timeselect_view = [[timeselecteview alloc]initWithFrame:CGRectMake(X, Y, 650*scaletowidth, 716*scaletoheight) andCellModel:loadModel indexSection:btnindex.section originIndexs:self.originTimeIndexArray[btnindex.section] originWeekday:[self.originWeekdayArray[btnindex.section]integerValue]];
    _timeselect_view = timeselect_view;
    
    //用whichSection来传递是哪一个section
    _timeselect_view.delegate = self;
    [self.view.window addSubview:_timeselect_view];
}

#pragma mark timeselectviewdelegate
- (void)timeSelectComfirm:(timeselecteview*)timeselect courseTimeArray:(NSMutableArray *)courseTimeArray inSection:(NSInteger)section
{
    [_cover removeFromSuperview];
    CourseModel *loadModel = _courseview_array[section];
    loadModel.timeArray = courseTimeArray;
    [_course_tableview reloadSections:[[NSIndexSet alloc] initWithIndex:section]  withRowAnimation:UITableViewRowAnimationNone];
}

- (void)timeSelectCancel:(timeselecteview *)timeSelectView{
    [_cover removeFromSuperview];
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
    if(textField.tag == 0){//课程名称
        for(int i = 0 ; i<_courseview_array.count ;i ++){
            CourseModel *courseCellModel = _courseview_array[i];
            courseCellModel.courseName = textField.text;
        }
    }else{//上课教室
        CourseTimeCell *fieldfrom = (CourseTimeCell *)[textField superview];
        NSIndexPath *index = [_course_tableview indexPathForCell:fieldfrom];
        CourseModel *loadModel = _courseview_array[index.section];
        loadModel.place = textField.text;
    }
}

//---------------------------------保存当前页数据的方法-------------------------------
-(void)cancel
{
    void (^otherBlock)(UIAlertAction *action) = ^(UIAlertAction *action){
        [self.navigationController popViewControllerAnimated:YES];
    };
    NSArray *otherBlocks = @[otherBlock];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确认退出？" message:@"一旦退出，编辑将不会保存" preferredStyle:UIAlertControllerStyleAlert cancelTitle:@"取消" cancelBlock:nil otherTitles:@[@"确定"] otherBlocks:otherBlocks];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)confirm{
    [self dataStore];
}

- (void)dataStore{
    if([self checkIfConflict]){
        void (^otherBlock)(UIAlertAction *action) = ^(UIAlertAction *action){
        };
        NSArray *otherBlocks = @[otherBlock];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"警告" message:@"课程时间冲突" preferredStyle:UIAlertControllerStyleAlert cancelTitle:nil cancelBlock:nil otherTitles:@[@"确定"] otherBlocks:otherBlocks];
        [self presentViewController:alert animated:YES completion:nil];
    }else{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            DbManager *dbManger = [DbManager shareInstance];
            //1.删除所有原课程（所有同名课程数据）
            NSString *deleteOrigin = [NSString stringWithFormat:@"DELETE FROM course_table WHERE courseName = '%@';",self.originCourseName];
            [dbManger executeNonQuery:deleteOrigin];
            //2.修改被覆盖的数据
            for (int i = 0; i < self.courseview_array.count; i++) {
                CourseModel *courseModel = self.courseview_array[i];
                NSMutableString *sqlweek = [NSMutableString string];
                NSMutableString *sqlTime = [NSMutableString string];
                for (int j = 0; j < courseModel.weekArray.count; j++) {
                    [sqlweek appendString:[NSString stringWithFormat:@"weeks LIKE '%%,%@,%%' or ",courseModel.weekArray[j]]];
                }
                sqlweek = (NSMutableString*)[sqlweek substringToIndex:sqlweek.length - 3];
                for (int j = 0; j < courseModel.timeArray.count; j++) {
                    [sqlTime appendString:[NSString stringWithFormat:@"time LIKE '%%,%@,%%' or ",courseModel.timeArray[j]]];
                }
                sqlTime = (NSMutableString*)[sqlTime substringToIndex:sqlTime.length - 3];
                
                NSString *sql = [NSString stringWithFormat:@"SELECT * FROM course_table WHERE weekday = '%@' and (%@) and (%@);",courseModel.weekday,sqlweek,sqlTime];
                NSArray *dataQuery = [dbManger executeQuery:sql];//查找出重合数据
                if (dataQuery.count > 0) {
                    for (int j = 0; j < dataQuery.count ; j++) {
                        NSMutableDictionary *courseDict = [NSMutableDictionary dictionaryWithDictionary:dataQuery[j]];
                        CourseModel *newModel = [[CourseModel alloc] initWithDict:courseDict];
                        //每条课程数据，删去重复的时间段（被覆盖掉了）得到新的课程时间段
                        //节数
                        NSMutableArray *newTimeArray = [newModel.timeArray mutableCopy];
                        for (int k = 0 ; k < courseModel.timeArray.count; k++) {
                            if ([newTimeArray containsObject:courseModel.timeArray[k]]) {
                                [newTimeArray removeObject:courseModel.timeArray[k]];
                            }
                        }
                        //周数
                        NSMutableArray *newWeekArray1 = [newModel.weekArray mutableCopy];//没被覆盖的部分，有可能是空
                        NSMutableArray *newWeekarray2 = [NSMutableArray array];//被覆盖的部分,一定非空
                        for (int k = 0; k < courseModel.weekArray.count; k++) {
                            if ([newWeekArray1 containsObject:courseModel.weekArray[k]]) {
                                [newWeekArray1 removeObject:courseModel.weekArray[k]];
                                [newWeekarray2 addObject:courseModel.weekArray[k]];
                            }
                        }
                        
                        if (newWeekArray1.count == 0) {//周数全覆盖
                            if (newTimeArray.count != 0) {//newTimeArray.count=0意味着现课程把原课程节数都覆盖掉了，所以原课程直接删
                                NSString *newWeekStr2 = [self appendStringWithArray:newWeekarray2];
                                //对新的课程节数时间段进行连续性分割
                                NSMutableArray *sections = [Utils subSectionArraysFromArray:newTimeArray];
                                //然后插入更新后周数覆盖部分的课程
                                [dbManger beginTransaction];
                                for (int k = 0; k < sections.count; k++) {
                                    NSMutableArray *newSection = sections[k];
                                    NSString *newTimeStr = [self appendStringWithArray:newSection];
                                    NSString *sql = [NSString stringWithFormat:@"INSERT INTO course_table (courseName,weeks,weekday,time,place) VALUES ('%@','%@','%@','%@','%@');",newModel.courseName,newWeekStr2,newModel.weekday,newTimeStr,newModel.place];
                                    [dbManger executeNonQuery:sql];
                                }
                                [dbManger commitTransaction];
                            }
                        }else{//周数不全覆盖
                            NSString *newWeekStr1 = [self appendStringWithArray:newWeekArray1];
                            //1.对周数没有覆盖的部分：
                            NSString *sql = [NSString stringWithFormat:@"INSERT INTO course_table (courseName,weeks,weekday,time,place) VALUES ('%@','%@','%@','%@','%@');",newModel.courseName,newWeekStr1,newModel.weekday,newModel.time,newModel.place];
                            [dbManger executeNonQuery:sql];
                            //2.对周数覆盖的部分：
                            if (newTimeArray.count != 0) {
                                NSString *newWeekStr2 = [self appendStringWithArray:newWeekarray2];
                                //对新的课程节数时间段进行连续性分割
                                NSMutableArray *sections = [Utils subSectionArraysFromArray:newTimeArray];
                                //然后插入更新后周数覆盖部分的课程
                                [dbManger beginTransaction];
                                for (int k = 0; k < sections.count; k++) {
                                    NSMutableArray *newSection = sections[k];
                                    NSString *newTimeStr = [self appendStringWithArray:newSection];
                                    NSString *sql = [NSString stringWithFormat:@"INSERT INTO course_table (courseName,weeks,weekday,time,place) VALUES ('%@','%@','%@','%@','%@');",newModel.courseName,newWeekStr2,newModel.weekday,newTimeStr,newModel.place];
                                    [dbManger executeNonQuery:sql];
                                }
                                [dbManger commitTransaction];
                            }
                        }
                    }
                    //删除旧的事务数据
                    NSString *deleteSql = [NSString stringWithFormat:@"DELETE FROM course_table WHERE weekday = '%@' and (%@) and (%@);",courseModel.weekday,sqlweek,sqlTime];
                    [dbManger executeNonQuery:deleteSql];
                }
                
                //插入新事务
                NSMutableArray *arr = [Utils subSectionArraysFromArray:courseModel.timeArray];
                NSString *weekstr = [self appendStringWithArray:courseModel.weekArray];
                [dbManger beginTransaction];
                for (int m = 0; m < arr.count; m ++) {
                    NSMutableArray *section = arr[m];
                    NSString *timeStr = [self appendStringWithArray:section];
                    NSString *sql = [NSString stringWithFormat:@"INSERT INTO course_table (courseName,weeks,weekday,time,place) VALUES ('%@','%@','%@','%@','%@');",courseModel.courseName,weekstr,courseModel.weekday,timeStr,courseModel.place];//注意VALUES字符串赋值要有单引号
                    [dbManger executeNonQuery:sql];
                    
                }
                [dbManger commitTransaction];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate CourseViewControllerConfirm:self];
                [self.navigationController popViewControllerAnimated:YES];
            });
        });
    }
}

- (NSString *)appendStringWithArray:(NSMutableArray *)array{
    NSMutableString *str = [[NSMutableString alloc] initWithCapacity:2];
    [str appendString:@","];
    for (int i = 0; i < array.count; i++) {
        [str appendFormat:@"%@,",array[i]];
    }
    return str;
}

//检查_courseview_array里的课程是否有冲突（两两进行对比）
//返回YES是有冲突，NO是没冲突
- (BOOL)checkIfConflict
{
    if(self.courseview_array.count == 1) return NO;
    for(int i = 0;i < self.courseview_array.count -1;i++){
        CourseModel *firstCellModel = self.courseview_array[i];
        for(int j = i + 1;j < self.courseview_array.count;j++){
            CourseModel *secondCellModel = self.courseview_array[j];
            if([firstCellModel checkIfConflictComparetoAnotherCourseModel:secondCellModel])
                return YES;
        }
    }
    return NO;
}
@end
