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

class QRCodeViewController: UIViewController {
    
    weak var delegate: QRCodeViewControllerDelegate?
    
    var qrcodeImage: CIImage?
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGreen
        label.numberOfLines = 0
        label.font = UIFont.semiBold(size: 20)
        label.text = "Here's your QRCode"
        return label
    }()
    
    lazy var bgImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .hightlightYellow
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "icon_func_cancel"), for: .normal)
        button.addTarget(self, action: #selector(tappedCloseBtn), for: .touchUpInside)
        return button
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let currentUserUID = currentUserUID else {
            return
        }
        
        createQRCode(currentUserUID)
        configureUI()

    }
    
    func configureUI() {
        
        view.addSubview(titleLabel)
        view.addSubview(bgImageView)
        view.addSubview(cancelButton)
        
        view.clipsToBounds = true
        view.layer.cornerRadius = 20
        
        titleLabel.anchor(top: view.topAnchor, left: view.leftAnchor,
                          paddingTop: 20, paddingLeft: 20, width: 150)
        bgImageView.anchor(top: titleLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor,
                           paddingTop: 10, paddingLeft: 20, paddingRight: 20, width: 300, height: 300)
        cancelButton.anchor(top: view.topAnchor, right: view.rightAnchor,
                            paddingTop: 10, paddingRight: 10, width: 50, height: 50)
    }
    
    @objc func tappedCloseBtn() {
        delegate?.didTappedClose()
    }
    
    func createQRCode(_ text: String) {
    
        // 將文字資料轉換成Data
        let data = text.data(using: .isoLatin1)
        // 用CIFilter轉換，建立新的 CoreImage 濾波器（利用 CIQRCodeGenerator ）來指定一些參數，
        // 然後即可獲得輸出的圖片，也就是 QR Code 圖片。
        let qrFilter = CIFilter(name: "CIQRCodeGenerator")
        // 這是要轉換成 QR Code 圖片的初始資料
        qrFilter?.setValue(data, forKey: "inputMessage")
        qrFilter?.setValue("Q", forKey: "inputCorrectionLevel")
        
        // 修正QRCode模糊度
        if let qrcodeImage = qrFilter?.outputImage {
            let qrWidth = UIScreen.main.bounds.width / 3 * 2 - 64
            let scaleX = qrWidth / qrcodeImage.extent.width
            let scaleY = qrWidth / qrcodeImage.extent.height
            
            // 取得調整後的圖片大小，用CGAffineTransform去做縮放
            let transformedImage = qrcodeImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
            bgImageView.image = UIImage(ciImage: transformedImage)
        }
                
    }
    
}
