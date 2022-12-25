//
//  CollectionViewCell.swift
//  SecureGallery
//
//  Created by Admin on 3.12.22.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {

    @IBOutlet var imageView: UIImageView!
    
    static let identifier = "CollectionViewCell"
    
   //override init(frame: CGRect) {
   //    super.init(frame: frame)
   //
   //}
   //
   //required init?(coder: NSCoder) {
   //    fatalError("init(coder:) has not been implemented")
   //}
    
    static func nib () -> UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    public func configure (withImage image:UIImage) {
        imageView.image = image
    }
    override func prepareForReuse () {
        imageView.image = nil
    }
    func setup (with image: UIImage) {
        imageView.image = image
    }

}
