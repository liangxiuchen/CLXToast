//
//  Toast.swift
//  Toast
//
//  Created by chen liangxiu on 2018/1/11.
//  Copyright © 2018年 liangxiu.chen.cn. All rights reserved.
//

import UIKit.UIView

public protocol Toastable: AnyObject {

    var content: ToastContent! {get}

    var isConcurrent: Bool {get set}

    var duration: TimeInterval {get set}

    var showDuraion: TimeInterval {get set}

    var dismissDuration: TimeInterval {get set}

    @discardableResult
    func show(in container: UIView, with layout: ((Toast) -> Void)?, animated: Bool, completion: (() -> Void)?) -> Self
    @discardableResult
    func show(animated: Bool, with completion: (() -> Void)?) -> Self
    
    func dismiss(animated:Bool)
}

public final class Toast: UIView, Toastable {

    private var circleRef: Toast? //为了链式语法调用，先循环自持有，否则在配置content的时候过早释放 在准备show的时候释放
    public private(set) var content: ToastContent! // 默认为Hud

    private(set) weak var myTransaction: ToastOperation? //属于自己的Toast事务

    public var isConcurrent = false //不按显示顺序执行，可以并发弹出（允许重叠),注意⚠️：对于waiting 无效

    public var duration: TimeInterval = 0.6 //hud 提示时间,对自动消息有用,默认0.4 seconds

    public var showDuraion: TimeInterval = 0.4 //toast出现动画的时间

    public var dismissDuration: TimeInterval = 0.4 //toast消失动画的时间

    public override var backgroundColor: UIColor? {//设置Toast的外观，请使用contentView
        get {
            return contentView.backgroundColor
        }
        set {
            contentView.backgroundColor = newValue
        }
    }

    public override var alpha: CGFloat {//设置Toast的外观，请使用contentView
        get {
            return contentView.alpha
        }
        set {
            contentView.alpha = newValue
        }
    }

    fileprivate(set) public var contentView: UIView = {
        let content = UIView()
        content.layer.cornerRadius = 4.0
        content.clipsToBounds = true
        content.alpha = 0
        content.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        return content
    }()

    public var aHudBuilder: DefaultHudExport {
        let aHud = DefaultHud()
        aHud.toast = self
        circleRef = self
        content = aHud
        return aHud as DefaultHudExport
    }

    public var aWaitingBuilder: DefaultWaitingExport {
        let aWaiting = DefaultWating()
        aWaiting.toast = self
        circleRef = self
        content = aWaiting
        return aWaiting
    }

    private var contentViewWidth: NSLayoutConstraint?
    private var contentViewHeight: NSLayoutConstraint?
    private var toastWidth: NSLayoutConstraint?
    private var toastHeight: NSLayoutConstraint?

    @discardableResult
    public func custom<T: ToastContent>(content: T) -> Toast {
        self.content = content
        return self
    }

    public func cancel() {
        myTransaction?.cancel()
    }

    public override func updateConstraints() {
        super.updateConstraints();
        var size = contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize);
        //默认大小为20
        size.width = size.width > 0 ? size.width : 20
        size.height = size.height > 0 ? size.height : 20
        size.width = min(size.width, UIScreen.main.bounds.size.width)
        if let contentView_w = self.contentViewWidth, let contentView_h = self.contentViewHeight {
            contentView_w.constant = size.width
            contentView_h.constant = size.height
        }
        if let toast_w = self.toastWidth, let toast_h = self.toastHeight {
            toast_w.constant = size.width
            toast_h.constant = size.height
        }
    }
    
    #if DEVELOP
    deinit {
        print("toast deinit")
    }
    #endif
}

//MARK: 类型方法和属性
extension Toast {
    static let animations: OperationQueue = {
        let q = OperationQueue()
        q.name = "CLXToast.AnimationTask.Queue"
        q.underlyingQueue = DispatchQueue.main
        return q
    }()
    static let transactions: OperationQueue = {
        let q = OperationQueue()
        q.name = "CLXToast.Transactions.Queue"
        q.underlyingQueue = DispatchQueue.main
        return q
    }()

    public static var hudBuilder: DefaultHudExport {
        let toast = Toast()
        let aHud = DefaultHud()
        aHud.toast = toast
        toast.circleRef = toast
        toast.content = aHud
        return aHud as DefaultHudExport
    }

    public static var waitingBuilder: DefaultWaitingExport {
        let toast = Toast()
        let aWaiting = DefaultWating()
        aWaiting.toast = toast
        toast.circleRef = toast
        toast.content = aWaiting
        return aWaiting
    }

    static var _currentWaiting: Toast?
    public static var currentWaiting: DefaultCurrentWaitingExport? {
        get {
            return _currentWaiting?.content as? DefaultCurrentWaitingExport
        }
    }

    public static func cancelAll() {
        Toast.transactions.cancelAllOperations()
    }
}

extension Toast {

