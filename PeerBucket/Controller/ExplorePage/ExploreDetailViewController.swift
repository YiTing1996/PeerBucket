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
    
    lazy var ratingView: UIView = create {
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 20
        $0.backgroundColor = .darkGreen
        $0.alpha = 0.95
//        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    lazy var webButton: UIButton = create {
        $0.setTextButton(bgColor: .darkGreen, titleColor: .lightGray, font: 15)
        $0.setTitle("More Detail > ", for: .normal)
        $0.addTarget(self, action: #selector(tappedWebBtn), for: .touchUpInside)
    }
    
    lazy var ratingImageView: UIImageView = create {
        $0.image = UIImage(named: "icon_rating3")
    }
    
    lazy var ratingLabel: UILabel = create {
        $0.font = UIFont.bold(size: 20)
        $0.textColor = UIColor.lightGray
    }
    
    lazy var collectButton: UIButton = create {
        $0.setImage(UIImage(named: "icon_func_collect"), for: .normal)
        $0.addTarget(self, action: #selector(tappedCollectBtn), for: .touchUpInside)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        
        configureRatingView()
        configureUI()
        
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
    
    func configureUI() {
        tableView.backgroundColor = .lightGray
        view.backgroundColor = .lightGray
        
        view.addSubview(collectButton)
        collectButton.anchor(top: tableView.topAnchor, right: view.rightAnchor,
                             paddingTop: 50, paddingRight: 20)
        
        blackView.backgroundColor = .black
        blackView.alpha = 0
        menuBottomConstraint.constant = hideMenuBottomConstraint
        view.bringSubviewToFront(blackView)
        view.bringSubviewToFront(containerView)
    }
    
    func configureRatingView() {
        
        view.addSubview(ratingView)
        ratingView.addSubview(ratingImageView)
        ratingView.addSubview(ratingLabel)
        ratingView.addSubview(webButton)

        ratingView.anchor(left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor,
                          paddingLeft: 20, paddingBottom: 30, paddingRight: 20, height: 60)
        
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
        self.present(webVC, animated: true)
    }
    
}

// MARK: - TableView

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
            return CGFloat(screenHeight*2.8/5)
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
            self.menuBottomConstraint.constant = hideMenuBottomConstraint
            self.blackView.alpha = 0
        }
    }
    
}
