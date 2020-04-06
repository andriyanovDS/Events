//
//  BottomModalViewController.swift
//  Events
//
//  Created by Dmitry on 06.04.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit

protocol ModalView: UIView {
	var backgroundView: UIView { get }
	var contentView: UIView { get }
	func didLoad()
}

class BottomModalViewController<View: ModalView>: UIViewController {
	var modalView: View!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupView()
	}
	
	override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    animateAppearance()
  }
	
	func setupView() {
		self.view = modalView
		modalView.contentView.transform = CGAffineTransform(
      translationX: 0,
      y: UIScreen.main.bounds.height
    )
		modalView.didLoad()
	}
	
	private func animateAppearance() {
    UIView.animate(
			withDuration: 0.4,
			delay: 0,
      usingSpringWithDamping: 0.9,
      initialSpringVelocity: 1,
      options: .curveEaseInOut,
      animations: {
				self.modalView.contentView.transform = .identity
      },
      completion: nil
    )
  }

	func animateDisappearance(completion: @escaping () -> Void) {
    UIView.animate(
			withDuration: 0.4,
      animations: {
				self.modalView.contentView.transform = CGAffineTransform(
          translationX: 0,
          y: UIScreen.main.bounds.height
        )
      },
      completion: { _ in completion() }
    )
  }
}
