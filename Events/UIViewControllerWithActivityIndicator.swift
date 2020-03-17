//
//  UIViewControllerActivityIndicatorExtension.swift
//  Events
//
//  Created by Дмитрий Андриянов on 12/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia

class UIViewControllerWithActivityIndicator: UIViewController {

  lazy var activityIndicatorView: UIView = {
		let activityIndicatorView = UIView(frame: CGRect.zero)
		activityIndicatorView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
    let activityIndicator = UIActivityIndicatorView.init(style: .gray)
    activityIndicator.startAnimating()
    activityIndicatorView.sv(activityIndicator)
		activityIndicator.centerInContainer()
    return activityIndicatorView
  }()

  func showActivityIndicator(for view: UIView?) {
    let wrapperView: UIView = view ?? self.view
    wrapperView.sv(activityIndicatorView)
		activityIndicatorView.fillContainer().centerInContainer()
  }

  func removeActivityIndicator() {
    UIView.animate(withDuration: 0.1, animations: {
      self.activityIndicatorView.alpha = 0
    }, completion: {[weak self] _ in
      self?.activityIndicatorView.removeFromSuperview()
    })
  }
}
