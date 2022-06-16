//
//  ExploreDetailTableViewCell.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/15.
//

import UIKit
import SwiftUI

class ExploreDetailTableViewCell: UITableViewCell, UIScrollViewDelegate {
        
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        scrollView.backgroundColor = .white
        return scrollView
    }()
    
    var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.isUserInteractionEnabled = false
        pageControl.numberOfPages = 4
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = .gray
        pageControl.pageIndicatorTintColor = .darkGray
        return pageControl
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
        
    var detailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Arial", size: 14)
        label.backgroundColor = .clear
        label.numberOfLines = 0
        return label
    }()
    
    var webButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .lightGray
        button.addTarget(self, action: #selector(tappedWebBtn), for: .touchUpInside)
        button.setTitle("Collect", for: .normal)
        button.clipsToBounds = true
        button.layer.cornerRadius = 10
        return button
    }()
    
    var ratingView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightGray
        view.clipsToBounds = true
        view.layer.cornerRadius = 10
        return view
    }()
    
    var ratingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Rating 4.7"
        label.numberOfLines = 0
        return label
    }()
    
    var ratingImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "Icon_Star")
        return imageView
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @objc func tappedWebBtn() {
        
    }
    
    func configureImageCell(content: ExploreBucket) {
        addSubview(scrollView)
        scrollView.addSubview(stackView)
        addSubview(pageControl)

        scrollView.anchor(top: topAnchor, left: leftAnchor,
                          bottom: bottomAnchor, right: rightAnchor)

        scrollView.contentSize.height = stackView.frame.height
        stackView.anchor(top: scrollView.topAnchor, left: scrollView.leftAnchor, right: scrollView.rightAnchor)
        
        pageControl.anchor(left: leftAnchor, bottom: bottomAnchor, paddingBottom: -50)
        
        for index in 0...content.images.count-1 {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.image = content.images[index]
            stackView.addArrangedSubview(imageView)
            if index == 1 {
//                imageView.anchor(width: scrollView.frame.width, height: scrollView.frame.height)
                imageView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor).isActive = true
                imageView.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor).isActive = true
            }
        }
    }
    
    func configureRatingCell(content: ExploreBucket) {
        addSubview(webButton)
        addSubview(ratingView)
        ratingView.addSubview(ratingLabel)
        ratingView.addSubview(ratingImageView)
        
        ratingView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor,
                          right: webButton.leftAnchor, paddingTop: 10, paddingBottom: 10,
                          paddingRight: 10)
        
        webButton.anchor(top: topAnchor, bottom: bottomAnchor, right: rightAnchor,
                         paddingTop: 10, paddingBottom: 10,
                         width: 80)
        
        ratingImageView.anchor(top: ratingView.topAnchor, left: ratingView.leftAnchor,
                               paddingTop: 10, paddingLeft: 10, width: 50, height: 50)
        
        ratingLabel.anchor(top: ratingImageView.topAnchor, left: ratingImageView.rightAnchor,
                           paddingTop: 15, paddingLeft: 10, width: 50)
        ratingLabel.text = content.rating
    }
    
    func configureInfoCell(content: ExploreBucket) {
        addSubview(titleLabel)
        addSubview(descriptionLabel)
        
        titleLabel.anchor(top: topAnchor, left: leftAnchor, bottom: descriptionLabel.topAnchor,
                          paddingTop: 10, paddingLeft: 10, paddingBottom: 10, height: 30)
        titleLabel.text = content.title
        descriptionLabel.anchor(left: leftAnchor, bottom: bottomAnchor, right: rightAnchor,
                                   paddingLeft: 10, paddingBottom: 10, paddingRight: 10, height: 400)
        descriptionLabel.text = content.description
    }
    
}
