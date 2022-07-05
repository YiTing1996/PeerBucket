//
//  AddScheduleViewController.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/18.
//

import Foundation
import UIKit
import FirebaseAuth

protocol AddScheduleViewControllerDelegate: AnyObject {
    func didTappedClose()
}

class AddScheduleViewController: UIViewController, UITextFieldDelegate {
    
    weak var delegate: AddScheduleViewControllerDelegate?
    
    var selectedDate: Date?
    var currentUserUID: String?
    var buckteListTitle: String? {
        didSet {
            eventTextField.text = buckteListTitle
        }
    }
    
    var eventLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.font = UIFont.semiBold(size: 20)
        label.text = "Add a new event below !"
        return label
    }()
    
    var eventTextField: UITextField = {
        let textField = UITextField()
        textField.setTextField(placeholder: "Type Event Name Here")
        return textField
    }()
    
    lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.timeZone = TimeZone.current
        datePicker.addTarget(self, action: #selector(didChangedDate(_:)), for: .valueChanged)
        datePicker.setValue(UIColor.darkGray, forKeyPath: "textColor")
        datePicker.backgroundColor = .lightGray
        datePicker.preferredDatePickerStyle = .wheels
        return datePicker
    }()
    
    lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "icon_func_cancel"), for: .normal)
        button.addTarget(self, action: #selector(tappedCloseBtn), for: .touchUpInside)
        return button
    }()
    
    lazy var submitButton: UIButton = {
        let button = UIButton()
        button.setTitle("SUBMIT", for: .normal)
        button.addTarget(self, action: #selector(tappedSubmitBtn), for: .touchUpInside)
        button.setTextButton(bgColor: .mediumGray, titleColor: .white, radius: 10, font: 15)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isBeta {
            self.currentUserUID = "AITNzRSyUdMCjV4WrQxT"
        } else {
            self.currentUserUID = Auth.auth().currentUser?.uid ?? nil
        }
//        print(currentUserUID)
        
        configureUI()
        
        eventTextField.delegate = self
    }
    
    func configureUI() {
        
        view.addSubview(eventLabel)
        view.addSubview(eventTextField)
        view.addSubview(datePicker)
        view.addSubview(cancelButton)
        view.addSubview(submitButton)
        
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = 30
        view.clipsToBounds = true
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        cancelButton.anchor(top: view.topAnchor, right: view.rightAnchor,
                            paddingTop: 10, paddingRight: 20, width: 50, height: 50)
        eventLabel.anchor(top: view.topAnchor, left: view.leftAnchor,
                          paddingTop: 25, paddingLeft: 30, height: 50)
        eventTextField.anchor(top: eventLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor,
                              paddingTop: 10, paddingLeft: 30, paddingRight: 30, height: 50)
        datePicker.anchor(top: eventTextField.bottomAnchor, left: view.leftAnchor,
                          paddingTop: 20, paddingLeft: 30, height: 100)
        
        submitButton.anchor(top: datePicker.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor,
                            paddingTop: 20, paddingLeft: 30, paddingRight: 30, height: 50)
        
    }
    
    @objc func didChangedDate(_ sender: UIDatePicker) {
        selectedDate = sender.date
    }
    
    @objc func tappedCloseBtn() {
        delegate?.didTappedClose()
    }
    
    @objc func tappedSubmitBtn() {
        
        guard let currentUserUID = currentUserUID else { return }
        
        if eventTextField.text != "" {
            
            var schedule: Schedule = Schedule(
                senderId: currentUserUID,
                event: eventTextField.text ?? "",
                id: "",
                eventDate: selectedDate ?? Date()
            )
            
            ScheduleManager.shared.addSchedule(schedule: &schedule) { result in
                switch result {
                case .success:
                    self.presentAlert()
                case .failure(let error):
                    self.presentAlert(title: "Error", message: error.localizedDescription + " Please try again")
                }
            }
            
            eventTextField.text = ""
            delegate?.didTappedClose()
            
        } else {
            presentAlert(title: "Error", message: "Please fill all the field")
        }
    }
}
