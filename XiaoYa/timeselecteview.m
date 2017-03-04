//
//  timeselecteview.m
//  XiaoYa
//
//  Created by 曾凌峰 on 2017/1/19.
//  Copyright © 2017年 commet. All rights reserved.
//

#import "timeselecteview.h"
#import "timeselecttableviewcell.h"
#import "Utils.h"
#import "Masonry.h"
#import "DbManager.h"
#import "CourseTimeCellModel.h"
#import "CourseModel.h"

#define kScreenWidth [UIApplication sharedApplication].keyWindow.bounds.size.width
#define kScreenHeight [UIApplication sharedApplication].keyWindow.bounds.size.height

#define scaletoheight [UIApplication sharedApplication].keyWindow.bounds.size.height/1334.0
#define scaletowidth [UIApplication sharedApplication].keyWindow.bounds.size.width/750.0
#define fontscale [UIApplication sharedApplication].keyWindow.bounds.size.width/375.0

#define marginX (95-60)/2*scaletowidth
#define marginY 14*scaletoheight
#define weeknumwidth 60*scaletowidth

@interface timeselecteview()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,weak) UIView* titleview; //顶部蓝色块和内部星期几的标签
@property (nonatomic,weak) UITableView *timetable;
@property (nonatomic,strong) NSArray *timeData;

@property (nonatomic,strong) NSMutableArray *busyTimeCourseID;//装数据库里查找的冲突的课程id,是二维数组(查出来的结果不止一条)
@property (nonatomic,strong) NSMutableArray *busyTimeCourseName;//装数据库里查找的冲突的课程name标签(一维的，拼接好的了string)
@end

@implementation timeselecteview


-(instancetype)initWithFrame:(CGRect)frame andCellModel:(CourseTimeCellModel *)cellMoedl
{
    if(self = [super initWithFrame:frame])
    {
        
        NSArray *timeData = @[@[@"早间"],@[@"8:00",@"1"],@[@"8:55",@"2"],@[@"10:00",@"3"],@[@"10:55",@"4"],@[@"午间"],@[@"14:30",@"5"],@[@"15:25",@"6"],@[@"16:20",@"7"],@[@"17:15",@"8"],@[@"19:00",@"9"],@[@"19:55",@"10"],@[@"20:50",@"11"],@[@"21:45",@"12"],@[@"晚间"]];
        _timeData = timeData;
        
        NSMutableArray *selectresult = [NSMutableArray array];
        _selectresult = selectresult;
        //_selectresult = cellMoedl.courseTimeArray;
        [_selectresult addObjectsFromArray:cellMoedl.courseTimeArray];
        
        NSMutableSet *toDeleteID = [[NSMutableSet alloc] init];
        _toDeleteID = toDeleteID;
        
        self.layer.cornerRadius = 10;
        self.clipsToBounds = YES;
        self.backgroundColor = [Utils colorWithHexString:@"#FFFFFF"];
        NSString *whichSection = [[NSString alloc] init];
        _whichSection = whichSection;
        
        //利用cellModel里的数据查询数据库得到当天的课程
        [self loadCoursefromSQLwithCourseCellModel:cellMoedl];
        
        [self setApperance];
        
        //显示当前选择了星期几
        _today.text = cellMoedl.weekDay;
 
    }
    return self;
}