    @discardableResult
    public func show(animated: Bool = true, with completion: (() -> Void)? = nil) -> Self {
        func showInKeyWindow() {
            guard let keyWindow = UIApplication.shared.keyWindow else {
                return
            }
            self.show(in: keyWindow, with: nil, animated: animated, completion: completion)
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
    public func show(in container: UIView, with layout: ((Toast) -> Void)?, animated: Bool, completion: (() -> Void)?) -> Toast {
        defer {  self.circleRef = nil } //手动破解循环引用
        guard myTransaction == nil else { return self }//不允许重复调用

        /* hud提示,自动做消失 */
        if content.style == .hud || content.style == .custom_hud {
            if isConcurrent {
                let show = self.showOperation(with: layout, animated: animated, in: container)
                let dismiss = self.dismissOperation(delay: self.duration)
                dismiss.addDependency(show)
                dismiss.completionBlock = completion
                Toast.animations.addOperations([show, dismiss], waitUntilFinished: false)
            } else {
                let transaction = ToastOperation(style: .transaction, task: {(op) in
                    let show = self.showOperation(with: layout, animated: animated, in: container)
                    let dismiss = self.dismissOperation(delay: self.duration)
                    dismiss.addDependency(show)
                    dismiss.completionBlock = {
                        op.finish()
                    }
                    Toast.animations.addOperations([show, dismiss], waitUntilFinished: false)
                })
                transaction.completionBlock = {
                    DispatchQueue.main.async {
                        completion?()
                    }
                }
                if let last = Toast.transactions.operations.last{
                    transaction.addDependency(last)
                }
                Toast.transactions.addOperation(transaction)
                myTransaction = transaction
            }
        } else if content.style == .waiting || content.style == .custom_waiting {
            /* waiting提示, 手动消失*/
            let transaction = ToastOperation(style: .transaction, task: { (_) in
                let show = self.showOperation(with: layout, animated: animated, in: container)
                Toast.animations.addOperation(show)
            })
            if let last = Toast.transactions.operations.last {
                transaction.addDependency(last)
            }
            transaction.completionBlock = {
                DispatchQueue.main.async {
                    completion?()
                }
            }
            Toast.transactions.addOperation(transaction)
            myTransaction = transaction
            if let current = Toast._currentWaiting {
                current.dismiss(animated: false);
            }
            Toast._currentWaiting = self
        }
        return self
    }

    public func dismiss(animated:Bool = true) {
        if content.style == .custom_waiting || content.style == .waiting {
            
            if Toast._currentWaiting == self {
                Toast._currentWaiting = nil;
            }
            
            if let executing = myTransaction?.isExecuting, executing {
                let dismiss = self.dismissOperation(delay: 0)
                dismiss.completionBlock = {
                    self.myTransaction?.finish()
                }
                Toast.animations.addOperation(dismiss)
            } else {
                myTransaction?.cancel()
            }
        } else if content.style == .hud || content.style == .custom_hud {
            #if DEBUG
                fatalError("hud提示不需要调用dismiss,其会自动消失")
            #endif
        }
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
            self.addToast(to: container)
            self.content.addSubviews(to: self.contentView)
            self.content.layoutSubviews(at: self.contentView)
            
            self.addContentView()
            self.layoutContentView()

            if let customLayout = layout {
                customLayout(self)
            } else {
                self.layoutToast(in: container)
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
    func addToast(to container: UIView) {
        container.addSubview(self)
    }

    func addContentView() {
        self.addSubview(contentView)
    }
}

//MARK: 布局模块
extension Toast {
    /* Toast布局在父view,默认实现为居中 */
    func layoutToast(in container: UIView) {
        //非模态
        func layoutHudToast() {
            self.translatesAutoresizingMaskIntoConstraints = false;
            if !self.frame.equalTo(.zero) {
                self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            } else {
                let centerX = NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: container, attribute: .centerX, multiplier: 1, constant: 0)
                let centerY = NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: container, attribute: .centerY, multiplier: 1, constant: 0)
                container.addConstraints([centerX, centerY])

                var size = contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize);
                //默认大小为20
                size.width = size.width > 0 ? size.width : 20
                size.height = size.height > 0 ? size.height : 20
                size.width = min(size.width, container.bounds.size.width)
                self.toastWidth = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: size.width)
                self.toastHeight = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: size.height)
                self.addConstraints([self.toastWidth!, self.toastHeight!])
            }
        }
        //模态
        func layoutWaitingToast() {
            self.frame = container.bounds
            self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }

        if content.style == .waiting || content.style == .custom_waiting {
            layoutWaitingToast()
        } else {
            layoutHudToast()
        }
    }

    /* conetentView 默认和Toast一样大小，waiting 模式下例外 */
    func layoutContentView() {
        //非模态形式
        func layoutHudContentView() {
            let leading = NSLayoutConstraint(item: contentView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0)
            let trailing = NSLayoutConstraint(item: contentView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0)
            let top = NSLayoutConstraint(item: contentView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
            let bottom = NSLayoutConstraint(item:contentView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
            self.addConstraints([leading, top, bottom, trailing])
        }
        //模态形式
        func layoutWaitingContentView() {
            if !contentView.frame.equalTo(.zero) {
                //frame不为空，不用进行自动布局,采用autoresizing
                contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                return
            }

            let centerX = NSLayoutConstraint(item: contentView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
            let centerY = NSLayoutConstraint(item: contentView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)

            self.addConstraints([centerX, centerY])


            var size = contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize);
            //默认大小为20
            size.width = size.width > 0 ? size.width : 20
            size.height = size.height > 0 ? size.height : 20
            self.contentViewWidth = NSLayoutConstraint(item: contentView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: min(size.width, UIScreen.main.bounds.size.width))
            self.contentViewHeight = NSLayoutConstraint(item: contentView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: max(size.height, contentView.bounds.size.height))
            self.addConstraints([self.contentViewWidth!,self.contentViewHeight!])
        }

        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        if content.style == .hud || content.style == .custom_hud {
            layoutHudContentView()
        } else {
            layoutWaitingContentView()
        }
    }
}

