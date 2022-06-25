//
//  ViewController.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/15.
//

import UIKit

class ExploreViewController: UIViewController {
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: configureLayout())
        collectionView.register(ExploreCollectionViewCell.self, forCellWithReuseIdentifier: ExploreCollectionViewCell.identifier)
        collectionView.register(ChallengeCollectionViewCell.self, forCellWithReuseIdentifier: ChallengeCollectionViewCell.identifier)
        collectionView.register(ExploreHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: ExploreHeaderView.identifier)
        collectionView.register(ChallengeHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: ChallengeHeaderView.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    
    var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "mock_avatar")
        imageView.layer.cornerRadius = 20
        return imageView
    }()
    
    var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Recommend Bucket To You"
        label.textColor = .darkGreen
        label.font = UIFont.bold(size: 30)
        label.numberOfLines = 0
        return label
    }()
    
    var decoView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var currentTab: Int = 0 {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        configureUI()
        self.view.backgroundColor = .lightGray
        collectionView.backgroundColor = .lightGray
    }
    
    func configureUI() {
//        view.addSubview(imageView)
        view.addSubview(nameLabel)
        view.addSubview(collectionView)
        
//        imageView.anchor(top: view.topAnchor, left: view.leftAnchor,
//                         paddingTop: 100, paddingLeft: 20,
//                         width: 100, height: 100)
        nameLabel.anchor(top: view.topAnchor, left: view.leftAnchor,
                         paddingTop: 100, paddingLeft: 40,
                         width: 250)
        collectionView.anchor(top: nameLabel.bottomAnchor, left: view.leftAnchor,
                              bottom: view.bottomAnchor, right: view.rightAnchor,
                              paddingTop: 20, paddingLeft: 10, paddingBottom: 10,
                              paddingRight: 10, height: view.frame.height/4*3)
        
    }
    
    func configureLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { section, _ in
            if section == 0 {
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(0.5),
                                                                    heightDimension: .absolute(300)))
                item.contentInsets.trailing = 16
                item.contentInsets.bottom = 16
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1),
                                                                                 heightDimension: .estimated(500)), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuous
                section.contentInsets.leading = 16
                section.contentInsets.top = 40
                
                section.boundarySupplementaryItems = [
                    .init(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(50)),
                          elementKind: UICollectionView.elementKindSectionHeader, alignment: .topLeading)
                ]
                
                return section
                
            } else {
                
                let item = NSCollectionLayoutItem.init(layoutSize: .init(widthDimension: .fractionalWidth(1),
                                                                         heightDimension: .fractionalHeight(1)))
                item.contentInsets.trailing = 16
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(0.8),
                                                                                 heightDimension: .absolute(150)), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuous
                section.contentInsets.leading = 16
                
                section.boundarySupplementaryItems = [
                    .init(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(50)),
                          elementKind: UICollectionView.elementKindSectionHeader, alignment: .topLeading)
                ]
                return section
                
            }
        }
    }
    
}

extension ExploreViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        section == 0 ? exploreMovie.count : 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
            guard let exploreCell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ExploreCollectionViewCell.identifier, for: indexPath) as? ExploreCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            exploreCell.configureCell(content: exploreList[currentTab][indexPath.row])
            exploreCell.backgroundColor = UIColor.lightGray
            exploreCell.clipsToBounds = true
            exploreCell.layer.cornerRadius = exploreCell.frame.height/15
            
            return exploreCell
            
        } else {
            guard let recommendCell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ChallengeCollectionViewCell.identifier, for: indexPath) as? ChallengeCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            recommendCell.backgroundColor = UIColor.lightGray
            recommendCell.clipsToBounds = true
            recommendCell.layer.cornerRadius = recommendCell.frame.height/10
            recommendCell.configureCell(image: challengeMainImage[indexPath.row])
            
            return recommendCell
        }
        
    }
    
}

extension ExploreViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if indexPath.section == 0 {
            let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "ExploreHeaderView", for: indexPath)
            
            guard let headerView = headerView as? ExploreHeaderView else { return headerView }
            headerView.delegate = self
            
            return headerView
            
        } else {
            let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "ChallengeHeaderView", for: indexPath)
            
            guard let headerView = headerView as? ChallengeHeaderView else { return headerView }
            
            return headerView
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            let exploreDetailVC = storyboard?.instantiateViewController(withIdentifier: "exploreDetailVC")
            guard let detailVC = exploreDetailVC as? ExploreDetailViewController else { return }
            detailVC.content = exploreList[currentTab][indexPath.row]
            navigationController?.pushViewController(detailVC, animated: true)

        } else {
            let challengeVC = storyboard?.instantiateViewController(withIdentifier: "challengeVC")
            guard let challengeVC = challengeVC as? ChallengeViewController else { return }
            navigationController?.pushViewController(challengeVC, animated: true)
            challengeVC.bgImage = challengeList[indexPath.row]

        }
        
    }
    
}

extension ExploreViewController: ExploreHeaderViewDelegate {
    func didSelectedButton(at index: Int) {
        self.currentTab = index
    }
    
}
