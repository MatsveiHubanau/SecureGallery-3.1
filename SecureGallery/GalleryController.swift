//
//  GalleryController.swift
//  SecureGallery
//
//  Created by Admin on 31.10.22.
//

import UIKit
import Kingfisher

@available(iOS 16.0, *)
class GalleryController: UIViewController {
    
    var images:[UIImage] = [UIImage] ()
    var spacingBetween:CGFloat = 3
    var imagesPerLine:CGFloat = 3
    
    // MARK: - IBOutlets
    //   @IBOutlet var imageView: UIImageView!
    @IBOutlet var collectionView: UICollectionView!
    
    func setupCollectionView () {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CollectionViewCell.nib(), forCellWithReuseIdentifier: CollectionViewCell.identifier)
    }
    
    // MARK: - IBActions
    @IBAction func BackButton(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func addImageButton(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
            self.showPicker(withSourceType:.camera)
        }
        let libraryAction = UIAlertAction(title: "Library", style: .default) { _ in
            self.showPicker(withSourceType:.photoLibrary)
        }
        let rollAction = UIAlertAction(title: "CameraRoll", style: .default) { _ in
            self.showPicker(withSourceType:.savedPhotosAlbum)
        }
        let linkAction = UIAlertAction(title: "Add by link", style: .default)
        { _ in
            let secondAlert = UIAlertController(title: "Put your link down below",                                           message: nil,
                                                preferredStyle: .alert)
            secondAlert.addTextField { textField
                in textField.placeholder = "Insert your URL"  }
            let addAction = UIAlertAction(title: "Add",
                                          style: .default,
                                          handler: { _ in self.loadImageFromLink (secondAlert ) })
            let cancelAction =  UIAlertAction(title: "Cancel",
                                              style: .cancel) { _ in
                secondAlert.dismiss(animated: true)
                self.dismiss(animated: true)
            }
            secondAlert.addAction(addAction)
            secondAlert.addAction(cancelAction)
            self.present(secondAlert, animated: true)
        }
        let cancelAction =  UIAlertAction(title: "Cancel", style: .cancel) { _ in
            alert.dismiss(animated: true)
            self.dismiss(animated: true)
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(cameraAction)
        }
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            alert.addAction(libraryAction)
        }
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            alert.addAction(rollAction)
        }
        alert.addAction(cancelAction)
        alert.addAction(linkAction)
        present(alert, animated: true)
    }
    
    // MARK: - Override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        loadImage()
        setupCollectionView()
    }
    // MARK: - Public methods
    
    func layoutCollectionView () {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func setImage (_ image: UIImage, withName name:String? = nil) {
        //  imageView.image = image
        images.append(image)
        collectionView.reloadData()
        let fileName = name ?? UUID().uuidString
        let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let fileURL = URL(filePath: fileName, relativeTo: directoryURL).appendingPathExtension("png")
        guard let data = image.pngData() else { return }
        try? data.write(to: fileURL)
        UserDefaults.standard.set(fileName, forKey: "\(images.count)imageName")
        UserDefaults.standard.set(images.count, forKey: "images.count")
    }
    
    func loadImage () {
        let count = UserDefaults.standard.integer(forKey: "images.count")
        guard count > 0 else { return  }
        for index in 1...count {
            guard let fileName = UserDefaults.standard.string(forKey: "\(index)imageName") else {
                collectionView.reloadData()
                continue
            }
            let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            let fileURL = URL(filePath: fileName, relativeTo: directoryURL).appendingPathExtension("png")
            guard let savedData = try? Data(contentsOf: fileURL),
                  let image = UIImage(data: savedData) else {
                collectionView.reloadData()
                continue }
            //        imageView.image = image
            images.append(image )
        }
        collectionView.reloadData()
    }
    
    private func showPicker (withSourceType sourceType:UIImagePickerController.SourceType) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.allowsEditing = false
        pickerController.mediaTypes = ["public.image"]
        pickerController.sourceType = sourceType
        present(pickerController, animated: true)
    }
    
    func loadImageFromLink   (_ secondAlert: UIAlertController)       {
        guard let textfield = secondAlert.textFields?[0] else {return}
        if textfield.text != nil {
            guard let url = URL(string: textfield.text ?? "  ") else {  return }
            let resourse = ImageResource(downloadURL: url)
            KingfisherManager.shared.retrieveImage(with: resourse, completionHandler: {result in
                switch result {
                case .success (let  value ):
                    self.setImage (value.image)
                    print("Image: \(value.image). Got from: \(value.cacheType)")
                case .failure(let error):
                    print ("Error: \(error)")
                }
            })
            //self.images[0].kf.setImage(with: url)
        } else {return}
        print("link added")
    }
}

// MARK: - Extensions

@available(iOS 16.0, *)
extension GalleryController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else {return}
        var name: String?
        if let imageName = info[.imageURL] as? URL {
            name = imageName.lastPathComponent
        }
        setImage(image, withName: name)
        self.presentedViewController?.dismiss(animated: true)
    }
}

extension GalleryController: UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.presentedViewController?.dismiss(animated: true)
        let alert = UIAlertController(title: "Oh", message: "Aint any photo has been chosen", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "It's ok", style: .default)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
}

extension GalleryController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { images.count  }
}

extension GalleryController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let index = indexPath.row
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCell.identifier, for: indexPath) as? CollectionViewCell else {
            return UICollectionViewCell ()
        }
        cell.configure(withImage: images[index])
        return cell
    }
}

extension GalleryController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalSpacing = (imagesPerLine - 1) * spacingBetween
        let width = (collectionView.bounds.width - totalSpacing) / imagesPerLine
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return spacingBetween
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return spacingBetween
    }
}
