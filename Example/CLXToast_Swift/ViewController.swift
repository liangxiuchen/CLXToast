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

    @IBAction func showHudDemo(_ sender: UIButton) {
        Toast.hudBuilder.title("it is a title").show()
        Toast.hudBuilder.subtitle("it is a subtitle").show()
        Toast.hudBuilder.icon(#imageLiteral(resourceName: "toast")).show()
        Toast.hudBuilder.title("it is a title").subtitle("it is a subtitle").show()
        Toast.hudBuilder.title("it is a long long long long long long long title").subtitle("it is a long long long long long long long long long long long long subtitle").icon(#imageLiteral(resourceName: "toast")).show()

        //adjust titles space demo
        Toast.hudBuilder.title("adjust space").subtitle("adjust space between title and subtitle").interTitlesSpacing(10).show()
        Toast.hudBuilder.title("adjust space").subtitle("adjust space between titles and icon").icon(#imageLiteral(resourceName: "toast")).interTitlesIconSpacing(10).show()

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
        Toast.hudBuilder.titleLabel(title).subtitleLabel(subtitle).icon(#imageLiteral(resourceName: "toast")).show()

        //completion callback demo
        Toast.hudBuilder.title("it is a completion callback test").show(animated: true) {
            print("--------------------hud is finished--------------------")
        }

        //config toast instance
        let tst = Toast()
        tst.isConcurrent = true
        tst.contentView.backgroundColor = UIColor.green
        tst.aHudBuilder.title("it is a concurrent toast").show()

        // full custom hud Demo
        let customHud = CustomHudContent()
        let toast = Toast()
        toast.custom(content: customHud).show()

        //cancel demo
        Toast.hudBuilder.title("i will cancel all").show(animated: true) {
            Toast.hudBuilder.title("i will never appear").show()
            Toast.cancelAll()
        }

    }

    @IBAction func showWaitingDemo(_ sender: UIButton) {
        Toast.waitingBuilder.prompt("同步中...同步中...同步中...同步中...同步中...同步中...同步中...同步中...同步中...同步中...同步中...同步中...同步中...同步中...同步中...同步中...同步中...同步中...同步中...同步中...同步中...同步中...同步中...同步中...").show()
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            Toast.currentWaiting?.dismiss(animated: true)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4)) {
            Toast.waitingBuilder.prompt("等待完成回调...").show(animated: true) {
                Toast.hudBuilder.title("waiting completion").show()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                Toast.currentWaiting?.dismiss()
            }
        }
    }
}

