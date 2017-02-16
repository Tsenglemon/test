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


#define kScreenWidth [UIApplication sharedApplication].keyWindow.bounds.size.width
#define kScreenHeight [UIApplication sharedApplication].keyWindow.bounds.size.height

#define scaletoheight [UIApplication sharedApplication].keyWindow.bounds.size.height/1334.0
#define scaletowidth [UIApplication sharedApplication].keyWindow.bounds.size.width/750.0
#define fontscale [UIApplication sharedApplication].keyWindow.bounds.size.width/375.0

#define marginX (95-60)/2*scaletowidth
#define marginY 14*scaletoheight
#define weeknumwidth 60*scaletowidth

@interface timeselecteview()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,weak) UIView* titleview;
@property (nonatomic,weak) UITableView *timetable;
@property (nonatomic,strong) NSArray *timeData;

@end

@implementation timeselecteview


-(instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        
        NSArray *timeData = @[@[@"早间"],@[@"8:00",@"1"],@[@"8:55",@"2"],@[@"10:00",@"3"],@[@"10:55",@"4"],@[@"午间"],@[@"14:30",@"5"],@[@"15:25",@"6"],@[@"16:20",@"7"],@[@"17:15",@"8"],@[@"19:00",@"9"],@[@"19:55",@"10"],@[@"20:50",@"11"],@[@"21:45",@"12"],@[@"晚间"]];
        _timeData = timeData;
        
        NSMutableArray *selectresult = [NSMutableArray array];
        
        for(int i = 0; i<_timeData.count; i++)
        {
            [selectresult addObject:@"0"];
        }
        _selectresult = selectresult;
        
        
        self.layer.cornerRadius = 10;
        self.clipsToBounds = YES;
        self.backgroundColor = [Utils colorWithHexString:@"#FFFFFF"];
        
        
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
        _today.text = @"星期几";
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

        
        
    }
    return self;
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
        [cell.select addTarget:self action:@selector(choose:) forControlEvents:UIControlEventTouchUpInside];
       
    }
    NSArray *time = _timeData[indexPath.row];
    cell.time.text = nil;
    cell.number.text = nil;
    cell.timenode.text = nil;
    if(time.count > 1){
        cell.time.text = time[0];
        cell.number.text = time[1];
    }
    else{
        cell.timenode.text = time[0];
    }
    
    if([_selectresult[indexPath.row]  isEqual: @"0"])
        cell.select.selected = 0;
    else cell.select.selected = 1;
    
    return cell;

}


-(void)choose:(id)sender
{
    UIButton *chosenbtn = (UIButton *)sender;
    chosenbtn.selected = !chosenbtn.selected;
    
    timeselecttableviewcell *clickcell = (timeselecttableviewcell *)[chosenbtn superview];
    NSIndexPath *clickindex = [_timetable indexPathForCell: clickcell];
    if(chosenbtn.isSelected)
        [_selectresult replaceObjectAtIndex:clickindex.row withObject:@"1"];
    else [_selectresult replaceObjectAtIndex:clickindex.row withObject:@"0"];
    
    //NSLog(@"%@",_selectresult);
    
    
}


@end
