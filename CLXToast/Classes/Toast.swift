//
//  Toast.swift
//  Toast
//
//  Created by chen liangxiu on 2018/1/11.
//  Copyright © 2018年 liangxiu.chen.cn. All rights reserved.
//

import UIKit

protocol Toastable where Self: UIView {
    //TODO:抽象层，留着备用
}

public final class Toast: UIView, Toastable {

    public var isConcurrent = false //不按显示顺序执行，可以并发弹出（允许重叠）
    
    @discardableResult
    @objc public func title(_ newValue: String) -> Toast {//标题的快捷链式语法糖 (hud 模式)
        if self.titleLabel == nil {
            self.titleLabel = UILabel()
            self.titleLabel.textColor = UIColor.white
            self.titleLabel.preferredMaxLayoutWidth = UIScreen.main.bounds.size.width
            self.titleLabel.numberOfLines = 0
        }
        self.titleLabel.text = newValue
        return self
    }
    @objc public var titleLabel: UILabel!

    @discardableResult
    @objc public func subtitle(_ newValue: String) -> Toast {//子标题的快捷链式语法糖 (hud 模式)
        if self.subtitleLabel == nil {
            self.subtitleLabel = UILabel()
            self.subtitleLabel.textColor = UIColor.white
            self.subtitleLabel.preferredMaxLayoutWidth = UIScreen.main.bounds.size.width
            self.subtitleLabel.numberOfLines = 0
        }
        self.subtitleLabel.text = newValue
        return self
    }
    @objc public var subtitleLabel :UILabel!

    @discardableResult
    @objc public func icon(_ newValue: UIImage?) -> Toast {//icon的快捷链式语法糖 (hud 模式)
        if iconView == nil {
            iconView = UIImageView(image: newValue)
        }
        return self
    }
    @objc public var iconView: UIImageView! //小图标默认在左边居中,可以自定义布局（hud 模式）

    @objc public var activity: UIActivityIndicatorView! //菊花,如果为空，组件自己会创建，默认样式为白色（waiting模式）

    @discardableResult
    @objc public func prompt(_ newValue: String?) -> Toast {//菊花提示的链式快捷方式（waiting模式）
        if self.activityPrompt == nil {
            self.activityPrompt = UILabel()
        }
        self.activityPrompt!.text = newValue
        return self
    }

    @objc public var activityPrompt: UILabel? //菊花提示（waiting模式）

    @objc public var duration: TimeInterval = 0.6 //hud 提示时间,对自动消息有用,默认0.4 seconds

    @objc public var showDuraion: TimeInterval = 0.4 //toast出现动画的时间

    @objc public var dismissDuration: TimeInterval = 0.4 //toast消失动画的时间

    @objc public var contentInset: UIEdgeInsets = UIEdgeInsetsMake(4, 4, 4, 4) //toast内容边距

    @objc public override var backgroundColor: UIColor? {//设置Toast的外观，请使用contentView
        get {
            return contentView.backgroundColor
        }
        set {
            contentView.backgroundColor = newValue
        }
    }

    @objc public override var alpha: CGFloat {//设置Toast的外观，请使用contentView
        get {
            return contentView.alpha
        }
        set {
            contentView.alpha = newValue
        }
    }

    weak var transaction: ToastOperation? //Toast显示的完整事务

    fileprivate(set) public var style: ToastStyle

    fileprivate(set) public var contentView: UIView = {
        let content = UIView()
        content.layer.cornerRadius = 3.0
        content.clipsToBounds = true
        content.alpha = 0
        content.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        return content
    }()

    @objc convenience public init(style s: ToastStyle = .hud) {
        self.init(frame: .zero, style: s)
    }

    @objc public init(frame: CGRect, style: ToastStyle) {
        self.style = style
        super.init(frame: frame)
        self.contentView.frame = frame
        self.addContentView()
        super.backgroundColor = UIColor.white.withAlphaComponent(0)//因为backgroundColor被重写成了设置contentView了,所以此处要用super设置Toast的背景
    }

    required public init?(coder aDecoder: NSCoder) {
        contentView = aDecoder.decodeObject(forKey: EncodeKey.contentView) as! UIView
        let rawStyle = aDecoder.decodeInteger(forKey: EncodeKey.style)
        style = ToastStyle(rawValue: rawStyle)!
        super.init(coder: aDecoder);
    }

