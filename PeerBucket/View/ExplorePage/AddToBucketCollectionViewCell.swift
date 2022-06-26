//
//  AddToBucketCollectionViewCell.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/15.
//

import UIKit

class AddToBucketCollectionViewCell: UICollectionViewCell {
    
    var categoryLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGreen
        label.font = UIFont.semiBold(size: 15)
        label.numberOfLines = 0
        return label
    }()
    
    var categoryImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // initialize what is needed
        configureUI()
    }
    
    func configureUI() {
        addSubview(categoryLabel)
        addSubview(categoryImageView)

        categoryImageView.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 20,
                                 paddingLeft: 5, paddingRight: 5, width: 50, height: 50)
        categoryLabel.anchor(top: categoryImageView.bottomAnchor, left: leftAnchor, right: rightAnchor,
                             paddingTop: 10, paddingLeft: 10, paddingRight: 5, height: 20)
        
    }
    
    func configureCell(bucketCategories: BucketCategory) {
        categoryLabel.text = bucketCategories.category
        
        // cell icon
        guard let urlString = bucketCategories.image as String?,
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
