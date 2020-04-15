//
//  DescriptionCellView.swift
//  Events
//
//  Created by Дмитрий Андриянов on 03/03/2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia
import RxSwift

class DescriptionCellView: UICollectionViewCell {
  
  private struct Constants {
    static let animationDuration: CGFloat = 0.3
    static let addButtonSize: CGFloat = 27
  }
  
  static let reuseIdentifier = String(describing: SelectedImageCell.self)

  var selectAnimation: UIViewPropertyAnimator {
    let scaleAnimator = UIViewPropertyAnimator(
      duration: 0.3,
      dampingRatio: 0.7,
      animations: {[unowned self] in
        self.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
      }
    )
    let identityAnimator = UIViewPropertyAnimator(
      duration: 0.3,
      dampingRatio: 0.7,
      animations: {[unowned self] in
        self.transform = .identity
      }
    )
    scaleAnimator.addCompletion { _ in identityAnimator.startAnimation() }
    return scaleAnimator
  }
	
	var isActive: Bool = false {
		didSet {
			if isActive {
        addShadow(view: self, radius: 7, color: UIColor.blueButtonBackground, opacity: 0.5)
			} else {
				addShadow(view: self, radius: 1.8)
			}
		}
	}

  var state: State = .empty {
    didSet {
      if state != oldValue { self.stateDidChange() }
    }
  }
  var closure: (() -> Void)?
  let titleLabel = UILabel()
  private var cornerButton: DescriptionCellButton?
	private let buttonContentView = UIView()
  private let disposeBag = DisposeBag()

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func stateDidChange() {
    switch state {
    case .add:
      let button = DescriptionCellButton(backgroundColor: .blueButtonBackground)
      setupButton(button)
      return
    case .delete:
      let button = DescriptionCellButton(backgroundColor: .red)
      button.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 4)
      setupButton(button)
      return
    case .normal, .empty:
      attemptToRemoveButton()
      return
    }
  }

  private func setupView() {
		buttonContentView.backgroundColor = .background
		buttonContentView.layer.cornerRadius = 10

    titleLabel.textAlignment = .center
		titleLabel.numberOfLines = 1
		
    styleText(
      label: titleLabel,
      text: "",
      size: 16,
      color: .fontLabel,
      style: .bold
    )
    let skeletonView = SkeletonView()
		skeletonView.backgroundColor = .background
		sv(buttonContentView.sv([titleLabel, skeletonView]))
		
		buttonContentView
			.left(0)
			.bottom(0)
			.right(Constants.addButtonSize / 3)
			.top(Constants.addButtonSize / 3)
		
		titleLabel.left(5).right(5).top(5)
		
    skeletonView
      .right(5)
      .left(5)
      .bottom(30)
      .Top == titleLabel.Bottom + 5
  }
	
	private func animateButtonRemove(_ button: UIButton, completion: @escaping () -> Void) {
		let animator = UIViewPropertyAnimator(
			duration: 0.4,
			dampingRatio: 1,
			animations: { button.alpha = 0 }
		)
		animator.addCompletion { _ in
			button.removeFromSuperview()
		}
		animator.startAnimation()
	}
	
  private func setupButton(_ button: DescriptionCellButton) {
		sv(button)
		button
			.right(0)
			.top(0)
			.width(Constants.addButtonSize)
			.height(Constants.addButtonSize)
		cornerButton = button
    button.rx.tap.subscribe(onNext: {[unowned self] _ in
      self.closure?()
    })
    .disposed(by: disposeBag)
	 }
	
	private func attemptToRemoveButton() {
    guard let button = cornerButton else { return }
		button.removeFromSuperview()
    self.cornerButton = nil
	}
  
  override func prepareForReuse() {
    titleLabel.text = nil
    closure = nil
    state = .empty
		attemptToRemoveButton()
  }
}

extension DescriptionCellView {
  enum State: Equatable {
    case delete
    case add
    case normal
    case empty
  }
}
