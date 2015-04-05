//
//  DetailViewController.swift
//  Meme Me
//
//  Created by Vishnu on 15/03/15.
//  Copyright (c) 2015 Vishnu Pillai. All rights reserved.
//

import UIKit

//detail view controller to show the memed image
class DetailViewController: UIViewController {

    var memes:[Meme]!
    var key: Int?
    
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            imageView.image = memes[key!].memedImage
        }
    }

}
