//
//  BSTDefaultHud.m
//  businessBase
//
//  Created by chen liangxiu on 2018/2/8.
//  Copyright © 2018年 best.inc. All rights reserved.
//

#import "CLXDefaultHud.h"
#import "CLXToast.h"
@interface CLXDefaultHud()

@property (nonatomic, assign) UIEdgeInsets _contentInset;
@property (nonatomic, strong) UILabel *_titleLabel;
@property (nonatomic, strong) UILabel *_subtitleLabel;
@property (nonatomic, strong) UIImageView *_iconView;
@property (nonatomic, assign) CGFloat titlesSpace;
@property (nonatomic, assign) CGFloat titleIconSpace;

@end

@implementation CLXDefaultHud
@synthesize _contentInset = _contentInset;
@synthesize _titleLabel = _titleLabel;
@synthesize _subtitleLabel = _subtitleLabel;
@synthesize _iconView = _iconView;

- (instancetype)init {
    return [self initWith:ToastHud];
}

- (instancetype)initWith:(ToastStyle)style {
    self = [super initWith:style];
    if (self) {
        _titlesSpace = 4.f;
        _titleIconSpace = 4.f;
        _contentInset = UIEdgeInsetsMake(12.f, 12.f, 12.f, 12.f);
    }
    return self;
}
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wimplicit-retain-self"
- (CLXDefaultHud *(^)(UIEdgeInsets))contentInset {
    return ^CLXDefaultHud *(UIEdgeInsets inset){
        _contentInset = inset;
        return self;
    };
}

- (CLXDefaultHud *(^)(NSString *))title {
    return ^CLXDefaultHud *(NSString *title) {
        if (_titleLabel == nil) {
            _titleLabel = [UILabel new];
            _titleLabel.textColor = [UIColor whiteColor];
            _titleLabel.font = [UIFont systemFontOfSize:16.0];
            _titleLabel.preferredMaxLayoutWidth = [UIScreen mainScreen].bounds.size.width * 0.8;
            _titleLabel.numberOfLines = 0;
        }
        _titleLabel.text = title;
        return self;
    };
}

- (CLXDefaultHud *(^)(UILabel *))titleLabel {
    return ^CLXDefaultHud *(UILabel *titleLabel) {
        _titleLabel = titleLabel;
        return self;
    };
}

- (CLXDefaultHud *(^)(NSString *))subtitle {
    return ^CLXDefaultHud *(NSString *subtitle) {
        if (_subtitleLabel == nil) {
            _subtitleLabel = [UILabel new];
            _subtitleLabel.textColor = [UIColor whiteColor];
            _subtitleLabel.font = [UIFont systemFontOfSize:15.0];
            _subtitleLabel.preferredMaxLayoutWidth = [UIScreen mainScreen].bounds.size.width * 0.8;
            _subtitleLabel.numberOfLines = 0;
        }
        _subtitleLabel.text = subtitle;
        return self;
    };
}

- (CLXDefaultHud *(^)(UILabel *))subtitleLabel {
    return ^CLXDefaultHud *(UILabel *subtitleLabel) {
        _subtitleLabel = subtitleLabel;
        return self;
    };
}

- (CLXDefaultHud *(^)(UIImage *))icon {
    return ^CLXDefaultHud *(UIImage *icon) {
        if (_iconView == nil && icon != nil) {
            _iconView = [UIImageView new];
            _iconView.contentMode = UIViewContentModeScaleAspectFit;
        }
        _iconView.image = icon;
        return self;
    };
}

- (CLXDefaultHud *(^)(UIImageView *))iconView {
    return ^CLXDefaultHud *(UIImageView *iconView) {
        _iconView = iconView;
        return self;
    };
}

- (CLXDefaultHud *(^)(CGFloat))interTitlesSpacing {
    return ^CLXDefaultHud *(CGFloat space) {
        _titlesSpace = MAX(0.f, space);
        return self;
    };
}

- (CLXDefaultHud *(^)(CGFloat))interTitlesIconSpacing {
    return ^CLXDefaultHud *(CGFloat space) {
        _titleIconSpace = MAX(0.f, space);
        return self;
    };
}
#pragma clang diagnostic pop

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

