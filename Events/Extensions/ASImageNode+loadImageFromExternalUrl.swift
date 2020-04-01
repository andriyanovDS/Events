//
//  ImageNode+loadImageFromExternalUrl.swift
//  Events
//
//  Created by Dmitry on 27.03.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Promises
import AVFoundation
import AsyncDisplayKit

extension ASImageNode {
	
	func loadImageFromExternalUrl(
		_ url: String,
		withResizeTo size: CGSize,
		loadOn queue: DispatchQueue = .global(qos: .utility),
		transitionConfig: UIImageView.TransitionConfig? = nil
	) {
		ExternalImageCache.shared.loadImage(by: url, queue: queue)
			.then(on: .global(qos: .userInitiated)) {[weak self] originImage in
				guard let self = self else { return }
				let newImage = resize(image: originImage, expectedSize: size)
				DispatchQueue.main.async {
					if let config = transitionConfig {
						UIView.transition(
							with: self.view,
							duration: config.duration,
							options: config.options,
							animations: {
								self.image = newImage
								self.view.layoutIfNeeded()
						}, completion: nil)
						return
					}
					self.image = newImage
				}
			}
	}
	
	func loadImageFromExternalUrl(
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
