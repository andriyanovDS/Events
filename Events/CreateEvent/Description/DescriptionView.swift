//
//  DescriptionView.swift
//  Events
//
//  Created by Дмитрий Андриянов on 11/08/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia
import Photos

class DescriptionView: UIView {
  let selectedImagesCollectionView: UICollectionView
  let descriptionsCollectionView: DescriptionsCollectionView
  var titleTextField = UITextField()
  let textView = UITextView()
  let submitButton = ButtonScale()
  var state: State {
    didSet { stateDidChange(from: oldValue) }
  }
  private var titleLabel = UILabel()

  init(state: State) {
    self.state = state
    let selectedImagesLayout = UICollectionViewFlowLayout()
    selectedImagesLayout.scrollDirection = .horizontal
		selectedImagesLayout.sectionInset = UIEdgeInsets(
			top: 0,
			left: 10,
			bottom: 0,
			right: 10
		)
    selectedImagesLayout.itemSize = SelectedImageCell.Constants.imageSize
    selectedImagesLayout.minimumLineSpacing = 10
    selectedImagesCollectionView = UICollectionView(
      frame: CGRect.zero,
      collectionViewLayout: selectedImagesLayout
    )
		selectedImagesCollectionView.dragInteractionEnabled = true

    let descriptionsLayout = UICollectionViewFlowLayout()
    descriptionsLayout.scrollDirection = .horizontal
    descriptionsLayout.sectionInset = UIEdgeInsets(
      top: 10,
      left: 10,
      bottom: 10,
      right: 10
    )
    descriptionsLayout.itemSize = CGSize(
			width: UIScreen.main.bounds.width * 0.3,
      height: 130
    )
    descriptionsLayout.minimumLineSpacing = 2
    descriptionsCollectionView = DescriptionsCollectionView(
      frame: CGRect.zero,
      collectionViewLayout: descriptionsLayout
    )

    super.init(frame: CGRect.zero)
    setupView()
    setupSelectedImagesCollectionView()
    setupDescriptionsCollectionView()

    let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTap))
    tapRecognizer.cancelsTouchesInView = false
    addGestureRecognizer(tapRecognizer)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func stateDidChange(from oldState: State) {
    switch state {
    case .main(let isSelectedImagesEmpty, let text):
      textView.text = text
      if oldState.isEmptySelectedImages != isSelectedImagesEmpty {
        animateSelectedImagesCollectionView(isNextCollectionEmpty: isSelectedImagesEmpty)
      }
      if state != oldState {
        transition(from: titleTextField, to: titleLabel)
      }
    case .additional(let isSelectedImagesEmpty, let title, let text):
      textView.text = text
      titleTextField.text = title
      if oldState.isEmptySelectedImages != isSelectedImagesEmpty {
        animateSelectedImagesCollectionView(isNextCollectionEmpty: isSelectedImagesEmpty)
      }
      if state != oldState {
        transition(from: titleLabel, to: titleTextField)
      }
    }
  }
  
  private  func animateSelectedImagesCollectionView(isNextCollectionEmpty: Bool) {
    if !isNextCollectionEmpty && (textView.isFirstResponder || titleTextField.isFirstResponder) {
      return
    }
    UIView.animate(withDuration: 0.2, animations: {
      self.selectedImagesCollectionView.heightConstraint?.constant = isNextCollectionEmpty
        ? 0
        : SelectedImageCell.Constants.imageSize.height + 10
      self.layoutIfNeeded()
    })
  }
  
  private func transition(from currentView: UIView, to nextView: UIView) {
    let animator = UIViewPropertyAnimator(
      duration: 0.3,
      curve: .linear,
      animations: {
        currentView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        currentView.alpha = 0
      }
    )
    animator.addCompletion { _ in
      UIView.animate(
        withDuration: 0.2,
        delay: 0,
        options: .curveEaseIn,
        animations: { nextView.alpha = 1 },
        completion: { _ in
          currentView.transform = .identity
          nextView.isUserInteractionEnabled = true
        }
      )
    }
    animator.startAnimation()
  }

  private func setupTitleTextField() {
    let textField = selectTextFieldStyle(UITextField())
    textField.isUserInteractionEnabled = false
    styleText(
      textField: textField,
      text: NSLocalizedString(
        "Description title",
        comment: "Create event: description title text field placeholder"
      ),
      size: 22,
      color: .fontLabel,
      style: .bold
    )
    textField.alpha = 0
    titleTextField = textField
    sv(textField)
    textField.Top == titleLabel.Top
    textField
      .left(15)
      .right(45)
      .height(50)
  }

  private func setupSelectedImagesCollectionView() {
    selectedImagesCollectionView.style { v in
      v.backgroundColor = .background
      v.showsHorizontalScrollIndicator = false
      v.register(
        SelectedImageCell.self,
        forCellWithReuseIdentifier: SelectedImageCell.reuseIdentifier
      )
    }
  }

  private func setupDescriptionsCollectionView() {
    descriptionsCollectionView.style { v in
      v.backgroundColor = .clear
      v.isOpaque = false
      v.clipsToBounds = false
      v.showsHorizontalScrollIndicator = false
      v.register(
        DescriptionCellView.self,
        forCellWithReuseIdentifier: DescriptionCellView.reuseIdentifier
      )
    }
  }

  @objc private func onTap(_ recognizer: UITapGestureRecognizer) {
    endEditing(true)
  }

  private func setupView() {
    backgroundColor = .background

    styleText(
      label: titleLabel,
      text: NSLocalizedString(
        "Tell more about event",
        comment: "Create event: description section title"
      ),
      size: 26,
      color: .fontLabel,
      style: .bold
    )
    titleLabel.numberOfLines = 2
    styleText(
      textView: textView,
      text: "",
      size: 16,
      color: .fontLabel,
      style: .medium
    )
    styleText(
      button: submitButton,
      text: NSLocalizedString("Next step", comment: "Create event: next step"),
      size: 20,
      color: .blueButtonFont,
      style: .medium
    )

    textView.style({ v in
      v.layer.cornerRadius = 10
      v.backgroundColor = .textField
    })

    submitButton.style({ v in
      v.isEnabled = false
      v.backgroundColor = .blueButtonBackground
    })
    sv([titleLabel, textView, selectedImagesCollectionView, submitButton, descriptionsCollectionView])
    setupTitleTextField()
    setupConstraints()
  }

  private func setupConstraints() {
    titleLabel.Top == safeAreaLayoutGuide.Top + 20
    titleLabel.left(15).right(15)
    titleLabel.centerHorizontally()
    submitButton
      .centerHorizontally()
      .width(200)
      .bottom(75)

    selectedImagesCollectionView
      .left(5)
      .right(5)
			.height(0)
      .Bottom == submitButton.Top - 15

    descriptionsCollectionView
      .left(5)
      .right(5)
      .height(150)
      .bottom(-75)

    textView
      .left(15).right(15)
      .Top == titleLabel.Bottom + 30
    textView.Bottom == selectedImagesCollectionView.Top - 10
  }
}

