//
//  UIImage+resize.swift
//  Events
//
//  Created by Dmitry on 11.04.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import func AVFoundation.AVMakeRect

extension UIImage {
	static func resize(_ originImage: UIImage, expectedSize: CGSize) -> UIImage? {
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
