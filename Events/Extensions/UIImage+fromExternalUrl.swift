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
	
	func fromExternalUrl(
		_ url: String,
		withResizeTo size: CGSize,
		loadOn queue: DispatchQueue = .global(qos: .utility)
	) {
		InternalImageCache.shared.loadImage(by: url, queue: queue)
			.then(on: .global(qos: .userInitiated)) {[weak self] originImage in
				let newImage = self?.resize(image: originImage, expectedSize: size)
				DispatchQueue.main.async {
					self?.image = newImage
				}
			}
	}
	
	func fromExternalUrl(
		_ url: String,
		withResizeTo size: CGSize,
		loadOn queue: DispatchQueue = .global(qos: .utility),
		semaphore: DispatchSemaphore
	) {
		Promise<UIImage?>(on: queue) {[weak self] () -> UIImage? in
			semaphore.wait()
			let originImage = try await(InternalImageCache.shared.loadImage(by: url, queue: queue))
			return self?.resize(image: originImage, expectedSize: size)
		}
		.then(on: .main) {[weak self] image in
			self?.image = image
		}
		.always(on: queue) {
			semaphore.signal()
		}
	}
	
	private func resize(image originImage: UIImage, expectedSize: CGSize) -> UIImage? {
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
}
