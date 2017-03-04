//
//  timeselecteview.h
//  XiaoYa
//
//  Created by 曾凌峰 on 2017/1/19.
//  Copyright © 2017年 commet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CourseTimeCellModel.h"

@protocol timeselectViewDelegate <NSObject>

-(void)setCourseTimeArray:(NSMutableArray *)courseTimeArray andtoDeleteID:(NSArray*) toDeleteID inSection:(NSInteger )section;
-(void)removeCover;

@end

@interface timeselecteview : UIView

@property (nonatomic,strong) NSMutableArray *dayselected_array;
@property (nonatomic,weak) UIButton *cancel_btn;
@property (nonatomic,weak) UIButton *confirm_btn;
@property (nonatomic,weak) UILabel *today;
@property (nonatomic,strong) NSMutableArray *selectresult;
@property (nonatomic,strong) NSString *whichSection;

@property (nonatomic,strong) NSMutableSet *toDeleteID;//整理的要删除的课程ID,避免重复用set

@property (nonatomic,weak) id delegate;

-(instancetype)initWithFrame:(CGRect)frame andCellModel:(CourseTimeCellModel *)cellMoedl;


@end
