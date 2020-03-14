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

class DescriptionView: UIView, CreateEventView {
  let selectedImagesCollectionView: UICollectionView
  let descriptionsCollectionView: DescriptionsCollectionView
  private var titleTextField: UITextField?
  private let textView = UITextView()
  private let submitButton = ButtonScale()
  private var titleLabel = UILabel()
  weak var delegate: DescriptionViewDelegate? {
    didSet {
      self.selectedImagesCollectionView.delegate = self.delegate
      self.selectedImagesCollectionView.dataSource = self.delegate
      self.selectedImagesCollectionView.dragDelegate = self.delegate
      self.selectedImagesCollectionView.dropDelegate = self.delegate
      self.descriptionsCollectionView.dataSource = self.delegate
      self.descriptionsCollectionView.delegate = self.delegate
    }
  }

  init() {
    let selectedImagesLayout = UICollectionViewFlowLayout()
    selectedImagesLayout.scrollDirection = .horizontal
		selectedImagesLayout.sectionInset = UIEdgeInsets(
			top: 0,
			left: 10,
			bottom: 0,
			right: 10
		)
    selectedImagesLayout.itemSize = SELECTED_IMAGE_SIZE
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
    textView.delegate = self

    let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTap))
    tapRecognizer.cancelsTouchesInView = false
    addGestureRecognizer(tapRecognizer)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func onChange(description: MutableDescription) {
    textView.text = description.text
    attemptToAnimateSelectedImagesCollectionView(nextAssetsCount: description.assets.count)
    if description.isMain {
      animateTextFieldToLabel()
    } else {
      titleTextField.foldL(
        none: {
          setupTitleTextField(text: description.title)
          animateLabelToTextField()
        },
        some: { v in
          v.text = description.title
        }
      )
    }
  }

  func attemptToAnimateSelectedImagesCollectionView(nextAssetsCount: Int) {
    let isCurrentAssetsEmpty = selectedImagesCollectionView.visibleCells.count == 0
    let isNextAssetsEmpty = nextAssetsCount == 0
    guard isCurrentAssetsEmpty != isNextAssetsEmpty else { return }
    isNextAssetsEmpty
      ? hideSelectedImagesCollectionView()
      : showSelectedImagesCollectionView()
  }

  func hideSelectedImagesCollectionView() {
    UIView.animate(withDuration: 0.2, animations: {
      self.selectedImagesCollectionView.heightConstraint?.constant = 0
      self.layoutIfNeeded()
    })
  }

  func showSelectedImagesCollectionView() {
    UIView.animate(withDuration: 0.2, animations: {
      self.selectedImagesCollectionView.heightConstraint?.constant = SELECTED_IMAGE_SIZE.height + 10
      self.layoutIfNeeded()
    })
  }

  private func animateLabelToTextField() {
    guard let textField = titleTextField else { return }
    UIView.animate(withDuration: 0.3, animations: {[unowned self] in
      self.titleLabel.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
      self.titleLabel.alpha = 0
    })
    UIView.animate(
      withDuration: 0.2,
      delay: 0.3,
      options: .curveEaseIn,
      animations: { textField.alpha = 1 },
      completion: {[unowned self] _ in
        self.titleLabel.transform = .identity
      }
    )
  }

  private func animateTextFieldToLabel() {
    guard let textField = titleTextField else { return }
    UIView.animate(withDuration: 0.3, animations: {
      textField.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
      textField.alpha = 0
    })
    UIView.animate(
      withDuration: 0.2,
      delay: 0.3,
      options: .curveEaseIn,
      animations: {[unowned self] in
        self.titleLabel.alpha = 1
      },
      completion: {[unowned self] _ in
        self.titleTextField?.removeFromSuperview()
        self.titleTextField = nil
      }
    )
  }

  private func setupTitleTextField(text: String?) {
    let textField = selectTextFieldStyle(UITextField())
    styleText(
      textField: textField,
      text: NSLocalizedString(
        "Description title",
        comment: "Create event: description title text field placeholder"
      ),
      size: 22,
      color: .black,
      style: .bold
    )
    textField.alpha = 0
    textField.text = text
    textField.addTarget(self, action: #selector(textFieldDidChangeText), for: .editingChanged)
    titleTextField = textField
    sv(textField)
    textField.Top == titleLabel.Top
    textField
      .left(15)
      .right(45)
      .height(50)
  }

  @objc private func textFieldDidChangeText(_ textField: UITextField) {
    delegate?.description(titleDidChange: textField.text ?? "")
  }

  private func setupSelectedImagesCollectionView() {
    selectedImagesCollectionView.style { v in
      v.backgroundColor = .white
      v.showsHorizontalScrollIndicator = false
      v.register(
        SelectedImageCell.self,
        forCellWithReuseIdentifier: String(describing: SelectedImageCell.self)
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
        forCellWithReuseIdentifier: String(describing: DescriptionCellView.self)
      )
    }
  }

  @objc private func onTap(_ recognizer: UITapGestureRecognizer) {
    endEditing(true)
  }

  private func setupView() {
    backgroundColor = .white

    styleText(
      label: titleLabel,
      text: NSLocalizedString(
        "Tell more about event",
        comment: "Create event: description section title"
      ),
      size: 26,
      color: .gray900(),
      style: .bold
    )
    titleLabel.numberOfLines = 2
    styleText(
      textView: textView,
      text: "",
      size: 16,
      color: .gray800(),
      style: .medium
    )
    styleText(
      button: submitButton,
      text: NSLocalizedString("Next step", comment: "Create event: next step"),
      size: 20,
      color: .white,
      style: .medium
    )

    textView.style({ v in
      v.layer.cornerRadius = 10
      v.backgroundColor = .gray100()
    })

    submitButton.style({ v in
      v.isEnabled = false
      v.backgroundColor = .blue()
    })

    sv([titleLabel, textView, selectedImagesCollectionView, submitButton, descriptionsCollectionView])
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

extension DescriptionView: UITextViewDelegate {
  func textViewDidChange(_ textView: UITextView) {
    delegate?.description(textDidChange: textView.text)
    submitButton.isEnabled = textView.text.count > 0
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
              if itemsCount > 0 { return SELECTED_IMAGE_SIZE.height + 10 }
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

protocol DescriptionViewDelegate:
	CreateEventViewDelegate,
  UICollectionViewDataSource,
  UICollectionViewDelegate,
	UICollectionViewDragDelegate,
	UICollectionViewDropDelegate {

  func description(titleDidChange title: String)
  func description(textDidChange text: String)
}

class DescriptionsCollectionView: UICollectionView {}
