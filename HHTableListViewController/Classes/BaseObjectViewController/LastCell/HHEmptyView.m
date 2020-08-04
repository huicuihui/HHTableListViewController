//
//  HHEmptyView.m
//  HHTableListViewController
//
//  Created by 崔辉辉 on 2020/5/15.
//  Copyright © 2020 huihui. All rights reserved.
//

#import "HHEmptyView.h"
#import "Masonry.h"

#define ImageSize       100
@interface HHEmptyView()
@end

@implementation HHEmptyView

- (instancetype)initWithFrame:(CGRect)frame image:(UIImage *)image andMessage:(NSString *)text {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        self.imageView.image = image;
        self.textLabel.text = text;
    }
    return self;
}

#pragma mark - setter
- (void)setImage:(UIImage *)image {
    [self.imageView setImage:image];
}

- (void)setMessage:(NSString *)message {
    self.textLabel.text = message;
}

- (void)setCustomView:(UIView *)customView
{
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    customView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [self addSubview:customView];
    _customView = customView;
}

#pragma mark - lazy load
- (UIImageView *)imageView
{
    if (!_imageView) {
        self.imageView = [[UIImageView alloc] init];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.imageView];
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(0);
            make.size.mas_equalTo(CGSizeMake(ImageSize, ImageSize));
        }];
    }
    return _imageView;
}

- (UILabel *)textLabel
{
    if (!_textLabel) {
        self.textLabel = [UILabel new];
        self.textLabel.textColor = [UIColor darkTextColor];
        self.textLabel.font = [UIFont systemFontOfSize:35];
        [self addSubview:self.textLabel];
        [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.imageView.mas_bottom).with.offset(5);
            make.centerX.equalTo(self.imageView);
        }];
    }
    return _textLabel;
}

- (UIButton *)actionButton
{
    if (!_actionButton) {
        self.actionButton = [[UIButton alloc] init];
        self.actionButton.layer.masksToBounds = YES;
        [self addSubview:self.actionButton];
        [self.actionButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.textLabel.mas_bottom).with.offset(5);
            make.centerX.equalTo(self.imageView);
        }];
        [self.actionButton addTarget:self action:@selector(buttomAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _actionButton;
}

- (void)buttomAction
{
    if (self.clickButtonAction) {
        self.clickButtonAction();
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
