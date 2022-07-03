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
    
    @IBOutlet weak var foreImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .darkGreen
        
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
        view.addSubview(nextButton)
        nextButton.anchor(top: foreImageView.bottomAnchor, right: view.rightAnchor,
                          paddingTop: 50, paddingRight: 25)
        
        titleLabel.font = UIFont.bold(size: 25)
        dateLabel.font = UIFont.semiBold(size: 20)
        titleLabel.textColor = .darkGray
        dateLabel.textColor = .darkGray

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
