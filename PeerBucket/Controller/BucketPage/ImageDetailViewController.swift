//
//  ImageDetailViewController.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/7/1.
//

import Foundation
import UIKit
import Kingfisher
import AVFoundation

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
    var timer = Timer()
    var playSelect = true
    
    var player: AVAudioPlayer?
    
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer.invalidate()
        player?.pause()
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
        if playSelect {
            playSelect = false
            self.timer = Timer.scheduledTimer(timeInterval: 2.0, target: self,
                                              selector: #selector(self.playVideo),
                                              userInfo: nil, repeats: true)
            // Music
            if let url = Bundle.main.url(forResource: "dreams", withExtension: "mp3") {
                player = try? AVAudioPlayer(contentsOf: url)
                player?.play()
            }
            
        } else {
            playSelect = true
            timer.invalidate()
            player?.pause()
        }
        
    }
    
    @objc func playVideo() {
        
        // Image
        
        if index < memoryData.count-1 {
            index += 1
        } else {
            index = 0
        }
        
        let basicAnimation = CABasicAnimation(keyPath: "contents")
        basicAnimation.fromValue = foreImageView.image?.cgImage
        basicAnimation.toValue = memoryData[index].image.cgImage
        basicAnimation.duration = 1
        foreImageView.layer.contents = foreImageView.image?.cgImage
        foreImageView.layer.add(basicAnimation, forKey: nil)
        
        foreImageView.image = memoryData[index].image
        titleLabel.text = memoryData[index].title
        dateLabel.text = memoryData[index].date
        
    }
    
}
