//
//  PopUpWindow.swift
//  Events
//
//  Created by Сослан Кулумбеков on 21/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit



class PopUpWindow: UIView {

    var delegate: PopUpDelegate?
    var coordinator: MainCoordinator?
   
    lazy var notificationLabel: UILabel = {
        let lable = UILabel()
        lable.translatesAutoresizingMaskIntoConstraints = false
        lable.font = UIFont(name: "CeraPro-Medium", size: 16)
        lable.textColor = UIColor.gray900()
        lable.textAlignment = .left
        return lable
    }()
    
    func setupView(with labelText: String) {
        notificationLabel.text = labelText
    }
    lazy var button: UIButtonScaleOnPress = {
        let button = UIButtonScaleOnPress()
        button.backgroundColor = .blue
        button.setTitle("Понятно", for: .normal)
        button.addTarget(self, action: #selector(handleDismissal), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 5
        return button
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        addSubview(notificationLabel)
        notificationLabel.numberOfLines = 2
        notificationLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -28).isActive = true
        notificationLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        addSubview(button)
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.leftAnchor.constraint(equalTo: leftAnchor, constant: 12).isActive = true
        button.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12).isActive = true
        button.rightAnchor.constraint(equalTo: rightAnchor, constant: -12).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func handleDismissal() {
        delegate?.hadleDismissal()
    }
}
