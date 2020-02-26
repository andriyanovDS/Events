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
  weak var delegate: DescriptionViewDelegate? {
    didSet {
      self.collectionView.delegate = self.delegate
      self.collectionView.dataSource = self.delegate
			self.collectionView.dragDelegate = self.delegate
			self.collectionView.dropDelegate = self.delegate
    }
  }
  let collectionView: UICollectionView
  private let textView = UITextView()
  private let submitButton = ButtonScale()
  private let label = UILabel()

  init() {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .horizontal
		layout.sectionInset = UIEdgeInsets(
			top: 0,
			left: 10,
			bottom: 0,
			right: 10
		)
    layout.itemSize = SELECTED_IMAGE_SIZE
    layout.minimumLineSpacing = 10
    collectionView = UICollectionView(
      frame: CGRect.zero,
      collectionViewLayout: layout
    )
		collectionView.dragInteractionEnabled = true
    super.init(frame: CGRect.zero)
    setupView()
    setupCollectionView()
    textView.delegate = self
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupCollectionView() {
    collectionView.backgroundColor = .white
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.register(
      SelectedImageCell.self,
      forCellWithReuseIdentifier: String(describing: SelectedImageCell.self)
    )
  }

  private func setupView() {
    backgroundColor = .white

    styleText(
      label: label,
      text: NSLocalizedString(
        "Tell more about event",
        comment: "Create event: description section title"
      ),
      size: 26,
      color: .gray900(),
      style: .bold
    )
    label.numberOfLines = 2
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
      v.layer.cornerRadius = 5
      v.backgroundColor = UIColor.gray100(alpha: 0.4)
    })

    submitButton.style({ v in
      v.isEnabled = false
      v.backgroundColor = .blue()
    })

    sv([label, textView, collectionView, submitButton])
    setupConstraints()
  }

  private func setupConstraints() {
    label.Top == safeAreaLayoutGuide.Top + 20
    label.left(15).right(15)
    label.centerHorizontally()
    submitButton
      .centerHorizontally()
      .width(200)
      .Bottom == Bottom - 50
    collectionView
      .left(5)
      .right(5)
			.height(SELECTED_IMAGE_SIZE.height + 10)
      .Bottom == submitButton.Top - 15

    textView
      .left(10).right(10)
      .Top == label.Bottom + 15
    textView.Bottom == collectionView.Top - 10
  }
}

extension DescriptionView: UITextViewDelegate {
  func textViewDidChange(_ textView: UITextView) {
    submitButton.isEnabled = textView.text.count > 0
  }
}

protocol DescriptionViewDelegate:
	CreateEventViewDelegate,
  UICollectionViewDataSource,
  UICollectionViewDelegate,
	UICollectionViewDragDelegate,
	UICollectionViewDropDelegate {}
