//
//  CourseViewController.h
//  XiaoYa
//
//  Created by commet on 16/11/27.
//  Copyright © 2016年 commet. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CourseViewController;
@protocol CourseViewControllerDelegate <NSObject>
//刷新主界面
- (void)CourseViewControllerConfirm:(CourseViewController*)viewController;
@end

@interface CourseViewController : UIViewController
@property (nonatomic,weak) id <CourseViewControllerDelegate> delegate;
@property (nonatomic,strong) NSMutableArray *courseview_array;//装coursetime_view里数据的array,里面都是Coursemodel

- (instancetype)initWithCourseModel:(NSMutableArray *)modelArray;
- (void)dataStore;
@end
