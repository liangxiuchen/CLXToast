//
//  DefaultHud.swift
//  CLXToast
//
//  Created by chen liangxiu on 2018/1/25.
//

import Foundation

final class DefaultHud: ToastContent, DefaultHudExport {

    weak var toast: Toast! //为了链式语法，直接一步到位show出来

    @discardableResult
    public func show(in container: UIView, with layout: ((Toast) -> Void)?, animated: Bool, completion: (() -> Void)?) -> Toast {
        return self.toast!.show(in: container, with: layout, animated: animated, completion: completion)
    }
    @discardableResult
    public func show(animated: Bool = true, with completion: (() -> Void)? = nil) -> Toast {
        return self.toast!.show(animated: animated, with: completion)
    }

    var contentInset: UIEdgeInsets = UIEdgeInsets.init(top: 12, left: 12, bottom: 12, right: 12)
    @discardableResult
    public func contentInset(_ inset: UIEdgeInsets) -> DefaultHud {
        contentInset = inset
        return self
    }

    var _titleLabel: UILabel!
    @discardableResult
    public func title(_ newValue: String) -> DefaultHud {//标题的快捷链式语法糖 (hud 模式)
        if _titleLabel == nil {
            _titleLabel = UILabel()
            _titleLabel.textColor = UIColor.white
            _titleLabel.font = UIFont.systemFont(ofSize: 16.0)
            _titleLabel.preferredMaxLayoutWidth = UIScreen.main.bounds.size.width * 0.8
            _titleLabel.numberOfLines = 0
        }
        _titleLabel.text = newValue
        return self
    }

    @discardableResult
    func titleLabel(_ newValue: UILabel?) -> DefaultHud {
        _titleLabel = newValue
        return self
    }

    var _subtitleLabel :UILabel!
    @discardableResult
    public func subtitle(_ newValue: String) -> DefaultHud {//子标题的快捷链式语法糖 (hud 模式)
        if _subtitleLabel == nil {
            _subtitleLabel = UILabel()
            _subtitleLabel.textColor = UIColor.white
            _subtitleLabel.font = UIFont.systemFont(ofSize: 15.0)
            _subtitleLabel.preferredMaxLayoutWidth = UIScreen.main.bounds.size.width * 0.8
            _subtitleLabel.numberOfLines = 0
        }
        _subtitleLabel.text = newValue
        return self
    }

    @discardableResult
    func subtitleLabel(_ newValue: UILabel?) -> DefaultHud {
        _subtitleLabel = newValue
        return self
    }

    var _iconView: UIImageView! //小图标默认在左边居中,可以自定义布局（hud 模式
    @discardableResult
    public func icon(_ newValue: UIImage?) -> DefaultHud {//icon的快捷链式语法糖 (hud 模式)
        if _iconView == nil {
            _iconView = UIImageView(image: newValue)
            _iconView.contentMode = .scaleAspectFit
        }
        _iconView.image = newValue
        return self
    }

    @discardableResult
    func iconView(_ newValue: UIImageView?) -> DefaultHud {
        _iconView = newValue
        return self
    }

    override func addSubviews(to contentView: UIView) {
        if let icon = _iconView, icon.superview == nil {
            _iconView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            contentView.addSubview(icon)
        }

        var empty = _titleLabel?.text?.isEmpty ?? true
        if !empty && _titleLabel.superview != contentView {
            _titleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
            contentView.addSubview(_titleLabel)
        }

        empty = _subtitleLabel?.text?.isEmpty ?? true
        if !empty && _subtitleLabel.superview != contentView {
            _subtitleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            contentView.addSubview(_subtitleLabel)
        }
    }

    var _titlesSpace: CGFloat = 4
    @discardableResult
    func interTitlesSpacing(_ space: CGFloat) -> Self {
        _titlesSpace = max(0.0, space)
        return self
    }

    var _titlesIconSpace: CGFloat = 4
    @discardableResult
    func interTitlesIconSpacing(_ space: CGFloat) -> Self {
        _titlesIconSpace = max(0.0, space)
        return self
    }

    init() {
        super.init(style: .hud)
    }

