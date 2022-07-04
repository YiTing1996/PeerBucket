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
    @IBOutlet weak var containerView: UIView!
    
    var content: ExploreBucket?
    var currentUserUID: String?
    
    var ratingView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 25
        view.backgroundColor = .darkGreen
        view.alpha = 0.95
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var webButton: UIButton = {
        let button = UIButton()
        button.setTextButton(bgColor: .darkGreen, titleColor: .lightGray, radius: 0, font: 15)
        button.setTitle("More Detail > ", for: .normal)
        button.addTarget(self, action: #selector(tappedWebBtn), for: .touchUpInside)
        return button
    }()
    
    var ratingImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "icon_rating3")
        return imageView
    }()
    
    var ratingLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.bold(size: 20)
        label.textColor = UIColor.lightGray
        return label
    }()
    
    lazy var collectButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "icon_func_collect"), for: .normal)
        button.addTarget(self, action: #selector(tappedCollectBtn), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = .lightGray
        view.backgroundColor = .lightGray
        
        tableView.dataSource = self
        tableView.delegate = self
        
        if isBeta {
            self.currentUserUID = "AITNzRSyUdMCjV4WrQxT"
        } else {
            self.currentUserUID = Auth.auth().currentUser?.uid ?? nil
        }
        
        view.addSubview(collectButton)
        collectButton.anchor(top: tableView.topAnchor, right: view.rightAnchor,
                             paddingTop: 50, paddingRight: 20)
        configureRatingView()
        
        blackView.backgroundColor = .black
        blackView.alpha = 0
        menuBottomConstraint.constant = -500
        view.bringSubviewToFront(blackView)
        view.bringSubviewToFront(containerView)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        
        if currentUserUID == nil {
            collectButton.isEnabled = false
        } else {
            collectButton.isEnabled = true
        }
        
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
    
    func configureRatingView() {
        
        view.addSubview(ratingView)
        ratingView.addSubview(ratingImageView)
        ratingView.addSubview(ratingLabel)
        ratingView.addSubview(webButton)

        ratingView.anchor(left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor,
                          paddingLeft: 20, paddingBottom: 50, paddingRight: 20, height: 70)
        
        ratingImageView.anchor(left: ratingView.leftAnchor, paddingLeft: 20)
        ratingLabel.anchor(left: ratingImageView.rightAnchor, paddingLeft: 15, width: 100)
        webButton.anchor(right: ratingView.rightAnchor, paddingRight: 20, width: 100, height: 50)
        
        ratingLabel.centerY(inView: ratingView)
        webButton.centerY(inView: ratingView)
        ratingImageView.centerY(inView: ratingView)
        
        ratingLabel.text = content?.rating
    }
    
    @objc func tappedCollectBtn() {
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0) {
            self.menuBottomConstraint.constant = 0
            self.blackView.alpha = 0.5
        }
    }
    
    @objc func tappedWebBtn() {
        let webVC = storyboard?.instantiateViewController(withIdentifier: "webVC")
        guard let webVC = webVC as? WebViewController, let content = content else { return }
        webVC.link = content.link
        navigationController?.pushViewController(webVC, animated: true)
    }
    
}

extension ExploreDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExploreDetailTableViewCell", for: indexPath)
        
        guard let exploreDetailCell = cell as? ExploreDetailTableViewCell,
              let content = content else { return cell }
        
        exploreDetailCell.delegate = self
        
        switch indexPath.row {
        case 0:
            exploreDetailCell.configureImageCell(content: content)
        default:
            exploreDetailCell.configureInfoCell(content: content)
            exploreDetailCell.selectionStyle = .none
        }
        
        return exploreDetailCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 450
        default:
            return UITableView.automaticDimension
        }
    }
}

extension ExploreDetailViewController: ExploreDetailTableViewCellDelegate {
    
    func didTappedMore() {
        DispatchQueue.main.async {
            self.tableView.reloadRows(at: [[0, 1]], with: .none)
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
