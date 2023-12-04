//
//  LaunchViewController.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/7/7.
//

import UIKit
import AVFoundation

final class LaunchViewController: UIViewController {
    
    // MARK: - Properties

    private var player: AVPlayer = {
        guard let path = Bundle.main.path(forResource: "launchScreen", ofType: "mp4") else {
            Log.e("invalid video path")
            return .init()
        }
        let player = AVPlayer(url: URL(fileURLWithPath: path))
        return player
    }()
    
    private lazy var playerLayer: AVPlayerLayer = {
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill
        return playerLayer
    }()
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.addSublayer(self.playerLayer)
        player.play()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) { [weak self] in
            self?.routeToRoot()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer.frame = view.bounds
    }
}
