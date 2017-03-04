//
//  timeselecttableviewcell.m
//  XiaoYa
//
//  Created by 曾凌峰 on 2017/1/19.
//  Copyright © 2017年 commet. All rights reserved.
//

#import "timeselecttableviewcell.h"
#import "Utils.h"
#import "Masonry.h"

#define kScreenWidth [UIApplication sharedApplication].keyWindow.bounds.size.width
#define kScreenHeight [UIApplication sharedApplication].keyWindow.bounds.size.height

#define scaletoheight [UIApplication sharedApplication].keyWindow.bounds.size.height/1334.0
#define scaletowidth [UIApplication sharedApplication].keyWindow.bounds.size.width/750.0
#define fontscale [UIApplication sharedApplication].keyWindow.bounds.size.width/375.0


@implementation timeselecttableviewcell

-(instancetype)initWithreuseIdentifier:(NSString *)reuseIdentifier
{
    if(self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier])
    {
        self.backgroundColor = [UIColor whiteColor];
        
        UIView *verticalline = [[UIView alloc] init];
        verticalline.backgroundColor = [Utils colorWithHexString:@"#D9D9D9"];
        [self addSubview:verticalline];
        __weak typeof(self) weakself=self;
        [verticalline mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(0.5);
            make.height.mas_equalTo(80*scaletoheight);
            make.left.equalTo(weakself.mas_left).offset(80*scaletowidth);
            make.centerY.equalTo(weakself.mas_centerY);
        }];
        
        UIView *horizonline = [[UIView alloc] init];
        horizonline.backgroundColor = [Utils colorWithHexString:@"#D9D9D9"];
        [self addSubview:horizonline];
        [horizonline mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(weakself.mas_bottom);
            make.left.equalTo(weakself.mas_left);
            make.height.mas_equalTo(0.5);
            make.width.mas_equalTo(586*scaletowidth);
        }];
        
        UILabel *time = [[UILabel alloc] init];
        _time = time;
        [_time setTextColor:[Utils colorWithHexString:@"#999999"]];
        [_time setTextAlignment:NSTextAlignmentCenter];
        [_time setFont:[UIFont systemFontOfSize:10*fontscale]];
        [self addSubview:_time];
        [_time mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.left.mas_equalTo(weakself);
            make.width.mas_equalTo(80*scaletowidth);
            make.height.mas_equalTo(40*scaletoheight);
        }];
        
        
        UILabel *number = [[UILabel alloc] init];
        _number = number;
        [_number setTextColor:[Utils colorWithHexString:@"#4c4c4c"]];
        [_number setTextAlignment:NSTextAlignmentCenter];
        [_number setFont:[UIFont systemFontOfSize:10*fontscale]];
        [self addSubview:_number];
        [_number mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.and.left.mas_equalTo(weakself);
            make.height.mas_equalTo(40*scaletoheight);
            make.width.mas_equalTo(80*scaletowidth);
        }];
        
        UILabel *timenode = [[UILabel alloc]init];
        _timenode = timenode;
        [_timenode setTextColor:[Utils colorWithHexString:@"#999999"]];
        [_timenode setTextAlignment:NSTextAlignmentCenter];
        [_timenode setFont:[UIFont systemFontOfSize:10*fontscale]];
        [self addSubview:_timenode];
        [_timenode mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.bottom.left.equalTo(weakself);
            make.width.mas_equalTo(80*scaletowidth);
        }];
        
        //右边的勾选框
        UIButton *selectBtn = [[UIButton alloc] init];
        _selectBtn = selectBtn;
        [_selectBtn setImage:[UIImage imageNamed:@"未选择节"] forState:UIControlStateNormal];
        [_selectBtn setImage:[UIImage imageNamed:@"选择节"] forState:UIControlStateSelected];
        //[_select addTarget:self action:@selector(choose:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_selectBtn];
        [_selectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(weakself);
            make.right.equalTo(weakself).offset(-20*scaletowidth);
        }];
        
        //中间的描述
        UILabel *comment = [[UILabel alloc] init];
        _comment = comment;
        [_comment setTextColor:[Utils colorWithHexString:@"#333333"]];
        [_comment setTextAlignment:NSTextAlignmentCenter];
        [_comment setFont:[UIFont systemFontOfSize:14*fontscale]];
        [self addSubview:_comment];
        [_comment mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.centerX.equalTo(weakself);
        }];
        
        //提示“将会覆盖原有课程”的警示条
        UIView *overlapAlertView = [[UIView alloc] init];
        _overlapAlertView = overlapAlertView;
        _overlapAlertView.backgroundColor = [Utils colorWithHexString:@"#D9D9D9"];
        [self addSubview:_overlapAlertView];
        [_overlapAlertView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakself);
            make.width.mas_equalTo(507*scaletowidth);
            make.height.mas_equalTo(24*scaletoheight);
            make.left.equalTo(verticalline.mas_right);
        }];
        
        UILabel *alertWord = [[UILabel alloc] init];
        alertWord.text = @"将会覆盖原有课程";
        alertWord.font = [UIFont systemFontOfSize:8*fontscale];
        alertWord.textColor = [Utils colorWithHexString:@"#999999"];
        [_overlapAlertView addSubview:alertWord];
        [alertWord mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.centerY.top.bottom.equalTo(_overlapAlertView);
        }];
        
        UIImageView *excalmatoryMark = [[UIImageView alloc] init];
        [excalmatoryMark setImage:[UIImage imageNamed:@"感叹号"]];
        [_overlapAlertView addSubview:excalmatoryMark];
        [excalmatoryMark mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(alertWord.mas_left).mas_offset(-10*scaletowidth);
            make.centerY.equalTo(alertWord.mas_centerY);
        }];
        
        UIImageView *angle = [[UIImageView alloc] init];
        [angle setImage:[UIImage imageNamed:@"折角"]];
        [_overlapAlertView addSubview:angle];
        [angle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.right.equalTo(_overlapAlertView);
        }];
        
        //默认是隐藏的
        _overlapAlertView.alpha=0;
        
    }
    
    return self;
}


//-(void)choose:(id)sender{
//    UIButton *chosenbtn = (UIButton *)sender;
//    chosenbtn.selected = !chosenbtn.selected;
//    
//    //后期要添加如果当前有课时是否覆盖当前课程的判断
//}

@end
