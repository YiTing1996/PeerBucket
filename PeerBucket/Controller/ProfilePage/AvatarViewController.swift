//
//  AvatarViewController.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/23.
//

import Foundation
import UIKit
import FirebaseAuth

protocol AvatarViewControllerDelegate: AnyObject {
    func didTappedSubmit()
}

final class AvatarViewController: BaseViewController {
    
    // MARK: - Properties
    
    weak var delegate: AvatarViewControllerDelegate?
        
    private lazy var submitButton: UIButton = create {
        $0.setTitle("Submit", for: .normal)
        $0.addTarget(self, action: #selector(tappedSubmit), for: .touchUpInside)
        $0.setTextBtn(bgColor: .clear, titleColor: .darkGreen, border: 0, font: 15)
    }
        
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var hair: UIImageView!
    @IBOutlet weak var face: UIImageView!
    @IBOutlet weak var glasses: UIImageView!
    @IBOutlet weak var body: UIImageView!
    
    @IBOutlet weak var backgroundSlider: UISlider!
    @IBOutlet weak var selectionView: UIView!
    @IBOutlet weak var hairView: UIView!
    @IBOutlet weak var faceView: UIView!
    @IBOutlet weak var glassesView: UIView!
    @IBOutlet weak var bodyView: UIView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.isHidden = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.submitButton)
        configureUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - Configure UI
    
    private func configureUI() {
        hairView.isHidden = false
        faceView.isHidden = true
        glassesView.isHidden = true
        bodyView.isHidden = true
        backgroundView.anchor(top: view.topAnchor, left: view.leftAnchor,
                              bottom: selectionView.topAnchor, right: view.rightAnchor,
                              height: ScreenConstant.height * 0.5)
        backgroundSlider.anchor(left: view.leftAnchor, bottom: backgroundView.bottomAnchor,
                                right: view.rightAnchor, paddingLeft: 10, paddingBottom: 10,
                                paddingRight: 10, height: 50)
        selectionView.anchor(left: view.leftAnchor, right: view.rightAnchor,
                             height: ScreenConstant.height * 0.1)
        hairView.anchor(top: selectionView.bottomAnchor, left: view.leftAnchor,
                        bottom: view.bottomAnchor, right: view.rightAnchor,
                        height: ScreenConstant.height * 0.4)
        faceView.anchor(top: selectionView.bottomAnchor, left: view.leftAnchor,
                        bottom: view.bottomAnchor, right: view.rightAnchor,
                        height: ScreenConstant.height * 0.4)
        glassesView.anchor(top: selectionView.bottomAnchor, left: view.leftAnchor,
                           bottom: view.bottomAnchor, right: view.rightAnchor,
                           height: ScreenConstant.height * 0.4)
        bodyView.anchor(top: selectionView.bottomAnchor, left: view.leftAnchor,
                        bottom: view.bottomAnchor, right: view.rightAnchor,
                        height: ScreenConstant.height * 0.4)
    }
    
    // MARK: - Firebase handler
    
    private func uploadImage(image: UIImage) {
        guard let imageData = image.pngData() else {
            return
        }
        ImageService.shared.uploadImage(type: .avatar, data: imageData) { [weak self] urlString in
            guard urlString.isNotEmpty else {
                return
            }
            Info.shared.updateUserData(avatar: urlString) {
                self?.delegate?.didTappedSubmit()
            }
        }
    }
    
    // MARK: - Button actions
    
    @objc
    private func tappedSubmit() {
        let renderer = UIGraphicsImageRenderer(size: backgroundView.bounds.size)
        let image = renderer.image { _ in
            backgroundView.drawHierarchy(in: backgroundView.bounds, afterScreenUpdates: true)
        }
        uploadImage(image: image)
        presentAlert(title: "Congrats", message: "Avatar successfully update") { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func changeHair(_ sender: UIButton) {
        let image = sender.currentBackgroundImage
        hair.image = image
    }
    @IBAction func changeFace(_ sender: UIButton) {
        let image = sender.currentBackgroundImage
        face.image = image
    }
    @IBAction func changeGlasses(_ sender: UIButton) {
        let image = sender.currentBackgroundImage
        glasses.image = image
        if image?.isSymbolImage == true {
            glasses.image = nil
        }
    }
    
    @IBAction func chageBody(_ sender: UIButton) {
        let image = sender.currentBackgroundImage
        body.image = image
    }
    
    @IBAction func chageBackground(_ sender: UISlider) {
        // sender的index
        let colorValue = CGFloat(sender.value)
        backgroundView.backgroundColor = UIColor(hue: colorValue, saturation: 0.8, brightness: 1, alpha: 1)
    }
    
    @IBAction func selectHair(_ sender: UIButton) {
        hairView.isHidden = false
        faceView.isHidden = true
        glassesView.isHidden = true
        bodyView.isHidden = true
    }
    
    @IBAction func selectFace(_ sender: UIButton) {
        hairView.isHidden = true
        faceView.isHidden = false
        glassesView.isHidden = true
        bodyView.isHidden = true
    }
    @IBAction func selectGlasses(_ sender: UIButton) {
        hairView.isHidden = true
        faceView.isHidden = true
        glassesView.isHidden = false
        bodyView.isHidden = true
    }
    
    @IBAction func selectBody(_ sender: UIButton) {
        hairView.isHidden = true
        faceView.isHidden = true
        glassesView.isHidden = true
        bodyView.isHidden = false
    }
}
