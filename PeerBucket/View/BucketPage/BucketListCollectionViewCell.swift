//
//  BucketListCollectionViewCell.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/16.
//

import UIKit
import Kingfisher

class BucketListCollectionViewCell: UICollectionViewCell {
    
    var categoryLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .darkGray
        label.font = UIFont.semiBold(size: 20)
        label.numberOfLines = 0
        return label
    }()
    
    var categoryImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
        
    override func awakeFromNib() {
        super.awakeFromNib()
        // initialize what is needed
        configureUI()
    }
    
    func configureUI() {
        addSubview(categoryImageView)
        addSubview(categoryLabel)
        
        categoryImageView.centerX(inView: self)
        categoryLabel.centerX(inView: self)

        categoryImageView.anchor(top: topAnchor, paddingTop: 20, width: 50, height: 50)
        categoryLabel.anchor(top: categoryImageView.bottomAnchor, paddingTop: 15)
        
    }
    
    var image: UIImage?
    
    func configureCell(category: BucketCategory) {
        
//        let group = DispatchGroup()
//        downloadImage(urlString: category.image, group: group)
        
        categoryLabel.text = category.category
        let url = URL(string: category.image)
        categoryImageView.kf.setImage(with: url)
        
//        group.notify(queue: .main) {
//            self.categoryLabel.text = category.category
////            self.categoryImageView.image = self.image
//        }
        
    }
    
//    func downloadImage(urlString: String, group: DispatchGroup) {
//        group.enter()
//        guard let urlString = urlString as String?,
//              let url = URL(string: urlString) else { return }
//        let task = URLSession.shared.dataTask(with: url) { data, _, error in
//            guard let data = data, error == nil else {
//                return
//            }
//            let image = UIImage(data: data)
//            self.image = image
//            group.leave()
//        }
//        task.resume()
//    }
    
}
