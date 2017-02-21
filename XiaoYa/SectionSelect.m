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

#define kScreenWidth [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height
@interface SectionSelect()<UITableViewDelegate,UITableViewDataSource,SectionSelectTableViewCellDelegate>
@property (nonatomic , weak) UIButton *confirm;
@property (nonatomic , weak) UIButton *cancel;
@property (nonatomic , weak) UILabel *weekdayLab;
@property (nonatomic , weak) UILabel *dateLab;
@property (nonatomic , weak) UITableView *multipleChoiceTable;

@property (nonatomic ,strong) NSArray *timeData;//左侧时间数据
@property (strong, nonatomic) NSMutableArray *selectIndexs;//多选选中的行
@property (nonatomic ,strong) NSDate *selectedDate;
@end

@implementation SectionSelect
- (instancetype)initWithFrame:(CGRect)frame sectionArr:(NSMutableArray* )sectionArray selectedDate:(NSDate*)date
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 10.0;
        self.layer.masksToBounds = YES;
        
        self.timeData = @[@[@"早间",@""],@[@"8:00",@"1"],@[@"8:55",@"2"],@[@"10:00",@"3"],@[@"10:55",@"4"],@[@"午间",@""],@[@"14:30",@"5"],@[@"15:25",@"6"],@[@"16:20",@"7"],@[@"17:15",@"8"],@[@"19:00",@"9"],@[@"19:55",@"10"],@[@"20:50",@"11"],@[@"21:45",@"12"],@[@"晚间",@""]];
        _selectIndexs = sectionArray;
        _selectedDate = date;
//        _currentDate = currentDate;
//        NSCalendar *gregorian = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
//        self.curDateComp = [gregorian components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:currentDate];
//        _year = self.curDateComp.year;
//        _month = self.curDateComp.month;
        
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
    if ([_selectIndexs containsObject:[NSString stringWithFormat:@"%ld",indexPath.row]]) {
        [cell.mutipleChoice setSelected:YES];
    }else{
        [cell.mutipleChoice setSelected:NO];
    }
    return cell;
}

#pragma mark SectionSelectTableViewCellDelegate
- (void)SectionSelectTableViewCell:(SectionSelectTableViewCell *)cell selectIndex:(NSIndexPath *)indexPath{
    [self.selectIndexs addObject:[NSString stringWithFormat:@"%ld",indexPath.row]];
}

- (void)SectionSelectTableViewCell:(SectionSelectTableViewCell *)cell deSelectIndex:(NSIndexPath *)indexPath{
    [self.selectIndexs removeObject:[NSString stringWithFormat:@"%ld",indexPath.row]];
}

//确定
- (void)confirmAction{
    [self removeFromSuperview];
    [self.delegate SectionSelectComfirmAction:self sectionArr:self.selectIndexs];
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

@end
