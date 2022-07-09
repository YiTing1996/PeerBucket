//
//  ExploreDetailTableViewCell.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/15.
//

import UIKit
import SwiftUI

protocol ExploreDetailTableViewCellDelegate: AnyObject {
    func didTappedMore()
}

class ExploreDetailTableViewCell: UITableViewCell, UIScrollViewDelegate {
    
    weak var delegate: ExploreDetailTableViewCellDelegate?
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        return scrollView
    }()
    
    var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.clipsToBounds = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.bold(size: 30)
        label.textColor = UIColor.darkGreen
        return label
    }()
    
    var descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.numberOfLines = 5
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    lazy var tapMoreGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer()
        gesture.numberOfTapsRequired = 1
        gesture.addTarget(self, action: #selector(handleTapGesture))
        return gesture
    }()
    
    var moreText: String = "Read More"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = .lightGray
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @objc func handleTapGesture() {
        if self.descriptionLabel.numberOfLines > 0 {
            self.descriptionLabel.numberOfLines = 0
            self.moreText = "Show Less"
        } else {
            self.descriptionLabel.numberOfLines = 6
            self.moreText = "Read More"
        }
        delegate?.didTappedMore()
    }
        
    func configureImageCell(content: ExploreBucket) {
        contentView.addSubview(scrollView)
        scrollView.addSubview(stackView)

        scrollView.anchor(top: contentView.topAnchor, left: contentView.leftAnchor,
                          bottom: contentView.bottomAnchor, right: contentView.rightAnchor, paddingLeft: 10, paddingRight: 10)
        
        scrollView.contentSize.height = stackView.frame.height
        stackView.anchor(top: scrollView.topAnchor, left: scrollView.leftAnchor, right: scrollView.rightAnchor)
        
        for index in 0...content.images.count-1 {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.layer.cornerRadius = 20
            imageView.image = content.images[index]
            stackView.addArrangedSubview(imageView)
            if index == 1 {
                imageView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor).isActive = true
                imageView.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor).isActive = true
            }
        }
    }
    
    // tableview automatic dimension
    func configureInfoCell(content: ExploreBucket) {
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        descriptionLabel.addGestureRecognizer(tapMoreGesture)
        descriptionLabel.isUserInteractionEnabled = true
        
        titleLabel.anchor(top: contentView.topAnchor, left: contentView.leftAnchor,
                          paddingTop: 20, paddingLeft: 10, height: 40)
        titleLabel.text = content.title
        descriptionLabel.anchor(top: titleLabel.bottomAnchor, left: contentView.leftAnchor,
                                bottom: contentView.bottomAnchor, right: contentView.rightAnchor,
                                paddingTop: 15, paddingLeft: 10, paddingBottom: 10, paddingRight: 15)
        descriptionLabel.text = content.description
        descriptionLabel.characterSpacing = 2
        
        if descriptionLabel.text!.count > 1 {
            
            let readmoreFont = UIFont.italic(size: 15)
            let readmoreFontColor = UIColor.darkGreen
            DispatchQueue.main.async {
                self.descriptionLabel.addTrailing(with: "... ", moreText: self.moreText,
                                                  moreTextFont: readmoreFont!,
                                                  moreTextColor: readmoreFontColor)
            }
        }
    }
}
