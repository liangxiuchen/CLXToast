//
//  BSTDefaultWaiting.h
//  businessBase
//
//  Created by chen liangxiu on 2018/2/8.
//  Copyright © 2018年 best.inc. All rights reserved.
//

#import "CLXContent.h"
#import <UIKit/UIKit.h>

@class CLXToast;
#if defined(__has_attribute) && __has_attribute(objc_subclassing_restricted)
__attribute__((objc_subclassing_restricted))
#endif
@interface CLXDefaultWaiting : CLXContent

@property (nonatomic, weak) CLXToast *toast;

@property (nonatomic, assign, readonly) CLXDefaultWaiting *(^contentInset)(UIEdgeInsets inset);//Taost的内容边距
@property (nonatomic, readonly) CLXDefaultWaiting *(^prompt)(NSString *prompt);//提示信息
@property (nonatomic, readonly) CLXDefaultWaiting *(^promptLabel)(UILabel *promptLabel);//提示信息Label,用于进一步自定义Label属性
@property (nonatomic, readonly) CLXDefaultWaiting *(^activityView)(UIActivityIndicatorView *activityView);//菊花控件
@property (nonatomic, readonly) CLXDefaultWaiting *(^interItemSpacing)(CGFloat space);//提示信息和菊花的上下间距

@property (nonatomic, readonly) CLXToast *(^show)(void);
@property (nonatomic, readonly) CLXToast *(^showWith)(NSTimeInterval delay, BOOL animated, void(^completion)(void));
@property (nonatomic, readonly) CLXToast *(^showIn)(UIView *container, void(^layout)(CLXToast *toast), BOOL animated, NSTimeInterval delay, void(^completion)(void));

@end