//根据model的时间去数据库查找课程，并显示在表格里
-(void)loadCoursefromSQLwithCourseCellModel:(CourseTimeCellModel *)cellMoedl
{
//    NSLog(@"weeks:%@",cellMoedl.weeksArray);
//    NSLog(@"weekDay:%@",cellMoedl.weekDayNum);
    
    //idsign用作标记时间段的课程id,若该时间段没课则标记0，有课则标记课程的id
    NSMutableArray *busyTimeCourseID = [NSMutableArray arrayWithCapacity:_timeData.count];
    _busyTimeCourseID = busyTimeCourseID;
    NSMutableArray *busyTimeCourseName = [[NSMutableArray alloc] init];
    _busyTimeCourseName = busyTimeCourseName;
    
    //占位
    for (int m=0; m<_timeData.count; m++) {
        [_busyTimeCourseID addObject:[NSMutableArray arrayWithObjects:@"0", nil]];
        [_busyTimeCourseName addObject:@"0"];
    }
    
    DbManager *dbManger = [DbManager shareInstance];
    [dbManger openDb:@"eventcourse.sqlite"];
    
    
    for(int i = 0; i<cellMoedl.weeksArray.count;i++)
    {

        
        NSString *sql = [NSString stringWithFormat:@"SELECT id,courseStart,numberOfCourse,courseName FROM course_table WHERE weeks is '%@' and weekDay is '%@'",cellMoedl.weeksArray[i],cellMoedl.weekDayNum];
        
        NSArray *dataFromSQL = [[NSArray alloc] init];
        dataFromSQL = [dbManger executeQuery:sql];
        
        if(dataFromSQL.count == 0) continue;//没有数据则说明这一天没有课程即不用继续下面的操作
        

        for(int m=0;m<dataFromSQL.count;m++){
            NSDictionary *course = dataFromSQL[m];
            
            NSString *courseID = [course valueForKey:@"id"];
            NSString *courseName = [course valueForKey:@"courseName"];
            int coursestart = [[course valueForKey:@"courseStart"] intValue];
            int numberofcourse = [[course valueForKey:@"numberOfCourse"] intValue];
            
            
            for(int n=coursestart;n<(coursestart+numberofcourse);n++)
            {
                NSMutableArray *arryfromCourseID = _busyTimeCourseID[n];
                NSString *showCourseName = _busyTimeCourseName[n];
                
                [arryfromCourseID addObject:courseID];
                showCourseName = [showCourseName stringByAppendingString:courseName];
                showCourseName = [showCourseName stringByAppendingString:@","];
                [_busyTimeCourseName replaceObjectAtIndex: n withObject:showCourseName];
            }
        }
    }
    //NSLog(@"_busyTimeCourseName:%@",_busyTimeCourseName);
    //NSLog(@"_busyTimeCourseID:%@",_busyTimeCourseID);
    

}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //NSLog(@"%lu",(unsigned long)_timeData.count);
    return [_timeData count];
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"timeselecttavleviewcell";
    timeselecttableviewcell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(cell == nil)
    {
        cell = [[timeselecttableviewcell alloc] initWithreuseIdentifier:ID];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell.selectBtn addTarget:self action:@selector(choose:) forControlEvents:UIControlEventTouchUpInside];
       
    }
    //在selectBtn上绑定row序号。在响应方法中方便使用
    cell.selectBtn.tag = indexPath.row;
    cell.selectBtn.selected = NO;
    NSArray *time = _timeData[indexPath.row];
    cell.time.text = nil;
    cell.number.text = nil;
    cell.timenode.text = nil;
    cell.comment.text = nil;
    cell.overlapAlertView.alpha = 0;
    if(time.count > 1){
        cell.time.text = time[0];
        cell.number.text = time[1];
    }
    else{
        cell.timenode.text = time[0];
    }

    
    NSString *showCourse = _busyTimeCourseName[indexPath.row];
    if(![showCourse isEqualToString:@"0"])//不等于0表示有课
    {
        showCourse = [showCourse substringWithRange:NSMakeRange(1, showCourse.length-2)];
        cell.comment.text = showCourse;
    }
    
    NSString *indexString = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
    //如果当前课程标签在_selectresult里
    if([_selectresult indexOfObject:indexString]<_selectresult.count)
    {
        cell.selectBtn.selected = YES;
        if(cell.comment.text.length>0)
            cell.overlapAlertView.alpha = 1;
    }
   
    return cell;

}


-(void)choose:(id)sender
{
    UIButton *chosenbtn = (UIButton *)sender;
    chosenbtn.selected = !chosenbtn.selected;
    
    timeselecttableviewcell *clickCell = (timeselecttableviewcell *)[chosenbtn superview];
    //NSLog(@"clickcell:%@",clickCell);
    
    //更改后出于被选中的状态
    if(chosenbtn.isSelected)
    {
        NSString *selectNum = [NSString stringWithFormat:@"%ld",(long)chosenbtn.tag ];
        [_selectresult addObject:selectNum];
        //NSLog(@"selectNum:%@",selectNum);
        //NSLog(@"timeData.count:%ld",(long)_timeData.count);
        //如果有课，则显示覆盖提示
        if(clickCell.comment.text.length>0)
            clickCell.overlapAlertView.alpha = 1;
    }
    //更改后处于取消选择的状态
    else
    {
        for(int i = 0;i<_selectresult.count;i++)
        {
            if([(NSString *)_selectresult[i] isEqualToString: [NSString stringWithFormat:@"%ld",(long)chosenbtn.tag]])
                [_selectresult removeObjectAtIndex:i];
        }
        
        //如果有课，则隐藏覆盖提示
        if(clickCell.comment.text.length>0)
            clickCell.overlapAlertView.alpha = 0;
    }
    //NSLog(@"_selectresult:%@",_selectresult);
    
    
}

