//
//  GalleryScrollViewController.swift
//  Notes
//
//  Created by ios_school on 2/20/20.
//  Copyright © 2020 ios_school. All rights reserved.
//

import UIKit

class GalleryScrollViewController: UIViewController {
    @IBOutlet weak var imageScrollView: UIScrollView!
    
    var images: [UIImage]?
    var imageViews = [UIImageView]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        for image in images ?? [UIImage]() {
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            imageScrollView.addSubview(imageView)
            imageViews.append(imageView)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        for (index, imageView) in imageViews.enumerated() {
            imageView.frame.size = imageScrollView.frame.size
            imageView.frame.origin.x = imageScrollView.frame.width * CGFloat(index)
            imageView.frame.origin.y = 0
        }

        let contentWidth = imageScrollView.frame.width * CGFloat(imageViews.count)
        imageScrollView.contentSize = CGSize(width: contentWidth, height: imageScrollView.frame.height)
    }
    
}
