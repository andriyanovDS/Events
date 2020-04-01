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

func resize(image originImage: UIImage, expectedSize: CGSize) -> UIImage? {
	let rect = AVMakeRect(aspectRatio: originImage.size, insideRect: CGRect(
		x: 0, y: 0, width: expectedSize.width, height: expectedSize.height
	))
	let aspectSize = CGSize(width: rect.width, height: rect.height)
	UIGraphicsBeginImageContextWithOptions(aspectSize, true, 0)
	originImage.draw(in: CGRect(origin: CGPoint.zero, size: aspectSize))
	let newImage = UIGraphicsGetImageFromCurrentImageContext()
	UIGraphicsEndImageContext()
	return newImage
}

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
		transitionConfig: TransitionConfig? = nil
	) {
		ExternalImageCache.shared.loadImage(by: url, queue: queue)
			.then(on: .global(qos: .userInitiated)) {[weak self] originImage in
				guard let self = self else { return }
				let newImage = resize(image: originImage, expectedSize: size)
				DispatchQueue.main.async {
					if let config = transitionConfig {
						UIView.transition(
							with: self,
							duration: config.duration,
							options: config.options,
							animations: {
								self.image = newImage
								self.layoutIfNeeded()
						}, completion: nil)
						return
					}
					self.image = newImage
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
			return resize(image: originImage, expectedSize: size)
		}
		.then(on: .main) {[weak self] image in
			self?.image = image
		}
		.always(on: queue) {
			semaphore.signal()
		}
	}
}
