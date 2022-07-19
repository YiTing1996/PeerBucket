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
import Lottie

struct MemoryData {
    var image: UIImage
    var title: String
    var date: String
}

class ImageDetailViewController: UIViewController {
    
    @IBOutlet weak var foreImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var index: Int = 1
    var timer = Timer()
    var playSelect = true
    
    var player: AVAudioPlayer?
    
    var memoryData: [MemoryData] = []
    var allBucketList: [BucketList] = []
    
    lazy var nextButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "icon_func_next"), for: .normal)
        button.addTarget(self, action: #selector(tappedNextBtn), for: .touchUpInside)
        return button
    }()
    
    var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.semiBold(size: 12)
        label.textColor = .darkGreen
        label.text = "Tap to play"
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .darkGreen
        configureUI()
        fetchDate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
        timer.invalidate()
        player?.pause()
    }
    
    func fetchDate() {
        
        let animationView = self.loadAnimation(name: "lottieLoading", loopMode: .loop)
        animationView.play()
        
        for list in allBucketList where list.images != [] {
            for image in list.images {
                DispatchQueue.global().async {
                    // perform url session at background thread
                    guard let data = try? Data(contentsOf: URL(string: image)!) else { return }
                    self.memoryData.append(MemoryData(image: UIImage(data: data)!,
                                                      title: list.list,
                                                      date: Date.dateFormatter.string(from: list.createdTime)))
                    DispatchQueue.main.async {
                        self.foreImageView.image = self.memoryData[0].image
                        self.titleLabel.text = self.memoryData[0].title
                        self.dateLabel.text = self.memoryData[0].date
                        self.stopAnimation(animationView: animationView)
                    }
                    
                }
            }
        }
    }
    
    func configureUI() {
        view.addSubview(nextButton)
        view.addSubview(descriptionLabel)
        nextButton.anchor(top: foreImageView.bottomAnchor, right: view.rightAnchor,
                          paddingTop: 40, paddingRight: 30)
        descriptionLabel.anchor(top: nextButton.bottomAnchor, right: view.rightAnchor,
                                paddingTop: 5, paddingRight: 30, width: 60)
        
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
