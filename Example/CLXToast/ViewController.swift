//
//  ViewController.swift
//  Demo
//
//  Created by chen liangxiu on 2018/1/15.
//  Copyright © 2018年 liangxiu.chen.cn. All rights reserved.
//

import UIKit
import CLXToast
class ViewController: UIViewController {
    var demos: [() -> Void] = []
    var waitingDemos: [() -> Void] = []

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func showHudDemo(_ sender: UIButton) {

        func onlyTitle() {
            Toast(style: .hud).title("nihao").subtitle("subtitle").show(animated: true) {
                DispatchQueue.main.async {
//                    Toast.cancelAll()
                }
            }
        }
        demos.append(onlyTitle)
        func onlySubTitle() {
            let toast = Toast(style: .hud)
//            toast.isConcurrent = true
            toast.subtitle("only subtitle").show()
        }
        demos.append(onlySubTitle)
        func onlyIcon() {
            let toast = Toast(style: .hud)
            toast.iconView = UIImageView(image: UIImage(named: "toast"))
            toast.show(animated: true, with: nil)
        }
        demos.append(onlyIcon)
        func allTitleWithoutIcon() {
            Toast(style: .hud).title("it is title").subtitle("it is subtitle").show()
        }
        demos.append(allTitleWithoutIcon)
        func allTitleandIcon() {
            let toast = Toast(style: .hud)
            toast.title("it is title").subtitle("it is subtitle").icon(UIImage(named: "toast")).show()
        }
        demos.append(allTitleandIcon)

        func attributeLabel() {
            let toast = Toast(style: .hud)
            toast.titleLabel = UILabel()
            toast.titleLabel.attributedText = NSAttributedString(string: "attibuted String label", attributes: [NSAttributedStringKey.backgroundColor : UIColor.green])
            toast.show(animated: true, with: nil)
        }
        demos.append(attributeLabel)

        func calledAsync() {
            let toast =  Toast(style: .hud)
            toast.title("异步线程调用")
            DispatchQueue.global().async {
                toast.show(animated: true, with: nil)
            }
        }
        demos.append(calledAsync)
        func completeBlock() {
            let toast = Toast(style: .hud)
            toast.title("我有complete,等我结束，会有一个结束后Toast回调提示")
            let comToast = Toast(style: .hud)
            comToast.title("completed")
            toast.show(animated: true) {
                comToast.show(animated: false, with: nil)
            }
        }
        demos.append(completeBlock)
        func customsubView() {
            let toast = Toast(frame: CGRect(x: 0, y: 0, width: 100, height: 100), style: .custom_hud)
            toast.show(in: self.view, with: { (toast) in
                let custTitle = UILabel(frame: CGRect(x: 50, y: 50, width: 10, height: 10))
                custTitle.text = "自定义"
                custTitle.sizeToFit()
                toast.contentView.addSubview(custTitle)

            }, animated: true, completion: nil)
        }
        demos.append(customsubView)
        for demo in demos {
            demo()
        }
        demos.removeAll()
    }

    @IBAction func showWaitingDemo(_ sender: UIButton) {
        func activityOnly() {
            let toast = Toast(style: .waiting)
            toast.show(animated: false) {
                print("default waiting")
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: 1000000)) {
                toast.dismiss(animated: true, with: {
                    DispatchQueue.main.async {
                        withPromptWaiting()
                    }
                })
            }
        }
        waitingDemos.append(activityOnly)
        func withPromptWaiting() {
            let toast = Toast(style: .waiting)
            toast.prompt("hello waiting").show(animated: false) {
                print("default waiting")
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: 1000000)) {
                toast.dismiss(animated: true, with: nil)
            }
        }
//        waitingDemos.append(withPromptWaiting)
        for demo in waitingDemos {
            demo()
        }
        waitingDemos.removeAll()
    }
}

