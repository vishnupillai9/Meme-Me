//
//  Meme.swift
//  ImagePicker
//
//  Created by Vishnu on 14/03/15.
//  Copyright (c) 2015 Demons. All rights reserved.
//

import Foundation
import UIKit

// Meme model
class Meme: NSObject, NSCoding {
    
    struct Keys {
        static let TopText = "topText"
        static let BottomText = "bottomText"
        static let Image = "image"
        static let MemedImage = "memedImage"
    }
    
    let topText: String?
    let bottomText: String?
    let image: UIImage?
    let memedImage: UIImage?
    
    init(dictionary: [String: AnyObject]) {
        topText = dictionary[Keys.TopText] as? String
        bottomText = dictionary[Keys.BottomText] as? String
        image = dictionary[Keys.Image] as? UIImage
        memedImage = dictionary[Keys.MemedImage] as? UIImage
    }
    
    required init?(coder decoder: NSCoder) {
        topText = decoder.decodeObjectForKey(Keys.TopText) as? String
        bottomText = decoder.decodeObjectForKey(Keys.BottomText) as? String
        image = decoder.decodeObjectForKey(Keys.Image) as? UIImage
        memedImage = decoder.decodeObjectForKey(Keys.MemedImage) as? UIImage
    }
    
    func encodeWithCoder(encoder: NSCoder) {
        encoder.encodeObject(topText, forKey: Keys.TopText)
        encoder.encodeObject(bottomText, forKey: Keys.BottomText)
        encoder.encodeObject(image, forKey: Keys.Image)
        encoder.encodeObject(memedImage, forKey: Keys.MemedImage)
    }
}
