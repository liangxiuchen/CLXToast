//
//  BSTHudActivityContent.m
//  base
//
//  Created by kunpo on 2018/3/7.
//  Copyright © 2018年 best.inc. All rights reserved.
//

#import "CLXHudActivityContent.h"

@interface CLXHudActivityContent ()

@property (nonatomic, strong) UIActivityIndicatorView *activityView;

@end

@implementation CLXHudActivityContent

- (instancetype)init {
    self = [super initWith:ToastCustomHud];
    if (self) {
        self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [self.activityView startAnimating];
    }
    return self;
}


- (void)addSubviewsTo:(UIView *)contentView {
    [contentView addSubview:self.activityView];
}

- (void)layoutSubviewsAt:(UIView *)contentView {
    self.activityView.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:self.activityView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:self.activityView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:80];
    NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:60];
    [contentView addConstraints:@[width, height,centerX, centerY]];
}

@end

