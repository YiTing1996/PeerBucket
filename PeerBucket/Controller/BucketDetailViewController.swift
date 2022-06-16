//
//  BucketDetailViewController.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/16.
//

import Foundation
import UIKit

class BucketDetailViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    lazy var addListButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(tappedAddBtn), for: .touchUpInside)
        button.setTitle("Add List", for: .normal)
        button.clipsToBounds = true
        button.layer.cornerRadius = 10
        button.backgroundColor = .lightGray
        return button
    }()
    
    var addListTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Type New List Here"
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 10
        return textField
    }()
    
    var selectedBucket: BucketCategory?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        configureUI()
//        addListTextField.isHidden = true
    }
    
    func configureUI() {

        view.addSubview(addListButton)
        view.addSubview(addListTextField)
        
        addListButton.anchor(top: view.topAnchor, right: view.rightAnchor, paddingTop: 100, paddingRight: 50, width: 50)
        addListTextField.anchor(top: view.topAnchor, left: view.leftAnchor, right: addListButton.leftAnchor, paddingTop: 100, paddingLeft: 50, width: 200)
        
    }
    
    @objc func tappedAddBtn() {
//        addListTextField.isHidden = false
        
        guard let selectedBucket = selectedBucket,
              addListTextField.text != "" else {
            return
        }

        BucketListManager.shared.updateBucketList(id: selectedBucket.id, bucketList: addListTextField.text ?? "") { [weak self] result in

            guard let self = self else { return }

            switch result {
            case .success(let bucketList):

//                selectedBucket = bucketList
                print("updated bucketList: \(bucketList)")

            case .failure(let error):
                print(error.localizedDescription)

            }
        }
    }
}

extension BucketDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedBucket?.content.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BucketDetailTableViewCell", for: indexPath)
        
        guard let bucketDetailCell = cell as? BucketDetailTableViewCell,
              let selectedBucket = selectedBucket else { return cell }
        
        bucketDetailCell.configureCell(bucketText: selectedBucket.content[indexPath.row]?.list ?? "")
        bucketDetailCell.contentView.backgroundColor = UIColor.lightGray
        
        return bucketDetailCell
    }
    
}
