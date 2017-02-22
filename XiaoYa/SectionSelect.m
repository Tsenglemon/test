//
//  SectionSelect.m
//  XiaoYa
//
//  Created by commet on 16/11/28.
//  Copyright © 2016年 commet. All rights reserved.
//时间段（节）选择器

#import "SectionSelect.h"
#import "SectionSelectTableViewCell.h"
#import "NSDate+Calendar.h"
#import "DbManager.h"
#import "BusinessModel.h"

#define kScreenWidth [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height
@interface SectionSelect()<UITableViewDelegate,UITableViewDataSource,SectionSelectTableViewCellDelegate>
@property (nonatomic , weak) UIButton *confirm;
@property (nonatomic , weak) UIButton *cancel;
@property (nonatomic , weak) UILabel *weekdayLab;
@property (nonatomic , weak) UILabel *dateLab;
@property (nonatomic , weak) UITableView *multipleChoiceTable;

@property (nonatomic ,strong) NSMutableArray *timeData;//时间数据
@property (strong, nonatomic) NSMutableArray *selectIndexs;//多选选中的行
@property (nonatomic ,strong) NSDate *selectedDate;//现在选择的日期
@property (nonatomic ,strong) NSMutableArray *originIndexs;//原选中的行
@property (nonatomic ,strong) NSDate *originDate;//原日期
@end

@implementation SectionSelect
- (instancetype)initWithFrame:(CGRect)frame sectionArr:(NSMutableArray* )sectionArray selectedDate:(NSDate*)date originIndexs:(NSMutableArray*)originIndexs originDate:(NSDate* )originDate
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 10.0;
        self.layer.masksToBounds = YES;
        
        //timeData数组的说明：元素1：“时间段”，元素2“第几节”，元素三“事务描述”或“课程信息”（为空代表没课程也没事务），元素四“是否有事务”
        [self timeDataInit];
        _selectIndexs = [sectionArray mutableCopy];
        _selectedDate = date;
        _originDate = originDate;
        _originIndexs = [originIndexs mutableCopy];

        NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyyMMdd"];
        NSString *dateString = [dateFormatter stringFromDate:_selectedDate];

        DbManager *dbManger = [DbManager shareInstance];
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM t_201601 WHERE date = '%@';",dateString];
        NSArray *dataQuery = [dbManger executeQuery:sql];
        if (dataQuery.count > 0) {
            for (int j = 0; j < dataQuery.count ; j++) {
                NSMutableDictionary *businessDict = [NSMutableDictionary dictionaryWithDictionary:dataQuery[j]];
                BusinessModel *busModel = [[BusinessModel alloc] initWithDict:businessDict];//转数据模型
                for (int k = 0; k < busModel.timeArray.count; k ++) {
                    int index = [busModel.timeArray[k] intValue];
                    [self.timeData[index] addObject:busModel.desc];//元素三
                    [self.timeData[index] addObject:@1];//元素四
                }
            }
        }
        
        [self commonInit];
    }
    return self;
}

