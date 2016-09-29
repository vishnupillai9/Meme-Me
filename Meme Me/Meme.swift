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
        topText = decoder.decodeObject(forKey: Keys.TopText) as? String
        bottomText = decoder.decodeObject(forKey: Keys.BottomText) as? String
        image = decoder.decodeObject(forKey: Keys.Image) as? UIImage
        memedImage = decoder.decodeObject(forKey: Keys.MemedImage) as? UIImage
    }
    
    func encode(with encoder: NSCoder) {
        encoder.encode(topText, forKey: Keys.TopText)
        encoder.encode(bottomText, forKey: Keys.BottomText)
        encoder.encode(image, forKey: Keys.Image)
        encoder.encode(memedImage, forKey: Keys.MemedImage)
    }
}