    override func layoutSubviews(at contentView: UIView) {
        let iconEmpty = _iconView?.image == nil ? true : false
        let titleEmpty = _titleLabel?.text?.isEmpty ?? true
        let subtitleEmpty = _subtitleLabel?.text?.isEmpty ?? true

        // only title exist
        if !titleEmpty && iconEmpty && subtitleEmpty {
            _titleLabel.translatesAutoresizingMaskIntoConstraints = false
            self.constraintOneitem(target: _titleLabel, in: contentView)
        }
        //only subtitle exist
        if !subtitleEmpty && iconEmpty && titleEmpty {
            _subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
            self.constraintOneitem(target: _subtitleLabel, in: contentView)
        }
        //only icon Imageview exist
        if !iconEmpty && titleEmpty && subtitleEmpty {
            _iconView.translatesAutoresizingMaskIntoConstraints = false
            self.constraintOneitem(target: _iconView, in: contentView)
        }

        //only title and subtitle exist
        if !titleEmpty && !subtitleEmpty && iconEmpty {
            _titleLabel.translatesAutoresizingMaskIntoConstraints = false
            _subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
            self.constraintTitleWithSubtitle(in: contentView)
            self.constraintSubtitleWithTitle(in: contentView)
        }
        //only icon and tile
        if !iconEmpty && !titleEmpty && subtitleEmpty {
            _iconView.translatesAutoresizingMaskIntoConstraints = false
            _titleLabel.translatesAutoresizingMaskIntoConstraints = false
            self.constraintIconWithALabel(in: contentView)
            self.constraintLabelWithIcon(target: _titleLabel, in: contentView)
        }
        //only icon and subtitle
        if !iconEmpty && titleEmpty && !subtitleEmpty {
            _iconView.translatesAutoresizingMaskIntoConstraints = false
            _subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
            self.constraintIconWithALabel(in: contentView)
            self.constraintLabelWithIcon(target: _subtitleLabel, in: contentView)
        }

        //icon ,title , subtitle all exist
        if !iconEmpty && !titleEmpty && !subtitleEmpty {
            _iconView.translatesAutoresizingMaskIntoConstraints = false
            _titleLabel.translatesAutoresizingMaskIntoConstraints = false
            _subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
            _subtitleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            _titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            self.constraintAllItem(in: contentView)
        }
    }

    func constraintOneitem(target: UIView, in contentView: UIView) {
        let leading = NSLayoutConstraint(item: target, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: contentInset.left);

        let top = NSLayoutConstraint(item: target, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: contentInset.top);

        let bottom = NSLayoutConstraint(item: target, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1, constant: -contentInset.bottom)

        let trailing = NSLayoutConstraint(item: target, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: -contentInset.right);
        contentView.addConstraints([leading, top, bottom, trailing])
    }

    func constraintTitleWithSubtitle(in contentView: UIView) {
        let leading = NSLayoutConstraint(item: _titleLabel, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: contentInset.left);

        let top = NSLayoutConstraint(item: _titleLabel, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: contentInset.top);

        let trailing = NSLayoutConstraint(item: _titleLabel, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: contentView, attribute: .trailing, multiplier: 1, constant: -contentInset.right);

        contentView.addConstraints([leading, top, trailing])
    }

    func constraintSubtitleWithTitle(in contentView: UIView) {
        let leading = NSLayoutConstraint(item: _subtitleLabel, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: contentInset.left);

        let top = NSLayoutConstraint(item: _subtitleLabel, attribute: .top, relatedBy: .equal, toItem: _titleLabel, attribute: .bottom, multiplier: 1, constant: _titlesSpace);

        let trailing = NSLayoutConstraint(item: _subtitleLabel, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: contentView, attribute: .trailing, multiplier: 1, constant: -contentInset.right);

        let bottom = NSLayoutConstraint(item: _subtitleLabel, attribute: .lastBaseline, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1, constant: -contentInset.bottom)

        contentView.addConstraints([leading, top, trailing, bottom])
    }

    func constraintIconWithALabel(in contentView: UIView) {
        let leading = NSLayoutConstraint(item: _iconView, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: contentInset.left);

        let top = NSLayoutConstraint(item: _iconView, attribute: .top, relatedBy: .greaterThanOrEqual, toItem: contentView, attribute: .top, multiplier: 1, constant: contentInset.top);

        let bottom = NSLayoutConstraint(item: _iconView, attribute: .bottom, relatedBy: .lessThanOrEqual, toItem: contentView, attribute: .bottom, multiplier: 1, constant: -contentInset.bottom)

        contentView.addConstraints([leading, top, bottom])
    }

    func constraintLabelWithIcon(target: UILabel, in contentView: UIView) {
        let leading = NSLayoutConstraint(item: target, attribute: .leading, relatedBy: .equal, toItem: _iconView, attribute: .trailing, multiplier: 1, constant: _titlesIconSpace);

        let top = NSLayoutConstraint(item: target, attribute: .top, relatedBy: .greaterThanOrEqual, toItem: contentView, attribute: .top, multiplier: 1, constant: contentInset.top);

        let trailing = NSLayoutConstraint(item: target, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: -contentInset.right);

        let bottom = NSLayoutConstraint(item: target, attribute: .bottom, relatedBy: .lessThanOrEqual, toItem: contentView, attribute: .bottom, multiplier: 1, constant: -contentInset.bottom)

        let equalCenterY = NSLayoutConstraint(item: target, attribute: .centerY, relatedBy: .equal, toItem: _iconView, attribute: .centerY, multiplier: 1, constant: 0)
        contentView.addConstraints([leading, top, trailing, bottom, equalCenterY])
    }