#pragma mark -overrided methods
- (void)addSubviewsTo:(UIView *)contentView {
    if (_iconView != nil && _iconView.superview == contentView) {
        [_iconView setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
        [contentView addSubview:_iconView];
    }

    if (_titleLabel != nil && _titleLabel.superview != contentView) {
        [_titleLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
        [contentView addSubview:_titleLabel];
    }

    if (_subtitleLabel != nil && _subtitleLabel.superview != contentView) {
        [_subtitleLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
        [contentView addSubview:_subtitleLabel];
    }
}

- (void)layoutSubviewsAt:(UIView *)contentView {
    BOOL iconEmpty = _iconView == nil;
    BOOL titleEmpty = _titleLabel == nil;
    BOOL subtitleEmpty = _subtitleLabel == nil;
    // only title exist
    if (!titleEmpty && iconEmpty && subtitleEmpty) {
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self constraintOneitemWith:_titleLabel at:contentView];
    }
    //only subtitle exist
    if (!subtitleEmpty && iconEmpty && titleEmpty) {
        _subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self constraintOneitemWith:_subtitleLabel at:contentView];
    }
    //only icon Imageview exist
    if (!iconEmpty && titleEmpty && subtitleEmpty) {
        _iconView.translatesAutoresizingMaskIntoConstraints = NO;
        [self constraintOneitemWith:_iconView at:contentView];
    }
    //only title and subtitle exist
    if (!titleEmpty && !subtitleEmpty && iconEmpty) {
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self constraintTitleWithSubtitleAt:contentView];
        [self constraintSubtitleWithTitleAt:contentView];
    }
    //only icon and tile
    if (!iconEmpty && !titleEmpty && subtitleEmpty) {
        _iconView.translatesAutoresizingMaskIntoConstraints = NO;
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self constraintIconWithLabelAt:contentView];
        [self constraintLabelWithIcon:_titleLabel at:contentView];
    }
    //only icon and subtitle
    if (!iconEmpty && titleEmpty && !subtitleEmpty) {
        _iconView.translatesAutoresizingMaskIntoConstraints = NO;
        _subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self constraintIconWithLabelAt:contentView];
        [self constraintLabelWithIcon:_subtitleLabel at:contentView];
    }
    //icon ,title , subtitle all exist
    if (!iconEmpty && !titleEmpty && !subtitleEmpty) {
        _iconView.translatesAutoresizingMaskIntoConstraints = NO;
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [_subtitleLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
        [_titleLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
        [self constraintAllItemAt:contentView];
    }
}

- (void)constraintOneitemWith:(UIView *)target at: (UIView *)contentView {
    NSLayoutConstraint *leading = [NSLayoutConstraint constraintWithItem:target attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeLeading multiplier:1 constant:_contentInset.left];

    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:target attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeTop multiplier:1 constant:_contentInset.top];

    NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:target attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:-(_contentInset.bottom)];

    NSLayoutConstraint *trailing = [NSLayoutConstraint constraintWithItem:target attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeTrailing multiplier:1 constant:-(_contentInset.right)];
    [contentView addConstraints:@[leading, top, bottom, trailing]];
}

- (void)constraintTitleWithSubtitleAt:(UIView *)contentView {
    NSLayoutConstraint *leading = [NSLayoutConstraint constraintWithItem:_titleLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeLeading multiplier:1 constant:_contentInset.left];

    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:_titleLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeTop multiplier:1 constant:_contentInset.top];

    NSLayoutConstraint *trailing = [NSLayoutConstraint constraintWithItem:_titleLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationLessThanOrEqual toItem:contentView attribute:NSLayoutAttributeTrailing multiplier:1 constant:-(_contentInset.right)];

    [contentView addConstraints:@[leading, top, trailing]];
}

- (void)constraintSubtitleWithTitleAt:(UIView *)contentView {
    NSLayoutConstraint *leading = [NSLayoutConstraint constraintWithItem:_subtitleLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeLeading multiplier:1 constant:_contentInset.left];

    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:_subtitleLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_titleLabel attribute:NSLayoutAttributeBottom multiplier:1 constant:_titlesSpace];

    NSLayoutConstraint *trailing = [NSLayoutConstraint constraintWithItem:_subtitleLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationLessThanOrEqual toItem:contentView attribute:NSLayoutAttributeTrailing multiplier:1 constant:-(_contentInset.right)];

    NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:_subtitleLabel attribute:NSLayoutAttributeLastBaseline relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:-(_contentInset.bottom)];

    [contentView addConstraints:@[leading, top, trailing, bottom]];
}

- (void)constraintIconWithLabelAt:(UIView *)contentView
{
    NSLayoutConstraint *leading = [NSLayoutConstraint constraintWithItem:_iconView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeLeading multiplier:1 constant:_contentInset.left];

    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:_iconView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:contentView attribute:NSLayoutAttributeTop multiplier:1 constant:_contentInset.top];

    NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:_iconView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationLessThanOrEqual toItem:contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:-(_contentInset.bottom)];

    [contentView addConstraints:@[leading, top, bottom]];
}

- (void)constraintLabelWithIcon:(UIView *)label at:(UIView *)contentView {
    NSLayoutConstraint *leading = [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_iconView attribute:NSLayoutAttributeTrailing multiplier:1 constant:_titleIconSpace];

    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:contentView attribute:NSLayoutAttributeTop multiplier:1 constant:_contentInset.top];

    NSLayoutConstraint *trailing = [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeTrailing multiplier:1 constant:-(_contentInset.right)];

    NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationLessThanOrEqual toItem:contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:-(_contentInset.bottom)];

    NSLayoutConstraint *equalCenterY = [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_iconView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];

    [contentView addConstraints: @[leading, top, trailing, bottom, equalCenterY]];
}