- (void)commonInit{
    UIButton *confirm = [[UIButton alloc]init];
    _confirm = confirm;
    [_confirm setTitle:@"确认" forState:UIControlStateNormal];
    [_confirm setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _confirm.titleLabel.font = [UIFont systemFontOfSize:13.0];
    _confirm.backgroundColor = [UIColor colorWithRed:57/255.0 green:185/255.0 blue:248/255.0 alpha:1.0];//39b9f8
    _confirm.layer.cornerRadius = 10.0;
    [_confirm addTarget:self action:@selector(confirmAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_confirm];
    
    UIButton *cancel = [[UIButton alloc]init];
    _cancel = cancel;
    [_cancel setTitle:@"取消" forState:UIControlStateNormal];
    [_cancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _cancel.titleLabel.font = [UIFont systemFontOfSize:13.0];
    _cancel.backgroundColor = [UIColor colorWithRed:57/255.0 green:185/255.0 blue:248/255.0 alpha:1.0];//39b9f8
    _cancel.layer.cornerRadius = 10.0;
    [_cancel addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_cancel];
    
    NSString *daystr = [self.selectedDate dayOfCHNWeek];
    UILabel *weekdayLab = [[UILabel alloc]init];
    _weekdayLab = weekdayLab;
    _weekdayLab.textAlignment = NSTextAlignmentCenter;
    _weekdayLab.text = [NSString stringWithFormat:@"星期%@",daystr];
    _weekdayLab.textColor = [UIColor whiteColor];
    _weekdayLab.font = [UIFont systemFontOfSize:30.0];
    [self addSubview:_weekdayLab];
    
    NSCalendar *gregorian = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *curDateComp = [gregorian components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:self.selectedDate];
    NSInteger month = curDateComp.month;
    NSInteger day = curDateComp.day;
    UILabel *dateLab = [[UILabel alloc]init];
    _dateLab = dateLab;
    _dateLab.textAlignment = NSTextAlignmentCenter;
    _dateLab.text = [NSString stringWithFormat:@"%ld月%ld号",month,day];
    _dateLab.textColor = [UIColor whiteColor];
    _dateLab.font = [UIFont systemFontOfSize:18.0];
    [self addSubview:_dateLab];
    
    //单元格固定高度39；5行
    UITableView *multipleChoiceTable = [[UITableView alloc]init];
    _multipleChoiceTable = multipleChoiceTable;
    _multipleChoiceTable.delegate = self;
    _multipleChoiceTable.dataSource = self;
    _multipleChoiceTable.separatorStyle = UITableViewCellSeparatorStyleNone;//去掉原生分割线
    [self addSubview:_multipleChoiceTable];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 39;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.timeData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SectionSelectTableViewCell *cell = [SectionSelectTableViewCell SectionCellWithTableView:tableView];
    cell.model = self.timeData[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    if ([_selectIndexs containsObject:[NSString stringWithFormat:@"%ld",indexPath.row]]) {//是否是现选择的行？
        [cell.mutipleChoice setSelected:YES];
        if ([self.timeData[indexPath.row] count] == 4) {
            cell.conflict.hidden = NO;
        }else{
            cell.conflict.hidden = YES;
        }
        NSCalendar *gregorian = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *comp1 = [gregorian components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:self.selectedDate];
        NSDateComponents *comp2 = [gregorian components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:self.originDate];
        if (comp1.year == comp2.year && comp1.month == comp2.month && comp1.day == comp2.day) {//没有更改过日期(1.直接改节，2.先改日期，再改节，再改回原来的日期)
            if ([_originIndexs containsObject:[NSString stringWithFormat:@"%ld",indexPath.row]]){
                cell.conflict.hidden = YES;
            }
        }
    }else{
        [cell.mutipleChoice setSelected:NO];
        cell.conflict.hidden = YES;
    }
    return cell;
}

#pragma mark SectionSelectTableViewCellDelegate
- (void)SectionSelectTableViewCell:(SectionSelectTableViewCell *)cell selectIndex:(NSIndexPath *)indexPath{
    [self.selectIndexs addObject:[NSString stringWithFormat:@"%ld",indexPath.row]];
    
    if ([self.timeData[indexPath.row] count] == 4) {
        cell.conflict.hidden = NO;
    }else{
        cell.conflict.hidden = YES;
    }
    NSCalendar *gregorian = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comp1 = [gregorian components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:self.selectedDate];
    NSDateComponents *comp2 = [gregorian components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:self.originDate];
    if (comp1.year == comp2.year && comp1.month == comp2.month && comp1.day == comp2.day) {//没有更改过日期(1.直接改节，2.先改日期，再改节，再改回原来的日期)
        if ([_originIndexs containsObject:[NSString stringWithFormat:@"%ld",indexPath.row]]){
            cell.conflict.hidden = YES;
        }
    }
}

- (void)SectionSelectTableViewCell:(SectionSelectTableViewCell *)cell deSelectIndex:(NSIndexPath *)indexPath{
    [self.selectIndexs removeObject:[NSString stringWithFormat:@"%ld",indexPath.row]];
}

//确定
- (void)confirmAction{
    [self removeFromSuperview];
    //现selectedindex-原originindex-(timedata.count!=4) = 标记覆盖的index,即现selectindex中不是origin又是有事务的
    NSMutableArray *coverIndexs = [NSMutableArray array];
    for (int i = 0 ; i < self.selectIndexs.count; i++) {
        //有事务                                                                      不是origin
        if ([self.timeData[[self.selectIndexs[i] intValue]] count] == 4 && [_originIndexs containsObject:self.selectIndexs[i]] == NO) {
            [coverIndexs addObject:self.selectIndexs[i]];
        }
    }
    [self.delegate SectionSelectComfirmAction:self sectionArr:self.selectIndexs coverIndexs:coverIndexs];
}

//取消,移除视图，什么也不做
- (void)cancelAction{
    [self removeFromSuperview];
    [self.delegate SectionSelectCancelAction:self];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    _confirm.frame = CGRectMake(0, 0, 180 / 750.0 * kScreenWidth, 78 / 1334.0 * kScreenHeight);
    CGPoint center =  _confirm.center;
    center.x = self.frame.size.width/2 + 60;
    center.y = self.frame.size.height - 130 / 1334.0 * kScreenHeight * 0.5;
    _confirm.center = center;
    
    _cancel.frame = CGRectMake(0, 0, 180 / 750.0 * kScreenWidth, 78 / 1334.0 * kScreenHeight);
    center =  _cancel.center;
    center.x = self.frame.size.width/2 - 60;
    center.y = self.frame.size.height - 130 / 1334.0 * kScreenHeight * 0.5;
    _cancel.center = center;
    
    _weekdayLab.frame = CGRectMake(0, 60/1334.0 *kScreenHeight + 18 , 150, 30);
    center =  _weekdayLab.center;
    center.x = self.frame.size.width/2;
    _weekdayLab.center = center;
    
    _dateLab.frame = CGRectMake(0, 40/1334.0 *kScreenHeight, 150, 18);
    center =  _dateLab.center;
    center.x = self.frame.size.width/2;
    _dateLab.center = center;
    
    _multipleChoiceTable.frame = CGRectMake(0, 178 / 1334.0 * kScreenHeight, self.frame.size.width, 39 *5);
}

- (void)drawRect:(CGRect)rect{
    CGFloat width = self.frame.size.width;
    CGFloat radius = 10;
    UIBezierPath*path = [UIBezierPath bezierPath];
    [path addArcWithCenter:CGPointMake(radius, radius) radius:radius startAngle:M_PI endAngle:M_PI/2*3 clockwise:1];
    [path moveToPoint:CGPointMake(radius, 0)];
    [path addLineToPoint:CGPointMake(width - radius, 0)];
    [path addArcWithCenter:CGPointMake(width - radius , radius) radius:radius startAngle:M_PI*3/2 endAngle:M_PI*2 clockwise:1];
    [path addLineToPoint:CGPointMake(width, 178 / 750.0 * kScreenWidth)];
    [path addLineToPoint:CGPointMake(0 , 178 / 750.0 * kScreenWidth)];
    [path addLineToPoint:CGPointMake(0, radius)];
    [path closePath];
    UIColor *fillColor = [UIColor colorWithRed:57/255.0 green:185/255.0 blue:248/255.0 alpha:1.0];//39b9f8
    [fillColor set];
    [path fill];
}

- (void)timeDataInit{
    self.timeData = [NSMutableArray arrayWithCapacity:15];
    [self.timeData addObject:[NSMutableArray arrayWithObjects:@"早间",@"", nil]];
    [self.timeData addObject:[NSMutableArray arrayWithObjects:@"8:00",@"1", nil]];
    [self.timeData addObject:[NSMutableArray arrayWithObjects:@"8:55",@"2", nil]];
    [self.timeData addObject:[NSMutableArray arrayWithObjects:@"10:00",@"3", nil]];
    [self.timeData addObject:[NSMutableArray arrayWithObjects:@"10:55",@"4", nil]];
    [self.timeData addObject:[NSMutableArray arrayWithObjects:@"午间",@"", nil]];
    [self.timeData addObject:[NSMutableArray arrayWithObjects:@"14:30",@"5", nil]];
    [self.timeData addObject:[NSMutableArray arrayWithObjects:@"15:25",@"6", nil]];
    [self.timeData addObject:[NSMutableArray arrayWithObjects:@"16:20",@"7", nil]];
    [self.timeData addObject:[NSMutableArray arrayWithObjects:@"17:15",@"8", nil]];
    [self.timeData addObject:[NSMutableArray arrayWithObjects:@"19:00",@"9", nil]];
    [self.timeData addObject:[NSMutableArray arrayWithObjects:@"19:55",@"10", nil]];
    [self.timeData addObject:[NSMutableArray arrayWithObjects:@"20:50",@"11", nil]];
    [self.timeData addObject:[NSMutableArray arrayWithObjects:@"21:45",@"12", nil]];
    [self.timeData addObject:[NSMutableArray arrayWithObjects:@"晚间",@"", nil]];
}

@end