-(void)setApperance
{
    UIView *titleview = [[UIView alloc] init];
    _titleview = titleview;
    _titleview.backgroundColor = [Utils colorWithHexString:@"#39B9F8"];
    [self addSubview:_titleview];
    __weak typeof(self) weakself = self;
    [_titleview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.width.centerX.equalTo(weakself);
        make.height.mas_equalTo(172*scaletoheight);
    }];
    
    
    UILabel *today = [[UILabel alloc] init];
    _today = today;
    [_today setTextColor:[Utils colorWithHexString:@"#FFFFFF"]];
    [_today setTextAlignment:NSTextAlignmentCenter];
    [_today setFont:[UIFont systemFontOfSize:30*fontscale]];
    //_today.text = @"星期几";
    [_titleview addSubview:_today];
    [_today mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.and.centerY.equalTo(_titleview);
    }];
    
    
    UITableView *timetable = [[UITableView alloc] init];
    _timetable = timetable;
    _timetable.dataSource = self;
    _timetable.delegate = self;
    [self addSubview:_timetable];
    [timetable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_titleview.mas_bottom);
        make.width.and.centerX.equalTo(weakself);
        make.height.mas_equalTo((700-172-76)*scaletoheight);
    }];
    
    
    UIView *line1 = [[UIView alloc] init];//横线
    line1.backgroundColor = [Utils colorWithHexString:@"#D9D9D9"];
    [self addSubview: line1];
    [line1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(weakself.mas_width);
        make.height.mas_equalTo(0.5);
        make.centerX.equalTo(weakself.mas_centerX);
        make.bottom.equalTo(weakself.mas_bottom).offset(-76*scaletoheight);
    }];
    
    UIView *line2 = [[UIView alloc] init];//竖线
    line2.backgroundColor = [Utils colorWithHexString:@"#D9D9D9"];
    [self addSubview: line2];
    [line2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(0.5);
        make.height.mas_equalTo(76*scaletoheight);
        make.centerX.equalTo(weakself.mas_centerX);
        make.bottom.equalTo(weakself.mas_bottom);
    }];
    
    //添加取消和确认按钮
    UIButton *cancel_btn = [[UIButton alloc] init];
    _cancel_btn=cancel_btn;
    [_cancel_btn setTitle:@"取消" forState:UIControlStateNormal];
    [_cancel_btn setTitleColor:[Utils colorWithHexString:@"#00A7FA"] forState:UIControlStateNormal];
    [_cancel_btn setTitleColor:[Utils colorWithHexString:@"#D9D9D9"] forState:UIControlStateHighlighted];
    _cancel_btn.titleLabel.font = [UIFont systemFontOfSize:13*fontscale];
    [self addSubview:_cancel_btn];
    //CGFloat masX1 = self.bounds.size.width/4;
    [_cancel_btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(76*scaletoheight);
        make.width.mas_equalTo(weakself.frame.size.width/2);
        make.right.equalTo(line2.mas_left);
        make.top.equalTo(line1.mas_bottom);
    }];
    
    
    UIButton *confirm_btn = [[UIButton alloc] init];
    _confirm_btn=confirm_btn;
    [_confirm_btn setTitle:@"确认" forState:UIControlStateNormal];
    [_confirm_btn setTitleColor:[Utils colorWithHexString:@"#00A7FA"] forState:UIControlStateNormal];
    [_confirm_btn setTitleColor:[Utils colorWithHexString:@"#D9D9D9"] forState:UIControlStateHighlighted];
    _confirm_btn.titleLabel.font = [UIFont systemFontOfSize:13*fontscale];
    [self addSubview:_confirm_btn];
    //CGFloat masX1 = self.bounds.size.width/4;
    [_confirm_btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(76*scaletoheight);
        make.width.mas_equalTo(weakself.frame.size.width/2);
        make.left.equalTo(line2.mas_right);
        make.top.equalTo(line1.mas_bottom);
    }];
    
    [_cancel_btn addTarget:self action:@selector(timeSelectCancel) forControlEvents:UIControlEventTouchUpInside];
    [_confirm_btn addTarget:self action:@selector(timeSelectConfirm) forControlEvents:UIControlEventTouchUpInside];

}

-(void)timeSelectCancel
{
    [_delegate removeCover];
    [self removeFromSuperview];
}

-(void)timeSelectConfirm
{
    //对_selectresult排序 从小到大排序
    //NSLog(@"排序前_selectresult:%@",_selectresult);
    
    NSArray *sortedArray = [_selectresult sortedArrayUsingComparator: ^(id obj1, id obj2) {
        if ([obj1 integerValue] > [obj2 integerValue]) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        if ([obj1 integerValue] < [obj2 integerValue]) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
    
    _selectresult = [NSMutableArray arrayWithArray:sortedArray];
    
    //NSLog(@"排序后_selectresult:%@",sortedArray);
    //整理出删除那些需要覆盖的课程ID(不在这里删除，留给上一级控制器删除)
    for(NSString *toDelete in _selectresult)
    {
        NSArray *courseID = [(NSMutableArray *)_busyTimeCourseID[toDelete.intValue] copy];
        if(courseID.count > 1)
        {
            for(int i = 1;i<courseID.count;i++)//第一个是0,所以i=1
            {
                [_toDeleteID addObject:courseID[i]];
            }
        }
    }
    
    //NSLog(@"_toDeleteID:%@",_toDeleteID);
    
    if([_delegate respondsToSelector:@selector(setCourseTimeArray:andtoDeleteID:inSection:)])
    {
        [_delegate setCourseTimeArray:_selectresult andtoDeleteID:[_toDeleteID allObjects]  inSection:_whichSection.integerValue];
    }
    

    [self timeSelectCancel];
    
}


@end
