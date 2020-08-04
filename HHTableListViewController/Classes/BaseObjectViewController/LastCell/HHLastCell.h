//
//  HHLastCell.h
//
//  Created by apple on 16/5/4.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HHEmptyView.h"
#define TableLastCellHeight             44.0
#define ErrorViewHeight                 300.0

typedef NS_ENUM(NSUInteger, LastCellStatus) {
    LastCellStatusNotVisible,
    LastCellStatusMore,
    LastCellStatusLoading,
    LastCellStatusError,
    LastCellStatusFinished,
    LastCellStatusEmpty,
};

@interface HHLastCell : UIView

@property (nonatomic, strong)HHEmptyView *emptyView;

@property (readonly, nonatomic, assign)BOOL shouldResponseToTouch;

@property (nonatomic, strong)UILabel *textLabel;
@property (nonatomic, assign)LastCellStatus status;

@property (nonatomic, copy)NSString *moreMessage;
@property (nonatomic, copy)NSString *errorMessage;
@property (nonatomic, copy)NSString *finishedMessage;
@property (nonatomic, copy)NSString *emptyMessage;

@end