extension DescriptionView: ViewWithKeyboard {
  func keyboardHeightDidChange(_ info: KeyboardAttachInfo?) {
    UIView.animate(withDuration: info?.duration ?? 0.2, animations: {
      let bottomConstraint = info
        .map { $0.height + 15.0 }
        .getOrElse(result: 75)
      self.selectedImagesCollectionView.heightConstraint?.constant = info
        .foldL(
          none: {
            if let itemsCount = self.selectedImagesCollectionView.dataSource?.collectionView(
              self.selectedImagesCollectionView,
              numberOfItemsInSection: 0
              ) {
              if itemsCount > 0 {
                return SelectedImageCell.Constants.imageSize.height + 10
              }
            }
            return 0
          },
          some: { _ in 0 }
        )
      self.submitButton.bottomConstraint?.constant = -bottomConstraint
      self.layoutIfNeeded()
    })
  }
}

extension DescriptionView {
  enum State: Equatable {
    case main(isSelectedImagesEmpty: Bool, text: String)
    case additional(isSelectedImagesEmpty: Bool, title: String, text: String)
    
    var isEmptySelectedImages: Bool {
      switch self {
      case .additional(let isSelectedImagesEmpty, _, _):
      return isSelectedImagesEmpty
      case .main(let isSelectedImagesEmpty, _):
      return isSelectedImagesEmpty
      }
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
      switch (lhs, rhs) {
      case (.additional, .additional):
        return true
      case (.main, .main):
        return true
      default: return false
      }
    }
  }
}

class DescriptionsCollectionView: UICollectionView {}
