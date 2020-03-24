//
//  internalImageCache.swift
//  Events
//
//  Created by Dmitry on 16.02.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import Foundation
import Promises

class InternalImageCache {
	private let config: Config
	// 1st level cache, that contains encoded images
	private lazy var imageCache: NSCache<AnyObject, AnyObject> = {
		let cache = NSCache<AnyObject, AnyObject>()
		cache.countLimit = config.countLimit
		return cache
	}()
	private let imageLoadingPromiseCache = NSCache<AnyObject, AnyObject>()
	
	private init(config: Config = Config.defaultConfig) {
		self.config = config
	}
	
	static let shared = InternalImageCache()
	
	struct Config {
		let countLimit: Int
		static let defaultConfig = Config(countLimit: 100)
	}
	
  func loadImage(by url: String, queue: DispatchQueue = .global()) -> Promise<UIImage> {
		let hex = md5Hex(string: url)
		if let cachedImage = imageCache.object(forKey: hex as AnyObject) as? UIImage {
			return Promise(cachedImage)
		}
		if let cachedLoadingPromise = imageLoadingPromiseCache.object(forKey: hex as AnyObject) as? Promise<UIImage> {
			return cachedLoadingPromise
		}
		let imageLoadingPromise = loadInternalImage(by: url, hex: hex, queue: queue)
    imageLoadingPromiseCache.setObject(imageLoadingPromise, forKey: hex as AnyObject)
		return imageLoadingPromise
	}

	private func loadInternalImage(
    by url: String,
    hex: String,
    queue: DispatchQueue
  ) -> Promise<UIImage> {
    Promise(on: queue) {[weak self] resolve, reject in
			guard let imageURL = URL(string: url) else {
				reject(FailedToLoadInternalImage.incorrectUrl)
				return
			}
			URLSession.shared.dataTask(with: imageURL) {[weak self] data, _, error in
				if let error = error {
					print("Failed to load image", error.localizedDescription)
					reject(FailedToLoadInternalImage.badRequest)
					return
				}
				guard let data = data else {
					reject(FailedToLoadInternalImage.badRequest)
					return
					
				}
				guard let image = UIImage(data: data) else {
					reject(FailedToLoadInternalImage.incorrectData)
					return
				}
				self?.imageCache.setObject(image, forKey: hex  as AnyObject)
				resolve(image)
			}.resume()
		}
		.always {[weak self] in
			self?.imageLoadingPromiseCache.removeObject(forKey: hex as AnyObject)
		}
	}
}

enum FailedToLoadInternalImage: Error {
	case incorrectUrl, badRequest, incorrectData
}
