//
//  ExploreHeaderView.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/15.
//

import Foundation
import UIKit

protocol ExploreHeaderViewDelegate: AnyObject {
    func didSelectedButton(at index: Int)
}

class ExploreHeaderView: UICollectionReusableView {
    
    static let identifier = "ExploreHeaderView"
    
    weak var delegate: ExploreHeaderViewDelegate?
    
    var headerStack: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 2
        return stackView
    }()
    
    var headerButton: [UIButton] = []
    var centerXConstraint = NSLayoutConstraint()
    
    var indicatorView: UIView = {
        let indicatorView = UIView()
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        indicatorView.backgroundColor = UIColor.hightlightColor
        return indicatorView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var buttonTitle: [String] = ["#Movie", "#Travel", "#Gift"]
    
    private func configureUI() {
        addSubview(headerStack)
        addSubview(indicatorView)
        
        for index in 0...2 {
            let button = UIButton(type: .system)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.tintColor = .darkGray
            button.setTitle(buttonTitle[index], for: .normal)
            button.setTitleColor(UIColor.textGray, for: .normal)
            button.titleLabel?.font = UIFont.semiBold(size: 20)
            button.addTarget(self, action: #selector(didTappedButton), for: .touchUpInside)
            headerStack.addArrangedSubview(button)
            headerButton.append(button)
        }
        
        headerStack.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor,
                           paddingTop: 5, paddingLeft: 5, paddingBottom: 5, paddingRight: 5)
        indicatorView.anchor(top: headerStack.bottomAnchor, paddingTop: 5, width: 100, height: 2)
        centerXConstraint = indicatorView.centerXAnchor.constraint(equalTo: headerButton[0].centerXAnchor)
        centerXConstraint.isActive = true

    }
    
    @objc func didTappedButton(button: UIButton) {
        
        UIView.animate(withDuration: 0.3, animations: {
            self.centerXConstraint.isActive = false
            self.centerXConstraint = self.indicatorView.centerXAnchor.constraint(equalTo: button.centerXAnchor)
            self.centerXConstraint.isActive = true
            self.layoutIfNeeded()
        })

        let index = headerButton.firstIndex(where: { $0 == button }) ?? 0
        delegate?.didSelectedButton(at: index)
        
    }
    
}
