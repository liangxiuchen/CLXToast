//
//  ViewController.swift
//  Demo
//
//  Created by chen liangxiu on 2018/1/15.
//  Copyright © 2018年 liangxiu.chen.cn. All rights reserved.
//

import UIKit
import CLXToast

class CustomContent: ToastContent {
//    override init(style: ToastStyle, Inset: UIEdgeInsets, delegate: Toastable) {
//        super.init(style: .custom_hud, Inset: Inset, delegate: delegate)
//    }
}

class ViewController: UIViewController {

    @IBAction func showHudDemo(_ sender: UIButton) {
        Toast.hud.title("it is a title").show()
        Toast.hud.subtitle("it is a subtitle").show()
        Toast.hud.icon(#imageLiteral(resourceName: "toast")).show()
        Toast.hud.title("it is a title").subtitle("it is a subtitle").show()
        Toast.hud.title("it is a long long long long long long long title").subtitle("it is a long long long long long long long long long long long longsubtitle").icon(#imageLiteral(resourceName: "toast")).show()
        //adjust titles space demo
        Toast.hud.title("adjust space").subtitle("adjust space between title and subtitle").interTitlesSpacing(10).show()
        Toast.hud.title("adjust space").subtitle("adjust space between titles and icon").icon(#imageLiteral(resourceName: "toast")).interTitlesIconSpacing(10).show()
        //custom subtitle Lable same as title and icon demo
        let subtitle = UILabel()
        subtitle.text = "adjust space between titles and icon"
        subtitle.preferredMaxLayoutWidth = 40
        subtitle.numberOfLines = 0
        let title = UILabel()
        title.text = "it is a title"
        title.preferredMaxLayoutWidth = 100
        title.numberOfLines = 0
        title.font = UIFont.systemFont(ofSize: 16)
        title.textColor = UIColor.green
        Toast.hud.titleLabel(title).subtitleLabel(subtitle).icon(#imageLiteral(resourceName: "toast")).show()
        //completion callback demo
        Toast.hud.title("it is a completion callback test").show(animated: true) {
            print("--------------------hud is finished--------------------")
        }
        //config toast instance
        let tst = Toast()
        tst.isConcurrent = true
        tst.contentView.backgroundColor = UIColor.green
        tst.aHud.title("it is a concurrent toast").show()
        //cancel demo
        Toast.hud.title("i will cancel all, which are appear after me").show(animated: true) {
            Toast.cancelAll()
        }
        Toast.hud.title("i will never appear").show()
    }

    @IBAction func showWaitingDemo(_ sender: UIButton) {
        let allItemWaiting = Toast.waiting.prompt("同步中...").show()
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            allItemWaiting.dismiss()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4)) {
            let waitingWithCallBack = Toast.waiting.prompt("等待完成回调...").show(animated: true) {
                Toast.hud.title("waiting completion").show()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                waitingWithCallBack.dismiss()
            }
        }
    }
}

