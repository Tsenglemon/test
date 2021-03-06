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
#import "CourseModel.h"
#import "DbManager.h"

#define kScreenWidth [UIApplication sharedApplication].keyWindow.bounds.size.width
#define kScreenHeight [UIApplication sharedApplication].keyWindow.bounds.size.height
#define scaletoheight [UIApplication sharedApplication].keyWindow.bounds.size.height/1334.0
#define scaletowidth [UIApplication sharedApplication].keyWindow.bounds.size.width/750.0
#define fontscale [UIApplication sharedApplication].keyWindow.bounds.size.width/375.0

@interface CourseViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
@property (nonatomic,weak) UIView *courseView;
@property (nonatomic,weak) UIView *businessView;//父view

@property (nonatomic,weak) UISegmentedControl *coursebusiness_seg;

//上课的子view
@property (nonatomic,weak) UIView *coursefield_view;
@property (nonatomic,weak) UITableView *course_tableview;
@property (nonatomic,weak) CourseTimeCell *coursetime_view;
@property (nonatomic,weak) UIButton *addcoursetime_btn;

//变暗的背景
@property (nonatomic,weak) UIButton *cover;
//浮窗view
@property (nonatomic,weak) weekselectview *weekselect_view;
@property (nonatomic,weak) dayselectview *dayselect_view;
@property (nonatomic,weak) timeselecteview *timeselect_view;

@end

