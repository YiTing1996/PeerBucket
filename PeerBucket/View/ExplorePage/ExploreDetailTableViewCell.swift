//
//  ExploreDetailTableViewCell.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/15.
//

import UIKit

protocol ExploreDetailTableViewCellDelegate: AnyObject {
    func didTappedMore()
}

final class ExploreDetailTableViewCell: UITableViewCell, UIScrollViewDelegate {
    
    weak var delegate: ExploreDetailTableViewCellDelegate?
    
    private lazy var scrollView: UIScrollView = create {
        $0.isPagingEnabled = true
        $0.showsHorizontalScrollIndicator = false
        $0.delegate = self
    }
    
    private lazy var stackView: UIStackView = create {
        let stackView = UIStackView()
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.alignment = .fill
        $0.clipsToBounds = true
    }
    
    private lazy var titleLabel: UILabel = create {
        $0.font = UIFont.bold(size: 30)
        $0.textColor = UIColor.darkGreen
    }
    
    private lazy var descriptionLabel: UILabel = create {
        $0.textColor = .darkGray
        $0.numberOfLines = 6
        $0.font = UIFont.systemFont(ofSize: 15)
    }
    
    private lazy var tapMoreGesture: UITapGestureRecognizer = create {
        $0.numberOfTapsRequired = 1
        $0.addTarget(self, action: #selector(handleTapGesture))
    }
    
    private var shouldShowMore: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .lightGray
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @objc
    private func handleTapGesture() {
        if self.descriptionLabel.numberOfLines > 0 {
            self.descriptionLabel.numberOfLines = 0
            shouldShowMore = false
        } else {
            self.descriptionLabel.numberOfLines = 6
            shouldShowMore = true
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
        
        for index in 0...content.images.count - 1 {
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
                                paddingTop: 15, paddingLeft: 10, paddingBottom: 10, paddingRight: 20)
        descriptionLabel.text = content.description
        
        guard let text = descriptionLabel.text else { return }

        if text.count > 1 {
            DispatchQueue.main.async {
                self.descriptionLabel.addTrailing(moreText: self.shouldShowMore ? "Read More" : "Show Less")
            }
        }
    }
}
