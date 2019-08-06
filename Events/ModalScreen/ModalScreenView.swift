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
    let image = UILabel()
    let contentView = UIView()
    
    init() {
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = .white
        sv(
            titleLabel,
            image,
            descriptionLabel,
            submitButton
        )
        setupPopupView()
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
        titleLabel.style({ v in
            v.textColor = UIColor.gray800()
            v.textAlignment = .center
            v.numberOfLines = 3
            v.font = UIFont.init(name: "CeraPro-Medium", size: 22)
        })
        
        descriptionLabel.style({ v in
            v.textColor = UIColor.black
            v.numberOfLines = 2
            v.textAlignment = .center
            v.font = UIFont.init(name: "CeraPro-Medium", size: 20)
        })
        
        image.style({v in
            v.textAlignment = .center
            v.font = UIFont.init(name: "CeraPro-Medium", size: 100)
        })
        
        submitButton.style({ v in
            v.layer.borderColor = UIColor.blue().cgColor
            v.setTitleColor(UIColor.blue(), for: .normal)
            v.contentEdgeInsets = UIEdgeInsets(
                top: 10,
                left: 0,
                bottom: 10,
                right: 0
            )
            v.titleLabel?.font = UIFont(name: "CeraPro-Medium", size: 20)
        })
    }
}
