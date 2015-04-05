//
//  Meme.swift
//  ImagePicker
//
//  Created by Vishnu on 14/03/15.
//  Copyright (c) 2015 Demons. All rights reserved.
//

import Foundation
import UIKit

//Meme model
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
    
    required init(coder decoder: NSCoder) {
        self.topText = decoder.decodeObjectForKey(Keys.TopText) as? String
        self.bottomText = decoder.decodeObjectForKey(Keys.BottomText) as? String
        self.image = decoder.decodeObjectForKey(Keys.Image) as? UIImage
        self.memedImage = decoder.decodeObjectForKey(Keys.MemedImage) as? UIImage
    }
    
    func encodeWithCoder(encoder: NSCoder) {
        encoder.encodeObject(self.topText, forKey: Keys.TopText)
        encoder.encodeObject(self.bottomText, forKey: Keys.BottomText)
        encoder.encodeObject(self.image, forKey: Keys.Image)
        encoder.encodeObject(self.memedImage, forKey: Keys.MemedImage)
    }
}
