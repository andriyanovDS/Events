//
//  ProfileActionSection.swift
//  Events
//
//  Created by Дмитрий Андриянов on 29/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import SwiftIconFont

class ProfileActionSection: UIView {

    let labelText: String
    let subtitleText: String?
    let iconName: String

    var label = UILabel()

    override var bounds: CGRect {
        didSet {
            addBorder(
                toSide: .bottom,
                withColor: UIColor.gray400().cgColor,
                andThickness: 1.0
            )
        }
    }

    init(labelText: String, subtitleText: String?, iconName: String) {
        self.labelText = labelText
        self.subtitleText = subtitleText
        self.iconName = iconName
        super.init(frame: CGRect())
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
         fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        layoutMargins = UIEdgeInsets(
            top: 10,
            left: 0,
            bottom: 10,
            right: 0
        )
        setupLabel()
        setupIcon()

        if let subtitle = subtitleText {
            setupSubtitle(text: subtitle)
        }
    }

    private func setupLabel() {
        label.text = labelText
        label.textColor = UIColor.gray800()
        label.font = UIFont.init(name: "CeraPro-Medium", size: 18)
        addSubview(label)
        
        setupLabelConstraints()
    }

    private func setupSubtitle(text: String) {
        let label = UILabel()
        label.text = text
        label.textColor = UIColor.gray600()
        label.font = UIFont.init(name: "CeraPro-Medium", size: 15)
        addSubview(label)

        setupSubtitleConstraints(label)
    }

    private func setupIcon() {
        let image = UIImage(
            from: .materialIcon,
            code: iconName,
            textColor: UIColor.gray800(),
            backgroundColor: .clear,
            size: CGSize(width: 35, height: 35)
        )
        let imageView = UIImageView(image: image)
        addSubview(imageView)

        setupIconConstraints(imageView)
    }

    private func setupLabelConstraints() {
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.topAnchor.constraint(equalTo: topAnchor)
            ])
    }

    private func setupSubtitleConstraints(_ subtitle: UIView) {
        subtitle.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            subtitle.leadingAnchor.constraint(equalTo: leadingAnchor),
            subtitle.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 5)
            ])
    }

    private func setupIconConstraints(_ icon: UIView) {
        icon.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            icon.trailingAnchor.constraint(equalTo: trailingAnchor),
            icon.topAnchor.constraint(equalTo: topAnchor, constant: 0)
            ])
    }
}
