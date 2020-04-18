//
//  UIImage+fromExternalUrl.swift
//  Events
//
//  Created by Dmitry on 26.03.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Promises
import AVFoundation

extension UIImageView {
	
	struct TransitionConfig {
		let duration: TimeInterval
		let options: UIView.AnimationOptions
		
		init(duration: TimeInterval) {
			self.duration = duration
			self.options = [.curveEaseOut, .transitionCrossDissolve]
		}
		
		init(duration: TimeInterval, options: UIView.AnimationOptions) {
			self.duration = duration
			self.options = options
		}
	}
	
  func fromExternalUrl(
    _ url: String,
    withResizeTo size: CGSize,
    loadOn queue: DispatchQueue = .global(qos: .utility),
    transitionConfig: TransitionConfig? = nil,
    setImageHandler: ((UIImage?) -> Void)? = nil
  ) {
    let setImageHandler = setImageHandler.getOrElse(result: {[weak self] image in
      self?.image = image}
    )
    ExternalImageCache.shared.loadImage(by: url, queue: queue)
      .then(on: .global(qos: .background)) {[weak self] originImage in
        guard let self = self else { return }
        let newImage = UIImage.resize(originImage, expectedSize: size)
        DispatchQueue.main.async {
          if let config = transitionConfig {
            UIView.transition(
              with: self,
              duration: config.duration,
              options: config.options,
              animations: {
                setImageHandler(newImage)
                self.layoutIfNeeded()
            }, completion: nil)
            return
          }
           setImageHandler(newImage)
        }
    }
  }
	
	func fromExternalUrl(
		_ url: String,
		withResizeTo size: CGSize,
		loadOn queue: DispatchQueue = .global(qos: .utility),
		semaphore: DispatchSemaphore
	) {
		Promise<UIImage?>(on: queue) { () -> UIImage? in
			semaphore.wait()
			let originImage = try await(ExternalImageCache.shared.loadImage(by: url, queue: queue))
			return UIImage.resize(originImage, expectedSize: size)
		}
		.then(on: .main) {[weak self] image in
			self?.image = image
		}
		.always(on: queue) {
			semaphore.signal()
		}
	}
}
