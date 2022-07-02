//
//  ImageDetailViewController.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/7/1.
//

import Foundation
import UIKit
import Kingfisher

struct MemoryData {
    var image: UIImage
    var title: String
    var date: String
}

class ImageDetailViewController: UIViewController {
    
    var selectedLists: [BucketList] = []
    
    var images: [UIImage] = []
    var titles: [String] = []
    var dates: [String] = []

    var memoryData: [MemoryData] = []
    
    var index: Int = 1
    
    lazy var nextButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "icon_func_next"), for: .normal)
        button.addTarget(self, action: #selector(tappedNextBtn), for: .touchUpInside)
        return button
    }()
    
    var backImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.image = UIImage(named: "background")
        return imageView
    }()
    
    var foreImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
        return imageView
    }()
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.semiBold(size: 20)
        label.numberOfLines = 0
        return label
    }()
    
    var dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.semiBold(size: 20)
        label.numberOfLines = 0
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for selectedList in selectedLists {
            for selectedImage in selectedList.images {
                guard let data = try? Data(contentsOf: URL(string: selectedImage)!) else { return }
                
                memoryData.append(MemoryData(image: UIImage(data: data)!,
                                             title: selectedList.list,
                                             date: Date.dateFormatter.string(from: selectedList.createdTime)))
                
                foreImageView.image = memoryData[0].image
                titleLabel.text = memoryData[0].title
                dateLabel.text = memoryData[0].date
            }
        }

        configureUI()
        
    }
    
    func configureUI() {
        view.addSubview(backImageView)
        view.addSubview(foreImageView)
        view.addSubview(nextButton)
        view.addSubview(titleLabel)
        view.addSubview(dateLabel)
        
        backImageView.anchor(top: view.topAnchor, left: view.leftAnchor,
                             bottom: view.bottomAnchor, right: view.rightAnchor)
        foreImageView.anchor(top: view.topAnchor, left: view.leftAnchor,
                             bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 130,
                             paddingLeft: 50, paddingBottom: 300, paddingRight: 50)
        nextButton.anchor(top: foreImageView.bottomAnchor, paddingTop: 100)
        nextButton.centerX(inView: view)
        titleLabel.anchor(left: view.leftAnchor, bottom: nextButton.topAnchor,
                          paddingLeft: 50, paddingBottom: 50, width: 200, height: 50)
        dateLabel.anchor(left: view.leftAnchor, bottom: nextButton.topAnchor,
                         paddingLeft: 50, paddingBottom: 20, width: 200, height: 50)
        
    }
    
    @objc func tappedNextBtn() {
        
        let num = index
        
        if index < memoryData.count-1 {
            index += 1
        } else {
            index = 0
        }
        
        let basicAnimation = CABasicAnimation(keyPath: "contents")
        basicAnimation.fromValue = foreImageView.image?.cgImage
        basicAnimation.toValue = memoryData[num].image.cgImage
        basicAnimation.duration = 1
        foreImageView.layer.contents = foreImageView.image?.cgImage
        foreImageView.layer.add(basicAnimation, forKey: nil)
        
        foreImageView.image = memoryData[num].image
        titleLabel.text = memoryData[num].title
        dateLabel.text = memoryData[num].date

    }

}
