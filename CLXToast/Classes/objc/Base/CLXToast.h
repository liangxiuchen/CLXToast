//
//  BSTToast.h
//  businessBase
//
//  Created by chen liangxiu on 2018/2/8.
//  Copyright © 2018年 best.inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CLXDefaultHud.h"
#import "CLXDefaultWaiting.h"
#import "CLXHudActivityContent.h"

@protocol BSTToastWaitingMode<NSObject>

//消失方法(waiting 模式下用,hud会自动消失)
@property (nonatomic, readonly) void(^dismiss)(void);
@property (nonatomic, readonly) void(^dismissWith)(BOOL animated);
//更新默认实现的waiting prompt字段，对于自定义和Default hud无效
@property (nonatomic, readonly) void(^updatePrompt)(NSString *prompt);

@end

#if defined(__has_attribute) && __has_attribute(objc_subclassing_restricted)
 __attribute__((objc_subclassing_restricted))
#endif
@interface CLXToast : UIView

@property(nonatomic, readonly) UIView *contentView;//Toast的内容视图，所有需要显示的子view都是加在它上面
@property (nonatomic, readonly) CLXContent *content;//Toast具体内容的抽象类,约束了如何加入子View到contentView中

@property(nonatomic, assign) NSTimeInterval duration;//Hud模式下，Toast显示时间
@property(nonatomic, assign) NSTimeInterval showDuration;//Toast显示动画持续时间
@property(nonatomic, assign) NSTimeInterval dismissDuration;//Toast消失动画持续时间
@property(nonatomic, assign) BOOL isConcurrent;//不必保证FIFO，可以并发出现(只对HUD模式有用)

@property(nonatomic, class, readonly) CLXDefaultHud *hudBuilder;//默认的实现的Hud content（类方法）
@property(nonatomic, class, readonly) CLXDefaultWaiting *waitingBuilder;// 默认实现的Waiting content（类方法）
@property(nonatomic, readonly) CLXDefaultHud *aHud;//默认的实现的Hud content（实例方法）
@property(nonatomic, readonly) CLXDefaultWaiting *aWaiting;// 默认实现的Waiting content（实例方法）

/** 显示方法
 *  param container:Toast的父view,默认是在keywindow
 *  param layout: Taost在父view上的自定义布局
 *  param animated: 是否动画显示
 *  param delay: 显示的延迟时间
 *  param completion:Taost的结束回调（⚠️不是show的完成回调）
 **/
@property (nonatomic, readonly) CLXToast *(^show)(void);
@property (nonatomic, readonly) CLXToast *(^showWith)(NSTimeInterval delay, BOOL animated, void(^completion)(void));
@property (nonatomic, readonly) CLXToast *(^showIn)(UIView *container, void(^layout)(CLXToast *toast), BOOL animated, NSTimeInterval delay, void(^completion)(void));
//取消方法
@property (nonatomic, readonly, class) void(^cancelAll)(void);
@property (nonatomic, readonly) void(^cancel)(void);
//消失方法(waiting 模式下用,hud会自动消失)
@property (nonatomic,class, readonly) CLXToast<BSTToastWaitingMode> *currentWaiting;
//@property (nonatomic, readonly) void(^dismiss)(void);
//@property (nonatomic, readonly) void(^dismissWith)(BOOL animated);
////更新默认实现的waiting prompt字段，对于自定义和Default hud无效
//@property (nonatomic, class, readonly) void(^updateDefaultWaiting)(NSString *prompt);
//自定义Toast的内容视图,可以参考DefaultHud和DefautWaiting来实现BSTContent的子类
- (CLXToast *)setCustom:(CLXContent *)content;

@end
