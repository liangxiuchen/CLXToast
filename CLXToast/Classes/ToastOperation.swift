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
    case show, dismiss, transaction
}

class ToastOperation: Operation {

    private enum State: Int, Comparable {
        case initialed
        case ready
        case executing
        case finished

        static func <(lhs: ToastOperation.State, rhs: ToastOperation.State) -> Bool {
            return lhs.rawValue < rhs.rawValue
        }

        static func ==(lhs: ToastOperation.State, rhs: ToastOperation.State) -> Bool {
            return lhs.rawValue == rhs.rawValue
        }

        func canTransitionToState(target: State) -> Bool {
            switch (self, target) {
            case (.initialed, .ready):
                return true
            case (.ready, .executing):
                return true
            case (.ready, .finished):
                return true
            case (.executing, .finished):
                return true
            case let(lhs, rhs) where lhs == rhs:
                return true
            default:
                return false
            }
        }
    }

    var task: Task!
    let style: ToastOperationStyle

    private var _state: State = .initialed
    private let stateLock = NSLock()
    private var state: State {
        get {
            stateLock.lock()
            let safe =  _state
            stateLock.unlock()
            return safe
        }
        set(newState) {
            willChangeValue(forKey: "state")
            stateLock.lock()
            guard _state != .finished else {
                stateLock.unlock()
                return
            }
            assert(_state.canTransitionToState(target: newState),"Operation \(_state)->\(newState)非法转换")
            _state = newState
            stateLock.unlock()
            didChangeValue(forKey: "state")
        }
    }

    override class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String> {
        if ["isReady", "isExecuting", "isFinished"].contains(key) {
            return ["state"]
        }
        return []
    }

    override var isExecuting: Bool {
        return state == .executing
    }

    override var isFinished: Bool {
        return state == .finished
    }

    override var isReady: Bool {
        switch state {
        case .initialed:
            return isCancelled
        case .ready:
            return super.isReady || isCancelled
        default:
            return false
        }
    }

    #if DEVELOP
    deinit {
        print("ToastOperation:\(self.style) deinit")
    }
    #endif
    
    init(style: ToastOperationStyle, task: @escaping Task) {
        self.task = task
        self.style = style
        super.init()
        self.state = .ready
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
        state = .executing
        task(self);
        self.removeAllDependencies()
    }

    fileprivate func removeAllDependencies() {
        for op in dependencies {
            self.removeDependency(op)
        }
    }

    func finish() {
        state = .finished
        task = nil
    }
}
