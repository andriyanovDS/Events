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
    activityIndicatorView.backgroundColor = UIColor.gray200(alpha: 0.5)
    let activityIndicator = UIActivityIndicatorView.init(style: .gray)
    activityIndicator.center = activityIndicatorView.center
    activityIndicator.startAnimating()
    activityIndicatorView.addSubview(activityIndicator)
    return activityIndicatorView
  }()

  func showActivityIndicator(for view: UIView?) {
    let wrapperView: UIView = view ?? self.view
    wrapperView.addSubview(activityIndicatorView)
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
