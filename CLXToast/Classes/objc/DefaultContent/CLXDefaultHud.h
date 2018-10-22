//
//  BSTDefaultHud.h
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
@interface CLXDefaultHud : CLXContent

@property (nonatomic, weak) CLXToast *toast;

@property (nonatomic, assign, readonly) CLXDefaultHud *(^contentInset)(UIEdgeInsets inset);//Taost的内容边距
@property (nonatomic, readonly) CLXDefaultHud *(^title)(NSString *title);//标题,快捷方式
@property (nonatomic, readonly) CLXDefaultHud *(^titleLabel)(UILabel *title);//标题Label,用于进一步自定义Label属性
@property (nonatomic, readonly) CLXDefaultHud *(^subtitle)(NSString *subtitle);//副标题,快捷方式
@property (nonatomic, readonly) CLXDefaultHud *(^subtitleLabel)(UILabel *subtitle);//副标题Label,用于进一步自定义Label属性
@property (nonatomic, readonly) CLXDefaultHud *(^icon)(UIImage *icon);//小图标
@property (nonatomic, readonly) CLXDefaultHud *(^iconView)(UIImageView *iconView);//小图标的imageView，用于进一步自定义属性
@property (nonatomic, readonly) CLXDefaultHud *(^interTitlesSpacing)(CGFloat space);//标题和副标题的上下间距
@property (nonatomic, readonly) CLXDefaultHud *(^interTitlesIconSpacing)(CGFloat space);//标题，副标题与小图标的左右间距

@property (nonatomic, readonly) CLXToast *(^show)(void);
@property (nonatomic, readonly) CLXToast *(^showWith)(NSTimeInterval delay, BOOL animated, void(^completion)(void));
@property (nonatomic, readonly) CLXToast *(^showIn)(UIView *container, void(^layout)(CLXToast *toast), BOOL animated, NSTimeInterval delay, void(^completion)(void));


@end
