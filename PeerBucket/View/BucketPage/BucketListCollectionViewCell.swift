//
//  BucketListCollectionViewCell.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/16.
//

import UIKit

class BucketListCollectionViewCell: UICollectionViewCell {
        
    var categoryLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.tintColor = .blue
        return label
    }()
    
    var categoryImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .bgGray
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
        categoryLabel.centerX(inView: self)
        categoryLabel.centerY(inView: self)
        
        categoryImageView.anchor(top: topAnchor, left: leftAnchor, width: 120, height: 240)
        
    }
    
    func configureCell(category: BucketCategory) {
        categoryLabel.text = category.category
        
        guard let urlString = category.image as String?,
              let url = URL(string: urlString) else {
            return
        }

        let task = URLSession.shared.dataTask(with: url, completionHandler: { data, _, error in
            guard let data = data, error == nil else {
                return
            }

            DispatchQueue.main.async {
                let image = UIImage(data: data)
                self.categoryImageView.image = image
            }
        })
        task.resume()
        
    }
    
}
