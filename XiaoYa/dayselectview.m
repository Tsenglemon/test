//
//  dayselectview.m
//  XiaoYa
//
//  Created by 曾凌峰 on 2016/11/30.
//  Copyright © 2016年 commet. All rights reserved.
//

#import "dayselectview.h"
#import "Utils.h"
#import "Masonry.h"
#import "DaySelectCell.h"

#define scaletoheight [UIApplication sharedApplication].keyWindow.bounds.size.height/1334.0
#define scaletowidth [UIApplication sharedApplication].keyWindow.bounds.size.width/750.0
#define fontscale [UIApplication sharedApplication].keyWindow.bounds.size.width/375.0

@interface dayselectview()<UITableViewDelegate,UITableViewDataSource,DaySelectCellDelegate>
@property (nonatomic,weak) UIButton *cancel_btn;
@property (nonatomic,weak) UIButton *confirm_btn;
@property (nonatomic,weak) UITableView *dayselect_tableview;
@property (nonatomic,strong) NSArray *itemData;//单元格文字内容
@property (nonatomic ,assign) NSInteger lastIndex;//上一个选中的行Index
@property (nonatomic,assign) NSInteger whichSection;
@end

@implementation dayselectview
- (instancetype)initWithFrame:(CGRect)frame andDayString:(NSString *)dayString indexSection:(NSInteger)section
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 10.0;
        self.layer.masksToBounds = YES;
        
        self.itemData = @[@"星期一",@"星期二",@"星期三",@"星期四",@"星期五",@"星期六",@"星期日"];
        self.lastIndex = dayString.integerValue;
        _whichSection = section;
        [self commonInit];
    }
    return self;
}

-(void)commonInit{
    UITableView *dayselect_tableview = [[UITableView alloc] init];
    _dayselect_tableview = dayselect_tableview;
    _dayselect_tableview.dataSource = self;
    _dayselect_tableview.delegate = self;
    _dayselect_tableview.bounces = NO;
    _dayselect_tableview.separatorStyle=UITableViewCellSeparatorStyleNone;
    [self addSubview:_dayselect_tableview];
    __weak typeof(self) weakself=self;
    [_dayselect_tableview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakself.mas_centerX);
        make.top.equalTo(weakself.mas_top);
        make.width.mas_equalTo(530.0*scaletowidth);
        make.height.mas_equalTo((80.0*7)*scaletoheight);
    }];

    UIView *line = [[UIView alloc] init];
    line.backgroundColor = [Utils colorWithHexString:@"#D9D9D9"];
    [self addSubview: line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(1);
        make.height.mas_equalTo(76*scaletoheight);
        make.centerX.equalTo(weakself.mas_centerX);
        make.bottom.equalTo(weakself.mas_bottom);
    }];
    
    UIButton *cancel_btn = [[UIButton alloc] init];
    _cancel_btn = cancel_btn;
    [_cancel_btn setTitle:@"取消" forState:UIControlStateNormal];
    [_cancel_btn setTitleColor:[Utils colorWithHexString:@"#00A7FA"] forState:UIControlStateNormal];
    _cancel_btn.titleLabel.font = [UIFont systemFontOfSize:13*fontscale];
    [self addSubview:_cancel_btn];
    [_cancel_btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(76.0*scaletoheight);
        make.width.mas_equalTo(weakself.frame.size.width/2);
        make.right.equalTo(line.mas_left);
        make.bottom.equalTo(weakself.mas_bottom);
    }];    
    
    UIButton *confirm_btn = [[UIButton alloc] init];
    _confirm_btn=confirm_btn;
    [_confirm_btn setTitle:@"确认" forState:UIControlStateNormal];
    [_confirm_btn setTitleColor:[Utils colorWithHexString:@"#00A7FA"] forState:UIControlStateNormal];
    _confirm_btn.titleLabel.font = [UIFont systemFontOfSize:13*fontscale];
    [self addSubview:_confirm_btn];
    [_confirm_btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(76.0*scaletoheight);
        make.width.mas_equalTo(weakself.frame.size.width/2);
        make.left.equalTo(line.mas_right);
        make.bottom.equalTo(weakself.mas_bottom);
    }];
    [_cancel_btn addTarget:self action:@selector(dayselectcancel) forControlEvents:UIControlEventTouchUpInside];
    [_confirm_btn addTarget:self action:@selector(dayselectconfirm) forControlEvents:UIControlEventTouchUpInside];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _itemData.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DaySelectCell *cell = [DaySelectCell DaySelectCellWithTableView:tableView];
    cell.model = self.itemData[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row == self.lastIndex) {
        cell.choiceBtn.selected = YES;
    }
    cell.delegate = self;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80.0*scaletoheight;
}

- (void)DaySelectCell:(DaySelectCell *)cell selectIndex:(NSIndexPath *)indexPath{
    NSUInteger newIndex[] = {0, self.lastIndex};
    NSIndexPath *newPath = [[NSIndexPath alloc] initWithIndexes:newIndex length:2];
    DaySelectCell *lastCell = [self.dayselect_tableview cellForRowAtIndexPath:newPath];
    lastCell.choiceBtn.selected = NO;
    self.lastIndex = indexPath.row;
}

-(void)dayselectcancel{
    [self.delegate daySelectCancelAction:self];
    [self removeFromSuperview];
}

-(void)dayselectconfirm{
    [self removeFromSuperview];
    [self.delegate daySelectComfirmAction:self selectedIndex:self.lastIndex inSection:self.whichSection];
}

@end
