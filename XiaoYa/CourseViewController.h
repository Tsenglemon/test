//
//  CourseViewController.h
//  XiaoYa
//
//  Created by commet on 16/11/27.
//  Copyright © 2016年 commet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CourseModel.h"
#import "CourseTimeCell.h"

@interface CourseViewController : UIViewController

-(NSInteger)DataStore;
-(void)setCourseCellModelFromCourseModel:(CourseModel *)courseMDL;
@end
