//
//  UIImage+makeRoundedImage.swift
//  Events
//
//  Created by Дмитрий Андриянов on 19/03/2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit

extension UIImage {

  func makeRoundedImage(size: CGSize, radius: CGFloat) -> UIImage {
    // make a CGRect with the image's size
    let rect = CGRect(origin: .zero, size: size)

    // begin the image context since we're not in a drawRect:
    UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)

    // create a UIBezierPath circle
    let circle = UIBezierPath(roundedRect: rect, cornerRadius: radius)

    // clip to the circle
    circle.addClip()

    UIColor.white.set()
    circle.fill()

    // draw the image in the circleRect *AFTER* the context is clipped
    self.draw(in: rect)

    // get an image from the image context
    let roundedImage = UIGraphicsGetImageFromCurrentImageContext()

    // end the image context since we're not in a drawRect:
    UIGraphicsEndImageContext()

    return roundedImage ?? self
  }
}
