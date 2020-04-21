//
//  EventDescriptionNode.swift
//  Events
//
//  Created by Дмитрий Андриянов on 23/03/2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia
import Promises

class EventDescriptionView: UIStackView {
  let titleButton = UIButtonScaleOnPress()
  let descriptionLabel = UILabel()
  var startImagesLoading: (() -> Void)!
  weak var delegate: EventDescriptionDelegate?
  private var isExpanded: Bool
  private var isImagesLoadingStarted: Bool = false
  private var isAnimationInProgress: Bool = false
  private let imagesStackView = UIStackView()

  struct Constants {
    private static let largeImageSize = CGSize(
      width: UIScreen.main.bounds.width - 40,
      height: UIScreen.main.bounds.height * 0.35
    )
    private static let mediumImageSize = CGSize(
      width: UIScreen.main.bounds.width / 2 - 25,
      height: 200
    )
    private static let smallImageSize = CGSize(
      width: UIScreen.main.bounds.width / 2 - 25,
      height: 100
    )
    private static let imageSizes = [
      Constants.largeImageSize,
      Constants.smallImageSize,
      Constants.mediumImageSize
    ]
    
    static func imageSize(at index: Int) -> CGSize {
      imageSizes[Int(ceil(Double(index) / 2)) % imageSizes.count]
    }
  }

  init(isExpanded: Bool) {
    self.isExpanded = isExpanded
    super.init(frame: CGRect.zero)
		setupView()
  }

  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func addImageStackView(initialView: UIView) {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = 10
    stackView.distribution = .fill
    stackView.addArrangedSubview(initialView)
    imagesStackView.addArrangedSubview(stackView)
  }
  
  private func isStackViewSuitable(_ stackView: UIStackView, for size: CGSize) -> Bool {
    if stackView.arrangedSubviews.count != 1 { return false }
    return stackView.arrangedSubviews[0].heightConstraint!.constant == size.height
  }
  
  func addImage(_ image: UIImage, withSize size: CGSize) {
    let suitableStackView = imagesStackView.arrangedSubviews
      .compactMap { $0 as? UIStackView }
      .first(where: { isStackViewSuitable($0, for: size) })
    
    let view = UIImageView()
    view.image = image
    view.clipsToBounds = true
    view.contentMode = .scaleAspectFill
    view.layer.cornerRadius = 10
    view.width(size.width).height(size.height)
    
    guard let stackView = suitableStackView else {
      addImageStackView(initialView: view)
      return
    }
    stackView.addArrangedSubview(view)
  }

  private func setupView() {
    styleText(
      button: titleButton,
      text: "",
      size: 24,
      color: .fontLabel,
      style: .bold
    )
    styleText(
      label: descriptionLabel,
      text: "",
      size: 18,
      color: .fontLabel,
      style: .medium
    )
    
    axis = .vertical
    spacing = 8
    alignment = .leading
    
		descriptionLabel.numberOfLines = 0
    imagesStackView.spacing = 10
    imagesStackView.axis = .vertical
    imagesStackView.alignment = .leading
    
    titleButton.addTarget(self, action: #selector(toggleExpand), for: .touchUpInside)
    
    addArrangedSubview(titleButton)
    addArrangedSubview(descriptionLabel)
    addArrangedSubview(imagesStackView)
    sv([titleButton, descriptionLabel, imagesStackView])
    if !isExpanded {
      descriptionLabel.isHidden = true
      imagesStackView.isHidden = true
    }
  }
	
	@objc private func toggleExpand() {
    isExpanded = !isExpanded
		if isExpanded && !isImagesLoadingStarted {
			startImagesLoading()
		}
    isAnimationInProgress = true
		UIView.animate(
			withDuration: 0.4,
			animations: {
        self.arrangedSubviews
          .dropFirst()
          .forEach { $0.isHidden = !self.isExpanded }
				if self.isExpanded {
					self.delegate?.scrollToView(self)
				}
			})
	}
}

protocol EventDescriptionDelegate: class {
  func scrollToView(_: UIView)
}