    func constraintAllItem(in contentView: UIView) {
        //prepear
        let wrapper = self.userWrapperForTitlesInAllItemExist()
        contentView.addSubview(wrapper)

        let wrapper_size = wrapper.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize);
        _iconView.sizeToFit()

        let icon_heigher = _iconView.bounds.size.height > wrapper_size.height

        //icon
        let icon_leading = NSLayoutConstraint(item: _iconView, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: contentInset.left);

        let icon_top = NSLayoutConstraint(item: _iconView, attribute: .top, relatedBy: (icon_heigher ? .equal : .greaterThanOrEqual), toItem: contentView, attribute: .top, multiplier: 1, constant: contentInset.top)

        let icon_bottom = NSLayoutConstraint(item: _iconView, attribute: .bottom, relatedBy: (icon_heigher ? .equal : .lessThanOrEqual), toItem: contentView, attribute: .bottom, multiplier: 1, constant: -contentInset.bottom)

        if icon_heigher == false {
            let icon_centerY = NSLayoutConstraint(item: _iconView, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1, constant: 0)
            contentView.addConstraint(icon_centerY)
        }

        contentView.addConstraints([icon_leading, icon_top, icon_bottom])


        let wrapper_leading = NSLayoutConstraint(item: wrapper, attribute: .leading, relatedBy: .equal, toItem: _iconView, attribute: .trailing, multiplier: 1, constant: _titlesIconSpace)

        let wrapper_top = NSLayoutConstraint(item: wrapper, attribute: .top, relatedBy: (icon_heigher == false ? .equal : .greaterThanOrEqual), toItem: contentView, attribute: .top, multiplier: 1, constant: contentInset.top)

        let wrapper_trailing = NSLayoutConstraint(item: wrapper, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: -contentInset.right)

        let wrapper_bottom = NSLayoutConstraint(item: wrapper, attribute: .bottom, relatedBy: (icon_heigher == false ? .equal : .lessThanOrEqual), toItem: contentView, attribute: .bottom, multiplier: 1, constant: -contentInset.bottom)
        contentView.addConstraints([wrapper_leading, wrapper_top, wrapper_trailing, wrapper_bottom])

        if icon_heigher {
            let wrapper_centerY = NSLayoutConstraint(item: wrapper, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1, constant: 0)
            contentView.addConstraint(wrapper_centerY)
        } else {
            let icon_centerY = NSLayoutConstraint(item: _iconView, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1, constant: 0)
            contentView.addConstraint(icon_centerY)
        }
    }

    func userWrapperForTitlesInAllItemExist() -> UIView {
        //deal with title and subtitle
        let wrapper = UIView()
        wrapper.translatesAutoresizingMaskIntoConstraints = false
        wrapper.backgroundColor = UIColor.clear
        wrapper.addSubview(_titleLabel)
        wrapper.addSubview(_subtitleLabel)

        //title
        let title_leading = NSLayoutConstraint(item: _titleLabel, attribute: .leading, relatedBy: .equal, toItem: wrapper, attribute: .leading, multiplier: 1, constant: 0);

        let title_top = NSLayoutConstraint(item: _titleLabel, attribute: .top, relatedBy: .equal, toItem: wrapper, attribute: .top, multiplier: 1, constant: 0);

        let title_trailing = NSLayoutConstraint(item: _titleLabel, attribute: .trailing, relatedBy: .equal, toItem: wrapper, attribute: .trailing, multiplier: 1, constant: 0);

        wrapper.addConstraints([title_leading, title_top, title_trailing])
        //subtitle
        let subtitle_leading = NSLayoutConstraint(item: _subtitleLabel, attribute: .leading, relatedBy: .equal, toItem: wrapper, attribute: .leading, multiplier: 1, constant: _titlesIconSpace);

        let subtitle_top = NSLayoutConstraint(item: _subtitleLabel, attribute: .top, relatedBy: .equal, toItem: _titleLabel, attribute: .bottom, multiplier: 1, constant: _titlesSpace);

        let subtitle_trailing = NSLayoutConstraint(item: _subtitleLabel, attribute: .trailing, relatedBy: .equal, toItem: wrapper, attribute: .trailing, multiplier: 1, constant: 0);

        let subtitle_bottom = NSLayoutConstraint(item: _subtitleLabel, attribute: .bottom, relatedBy: .equal, toItem: wrapper, attribute: .bottom, multiplier: 1, constant: 0)

        wrapper.addConstraints([subtitle_leading, subtitle_top, subtitle_trailing, subtitle_bottom])

        return wrapper
    }
}
