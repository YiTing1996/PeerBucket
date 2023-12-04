//
//  ExploreHeaderView.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/15.
//

import UIKit

protocol ExploreHeaderViewDelegate: AnyObject {
    func didSelectedButton(at index: Int)
}

final class ExploreHeaderView: UICollectionReusableView {
        
    weak var delegate: ExploreHeaderViewDelegate?
    
    private lazy var headerStack: UIStackView = create {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.spacing = 5
    }
    
    private var headerButton: [UIButton] = []
    private var buttonTitle: [String] = ["#MOVIE", "#TRAVEL", "#GIFT"]

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        addSubview(headerStack)
        setButtonStack()
        headerStack.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor,
                           right: rightAnchor, paddingTop: 5, paddingLeft: 5, paddingRight: 5)
    }
    
    private func setButtonStack() {
        for index in 0...buttonTitle.count - 1 {
            let button = UIButton(type: .system)
            button.setTitle(buttonTitle[index], for: .normal)
            button.addTarget(self, action: #selector(didTappedButton), for: .touchUpInside)
            if index == 0 {
                button.setBoldTextBtn(bgColor: .darkGreen, titleColor: .white)
            } else {
                button.setBoldTextBtn(bgColor: .lightGray, titleColor: .darkGreen)
            }
            headerStack.addArrangedSubview(button)
            headerButton.append(button)
        }
    }
    
    @objc
    private func didTappedButton(button: UIButton) {
        UIView.animate(withDuration: 0.3) {
            for btn in self.headerButton {
                if btn == button {
                    btn.setBoldTextBtn(bgColor: .darkGreen, titleColor: .white)
                } else {
                    btn.setBoldTextBtn(bgColor: .lightGray, titleColor: .darkGreen)
                }
            }
            self.layoutIfNeeded()
        }
        let index = headerButton.firstIndex(where: { $0 == button }) ?? 0
        delegate?.didSelectedButton(at: index)
    }
}