@implementation CourseViewController
{
    NSMutableArray *courseview_array;//装coursetime_view里数据的array，每一个coursetime_view是一个dictionary
    NSString *coursename;//课程名字
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *courseview = [[UIView alloc] init];
    _courseView = courseview;
    
    //先随便写，到时候key要和模型里的名称相同
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"1-16周",@"weeksnum",@"周一",@"weekday",@"1-2节",@"coursenum",@"",@"classroom",nil];
    courseview_array = [[NSMutableArray alloc] init];
    coursename = [[NSString alloc] init];
    [courseview_array addObject:dict];
    //UINavigationItem *finish = [[UINavigationItem alloc] rightBarButtonItem];
    UIBarButtonItem *finish = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:nil];
    self.navigationController.navigationItem.rightBarButtonItem = finish;
    
    
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
    namefield.delegate = self;
    //namefield文本框的tag是0，classroom文本框的tag是1
    namefield.tag = 0;
    [namefield setBorderStyle:UITextBorderStyleRoundedRect];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[NSForegroundColorAttributeName] = [Utils colorWithHexString:@"#d9d9d9"];
    dict[NSFontAttributeName] = [UIFont systemFontOfSize:12.0];
    NSAttributedString *attribute = [[NSAttributedString alloc] initWithString:@"请输入你的课程" attributes:dict];
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
    return [courseview_array count];
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
        [cell.weeksnum addTarget:self action:@selector(chooseweek:) forControlEvents:UIControlEventTouchUpInside];
        [cell.weekday addTarget:self action:@selector(chooseday:) forControlEvents:UIControlEventTouchUpInside];
        [cell.coursenum addTarget:self action:@selector(choosetime:) forControlEvents:UIControlEventTouchUpInside];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.classroom.delegate = self;
        cell.classroom.tag = 1;
    }
    
    
    NSMutableDictionary *loaddict = courseview_array[indexPath.section];
    [cell.weeksnum setTitle:[loaddict valueForKey:@"weeksnum"] forState:UIControlStateNormal];
    [cell.weekday setTitle:[loaddict valueForKey:@"weekday"] forState:UIControlStateNormal];
    [cell.coursenum setTitle:[loaddict valueForKey:@"coursenum"] forState:UIControlStateNormal];
    cell.classroom.text = [loaddict valueForKey:@"classroom"];
    
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
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"1-16周",@"weeksnum",@"周一",@"weekday",@"1-2节",@"coursenum",@"",@"classroom",nil];
    [courseview_array addObject:dict];
    NSInteger addone = courseview_array.count-1;
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
    if(courseview_array.count>=1)
    {
        [courseview_array removeObjectAtIndex:deleteone];
        NSIndexSet *index= [[NSIndexSet alloc] initWithIndex:deleteone];
        [_course_tableview deleteSections:index withRowAnimation:UITableViewRowAnimationMiddle];
        [_course_tableview reloadData];
        
        CGFloat makesureY = _addcoursetime_btn.frame.origin.y;
        if(makesureY - (320.0)*scaletoheight >0 && courseview_array.count<3){
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

-(void)removecover{
    [UIWindow animateWithDuration:0.5 animations:^{
        [_cover removeFromSuperview];
        
    }];
}

//---------------------------点击cell里的第一个按钮，周数选择按钮 系列事件--------------------------------
-(void)chooseweek:(id)sender
{
    CourseTimeCell *btnfromcell = (CourseTimeCell *)[sender superview];
    NSIndexPath *btnindex = [_course_tableview indexPathForCell:btnfromcell];
    
    [self addcover];
    
    CGFloat X = kScreenWidth/2-(530.0/2*scaletowidth);
    CGFloat Y = kScreenHeight/2-(601.0/2*scaletoheight);
    weekselectview *weekselect_view = [[weekselectview alloc] initWithFrame:CGRectMake(X, Y, 530.0*scaletowidth, 601.0*scaletoheight)];
    _weekselect_view = weekselect_view;
    [_weekselect_view.cancel_btn addTarget:self action:@selector(weekselectcancel) forControlEvents:UIControlEventTouchUpInside];
    //利用确认按钮的tag来传递section
    _weekselect_view.confirm_btn.tag=btnindex.section;
    [_weekselect_view.confirm_btn addTarget:self action:@selector(weekselectconfirm:) forControlEvents:UIControlEventTouchUpInside];
    [self.view.window addSubview:_weekselect_view];
}

-(void)weekselectcancel{
    [self removecover];
    [_weekselect_view removeFromSuperview];
}


-(void)weekselectconfirm:(id)sender{
    //拿到section
    UIButton *btnfrom = (UIButton*)sender;
    long index = btnfrom.tag;
    
    //改数组里的字典
    NSString *weeksnum = [[NSString alloc] init];
    weeksnum = [weeksnum stringByAppendingString:@"第"];
    NSArray *weeksarray = _weekselect_view.weekselected_array;
    for(UIButton *btn in weeksarray)
    {
        if(btn.selected == YES)
        {
            weeksnum = [weeksnum stringByAppendingFormat:@"%@,",btn.titleLabel.text];
        }
    }
    NSString *newweeksnum = [weeksnum substringWithRange:NSMakeRange(0,weeksnum.length-1)];
    newweeksnum = [newweeksnum stringByAppendingString:@"周"];
    
    //这里需要考虑一下weeksnum的智能显示，比如智能显示出单周，双周，或者1~n周，而非罗列出所有周数
    
    
    NSMutableDictionary *changedict = courseview_array[index];
    
    [changedict setValue:newweeksnum forKey:@"weeksnum"];
    
    
    
    //让tableview刷新数据
    NSIndexSet *indexset= [[NSIndexSet alloc] initWithIndex:index];
    [_course_tableview reloadSections:indexset withRowAnimation:UITableViewRowAnimationFade];
    [self weekselectcancel];
    
}


//-----------------------------点击cell里的第二个按钮，星期几选择系列事件----------------------------------
-(void)chooseday:(id)sender
{
    CourseTimeCell *btnfromcell = (CourseTimeCell *)[sender superview];
    NSIndexPath *btnindex = [_course_tableview indexPathForCell:btnfromcell];
    
    [self addcover];
    CGFloat X = kScreenWidth/2-(530.0/2*scaletowidth);
    CGFloat Y = kScreenHeight/2-(635.0/2*scaletoheight);
    dayselectview *dayselect_view = [[dayselectview alloc] initWithFrame:CGRectMake(X, Y, 530.0*scaletowidth, 635.0*scaletoheight)];
    _dayselect_view = dayselect_view;
    [_dayselect_view.cancel_btn addTarget:self action:@selector(dayselectcancel) forControlEvents:UIControlEventTouchUpInside];
    
    //利用确认按钮的tag来传递section
    _dayselect_view.confirm_btn.tag=btnindex.section;
    [_dayselect_view.confirm_btn addTarget:self action:@selector(dayselectconfirm:) forControlEvents:UIControlEventTouchUpInside];
    [self.view.window addSubview:_dayselect_view];
}

-(void)dayselectcancel{
    [self removecover];
    [_dayselect_view removeFromSuperview];
}


-(void)dayselectconfirm:(id)sender{
    //拿到section
    UIButton *btnfrom = (UIButton*)sender;
    long index = btnfrom.tag;
    dayselectview *showview = (dayselectview *)[btnfrom superview];
    
    if(showview.dayselected != NULL)
    {
        //改数组里的字典
        NSMutableDictionary *changedict = courseview_array[index];
        [changedict setValue:showview.dayselected forKey:@"weekday"];
        
        
        //让tableview刷新数据
        NSIndexSet *indexset= [[NSIndexSet alloc] initWithIndex:index];
        [_course_tableview reloadSections:indexset withRowAnimation:UITableViewRowAnimationFade];
    }
    [self dayselectcancel];
    
}

//-----------------------------点击cell里的第三个按钮，时间选择系列事件----------------------------------

-(void)choosetime:(id)sender
{
    CourseTimeCell *btnfromcell = (CourseTimeCell *)[sender superview];
    NSIndexPath *btnindex = [_course_tableview indexPathForCell:btnfromcell];
    
    [self addcover];
    
    CGFloat X = kScreenWidth/2-(650/2*scaletowidth);
    CGFloat Y = kScreenHeight/2-(700/2*scaletoheight);
    timeselecteview *timeselect_view = [[timeselecteview alloc] initWithFrame:CGRectMake(X, Y, 650*scaletowidth, 700*scaletoheight)];
    _timeselect_view = timeselect_view;
    _timeselect_view.confirm_btn.tag = btnindex.section; //用comfirm按钮的tag来传递是哪一个section
    [_timeselect_view.cancel_btn addTarget:self action:@selector(timeselectcancel) forControlEvents:UIControlEventTouchUpInside];
    [_timeselect_view.confirm_btn addTarget:self action:@selector(timeselectconfirm:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view.window addSubview:_timeselect_view];
    
    NSDictionary *clickcell = courseview_array[btnindex.section];
    NSString *today = [clickcell valueForKey:@"weekday"];
    _timeselect_view.today.text = today;
}

-(void)timeselectcancel
{
    [self removecover];
    [_timeselect_view removeFromSuperview];
}

-(void)timeselectconfirm:(id) sender
{
    UIButton *btnfrom = (UIButton*)sender;
    long index = btnfrom.tag;
    timeselecteview *showview = (timeselecteview *)[btnfrom superview];
    
    NSArray *label = @[@"早间",@"1节",@"2节",@"3节",@"4节",@"午间",@"5节",@"6节",@"7节",@"8节",@"9节",@"10节",@"11节",@"12节",@"晚间"];
    
    
    //改数组里的字典
    NSString *coursenumstring = [[NSString alloc] init];
    for(int i = 0; i<showview.selectresult.count; i++)
    {
        if([showview.selectresult[i] isEqual: @"1"]){
            coursenumstring = [coursenumstring stringByAppendingString:label[i]];
            coursenumstring = [coursenumstring stringByAppendingString:@","];
        }
    }
    
    NSString *newcoursenumstring = [[NSString alloc] init];
    if(coursenumstring.length >1)//添加判断条件是为了避免什么也没选的时候出错
        newcoursenumstring = [coursenumstring substringWithRange:NSMakeRange(0, [coursenumstring length] - 1)];//去掉最后添加的,符号
    
    
    NSMutableDictionary *changedict = courseview_array[index];
    [changedict setValue:newcoursenumstring forKey:@"coursenum"];
    
    
    
    //让tableview刷新数据
    NSIndexSet *indexset= [[NSIndexSet alloc] initWithIndex:index];
    [_course_tableview reloadSections:indexset withRowAnimation:UITableViewRowAnimationFade];
    
    [self timeselectcancel];
    
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
    if(textField.tag == 0){
        //课程名称
        coursename = textField.text;
    }
    else{
        //上课教室
        CourseTimeCell *fieldfrom = (CourseTimeCell *)[textField superview];
        NSIndexPath *index = [_course_tableview indexPathForCell:fieldfrom];
        
        NSMutableDictionary *changedict = courseview_array[index.section];
        [changedict setValue:textField.text forKey:@"classroom"];
        
        //NSLog(@"%@",changedict);
        NSIndexSet *indexset= [[NSIndexSet alloc] initWithIndex:index.section];
        [_course_tableview reloadSections:indexset withRowAnimation:UITableViewRowAnimationFade];
        
        
    }
}

//---------------------------------保存当前页数据的方法-------------------------------
-(BOOL)DataStore
{
    //保存数据
    NSMutableArray *model_array = [[NSMutableArray alloc] init];
    if([self Dictionary:courseview_array toModel:model_array]){
        //数据完整，可写入数据库
        for(int i=0;i<model_array.count;i++)
        {
            CourseModel *gonnatosave = model_array[i];
            [self writeCourseModeltoSQL:gonnatosave];
        }
        return YES;
    }
    else{
        //数据不完整，提示完善输入
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"警告" message:@"请完善课程信息" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"好的", nil];
        [alertView show];
        return NO;
    }
}

//把courseview_array里的字典转成一个个模型放入新的数组,返回值YES表示数据完整，否则数据不完整，提示完善输入
-(BOOL)Dictionary:(NSMutableArray *)Dict toModel:(NSMutableArray *)Model
{
    //NSLog(@"%@",Dict);
    
    for(int i = 0;i<Dict.count;i++)
    {
        NSDictionary *dealdict = Dict[i];
        //1.周数处理
        NSString *originweek = [NSString stringWithString:[dealdict valueForKey:@"weeksnum"]];
        NSString *weeks = [originweek substringWithRange:NSMakeRange(1, originweek.length-2)];
        NSArray *weeksnum = [weeks componentsSeparatedByString:@","];
        //NSLog(@"weeksnum:%@",weeksnum);
        
        //2.时段处理
        //2.1获取时段array
        NSArray *timelabel = @[@"早间",@"1节",@"2节",@"3节",@"4节",@"午间",@"5节",@"6节",@"7节",@"8节",@"9节",@"10节",@"11节",@"12节",@"晚间"];
        NSString *time = [NSString stringWithString:[dealdict valueForKey:@"coursenum"]];
        NSArray *temp = [time componentsSeparatedByString:@","];
        NSMutableArray *coursenumtemp = [[NSMutableArray alloc] init];
        for(int j = 0;j<temp.count;j++)
        {
            NSString *timenode = temp[j];
            NSNumber *position = [NSNumber numberWithUnsignedInteger:[timelabel indexOfObject:timenode]];
            [coursenumtemp addObject:position];
        }
        //2.2连续性识别
        NSArray *coursenum = [[self consecutivejude:coursenumtemp] copy];
        
        //3.课室，星期几
        NSArray *weekdaylabel = @[@"0",@"星期一",@"星期二",@"星期三",@"星期四",@"星期五",@"星期六",@"星期日"];
        NSString *classroom = [dealdict valueForKey:@"classroom"];
        NSString *tempweekday = [dealdict valueForKey:@"weekday"];
        NSString *weekday = [NSString stringWithFormat:@"%ld",[weekdaylabel indexOfObject:tempweekday]];
        
        
        //检查处理后的数据是否完整，不完整则返回，完整则继续
        if(weeksnum.count==0 || coursenum.count == 0 || classroom.length==0 || weekday.length == 0 || coursename.length == 0)
            return NO;//数据不完整
        
        
        for(int j = 0;j<coursenum.count;j++)
        {
            NSArray *course_startlast = coursenum[j];
            for(int k=0;k<weeksnum.count;k++)
            {
                CourseModel *datamodel = [[CourseModel alloc] init];
                datamodel.place = classroom;
                datamodel.courseName = coursename;
                datamodel.weekday = weekday;
                datamodel.weeks = weeksnum[k];
                NSNumber *start = course_startlast[0];
                NSNumber *last = course_startlast[1];
                datamodel.courseStart = start.description;
                datamodel.numberOfCourse = last.description;
                //NSLog(@"model:%@,%@,%@,%@,%@,%@",datamodel.place,datamodel.courseName,datamodel.weekday,datamodel.weeks,datamodel.courseStart,datamodel.numberOfCourse);
                [Model addObject:datamodel];
            }
        }
        
    }
    return YES;
}

//从时段array得出开始时间和持续时间（如1,2,4识别出第一组开始第一节，持续两节，第二组开始第四节，持续一节...）
-(NSMutableArray *)consecutivejude:(NSMutableArray *)array
{
    NSMutableArray *returnmodelarray = [[NSMutableArray alloc] init];
    [array addObject:[NSNumber numberWithInt:0]];//添加0尾方便处理
    int start = [array[0] intValue];
    int last = 1;
    for(int i=1;i<array.count;i++)
    {
        int next = [array[i] intValue];
        if(next == (start+1)){
            last+=1;
        }
        else{
            NSArray *group = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:start],[NSNumber numberWithInt:last],nil];
            [returnmodelarray addObject:group];
            start = next;
            last = 1;
        }
    }
    
    //NSLog(@"returnmodel:%@",returnmodelarray);
    return returnmodelarray;
}


//把一个模型写入数据库
-(void)writeCourseModeltoSQL:(CourseModel *)model
{
    DbManager *dbManger = [DbManager shareInstance];
    [dbManger openDb:@"eventcourse.sqlite"];
    
    //先查找有无重复或冲突数据
    
    
    //没有冲突，确认添加数据
    NSString *sql = [NSString stringWithFormat:@"insert into course_table (weeks,weekDay,courseStart,numberOfCourse,courseName,place) values (%@,'%@',%@,%@,'%@','%@')",model.weeks,model.weekday,model.courseStart,model.numberOfCourse,model.courseName,model.place];
    
    //NSLog(@"sql:%@",sql);
    [dbManger executeNonQuery:sql];
}

@end
