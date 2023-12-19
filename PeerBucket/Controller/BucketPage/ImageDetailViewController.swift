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

final class ImageDetailViewController: UIViewController {
    
    // MARK: - Properties

    @IBOutlet weak var foreImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    private var index: Int = 1
    private var timer = Timer()
    private var playSelect = true
    
    private var player: AVAudioPlayer?
    
    private var memoryData: [MemoryData] = []
    var allBucketList: [BucketList] = []
    
    private lazy var nextButton: UIButton = create {
        $0.setImage(UIImage(named: "icon_func_next"), for: .normal)
        $0.addTarget(self, action: #selector(tappedNextBtn), for: .touchUpInside)
    }
    
    private lazy var descriptionLabel: UILabel = create {
        $0.font = UIFont.semiBold(size: 12)
        $0.textColor = .darkGreen
        $0.text = "Tap to play"
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.isHidden = true
        configureUI()
        fetchDate()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
        timer.invalidate()
        player?.pause()
    }
    
    // MARK: - Firebase data handler

    private func fetchDate() {
        let animationView = self.loadAnimation(name: "lottieLoading", loopMode: .loop)
        animationView.play()
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        DispatchQueue.global().async {
            let imageLists = self.allBucketList.filter { $0.images.isNotEmpty }
            imageLists.enumerated().forEach { listIndex, list in
                let images = list.images
                images.enumerated().forEach { imageIndex, image in
                    guard let url = URL(string: image), let data = try? Data(contentsOf: url), let image = UIImage(data: data) else {
                        return
                    }
                    self.memoryData.append(MemoryData(image: image,
                                                      title: list.list,
                                                      date: Date.dateFormatter.string(from: list.createdTime)))
                    // leave dispatch group when finish last data
                    if listIndex == imageLists.count - 1, imageIndex == images.count - 1 {
                        dispatchGroup.leave()
                    }
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.foreImageView.image = self.memoryData.first?.image
            self.titleLabel.text = self.memoryData.first?.title
            self.dateLabel.text = self.memoryData.first?.date
            self.stopAnimation(animationView: animationView)
        }
    }
    
    // MARK: - UI handler

    private func configureUI() {
        view.backgroundColor = .darkGreen
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
    
    // MARK: - User interaction handler

    @objc
    private func tappedNextBtn() {
        if playSelect {
            playSelect = false
            self.timer = Timer.scheduledTimer(timeInterval: 2.0, target: self,
                                              selector: #selector(self.playVideo),
                                              userInfo: nil, repeats: true)
            // Music
            guard let url = Bundle.main.url(forResource: "dreams", withExtension: "mp3") else {
                Log.e("Cant find mp3 url")
                return
            }
            player = try? AVAudioPlayer(contentsOf: url)
            player?.play()
        } else {
            playSelect = true
            timer.invalidate()
            player?.pause()
        }
    }
    
    @objc
    private func playVideo() {
        if index < memoryData.count - 1 {
            index += 1
        } else {
            // last image should transit to first one
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
