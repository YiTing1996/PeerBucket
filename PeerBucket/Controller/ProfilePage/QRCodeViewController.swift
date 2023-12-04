//
//  QRCodeViewController.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/21.
//

import Foundation
import UIKit
import FirebaseAuth

protocol QRCodeViewControllerDelegate: AnyObject {
    func didTappedClose()
}

final class QRCodeViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var delegate: QRCodeViewControllerDelegate?
    
    private var qrcodeImage: CIImage?
    
    private lazy var titleLabel: UILabel = create {
        $0.textColor = .darkGreen
        $0.numberOfLines = 0
        $0.font = UIFont.semiBold(size: 20)
        $0.text = "Here's your QRCode"
    }
    
    private lazy var bgImageView: UIImageView = create {
        $0.backgroundColor = .hightlightYellow
        $0.contentMode = .scaleAspectFill
    }
    
    private lazy var cancelButton: UIButton = create {
        $0.setImage(UIImage(named: "icon_func_cancel"), for: .normal)
        $0.addTarget(self, action: #selector(tappedCloseBtn), for: .touchUpInside)
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let currentUserUID = currentUserUID else {
            return
        }
        createQRCode(currentUserUID)
        configureUI()
    }
    
    // MARK: - UI

    func configureUI() {
        view.addSubviews([titleLabel, bgImageView, cancelButton])
        view.clipsToBounds = true
        view.layer.cornerRadius = 20
        titleLabel.anchor(top: view.topAnchor, left: view.leftAnchor,
                          paddingTop: 20, paddingLeft: 20, width: 150)
        bgImageView.anchor(top: titleLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor,
                           paddingTop: 10, paddingLeft: 20, paddingRight: 20, width: 300, height: 300)
        cancelButton.anchor(top: view.topAnchor, right: view.rightAnchor,
                            paddingTop: 10, paddingRight: 10, width: 50, height: 50)
    }
    
    // MARK: - User interaction handler

    @objc
    private func tappedCloseBtn() {
        delegate?.didTappedClose()
    }
    
    private func createQRCode( _ text: String) {
        let data = text.data(using: .isoLatin1)
        let qrFilter = CIFilter(name: "CIQRCodeGenerator")
        qrFilter?.setValue(data, forKey: "inputMessage")
        qrFilter?.setValue("Q", forKey: "inputCorrectionLevel")
        
        if let qrcodeImage = qrFilter?.outputImage {
            let qrWidth = UIScreen.main.bounds.width / 3 * 2 - 64
            let scaleX = qrWidth / qrcodeImage.extent.width
            let scaleY = qrWidth / qrcodeImage.extent.height
            let transformedImage = qrcodeImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
            bgImageView.image = UIImage(ciImage: transformedImage)
        }
    }
}
