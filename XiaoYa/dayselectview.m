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


#define kScreenWidth [UIApplication sharedApplication].keyWindow.bounds.size.width
#define kScreenHeight [UIApplication sharedApplication].keyWindow.bounds.size.height

#define scaletoheight [UIApplication sharedApplication].keyWindow.bounds.size.height/1334.0
#define scaletowidth [UIApplication sharedApplication].keyWindow.bounds.size.width/750.0
#define fontscale [UIApplication sharedApplication].keyWindow.bounds.size.width/375.0

#define marginX (95-60)/2*scaletowidth
#define marginY 14*scaletoheight
#define weeknumwidth 60*scaletowidth

@interface dayselectview()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) NSArray *itemData;
@property (nonatomic,weak) UITableView *dayselect_tableview;

@end

@implementation dayselectview
{
    NSMutableArray *choicebtn_aray;
}


- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 10.0;
        self.layer.masksToBounds = YES;
        
        self.itemData = @[@"星期一",@"星期二",@"星期三",@"星期四",@"星期五",@"星期六",@"星期日"];
        choicebtn_aray = [[NSMutableArray alloc] init];
        [self settableview];
        [self setconfirmcancelbtn];
    
    }
    return self;
}


-(void)settableview{
    UITableView *dayselect_tableview = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _dayselect_tableview=dayselect_tableview;
    _dayselect_tableview.dataSource=self;
    _dayselect_tableview.delegate=self;
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

}

-(void)setconfirmcancelbtn
{
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = [Utils colorWithHexString:@"#D9D9D9"];
    [self addSubview: line];
    __weak typeof(self) weakself=self;
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(1);
        make.height.mas_equalTo(76*scaletoheight);
        make.centerX.equalTo(weakself.mas_centerX);
        make.bottom.equalTo(weakself.mas_bottom);
    }];
    
    
    UIButton *cancel_btn = [[UIButton alloc] init];
    _cancel_btn=cancel_btn;
    [_cancel_btn setTitle:@"取消" forState:UIControlStateNormal];
    [_cancel_btn setTitleColor:[Utils colorWithHexString:@"#00A7FA"] forState:UIControlStateNormal];
    [_cancel_btn setTitleColor:[Utils colorWithHexString:@"#D9D9D9"] forState:UIControlStateHighlighted];
    _cancel_btn.titleLabel.font = [UIFont systemFontOfSize:13*fontscale];
    [self addSubview:_cancel_btn];
    //CGFloat masX1 = self.bounds.size.width/4;
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
    [_confirm_btn setTitleColor:[Utils colorWithHexString:@"#D9D9D9"] forState:UIControlStateHighlighted];
    _confirm_btn.titleLabel.font = [UIFont systemFontOfSize:13*fontscale];
    [self addSubview:_confirm_btn];
    //CGFloat masX1 = self.bounds.size.width/4;
    [_confirm_btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(76.0*scaletoheight);
        make.width.mas_equalTo(weakself.frame.size.width/2);
        make.left.equalTo(line.mas_right);
        make.bottom.equalTo(weakself.mas_bottom);
    }];

    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _itemData.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"dayselectcell";
    PublicTemplateCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if(cell == nil)
    {
        cell=[[PublicTemplateCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        [choicebtn_aray addObject:cell.choiceBtn];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        [cell.choiceBtn addTarget:self action:@selector(choice_click:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    cell.model = _itemData[indexPath.row];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 80.0*scaletoheight;
    return height;
}

-(void)choice_click:(id)sender
{
    for(id item in choicebtn_aray)
    {
        UIButton *choice_btn = (UIButton *)item;
        choice_btn.selected = NO;
    }
    UIButton *selected_btn = (UIButton *)sender;
    selected_btn.selected=YES;
    PublicTemplateCell *cellfrom = (PublicTemplateCell *)[[selected_btn superview] superview];
    NSLog(@"%@",cellfrom);
    NSIndexPath *index = [_dayselect_tableview indexPathForCell:cellfrom];
    _dayselected = _itemData[index.row];
}

@end
