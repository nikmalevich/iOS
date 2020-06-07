//
//  GalleryCollectionViewController.swift
//  Notes
//
//  Created by ios_school on 2/20/20.
//  Copyright © 2020 ios_school. All rights reserved.
//

import UIKit

class GalleryCollectionViewController: UIViewController {
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    var images = [UIImage]()
    let reuseIdentifier = "image cell"
    
    @IBAction func addImageButtonTapped(_ sender: UIBarButtonItem) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        let actionSheet = UIAlertController(title: "Источник изображения", message: "Выберите источник", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Камера", style: .default, handler: { [weak self] action in
            imagePicker.sourceType = .camera
            self?.present(imagePicker, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Галерея", style: .default, handler: { [weak self] action in
            imagePicker.sourceType = .photoLibrary
            self?.present(imagePicker, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Закрыть", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? GalleryScrollViewController, segue.identifier == "ScrollGallerySegue" {
            controller.images = images
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageCollectionView.register(UINib(nibName: "ImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
    }

}
