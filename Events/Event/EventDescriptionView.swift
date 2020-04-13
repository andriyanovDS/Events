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
	weak var delegate: EventDescriptionDelegate?
  var isExpanded: Bool {
    didSet {
      if isExpanded == oldValue { return }
			toggleExpand()
    }
  }
  let eventDescription: DescriptionWithImageUrls
  let titleButton = UIButtonScaleOnPress()
	private var isImageLoadingDidStarted: Bool = false
  private let descriptionLabel = UILabel()
  private var imageViews: [UIImageView]
  private let imageSizes = [
    Constants.largeImageSize,
    Constants.smallImageSize,
    Constants.mediumImageSize
  ]
	private var arrangedSubviewsExceptTitle: ArraySlice<UIView> {
    arrangedSubviews.dropFirst()
	}

  private struct Constants {
    static let largeImageSize = CGSize(
      width: UIScreen.main.bounds.width - 40,
      height: UIScreen.main.bounds.height * 0.35
    )
    static let mediumImageSize = CGSize(
      width: UIScreen.main.bounds.width / 2 - 25,
      height: 200
    )
    static let smallImageSize = CGSize(
      width: UIScreen.main.bounds.width / 2 - 25,
      height: 100
    )
  }

  init(description: DescriptionWithImageUrls) {
    eventDescription = description
    if description.isMain {
      imageViews = []
    } else {
      imageViews = description.imageUrls.map { _ in
        let view = UIImageView()
				view.clipsToBounds = true
				view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 10
        return view
      }
    }
    isExpanded = description.isMain
    super.init(frame: CGRect.zero)
		setupView()
  }

  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupView() {
    styleText(
      button: titleButton,
      text: eventDescription.title ?? NSLocalizedString("What you'll do", comment: "Event description title"),
      size: 24,
      color: .fontLabel,
      style: .bold
    )
    styleText(
      label: descriptionLabel,
      text: eventDescription.text,
      size: 18,
      color: .fontLabel,
      style: .medium
    )
		descriptionLabel.numberOfLines = 0
		spacing = 10
		axis = .vertical
		alignment = .leading
		addArrangedSubview(titleButton)
		addArrangedSubview(descriptionLabel)
		setupImageViews()
		if !eventDescription.isMain {
			arrangedSubviewsExceptTitle
				.forEach { $0.isHidden = !self.isExpanded }
		}
  }
	
	private func setupImageViews() {
		if eventDescription.isMain { return }
		if imageViews.isEmpty { return }
		let firstImage = imageViews.first!
		firstImage
			.height(Constants.largeImageSize.height)
			.width(Constants.largeImageSize.width)
		addArrangedSubview(firstImage)
		if imageViews.count > 1 {
			let restImages = Array(imageViews[1...imageViews.count - 1])
			restImages
				.chunks(2)
				.enumerated()
				.map { (index, images) in
					let stackView = UIStackView()
					stackView.axis = .horizontal
					stackView.spacing = 10
					stackView.distribution = .fill
					let size = imageSize(at: index + 1)
					images.forEach { v in
						v.height(size.height).width(size.width)
						stackView.addArrangedSubview(v)
					}
					return stackView
				}
				.forEach { addArrangedSubview($0) }
		}
	}
	
	private func toggleExpand() {
		if isExpanded {
			attemptToLoadDescriptionImages()
		}
		UIView.animate(
			withDuration: 0.4,
			animations: {
				self.arrangedSubviewsExceptTitle
					.forEach { $0.isHidden = !self.isExpanded }
				if self.isExpanded {
					self.delegate?.scrollTo(description: self.eventDescription)
				}
			})
	}

  private func imageSize(at index: Int) -> CGSize {
    return imageSizes[index % imageSizes.count]
  }

  private func attemptToLoadDescriptionImages() {
		if isImageLoadingDidStarted { return }
		if eventDescription.isMain { return }
    guard let delegate = delegate else { return }
		isImageLoadingDidStarted = true
    eventDescription.imageUrls
      .enumerated()
      .forEach { (index, url) in
				imageViews[index].fromExternalUrl(
					url,
					withResizeTo: Constants.largeImageSize,
					loadOn: delegate.loadImageQueue,
					semaphore: delegate.loadImageSemaphore
				)
      }
  }
}

protocol EventDescriptionDelegate: EventViewSectionDelegate {
  func scrollTo(description: DescriptionWithImageUrls)
}
