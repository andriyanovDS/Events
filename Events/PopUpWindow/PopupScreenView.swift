//
//  PopupScreenView.swift
//  Events
//
//  Created by Сослан Кулумбеков on 03/08/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia

class PopupScreenView: UIView {
    let okButton = ButtonWithBorder()
    let titleLabel = UILabel()
    let descriptionLabel = UILabel()
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
        sv([
            titleLabel,
            descriptionLabel,
            okButton
        ])
        setupPopupView()
        layout([
            200,
            |-titleLabel-|,
            50,
            |-descriptionLabel-|,
            250,
            |-okButton-|
            ])
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
        
        okButton.style({ v in
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
