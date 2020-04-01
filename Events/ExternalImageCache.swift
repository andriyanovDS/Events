//
//  internalImageCache.swift
//  Events
//
//  Created by Dmitry on 16.02.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import Foundation
import Promises

class ExternalImageCache {
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
	
	static let shared = ExternalImageCache()
	
	struct Config {
		let countLimit: Int
		static let defaultConfig = Config(countLimit: 100)
	}
	
	private struct Constants {
		static let imageFolderName: String = "externalImages"
	}
	
  func loadImage(by url: String, queue: DispatchQueue = .global()) -> Promise<UIImage> {
		let hex = md5Hex(string: url)
		if let cachedImage = imageCache.object(forKey: hex as AnyObject) as? UIImage {
			return Promise(cachedImage)
		}
		if let cachedLoadingPromise = imageLoadingPromiseCache.object(forKey: hex as AnyObject) as? Promise<UIImage> {
			return cachedLoadingPromise
		}
		let imageLoadingPromise = attemptToLoadLocalImage(hex: hex)
			.then { imageOption -> Promise<UIImage> in
				if let image = imageOption {
					return Promise(image)
				}
				return self.loadExternalImage(by: url, hex: hex, queue: queue)
			}
			.catch {[weak self] error in
				print(error.localizedDescription)
				self?.imageLoadingPromiseCache.removeObject(forKey: hex as AnyObject)
			}
    imageLoadingPromiseCache.setObject(imageLoadingPromise, forKey: hex as AnyObject)
		return imageLoadingPromise
	}
	
	private func attemptToLoadLocalImage(hex: String) -> Promise<UIImage?> {
		Promise(on: .global()) { resolve, _ in
			let documentDirectory = try FileManager.default.url(
				for: .documentDirectory,
				in: .userDomainMask,
				appropriateFor: nil,
				create: false
			)
			let fileURL = documentDirectory
				.appendingPathComponent(Constants.imageFolderName)
				.appendingPathComponent(hex)
			guard let data = FileManager.default.contents(atPath: fileURL.path) else {
				resolve(nil)
				return
			}
			guard let image = UIImage(data: data) else {
				resolve(nil)
				return
			}
			self.imageCache.setObject(image, forKey: hex  as AnyObject)
			resolve(image)
		}
	}
	
	private func saveImage(data: Data, hex: String) -> Promise<Void> {
		Promise(on: .global(qos: .utility)) { _, _ in
			let documentDirectory = try FileManager.default.url(
				for: .documentDirectory,
				in: .userDomainMask,
				appropriateFor: nil,
				create: false
			)
			let fileDirectory = documentDirectory.appendingPathComponent(Constants.imageFolderName)
			if !FileManager.default.fileExists(atPath: fileDirectory.path) {
				try FileManager.default.createDirectory(
					atPath: fileDirectory.path,
					withIntermediateDirectories: true
				)
			}
			let fileURL = fileDirectory.appendingPathComponent(hex)
			try data.write(to: fileURL)
		}
	}

	private func loadExternalImage(
    by url: String,
    hex: String,
    queue: DispatchQueue
  ) -> Promise<UIImage> {
    Promise(on: queue) {[weak self] resolve, reject in
			guard let imageURL = URL(string: url) else {
				reject(FailedToLoadExternalImage.incorrectUrl)
				return
			}
			URLSession.shared.dataTask(with: imageURL) {[weak self] data, _, error in
				if let error = error {
					reject(FailedToLoadExternalImage.badRequest)
					return
				}
				guard let data = data else {
					reject(FailedToLoadExternalImage.badRequest)
					return
				}
				_ = self?.saveImage(data: data, hex: hex)
					.catch { error in
						print(error.localizedDescription)
					}
				guard let image = UIImage(data: data) else {
					reject(FailedToLoadExternalImage.incorrectData)
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

enum FailedToLoadExternalImage: Error {
	case incorrectUrl, badRequest, incorrectData
}