    override open func encode(with aCoder: NSCoder) {
        aCoder.encode(contentView, forKey: EncodeKey.contentView);
        super.encode(with: aCoder)
    }
}

//MARK: 命名空间
extension Toast {
    @objc public enum ToastStyle: Int {
        @objc(hud) case hud //弱提示，可是设置持续时间，时间到后，自动消失
        @objc(waiting) case waiting //类模态化即屏蔽了用户交互,使用场景，等待网络请求。 需要自己dismiss
        @objc(custom_hud) case custom_hud //hud模式下, 自定义子view和布局
        @objc(custom_waiting) case custom_waiting //waiting 模式下, 自定义子view和布局
    }

    struct EncodeKey {
        static let contentView = "kContentView"
        static let backgroundView = "kBackgroundView"
        static let style = "kStyle"
    }

    public typealias CompletionBlock = () -> Void
}

//MARK: 类型方法和属性
extension Toast {
    fileprivate static let animations: OperationQueue = {
        let q = OperationQueue()
        q.underlyingQueue = DispatchQueue.main
        return q;
    }()
    fileprivate static let transactions: OperationQueue = {
        let q = OperationQueue()
        q.underlyingQueue = DispatchQueue.main
        return q;
    }()

    @objc static public func cancelAll() {
        Toast.transactions.cancelAllOperations()
    }
}

extension Toast {
    @discardableResult
    @objc public func show(animated: Bool = true, with completion: CompletionBlock? = nil) -> Toast {
        func showInKeyWindow() {
            guard let keyWindow = UIApplication.shared.keyWindow else {
                return
            }
            self.show(in: keyWindow, with: nil, animated: true, completion: completion)
        }
        if Thread.isMainThread {
            showInKeyWindow()
        } else {
            DispatchQueue.main.async {
                showInKeyWindow()
            }
        }
        return self
    }
    @discardableResult
    @objc public func show(in container: UIView, with layout: ((Toast) -> Void)?, animated: Bool, completion: CompletionBlock?) -> Toast {
        guard self.transaction == nil else {
            //不允许重复调用
            return self;
        }
        /* hud提示,自动做消失 */
        if self.style == .hud || self.style == .custom_hud {
            let transaction = ToastOperation(style: .transaction, task: { (op) in
                let show = self.showOperation(with: layout, animated: animated, in: container)
                let dismiss = self.dismissOperation(delay: self.duration)
                dismiss.addDependency(show)
                dismiss.completionBlock = {
                    op.finish()
                }
                Toast.animations.addOperations([show, dismiss], waitUntilFinished: false)
            })
            transaction.completionBlock = completion;
            if let last = Toast.transactions.operations.last, !isConcurrent {
                transaction.addDependency(last)
            }
            Toast.transactions.addOperation(transaction)
            self.transaction = transaction
        } else if self.style == .waiting || self.style == .custom_waiting {
            /* waiting提示,自动做消失 */
            let transaction = ToastOperation(style: .transaction, task: { (_) in
                let show = self.showOperation(with: layout, animated: animated, in: container)
                Toast.animations.addOperation(show)
            })
            if let last = Toast.transactions.operations.last, !isConcurrent {
                transaction.addDependency(last)
            }
            Toast.transactions.addOperation(transaction)
            self.transaction = transaction
        }
        return self
    }

    @objc public func dismiss(animated:Bool = true, with completion: CompletionBlock? = nil) {
        if self.style == .custom_waiting || self.style == .waiting {
            if let executing = self.transaction?.isExecuting, executing {
                let dismiss = self.dismissOperation(delay: 0)
                self.transaction?.completionBlock = completion
                dismiss.completionBlock = {
                    self.transaction?.finish()
                }
                Toast.animations.addOperation(dismiss)
            } else {
                self.transaction?.cancel()
            }

        } else if self.style == .hud || self.style == .custom_hud {
            #if DEBUG
                fatalError("hud提示不需要调用dismiss,其会自动消失")
            #endif
        }
    }

    @objc public func cancel() {
        self.transaction?.cancel()
    }

    func dismissOperation(delay: TimeInterval) -> ToastOperation {
        return ToastOperation(style: .dismiss) { (operation) in
            guard let _ = self.superview else {
                return
            }
            UIView.animate(withDuration: self.dismissDuration, delay: delay, options: [.curveEaseOut, .allowUserInteraction], animations: {
                self.contentView.alpha = 0
            }, completion: { (_) in
                self.removeFromSuperview()
                operation.finish()
            })
        }
    }

