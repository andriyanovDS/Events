//
//  UIColorExtension.swift
//  Events
//
//  Created by Дмитрий Андриянов on 05/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit

extension UIColor {
    
    static func gray200(alpha: CGFloat = 1) -> UIColor {
        return UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: alpha)
    }
    
    static func gray400(alpha: CGFloat = 1) -> UIColor {
        return UIColor(red: 189/255, green: 189/255, blue: 189/255, alpha: alpha)
    }
    
    static func gray600(alpha: CGFloat = 1) -> UIColor {
        return UIColor(red: 117/255, green: 117/255, blue: 117/255, alpha: alpha)
    }
    
    static func gray800(alpha: CGFloat = 1) -> UIColor {
        return UIColor(red: 88/255, green: 89/255, blue: 91/255, alpha: alpha)
    }
    
    static func gray900(alpha: CGFloat = 1) -> UIColor {
        return UIColor(red: 31/255, green: 31/255, blue: 31/255, alpha: alpha)
    }

    static func blue100(alpha: CGFloat = 1) -> UIColor {
        return UIColor(red: 229/255, green: 240/255, blue: 255/255, alpha: alpha)
    }
    
    static func lightBlue(alpha: CGFloat = 1) -> UIColor {
        return UIColor(red: 122/255, green: 177/255, blue: 1, alpha: alpha)
    }
    
    static func blue(alpha: CGFloat = 1) -> UIColor {
        return UIColor(red: 2/255, green: 96/255, blue: 232/255, alpha: alpha)
    }

    static func lightRed(alpha: CGFloat = 1) -> UIColor {
        return UIColor(red: 248/255, green: 92/255, blue: 80/255, alpha: alpha)
    }
}
