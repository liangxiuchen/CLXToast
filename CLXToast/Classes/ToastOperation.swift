//
//  ToastOperation.swift
//  Toast
//
//  Created by chen liangxiu on 2018/1/11.
//  Copyright © 2018年 liangxiu.chen.cn. All rights reserved.
//

import UIKit

typealias Task = (ToastOperation) -> Void

enum ToastOperationStyle: Int {
    case show, dismiss, toastTransaction
}

class ToastOperation: Operation {
    let task: Task
    let style: ToastOperationStyle
    private var _executing: Bool = false
    private(set) override var isExecuting: Bool {
        get {
            return _executing;
        }
        set {
            self.willChangeValue(forKey: "isExecuting");
            _executing = newValue
            self.didChangeValue(forKey: "isExecuting")
        }
    }

    private var _finished: Bool = false
    private(set) override var isFinished: Bool {
        get {
            return _finished
        }
        set {
            self.willChangeValue(forKey: "isFinished");
            _finished = newValue
            self.didChangeValue(forKey: "isFinished")
        }
    }

    init(style: ToastOperationStyle, task: @escaping Task) {
        self.task = task
        self.style = style
        super.init()
    }

    override func start() {
        super.start()
        if super.isCancelled {
            self.completionBlock = nil
            finish()
        }
    }

    override func main() {
        guard !super.isCancelled else {
            self.completionBlock = nil
            finish()
            return
        }
        self.isExecuting = true
        task(self);
    }

    func finish() {
        self.isExecuting = false
        self.isFinished = true
    }
}