    func showOperation(with layout: ((Toast) -> Void)?, animated:Bool, in container: UIView) -> ToastOperation {
        return ToastOperation(style: .show) { (operation) in
            self.addSelfToContainer(container: container)
            self.addSubviewsToContentView()
            /* 布局子视图 */
            if let safeLayout = layout {
                //外部可以自定义布局
                safeLayout(self)
            } else {
                //提供默认子视图布局
                switch self.style {
                case .hud:
                    self.layoutSubviewInHudCase()
                case .waiting:
                    self.layoutSubviewInWaitingCase()
                case .custom_hud, .custom_waiting:
                    break
                }
                self.layoutContentView()
                self.layoutSelfInContainer(container: container)
            }

            /* 显示动画 */
            if animated {
                UIView.animate(withDuration: self.showDuraion, delay: 0, options: [.curveEaseIn, .allowUserInteraction], animations: {
                    self.contentView.alpha = 1
                }, completion: { (_) in
                    operation.finish()
                })
            } else {
                self.contentView.alpha = 1
                operation.finish()
            }
        }
    }
}

//MARK: 根据Style添加默认的子视图
extension Toast {
    func addSelfToContainer(container: UIView) {
        container.addSubview(self)
    }

    func addContentView() {
        self.addSubview(contentView)
    }

    func addSubviewsToContentView() {
        switch style {
        case .hud:
            self.addSubViewsInHudCase()
        case .waiting:
            self.addSubviewsInWaitingCase()
        case .custom_hud, .custom_waiting:
            break
        }
    }

    func addSubviewsInWaitingCase() {
        if self.activity == nil {
            self.activity = UIActivityIndicatorView()
            self.activity.hidesWhenStopped = false
        }
        if self.activity.superview != self.contentView {
            self.contentView.addSubview(self.activity)
        }
        self.activity.startAnimating()

        let empty = self.activityPrompt?.text?.isEmpty ?? true
        if !empty && self.activityPrompt?.superview != self.contentView {
            self.contentView.addSubview(self.activityPrompt!)
        }
    }

    func addSubViewsInHudCase() {
        if let icon = self.iconView, icon.superview == nil {
            self.contentView.addSubview(icon)
        }

        var empty = self.titleLabel?.text?.isEmpty ?? true
        if !empty && self.titleLabel.superview != self.contentView {
            self.contentView.addSubview(self.titleLabel)
        }

        empty = self.subtitleLabel?.text?.isEmpty ?? true
        if !empty && self.subtitleLabel.superview != self.contentView {
            self.contentView.addSubview(self.subtitleLabel)
        }
    }
}

