//
//  BSTToast.m
//  businessBase
//
//  Created by chen liangxiu on 2018/2/8.
//  Copyright © 2018年 best.inc. All rights reserved.
//

#import "CLXToast.h"
#import "CLXToast+internal.h"

static __unsafe_unretained CLXToast *_currentWaiting = nil;

@interface CLXToast()<BSTToastWaitingMode>
@end

@implementation CLXToast

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _isConcurrent = NO;
        _duration = 0.6;
        _showDuration = 0.4;
        _dismissDuration = 0.4;
    }
    return self;
}

- (CLXDefaultHud *)aHud {
    CLXDefaultHud *hud = [CLXDefaultHud new];
    hud.toast = self;
    _retainCircle = self;
    _content = hud;
    return hud;
}

- (CLXDefaultWaiting *)aWaiting {
    CLXDefaultWaiting *waiting = [CLXDefaultWaiting new];
    waiting.toast = self;
    _retainCircle = self;
    _content = waiting;
    return waiting;
}

- (CLXToast *)setCustom:(CLXContent *)content {
    self.content = content;
    return self;
}

#pragma mark - override methods

+ (BOOL)requiresConstraintBasedLayout {
    return NO;
}

- (void)updateConstraints {
    [super updateConstraints];
    CGSize size = [self.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    //默认大小为20
    size.width = size.width > 0 ? size.width : 20;
    size.height = size.height > 0 ? size.height : 20;
    size.width = MIN(size.width, [UIScreen mainScreen].bounds.size.width);
    if (self.contentView_w && self.contentView_h) {
        self.contentView_w.constant = size.width;
        self.contentView_h.constant = size.height;
    }
    if (self.toast_w && self.toast_h) {
        self.toast_w.constant = size.width;
        self.toast_h.constant = size.height;
    }
}

#pragma mark - cancel methods

+ (void (^)(void))cancelAll {
    return ^{
        [self _cancelAll];
    };
}

+ (void)_cancelAll {
    [[self transactions] cancelAllOperations];
}

- (void (^)(void))cancel {
    return ^{
        [self _cancel];
    };
}

- (void)_cancel {
    if (self.myTransaction) {
        [self.myTransaction cancel];
    }
}

#pragma mark - show and dismiss methods

- (CLXToast *(^)(void))show {
    return ^CLXToast *{
        dispatch_block_t task = ^{
            [self _show];
        };
        if ([NSThread isMainThread]) {
            task();
        } else {
            dispatch_async(dispatch_get_main_queue(), task);
        }
        return self;
    };
}

- (CLXToast *(^)(NSTimeInterval, BOOL, void (^)(void)))showWith {
    return ^CLXToast *(NSTimeInterval delay, BOOL animated, void(^completion)(void)) {
        dispatch_block_t task = ^{
            [self _show:animated with:completion];
        };
        if (delay > 0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(),task);
        } else {
            if ([NSThread isMainThread]) {
                task();
            } else {
                dispatch_async(dispatch_get_main_queue(), task);
            }
        }
        return self;
    };
}

- (CLXToast *(^)(UIView *, void (^)(CLXToast *), BOOL, NSTimeInterval, void (^)(void)))showIn {
    return ^CLXToast *(UIView *container, void(^layout)(CLXToast *toast), BOOL animated, NSTimeInterval delay, void(^completion)(void)) {
        dispatch_block_t task = ^{
            [self _showIn:container with:layout animated:animated completion:completion];
        };
        if (delay > 0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), task);
        } else {
            if ([NSThread isMainThread]) {
                task();
            } else {
                dispatch_async(dispatch_get_main_queue(), task);
            }
        }
        return self;
    };
}

- (CLXToast *)_show {
    return [self _show:YES with:nil];
}

- (CLXToast *)_show:(BOOL)animated with:(void (^)(void))completion{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    if (keyWindow) {
        return [self _showIn:keyWindow with:nil animated:animated completion:completion];
    } else {
        return nil;
    }
}

