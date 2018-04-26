//
//  Utilities.swift
//  OSRS DPS Calculator
//
//  Created by Bronson Graansma on 2018-03-10.
//  Copyright © 2018 Bronson Graansma. All rights reserved.
//

import Foundation
import UIKit

class Utilities {
    public class func resizeImage(_ image: UIImage, width: CGFloat, height: CGFloat) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return newImage.withRenderingMode(.alwaysOriginal)
    }
    
    public class func textOnImage(drawText text: String, inImage image: UIImage, atPoint point: CGPoint, size: CGFloat) -> UIImage {
        let textColor = UIColor.yellow
        let textFont = UIFont(name: "RuneScape-UF", size: size)!
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.center
        
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(image.size, false, scale)
        
        let textFontAttributes = [
            NSAttributedStringKey.font: textFont,
            NSAttributedStringKey.foregroundColor: textColor,
            ] as [NSAttributedStringKey : Any]
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))
        
        let rect = CGRect(origin: point, size: image.size)
        text.draw(in: rect, withAttributes: textFontAttributes)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    class func overlay(_ image: UIImage, on: UIImage) -> UIImage {
        let posX = on.size.width/2 - image.size.width/2
        let posY = on.size.height/2 - image.size.height/2
        UIGraphicsBeginImageContextWithOptions(on.size, false, 0.0)
        on.draw(in: CGRect(origin: CGPoint.zero, size: on.size))
        image.draw(in: CGRect(origin: CGPoint(x: posX, y: posY), size: image.size))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