//MARK: 布局模块
extension Toast {
    /* Toast布局再父view,默认实现为居中 */
    func layoutSelfInContainer(container: UIView) {
        if self.style == .waiting || self.style == .custom_waiting {
            //模态
            self.frame = container.bounds
            self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        } else {
            //非模态
            self.translatesAutoresizingMaskIntoConstraints = false;
            if !self.frame.equalTo(.zero) {
                self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            } else {
                let centerX = NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: container, attribute: .centerX, multiplier: 1, constant: 0)
                let centerY = NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: container, attribute: .centerY, multiplier: 1, constant: 0)
                container.addConstraints([centerX, centerY])

                var size = self.systemLayoutSizeFitting(UILayoutFittingCompressedSize);
                //默认大小为20
                size.width = size.width > 0 ? size.width : 20
                size.height = size.height > 0 ? size.height : 20
                let w = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: size.width)
                let h = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: size.height)
                self.addConstraints([h,w])
            }
        }
    }

    /* conetentView 默认和Toast一样大小，waiting 模式下例外 */
    func layoutContentView() {
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        if self.style != .waiting && self.style != .custom_waiting {
            //非模态形式
            let leading = NSLayoutConstraint(item: contentView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0);
            let trailing = NSLayoutConstraint(item: contentView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0);
            let top = NSLayoutConstraint(item: contentView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0);
            let bottom = NSLayoutConstraint(item:contentView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
            self.addConstraints([leading, top, bottom, trailing])
        } else {
            //模态形式
            if !contentView.frame.equalTo(.zero) {
                //frame不为空，不用进行自动布局,采用autoresizing
                contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                return
            }
            let centerX = NSLayoutConstraint(item: contentView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
            let centerY = NSLayoutConstraint(item: contentView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
            self.addConstraints([centerX, centerY])

            var size = contentView.systemLayoutSizeFitting(UILayoutFittingCompressedSize);
            //默认大小为20
            size.width = size.width > 0 ? size.width : 20
            size.height = size.height > 0 ? size.height : 20
            let w = NSLayoutConstraint(item: contentView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: max(size.width, contentView.bounds.size.width))
            let h = NSLayoutConstraint(item: contentView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: max(size.height, contentView.bounds.size.height))
            self.addConstraints([h,w])
        }
    }

    /* waitingStyle 模式下所具有的子视图和布局*/
    func layoutSubviewInWaitingCase() {
        //布局activity
        self.activity.translatesAutoresizingMaskIntoConstraints = false
        let empty = self.activityPrompt?.text?.isEmpty ?? true

        let activityCenterX = NSLayoutConstraint(item: self.activity, attribute: .centerX, relatedBy: .equal, toItem: self.contentView, attribute: .centerX, multiplier: 1, constant: 0)

        let activityCenterY = NSLayoutConstraint(item: self.activity, attribute: .centerY, relatedBy: .equal, toItem: self.contentView, attribute: .centerY, multiplier: 1, constant: 0)

        let activityLeading = NSLayoutConstraint(item: self.activity, attribute: .leading, relatedBy: .greaterThanOrEqual, toItem: self.contentView, attribute: .leading, multiplier: 1, constant: contentInset.left)

        let activityTop = NSLayoutConstraint(item: self.activity, attribute: .top, relatedBy: .greaterThanOrEqual, toItem: self.contentView, attribute: .top, multiplier: 1, constant: contentInset.top)

        let activityTrailing = NSLayoutConstraint(item: self.activity, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: self.contentView, attribute: .trailing, multiplier: 1, constant: -contentInset.right)

        var activityBottom: NSLayoutConstraint
        if empty {
            activityBottom = NSLayoutConstraint(item: self.activity, attribute: .bottom, relatedBy: .lessThanOrEqual, toItem: self.contentView, attribute: .bottom, multiplier: 1, constant: -contentInset.bottom)
            self.contentView.addConstraints([activityCenterX, activityCenterY, activityLeading, activityTop, activityTrailing, activityBottom])
            //子控件布局完成
            return
        } else {
            //需要布局prompt label
            activityBottom = NSLayoutConstraint(item: self.activity, attribute: .bottom, relatedBy: .equal, toItem: self.contentView, attribute: .centerY, multiplier: 1, constant: 0)
            self.contentView.addConstraints([activityCenterX, activityLeading, activityTop, activityTrailing, activityBottom])
        }

        //布局promptLabel
        self.activityPrompt!.translatesAutoresizingMaskIntoConstraints = false
        let promptCenterX = NSLayoutConstraint(item: self.activityPrompt!, attribute: .centerX, relatedBy: .equal, toItem: self.contentView, attribute: .centerX, multiplier: 1, constant: 0)

        let promptLeading = NSLayoutConstraint(item: self.activityPrompt!, attribute: .leading, relatedBy: .greaterThanOrEqual, toItem: self.contentView, attribute: .leading, multiplier: 1, constant: contentInset.left)

        let promptTop = NSLayoutConstraint(item: self.activityPrompt!, attribute: .top, relatedBy: .equal, toItem: self.contentView, attribute: .centerY, multiplier: 1, constant: 4)

        let promptTrailing = NSLayoutConstraint(item: self.activityPrompt!, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: self.contentView, attribute: .trailing, multiplier: 1, constant: -contentInset.right)

        let promptBottom = NSLayoutConstraint(item: self.activityPrompt!, attribute: .bottom, relatedBy: .lessThanOrEqual, toItem: self.contentView, attribute: .bottom, multiplier: 1, constant: -contentInset.bottom)
        self.contentView.addConstraints([promptCenterX, promptLeading, promptTop, promptTrailing, promptBottom])
    }

    /* hudStyle下所具有的子视图和布局 */
    func layoutSubviewInHudCase() {
        let iconEmpty = self.iconView?.image == nil ? true : false
        let titleEmpty = self.titleLabel?.text?.isEmpty ?? true
        let subtitleEmpty = self.subtitleLabel?.text?.isEmpty ?? true
        //left icon
        if !iconEmpty {
            self.iconView.translatesAutoresizingMaskIntoConstraints = false
            let center = NSLayoutConstraint(item: self.iconView, attribute: .centerY, relatedBy: .equal, toItem: self.contentView, attribute: .centerY, multiplier: 1, constant: 0);
            let leading = NSLayoutConstraint(item: self.iconView, attribute: .leading, relatedBy: .greaterThanOrEqual, toItem: self.contentView, attribute: .leading, multiplier: 1, constant: contentInset.left);
            let top = NSLayoutConstraint(item: self.iconView, attribute: .top, relatedBy: .greaterThanOrEqual, toItem: self.contentView, attribute: .top, multiplier: 1, constant: contentInset.top);
            let bottom = NSLayoutConstraint(item: self.iconView, attribute: .bottom, relatedBy: .lessThanOrEqual, toItem: self.contentView, attribute: .bottom, multiplier: 1, constant: -contentInset.bottom);
            if titleEmpty && subtitleEmpty {
                let trailing = NSLayoutConstraint(item: self.iconView, attribute: .trailing, relatedBy: .equal, toItem: self.contentView, attribute: .trailing, multiplier: 1, constant: -contentInset.right)
                self.contentView.addConstraint(trailing)
            }
            self.contentView.addConstraints([center, leading, top, bottom])

            let s = self.iconView.image != nil ? self.iconView.image!.size : CGSize(width: 0, height: 0)
            let w = NSLayoutConstraint(item: self.iconView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: s.width)
            let h = NSLayoutConstraint(item: self.iconView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: s.height)
            self.iconView.addConstraints([w,h])
        }

        //Title Label
        if !titleEmpty {
            self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
            let leading = NSLayoutConstraint(item: self.titleLabel, attribute: .leading, relatedBy: (!iconEmpty ? .equal : .greaterThanOrEqual), toItem: (!iconEmpty ? self.iconView : self.contentView), attribute: (!iconEmpty ? .trailing : .leading), multiplier: 1, constant: (!iconEmpty ? 4 : contentInset.left));

            let top = NSLayoutConstraint(item: self.titleLabel, attribute: .top, relatedBy: .greaterThanOrEqual, toItem: self.contentView, attribute: .top, multiplier: 1, constant: contentInset.top);

            let titleLayoutAttribute: NSLayoutAttribute =  subtitleEmpty ? .centerY : .bottom
            let bottom = NSLayoutConstraint(item:self.titleLabel, attribute: titleLayoutAttribute, relatedBy: .equal, toItem: self.contentView, attribute: .centerY, multiplier: 1, constant: (subtitleEmpty ? 0 : -4))

            let trailing = NSLayoutConstraint(item: self.titleLabel, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: self.contentView, attribute: .trailing, multiplier: 1, constant: -contentInset.right);

            self.contentView.addConstraints([leading, top, bottom, trailing])
        }

        if !subtitleEmpty {
            self.subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
            let leading = NSLayoutConstraint(item: self.subtitleLabel, attribute: .leading, relatedBy: (!iconEmpty ? .equal : .greaterThanOrEqual), toItem: (!iconEmpty ? self.iconView : self.contentView), attribute: (!iconEmpty ? .trailing : .leading), multiplier: 1, constant: (!iconEmpty ? 4 : contentInset.left));

            let subtitleLayoutAttribute: NSLayoutAttribute =  titleEmpty ? .centerY : .top
            let top = NSLayoutConstraint(item: self.subtitleLabel, attribute: subtitleLayoutAttribute, relatedBy: .equal, toItem: self.contentView, attribute: .centerY, multiplier: 1, constant: (titleEmpty ? 0 : 4));

            let bottom = NSLayoutConstraint(item: self.subtitleLabel, attribute: .bottom, relatedBy: .lessThanOrEqual, toItem: self.contentView, attribute: .bottom, multiplier: 1, constant: -contentInset.bottom);

            let trailing = NSLayoutConstraint(item: self.subtitleLabel, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: self.contentView, attribute: .trailing, multiplier: 1, constant: -contentInset.right);
            self.contentView.addConstraints([leading, top, bottom, trailing])
        }

        if !titleEmpty && !subtitleEmpty {
            let equalWidth = NSLayoutConstraint(item: self.titleLabel, attribute: .width, relatedBy: .equal, toItem: self.subtitleLabel, attribute: .width, multiplier: 1, constant: 0)
            self.contentView.addConstraint(equalWidth)
        }
    }
}