- (CLXToast *)_showIn:(UIView *)container with:(void (^)(CLXToast *))layout animated:(BOOL)animated completion:(void (^)(void))completion {
    if (self.myTransaction != nil) {
        return self;
    }
    if (self.content.style == ToastHud || self.content.style == ToastCustomHud) {
        if (self.isConcurrent) {
            CLXOperation *showTask = [self showOperationWithLayout:layout animated:animated at:container];
            CLXOperation *dismissTask = [self dismissOperationWithDelay:self.duration];
            [dismissTask addDependency:showTask];
            dismissTask.completionBlock = completion;
            [[CLXToast animations] addOperations:@[showTask, dismissTask] waitUntilFinished:NO];
        } else {
            CLXOperation *transaction = [[CLXOperation alloc] initWithTask:^(CLXOperation *operation) {
                CLXOperation *showTask = [self showOperationWithLayout:layout animated:animated at:container];
                CLXOperation *dismissTask = [self dismissOperationWithDelay:self.duration];
                [dismissTask addDependency:showTask];
                dismissTask.completionBlock = ^{
                    [operation finish];
                };
                [[CLXToast animations] addOperations:@[showTask, dismissTask] waitUntilFinished:NO];
            }];
            transaction.completionBlock = ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion? completion() : ((void)0);
                });
            };
            CLXOperation *last = [CLXToast transactions].operations.lastObject;
            if (last) {
                [transaction addDependency:last];
            }
            [[CLXToast transactions] addOperation:transaction];
            _myTransaction = transaction;
        }
    } else if (self.content.style == ToastWaiting || self.content.style == ToastCustomWaiting) {
        CLXOperation *transaction = [[CLXOperation alloc] initWithTask:^(CLXOperation *operation) {
            CLXOperation *showTask = [self showOperationWithLayout:layout animated:animated at:container];
            [[CLXToast animations] addOperation:showTask];
        }];
        CLXOperation *last = [CLXToast transactions].operations.lastObject;
        if (last) {
            [transaction addDependency:last];
        }
        transaction.completionBlock = ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                completion? completion() : ((void)0);
            });
        };
        [[CLXToast transactions] addOperation:transaction];
        _myTransaction = transaction;
        if (CLXToast.currentWaiting != nil) {
            CLXToast.currentWaiting.dismissWith(NO);
        }
        CLXToast.currentWaiting = self;
    }
    self.retainCircle = nil;//破解循环引用
    return self;
}

- (void (^)(void))dismiss {
    return ^{
        [self _dismiss];
    };
}

- (void)_dismiss {
    [self _dismiss:YES];
}

- (void (^)(BOOL))dismissWith {
    return ^(BOOL animated){
        [self _dismiss:animated];
    };
}

- (void)_dismiss:(BOOL)animated {
    assert((self.content.style == ToastWaiting || self.content.style == ToastCustomWaiting));
    dispatch_block_t task = ^{
        if (self.myTransaction && self.myTransaction.isExecuting) {
            CLXOperation *dismissTask = [self dismissOperationWithDelay:0];
            dismissTask.completionBlock = ^{
                [self.myTransaction finish];
            };
            [[CLXToast animations] addOperation:dismissTask];
        } else if(self.myTransaction) {
            [self.myTransaction cancel];
        } else {}
    };
    if ([NSThread isMainThread]) {
        task();
    } else {
        dispatch_async(dispatch_get_main_queue(), task);
    }
    
    CLXToast.currentWaiting = nil;
}

#pragma mark - accessor methods
- (UIView *)contentView {
    if (_contentView == nil) {
        _contentView = [UIView new];
        _contentView.layer.cornerRadius = 4.0;
        _contentView.clipsToBounds = YES;
        _contentView.alpha = 0.f;
        _contentView.backgroundColor = [UIColor blackColor];
    }
    return _contentView;
}

- (UIColor *)backgroundColor {
    return _contentView.backgroundColor;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    _contentView.backgroundColor = backgroundColor;
}

- (CGFloat)alpha {
    return _contentView.alpha;
}

- (void)setAlpha:(CGFloat)alpha {
    _contentView.alpha = alpha;
}

- (CLXOperation *)showOperationWithLayout:(void (^)(CLXToast *))layout animated:(BOOL)animated at:(UIView *)container {
    return [[CLXOperation alloc] initWithTask:^(CLXOperation *operation) {
        [container addSubview:self];
        
        [self.content addSubviewsTo:self.contentView];
        [self.content layoutSubviewsAt:self.contentView];

        [self addSubview:self.contentView];
        [self layoutContentView];

        if (layout) {
            layout(self);
        } else {
            [self layoutToastAt:container];
        }

        if (animated) {
            [UIView animateWithDuration:self.showDuration delay:0 options:UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionAllowUserInteraction animations:^{
                self.contentView.alpha = 0.7;
            } completion:^(BOOL finished) {
                [operation finish];
            }];
        } else {
            self.contentView.alpha = 0.7;
            [operation finish];
        }
    }];
}

