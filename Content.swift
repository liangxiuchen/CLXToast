//
//  Content.swift
//  CLXToast
//
//  Created by chen liangxiu on 2018/1/25.
//

import Foundation

public enum ToastStyle: Int {
    case hud //弱提示，可是设置持续时间，时间到后，自动消失
    case waiting //类模态化即屏蔽了用户交互,使用场景，等待网络请求。 需要自己dismiss
    case custom_hud //hud模式下, 自定义子view和布局
    case custom_waiting //waiting 模式下, 自定义子view和布局
}

open class ToastContent {
    private(set) var style: ToastStyle

    public init(style: ToastStyle) {
        self.style = style
    }
    open func addSubviews(to contentView: UIView) {}
    open func layoutSubviews(in contentView: UIView) {}
}

public protocol DefaultCommonExport {
    @discardableResult
    func show(animated: Bool, with completion: (() -> Void)?) -> Toast
    @discardableResult
    func show(in container: UIView, with layout: ((Toast) -> Void)?, animated: Bool, completion: (() -> Void)?) -> Toast

    @discardableResult
    func contentInset(_ inset: UIEdgeInsets) -> Self
}

extension DefaultCommonExport {
    @discardableResult
    public func show() -> Toast {
        return self.show(animated: true, with: nil)
    }
}

public protocol DefaultHudExport: DefaultCommonExport {
    @discardableResult
    func title(_ newValue: String) -> Self

    @discardableResult
    func titleLabel(_ newValue: UILabel?) -> Self

    @discardableResult
    func subtitle(_ newValue: String) -> Self

    @discardableResult
    func subtitleLabel(_ newValue: UILabel?) -> Self

    @discardableResult
    func icon(_ newValue: UIImage?) -> Self

    @discardableResult
    func iconView(_ newValue: UIImageView?) -> Self

    @discardableResult
    func interTitlesSpacing(_ space: CGFloat) -> Self

    @discardableResult
    func interTitlesIconSpacing(_ space: CGFloat) -> Self
    
}

public protocol DefaultWaitingExport: DefaultCommonExport {
    @discardableResult
    func activityView(_ newValue: UIActivityIndicatorView?) -> Self

    @discardableResult
    func prompt(_ newValue: String?) -> Self

    @discardableResult
    func promptLabel(_ newValue: UILabel?) -> Self

    @discardableResult
    func interitemSpacing(_ space: CGFloat) -> Self
}
