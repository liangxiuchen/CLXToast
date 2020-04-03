//
//  CustomHudContent.swift
//  CLXToast_Example
//
//  Created by chen liangxiu on 2018/1/26.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import Foundation
import CLXToast

class CustomHudContent: ToastContent {
    @IBOutlet var customView: UIView!
    init() {
        super.init(style: .custom_hud)
        UINib(nibName: "CustomHud", bundle: nil).instantiate(withOwner: self, options: nil);
    }

    override func addSubviews(to contentView: UIView) {
        contentView.addSubview(customView)
    }
    
    override func layoutSubviews(at contentView: UIView) {
        customView.translatesAutoresizingMaskIntoConstraints = false
        let leading = NSLayoutConstraint(item: customView as Any, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 0);

        let top = NSLayoutConstraint(item: customView as Any, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 0);

        let bottom = NSLayoutConstraint(item: customView as Any, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1, constant: 0)

        let trailing = NSLayoutConstraint(item: customView as Any, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: 0);

        let width = NSLayoutConstraint(item: customView as Any, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 175)
        
        let height = NSLayoutConstraint(item: customView as Any, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 179)
        contentView.addConstraints([leading, top, bottom, trailing, width, height])
    }
}
