//
//  HHEmptyView.h
//  HHTableListViewController
//
//  Created by 崔辉辉 on 2020/5/15.
//  Copyright © 2020 huihui. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HHEmptyView : UIView

@property (nonatomic, strong)UIImageView *imageView;
@property (nonatomic, strong)UILabel *textLabel;
@property (nonatomic, strong)UIButton *actionButton;


@property (nonatomic, strong)UIImage *image;
@property (nonatomic, copy)NSString *message;

- (instancetype)initWithFrame:(CGRect)frame image:(UIImage *)image andMessage:(NSString *)text;

@property (nonatomic, strong)UIView *customView;

@property (nonatomic, copy)void (^clickButtonAction)(void);

@end

NS_ASSUME_NONNULL_END
