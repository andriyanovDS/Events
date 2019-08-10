//
//  ModalScreenView.swift
//  Events
//
//  Created by Сослан Кулумбеков on 05/08/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia

class PermissionModalScreenView: UIView {
    let submitButton = ButtonWithBorder()
    let titleLabel = UILabel()
    let descriptionLabel = UILabel()
    let image = UIImageView()
    let viewData: PermissionModal
    
    init(dataView: PermissionModal) {
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
            descriptionLabel,
            image,
            submitButton
        )
        
        layout(
            150,
            |-titleLabel-|,
            100,
            |-image-|,
            50,
            |-descriptionLabel-|
        )
        
        submitButton
            .bottom(150)
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
            v.layer.cornerRadius = 50/2
            v.translatesAutoresizingMaskIntoConstraints = false
            v.contentMode = .scaleAspectFit
            v.width(150)
            v.height(150)
            v.image = UIImage(named: viewData.image)
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
