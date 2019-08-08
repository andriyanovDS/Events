//
//  ModalScreenView.swift
//  Events
//
//  Created by Сослан Кулумбеков on 05/08/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia

class ModalScreenView: UIView {
    let submitButton = ButtonWithBorder()
    let titleLabel = UILabel()
    let descriptionLabel = UILabel()
    let image = UIImageView()
    let viewData: Modal
    
    init(dataView: Modal) {
        viewData = dataView
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = .white
        setupPopupView()
        sv(
            titleLabel,
            image,
            descriptionLabel,
            submitButton
        )
    
        layout(
            150,
            |-titleLabel-|,
            50,
            |-descriptionLabel-|,
            50,
            |-image-|
        )
        
        submitButton
            .bottom(50)
            .left(50)
            .right(50)
            .height(45)
    }
    
    private func setupPopupView(){
        styleText(
            label: titleLabel,
            text: viewData.title,
            size: 26,
            color: .gray900(),
            style: .bold
        )
        titleLabel.style({v in
            v.textAlignment = .center
        })
        
        styleText(
            label: descriptionLabel,
            text: viewData.description,
            size: 26,
            color: .gray900(),
            style: .regular
        )
        descriptionLabel.style({v in
            v.textAlignment = .center
            v.numberOfLines = 2
        })
        
        image.style({v in
            v.backgroundColor = UIColor.gray200()
            v.layer.cornerRadius = 50/2
        })
        
        styleText(
            button: submitButton,
            text: viewData.buttonLabelText,
            size: 20,
            color: .blue(),
            style: .medium
        )
        
        submitButton.style({ v in
            v.layer.borderColor = UIColor.blue().cgColor
            v.contentEdgeInsets = UIEdgeInsets(
                top: 10,
                left: 0,
                bottom: 10,
                right: 0
            )
        })
    }
}
