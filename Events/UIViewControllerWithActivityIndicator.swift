//
//  UIViewControllerActivityIndicatorExtension.swift
//  Events
//
//  Created by Дмитрий Андриянов on 12/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit

class UIViewControllerWithActivityIndicator: UIViewController {

  lazy var activityIndicatorView: UIView = {
    let activityIndicatorView = UIView(frame: self.view.bounds)
    activityIndicatorView.backgroundColor = UIColor.gray200(alpha: 0.5)
    let activityIndicator = UIActivityIndicatorView.init(style: .gray)
    activityIndicator.center = activityIndicatorView.center
    activityIndicator.startAnimating()
    activityIndicatorView.addSubview(activityIndicator)
    return activityIndicatorView
  }()

  func showActivityIndicator(for view: UIView?) {
    let wrapperView: UIView = view ?? self.view
    if view != self.view {
      activityIndicatorView.bounds = wrapperView.bounds
    }
    wrapperView.addSubview(activityIndicatorView)
  }

  func removeActivityIndicator() {
    UIView.animate(withDuration: 0.1, animations: {
      self.activityIndicatorView.alpha = 0
    }, completion: {[weak self] _ in
      self?.activityIndicatorView.removeFromSuperview()
    })
  }
}
