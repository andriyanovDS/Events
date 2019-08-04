//
//  LocationView.swift
//  Events
//
//  Created by Дмитрий Андриянов on 04/08/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia

class LocationView: UIView {

    let locationButton = UIButton()
    let submitButton = ButtonWithBorder()
    private let contentView = UIView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()

    init(locationName: String) {
        super.init(frame: CGRect.zero)
        setupView(locationName: locationName)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView(locationName: String) {
        backgroundColor = .white

        styleText(
            label: titleLabel,
            text: "Место проведения",
            size: 26,
            color: .gray900(),
            style: .bold
        )

        styleText(
            label: descriptionLabel,
            text: "Где будет проходить мероприятие?",
            size: 18,
            color: .gray400(),
            style: .regular
        )

        styleText(
            button: locationButton,
            text: locationName,
            size: 18,
            color: .gray900(),
            style: .medium
        )

        locationButton.style({ v in
            v.contentEdgeInsets = UIEdgeInsets(
                top: 7,
                left: 10,
                bottom: 7,
                right: 10
            )
            v.contentHorizontalAlignment = .left
            v.layer.borderWidth = 1
            v.layer.cornerRadius = 4
            v.layer.borderColor = UIColor.gray200().cgColor
        })

        styleText(
            button: submitButton,
            text: "Далее",
            size: 20,
            color: .blue(),
            style: .medium
        )
        submitButton.layer.borderColor = UIColor.blue().cgColor
        sv(contentView.sv([titleLabel, descriptionLabel, locationButton, submitButton]))
        setupConstraints()
    }

    private func setupConstraints() {
        contentView.left(20).right(20)
        contentView.Top == safeAreaLayoutGuide.Top
        contentView.Bottom == safeAreaLayoutGuide.Bottom

        titleLabel
            .top(20%)
            .left(0)
            .right(0)

        align(vertically: [titleLabel, descriptionLabel, locationButton])

        layout(
            |-titleLabel-|,
            8,
            |-descriptionLabel-|,
            45,
            |-locationButton.height(40)-|
        )

        submitButton.width(200).centerHorizontally()
        submitButton.Bottom == contentView.Bottom - 50
    }
}
