//
//  DetailViewController.swift
//  LiLyGallery
//
//  Created by Mattia Bugossi on 1/28/16.
//  Copyright © 2016 Mattia Bugossi. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView?
    
    var image: UIImage!
    
    @IBAction func back(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView?.image = image
    }
    

}
