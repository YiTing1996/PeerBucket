//
//  ExploreDetailViewController.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/15.
//

import Foundation
import UIKit
import FirebaseAuth

class ExploreDetailViewController: UIViewController {
        
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var menuBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var blackView: UIView!
        
    var content: ExploreBucket?
    var currentUserUID: String?

    override func viewDidLoad() {
        super.viewDidLoad()
                
        blackView.backgroundColor = .black
        blackView.alpha = 0
        menuBottomConstraint.constant = -500
        
        tableView.backgroundColor = .lightGray
        view.backgroundColor = .lightGray
        
        tableView.dataSource = self
        tableView.delegate = self
        
        if isBeta {
            self.currentUserUID = "AITNzRSyUdMCjV4WrQxT"
        } else {
            self.currentUserUID = Auth.auth().currentUser?.uid ?? nil
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? AddToBucketViewController {
            destination.delegate = self
            destination.selectedBucketTitle = content?.title
        }
    }
    
}

extension ExploreDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExploreDetailTableViewCell", for: indexPath)
        
        guard let exploreDetailCell = cell as? ExploreDetailTableViewCell,
              let content = content else { return cell }
        
        exploreDetailCell.delegate = self
        
        switch indexPath.row {
        case 0:
            exploreDetailCell.configureImageCell(content: content)
            exploreDetailCell.clipsToBounds = true
            exploreDetailCell.layer.cornerRadius = exploreDetailCell.frame.height/10
            
        case 1:
            exploreDetailCell.configureRatingCell(content: content)
            if currentUserUID == nil {
                exploreDetailCell.collectButton.isEnabled = false
            }
            
        default:
            exploreDetailCell.configureInfoCell(content: content)
        }
                
        return exploreDetailCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 450
        case 1:
            return 80
        default:
            return UITableView.automaticDimension
        }
    }
}

extension ExploreDetailViewController: ExploreDetailTableViewCellDelegate {
    
    func didTappedWeb() {
        let webVC = storyboard?.instantiateViewController(withIdentifier: "webVC")
        guard let webVC = webVC as? WebViewController, let content = content else { return }
        webVC.link = content.link
        navigationController?.pushViewController(webVC, animated: true)
    }
    
    func didTappedCollect() {
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0) {
            self.menuBottomConstraint.constant = 0
            self.blackView.alpha = 0.5
        }
    }
}

extension ExploreDetailViewController: AddToBucketViewControllerDelegate {
    
    func didTappedClose() {
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0) {
            self.menuBottomConstraint.constant = -500
            self.blackView.alpha = 0
        }
    }
    
}
