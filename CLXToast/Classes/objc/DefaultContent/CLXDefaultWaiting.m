//
//  BSTDefaultWaiting.m
//  businessBase
//
//  Created by chen liangxiu on 2018/2/8.
//  Copyright © 2018年 best.inc. All rights reserved.
//

#import "CLXDefaultWaiting.h"
#import "CLXToast+internal.h"

@interface CLXDefaultWaiting()

@property (nonatomic, assign) UIEdgeInsets _contentInset;
@property (nonatomic, strong) UILabel *_promptLabel;
@property (nonatomic, strong) UIActivityIndicatorView *_activityIndicator;
@property (nonatomic, assign) CGFloat _interItemSpacing;

@end

@implementation CLXDefaultWaiting
@synthesize _contentInset = _contentInset;
@synthesize _promptLabel = _promptLabel;
@synthesize _activityIndicator = _activityIndicator;
@synthesize _interItemSpacing = _interItemSpacing;

- (instancetype)init {
    return [self initWith:ToastWaiting];
}

- (instancetype)initWith:(ToastStyle)style {
    self = [super initWith:style];
    if (self) {
        _interItemSpacing = 4.f;
        _contentInset = UIEdgeInsetsMake(8.f, 8.f, 8.f, 8.f);
    }
    return self;
}
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wimplicit-retain-self"
- (CLXDefaultWaiting *(^)(UIEdgeInsets))contentInset {
    return ^CLXDefaultWaiting *(UIEdgeInsets inset){
        _contentInset = inset;
        return self;
    };
}

- (CLXDefaultWaiting *(^)(NSString *))prompt {
    return ^CLXDefaultWaiting *(NSString *prompt) {
        if (_promptLabel == nil) {
            _promptLabel = [UILabel new];
            _promptLabel.textColor = [UIColor whiteColor];
            _promptLabel.font = [UIFont systemFontOfSize:15.0];
            _promptLabel.preferredMaxLayoutWidth = [UIScreen mainScreen].bounds.size.width * 0.8;
            _promptLabel.numberOfLines = 0;
        }
        _promptLabel.text = prompt;
        if (self.toast && self.toast.myTransaction.isExecuting) {
            [self.toast setNeedsUpdateConstraints];
        }
        return self;
    };
}

- (CLXDefaultWaiting *(^)(UILabel *))promptLabel {
    return ^CLXDefaultWaiting *(UILabel *promptLabel) {
        _promptLabel = promptLabel;
        return self;
    };
}

- (CLXDefaultWaiting *(^)(UIActivityIndicatorView *))activityView {
    return ^CLXDefaultWaiting *(UIActivityIndicatorView *activity) {
        _activityIndicator = activity;
        return self;
    };
}

- (CLXDefaultWaiting *(^)(CGFloat))interItemSpacing {
    return ^CLXDefaultWaiting *(CGFloat space) {
        _interItemSpacing = MAX(space, 0.f);
        return self;
    };
}
#pragma clang diagnostic pop

#pragma mark -overrided methods
- (void)addSubviewsTo:(UIView *)contentView {
    if (_activityIndicator == nil) {
        _activityIndicator = [UIActivityIndicatorView new];
        _activityIndicator.hidesWhenStopped = NO;
    }
    if (_activityIndicator.superview != contentView) {
        [contentView addSubview:_activityIndicator];
    }
    [_activityIndicator startAnimating];
    if (_promptLabel && _promptLabel.superview != contentView) {
        [contentView addSubview:_promptLabel];
    }
}

- (void)layoutSubviewsAt:(UIView *)contentView {
    assert(_activityIndicator);
    _activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;

    BOOL empty = _promptLabel == nil;

    NSLayoutConstraint *activityCenterX = [NSLayoutConstraint constraintWithItem:_activityIndicator attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];

    NSLayoutConstraint *activityCenterY = [NSLayoutConstraint constraintWithItem:_activityIndicator attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];

    NSLayoutConstraint *activityLeading = [NSLayoutConstraint constraintWithItem:_activityIndicator attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:contentView attribute:NSLayoutAttributeLeading multiplier:1 constant:_contentInset.left];

    NSLayoutConstraint *activityTop = [NSLayoutConstraint constraintWithItem:_activityIndicator attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:contentView attribute:NSLayoutAttributeTop multiplier:1 constant:_contentInset.top];


    NSLayoutConstraint *activityTrailing = [NSLayoutConstraint constraintWithItem:_activityIndicator attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationLessThanOrEqual toItem:contentView attribute:NSLayoutAttributeTrailing multiplier:1 constant:-(_contentInset.right)];


    NSLayoutConstraint *activityBottom;
    if (empty) {
        NSLayoutConstraint *activityBottom = [NSLayoutConstraint constraintWithItem:_activityIndicator attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationLessThanOrEqual toItem:contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:-(_contentInset.bottom)];

        [contentView addConstraints:@[activityCenterX, activityCenterY, activityLeading, activityTop, activityTrailing, activityBottom]];
        //子控件布局完成
        return;
    } else {
        //需要布局prompt label
        activityBottom = [NSLayoutConstraint constraintWithItem:_activityIndicator attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeCenterY multiplier:1 constant:-(_interItemSpacing / 2.f)];

        [contentView addConstraints:@[activityCenterX, activityLeading, activityTop, activityTrailing, activityBottom]];
    }

    //布局promptLabel
    _promptLabel.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *promptCenterX = [NSLayoutConstraint constraintWithItem:_promptLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];

    NSLayoutConstraint *promptLeading = [NSLayoutConstraint constraintWithItem:_promptLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:contentView attribute:NSLayoutAttributeLeading multiplier:1 constant:_contentInset.left];

    NSLayoutConstraint *promptTop = [NSLayoutConstraint constraintWithItem:_promptLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeCenterY multiplier:1 constant:_interItemSpacing / 2.0];

    NSLayoutConstraint *promptTrailing = [NSLayoutConstraint constraintWithItem:_promptLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationLessThanOrEqual toItem:contentView attribute:NSLayoutAttributeTrailing multiplier:1 constant:-_contentInset.right];


    NSLayoutConstraint *promptBottom = [NSLayoutConstraint constraintWithItem:_promptLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationLessThanOrEqual toItem:contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:-_contentInset.bottom];

    [contentView addConstraints:@[promptCenterX, promptLeading, promptTop, promptTrailing, promptBottom]];
}

#pragma mark - show methods
- (CLXToast *(^)(void))show {
    return self.toast.show;
}

- (CLXToast *(^)(NSTimeInterval, BOOL, void (^)(void)))showWith {
    return self.toast.showWith;
}

- (CLXToast *(^)(UIView *, void (^)(CLXToast *), BOOL, NSTimeInterval, void (^)(void)))showIn {
    return self.toast.showIn;
}

@end
