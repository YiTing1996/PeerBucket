//
//  LaunchViewController.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/7/7.
//

import Foundation
import UIKit
import AVFoundation

class LaunchViewController: UIViewController {
    
    // MARK: - Properties

    var player: AVPlayer = {
        guard let path = Bundle.main.path(forResource: "launchScreen", ofType: "mp4") else {
            fatalError("Invalid Video path")
        }
        let player = AVPlayer(url: URL(fileURLWithPath: path))
        return player
    }()
    
    lazy var playerLayer: AVPlayerLayer = {
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill
        return playerLayer
    }()
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer.addSublayer(self.playerLayer)
        player.play()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let tabBarVC = storyboard.instantiateViewController(withIdentifier: "tabBarVC")
            guard let tabBarVC = tabBarVC as? TabBarController else { return }

            let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
            sceneDelegate?.changeRootViewController(tabBarVC)
            
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer.frame = view.bounds
        
    }
    
}
