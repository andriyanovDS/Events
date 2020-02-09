//
//  SelectedImagesView.swift
//  Events
//
//  Created by Дмитрий Андриянов on 01/09/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia
import Photos

private let IMAGE_WIDTH: CGFloat = 100.0
private let IMAGE_HEIGHT: CGFloat = 80.0

class SelectedImagesView: UIView {
  let openImagePickerButton = UIButton()
  private var selectedAssets: [PHAsset] = []
	private var imageSizeScale: CGFloat {
		UIScreen.main.scale
	}
	private lazy var imagesStackView = UIStackView()
  private lazy var imagesScrollView = UIScrollView()
	private lazy var imageManager = PHImageManager()
	private lazy var imageRequestOptions: PHImageRequestOptions = {
		let requestOptions = PHImageRequestOptions()
		requestOptions.version = .current
    requestOptions.deliveryMode = .highQualityFormat
    requestOptions.isSynchronous = false
		return requestOptions
	}()

  func handleImagePickerResult(assets: [PHAsset]) {
    if assets.count == 0 {
      return
    }
    if selectedAssets.count == 0 {
      openImagePickerButton.removeFromSuperview()
      setupImageViews()
      selectedAssets = assets
			appendAssets(assets)
      return
    }
    selectedAssets.append(contentsOf: assets)
		appendAssets(assets)
  }
	
	private func appendAssets(_ assets: [PHAsset]) {
		assets.forEach { asset in
			imageManager.requestImage(
				for: asset,
				targetSize: CGSize(
					width: IMAGE_WIDTH * imageSizeScale,
					height: IMAGE_HEIGHT * imageSizeScale
				),
				contentMode: .aspectFill,
				options: imageRequestOptions,
				resultHandler: {[weak self] image, _ in
					guard let image = image else { return }
					self?.addSelectedImage(image, asset: asset)
				}
			)
		}
	}

	private func addSelectedImage(_ image: UIImage, asset: PHAsset) {
    let imageContentView = UIView()
    let imageView = UIImageView(image: image)
    let removeButton = UIButtonScaleOnPress()
    imageView.style({ v in
      v.clipsToBounds = true
      v.contentMode = .scaleAspectFill
      v.layer.cornerRadius = 10
    })
    removeButton.style({ v in
      v.layer.cornerRadius = 10
      v.layer.borderColor = UIColor.white.cgColor
      v.layer.borderWidth = 2
      v.backgroundColor = .blue()
      let image = UIImage(
        from: .materialIcon,
        code: "close",
        textColor: .white,
        backgroundColor: .clear,
        size: CGSize(width: 16, height: 16)
      )
      v.setImage(image, for: .normal)
    })
    removeButton.uniqueData = asset
    removeButton.addTarget(self, action: #selector(onPressRemoveButton(_:)), for: .touchUpInside)
    imageContentView.sv(imageView, removeButton)
    imageView.fillContainer().centerInContainer()
    removeButton.right(4).top(4).width(20).height(20)
    imagesStackView.addArrangedSubview(imageContentView)
    imageContentView.width(100).height(80)
  }

  private func setupImageViews() {
    imagesScrollView.showsHorizontalScrollIndicator = false
    imagesScrollView.canCancelContentTouches = true
    imagesStackView.style({ v in
      v.axis = .horizontal
      v.alignment = .fill
      v.distribution = .fillEqually
      v.spacing = 5
    })
    sv(imagesScrollView.sv(imagesStackView))
    imagesScrollView.fillContainer().centerInContainer()
    imagesStackView.top(5).right(5).left(5).bottom(5)
    heightConstraint?.constant = 90
  }

  private func removeSelectedImage(_ view: UIView) {
    UIView.animate(withDuration: 0.1, animations: {
      view.alpha = 0
      self.layoutIfNeeded()
    }, completion: { _ in
      UIView.animate(withDuration: 0.2, animations: {
        self.imagesStackView.removeArrangedSubview(view)
        self.layoutIfNeeded()
      }, completion: { _ in
        if self.selectedAssets.count == 0 {
          self.heightConstraint?.constant = 0
          UIView.animate(withDuration: 0.1, animations: {
            self.superview?.layoutIfNeeded()
          })
        }
      })
    })
  }

  @objc private func onPressRemoveButton(_ button: UIButtonScaleOnPress) {
    guard let asset = button.uniqueData as? PHAsset else {
      return
    }
		if let index = selectedAssets.firstIndex(where: { $0 == asset }) {
			selectedAssets.remove(at: index)
			let removedView = imagesStackView.arrangedSubviews[index]
			self.removeSelectedImage(removedView)
		}
  }
}