- (CLXOperation *)dismissOperationWithDelay:(NSTimeInterval)delay {
    return [[CLXOperation alloc] initWithTask:^(CLXOperation *operation) {
        if (self.superview == nil) {
            return;
        }
        [UIView animateWithDuration:self.dismissDuration delay:delay options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction animations:^{
            self.contentView.alpha = 0.f;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
            [operation finish];
        }];
    }];
}

#pragma mark - layout methods
- (void)layoutToastAt:(UIView *)container {
    //非模态
    dispatch_block_t hudLayout = ^ {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        if (!CGRectEqualToRect(self.frame, CGRectZero)) {
            self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        } else {
            NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:container attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];

            NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:container attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];

            [container addConstraints:@[centerX, centerY]];

            CGSize size = [self.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
            //默认大小为20
            size.width = size.width > 0 ? size.width : 20;
            size.height = size.height > 0 ? size.height : 20;
            size.width = MIN(size.width, container.bounds.size.width);
            self.toast_w = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:size.width];

            self.toast_h = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:size.height];

            [self addConstraints:@[self.toast_w, self.toast_h]];
        }
    };
    //模态
    dispatch_block_t waitingLayout = ^ {
        self.frame = container.bounds;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    };

    if (self.content.style == ToastWaiting || self.content.style == ToastCustomWaiting) {
        waitingLayout();
    } else {
        hudLayout();
    }
}

- (void)layoutContentView {
    //非模态形式
    dispatch_block_t hudLayout = ^{
        NSLayoutConstraint *leading = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1 constant:0];

        NSLayoutConstraint *trailing = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];

        NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0];

        NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0];

        [self addConstraints:@[leading, top, bottom, trailing]];
    };
    //模态形式
    dispatch_block_t waitingLayout = ^{
        if (!CGRectEqualToRect(self.contentView.frame, CGRectZero)) {
            self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            return;
        }
        NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];

        NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];

        [self addConstraints:@[centerX, centerY]];


        CGSize size = [self.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        //默认大小为20
        size.width = size.width > 0 ? size.width : 20;
        size.height = size.height > 0 ? size.height : 20;
        self.contentView_w = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:MIN(size.width, [UIScreen mainScreen].bounds.size.width)];

        self.contentView_h = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:MAX(size.height, self.contentView.bounds.size.height)];

        [self addConstraints:@[self.contentView_w, self.contentView_h]];
    };

    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    if (self.content.style == ToastHud || self.content.style == ToastCustomHud) {
        hudLayout();
    } else {
        waitingLayout();
    }
}

#pragma mark - static methods

+ (CLXDefaultHud *)hudBuilder {
    CLXToast *toast = [CLXToast new];
    CLXDefaultHud *aHud = [CLXDefaultHud new];
    toast->_retainCircle = toast;
    aHud.toast = toast;
    toast->_content = aHud;
    return aHud;
}

+ (CLXDefaultWaiting *)waitingBuilder {
    CLXToast *toast = [CLXToast new];
    CLXDefaultWaiting *aWaiting = [CLXDefaultWaiting new];
    toast->_retainCircle = toast;
    aWaiting.toast = toast;
    toast->_content = aWaiting;
    return aWaiting;
}

+ (NSOperationQueue *)animations {
    static NSOperationQueue *q;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        q = [NSOperationQueue new];
        q.name = @"BSTToast.AnimationTask.Queue";
        q.underlyingQueue = dispatch_get_main_queue();
    });
    return q;
}

+ (NSOperationQueue *)transactions {
    static NSOperationQueue *q;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        q = [NSOperationQueue new];
        q.name = @"BSTToast.Transactions.Queue";
        q.underlyingQueue = dispatch_get_main_queue();
    });
    return q;
}

+ (CLXToast<BSTToastWaitingMode> *)currentWaiting {
    if ([_currentWaiting conformsToProtocol:@protocol(BSTToastWaitingMode)]) {
        return _currentWaiting;
    } else {
        return nil;
    }
}

+ (void)setCurrentWaiting:(CLXToast<BSTToastWaitingMode> *)currentWaiting {
    _currentWaiting = currentWaiting;
}

- (void (^)(NSString *))updatePrompt {
    return ^(NSString *prompt) {
        dispatch_block_t task = ^{
            if ([CLXToast.currentWaiting.content isKindOfClass:[CLXDefaultWaiting class]]) {
                CLXDefaultWaiting *waitingContent = (CLXDefaultWaiting *)CLXToast.currentWaiting.content;
                waitingContent.prompt(prompt);
            }
        };
        if ([NSThread isMainThread]) {
            task();
        } else {
            dispatch_async(dispatch_get_main_queue(), task);
        }
    };
}

@end