- (void)constraintAllItemAt:(UIView *)contentView {
    //prepear
    UIView *wrapper = [self userWrapperForTitlesInAllItemExist];
    [contentView addSubview:wrapper];

    CGSize wrapper_size = [wrapper systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    [_iconView sizeToFit];
    BOOL icon_heigher = _iconView.bounds.size.height > wrapper_size.height;

    //icon
    NSLayoutConstraint *icon_leading = [NSLayoutConstraint constraintWithItem:_iconView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeLeading multiplier:1 constant:_contentInset.left];

    NSLayoutConstraint *icon_top = [NSLayoutConstraint constraintWithItem:_iconView attribute:NSLayoutAttributeTop relatedBy:(icon_heigher ? NSLayoutRelationEqual : NSLayoutRelationGreaterThanOrEqual) toItem:contentView attribute:NSLayoutAttributeTop multiplier:1 constant:_contentInset.top];


    NSLayoutConstraint *icon_bottom = [NSLayoutConstraint constraintWithItem:_iconView attribute:NSLayoutAttributeBottom relatedBy:(icon_heigher ? NSLayoutRelationEqual : NSLayoutRelationLessThanOrEqual) toItem:contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:-(_contentInset.bottom)];


    if (icon_heigher == NO) {
        NSLayoutConstraint *icon_centerY = [NSLayoutConstraint constraintWithItem:_iconView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];

        [contentView addConstraint:icon_centerY];
    }

    [contentView addConstraints:@[icon_leading, icon_top, icon_bottom]];

    NSLayoutConstraint *wrapper_leading = [NSLayoutConstraint constraintWithItem:wrapper attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_iconView attribute:NSLayoutAttributeTrailing multiplier:1 constant:_titleIconSpace];

    NSLayoutConstraint *wrapper_top = [NSLayoutConstraint constraintWithItem:wrapper attribute:NSLayoutAttributeTop relatedBy:(icon_heigher == NO ? NSLayoutRelationEqual : NSLayoutRelationGreaterThanOrEqual) toItem:contentView attribute:NSLayoutAttributeTop multiplier:1 constant:_contentInset.top];

    NSLayoutConstraint *wrapper_trailing = [NSLayoutConstraint constraintWithItem:wrapper attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeTrailing multiplier:1 constant:-(_contentInset.right)];

    NSLayoutConstraint *wrapper_bottom = [NSLayoutConstraint constraintWithItem:wrapper attribute:NSLayoutAttributeBottom relatedBy:(icon_heigher == NO ? NSLayoutRelationEqual : NSLayoutRelationLessThanOrEqual) toItem:contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:-(_contentInset.bottom)];

    [contentView addConstraints:@[wrapper_leading, wrapper_top, wrapper_trailing, wrapper_bottom]];

    if (icon_heigher) {
        NSLayoutConstraint *wrapper_centerY = [NSLayoutConstraint constraintWithItem:wrapper attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];

        [contentView addConstraint:wrapper_centerY];
    } else {
        NSLayoutConstraint *icon_centerY = [NSLayoutConstraint constraintWithItem:_iconView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
        [contentView addConstraint:icon_centerY];
    }
}

- (UIView *)userWrapperForTitlesInAllItemExist {
    //deal with title and subtitle
    UIView *wrapper = [UIView new];
    wrapper.translatesAutoresizingMaskIntoConstraints = NO;
    wrapper.backgroundColor = [UIColor clearColor];
    [wrapper addSubview:_titleLabel];
    [wrapper addSubview:_subtitleLabel];

    //title
    NSLayoutConstraint *title_leading = [NSLayoutConstraint constraintWithItem:_titleLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:wrapper attribute:NSLayoutAttributeLeading multiplier:1 constant:0];

    NSLayoutConstraint *title_top = [NSLayoutConstraint constraintWithItem:_titleLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:wrapper attribute:NSLayoutAttributeTop multiplier:1 constant:0];

    NSLayoutConstraint *title_trailing = [NSLayoutConstraint constraintWithItem:_titleLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:wrapper attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];

    [wrapper addConstraints:@[title_leading, title_top, title_trailing]];
    //subtitle
    NSLayoutConstraint *subtitle_leading = [NSLayoutConstraint constraintWithItem:_subtitleLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:wrapper attribute:NSLayoutAttributeLeading multiplier:1 constant:0];

    NSLayoutConstraint *subtitle_top = [NSLayoutConstraint constraintWithItem:_subtitleLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_titleLabel attribute:NSLayoutAttributeBottom multiplier:1 constant:_titlesSpace];

    NSLayoutConstraint *subtitle_trailing = [NSLayoutConstraint constraintWithItem:_subtitleLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:wrapper attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];

    NSLayoutConstraint *subtitle_bottom = [NSLayoutConstraint constraintWithItem:_subtitleLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:wrapper attribute:NSLayoutAttributeBottom multiplier:1 constant:0];

    [wrapper addConstraints:@[subtitle_leading, subtitle_top, subtitle_trailing, subtitle_bottom]];

    return wrapper;
}

@end
