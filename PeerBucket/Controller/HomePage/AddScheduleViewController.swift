//
//  AddScheduleViewController.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/18.
//

import Foundation
import UIKit

protocol AddScheduleViewControllerDelegate: AnyObject {
    func didTappedClose()
    func didChangeDate()
}

class AddScheduleViewController: UIViewController {
    
    weak var delegate: AddScheduleViewControllerDelegate?
    
    var eventTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Type Event Name Here"
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 10
        textField.setLeftPaddingPoints(amount: 10)
        return textField
    }()
    
    lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.frame = CGRect(x: 10, y: 50, width: 200, height: 50)
        datePicker.timeZone = NSTimeZone.local
        datePicker.backgroundColor = UIColor.bgGray
        datePicker.addTarget(self, action: #selector(didChangedDate(_:)), for: .valueChanged)
        return datePicker
    }()
    
    lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.bgGray
        button.addTarget(self, action: #selector(tappedCloseBtn), for: .touchUpInside)
        return button
    }()
    
    lazy var submitButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.bgGray
        button.addTarget(self, action: #selector(tappedSubmitBtn), for: .touchUpInside)
        button.setTitle("Submit", for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    func configureUI() {
        view.addSubview(eventTextField)
        view.addSubview(datePicker)
        view.addSubview(cancelButton)
        view.addSubview(submitButton)
        
        eventTextField.anchor(top: view.topAnchor, left: view.leftAnchor,
                              paddingTop: 50, paddingLeft: 50, width: 250, height: 50)
        datePicker.anchor(top: eventTextField.bottomAnchor, left: view.leftAnchor,
                          paddingTop: 20, paddingLeft: 50)
        cancelButton.anchor(top: view.topAnchor, right: view.rightAnchor,
                            paddingTop: 20, paddingRight: 20, width: 50, height: 50)
        submitButton.anchor(top: datePicker.bottomAnchor, paddingTop: 50, width: 150, height: 50)
        submitButton.centerX(inView: view)

    }
    
    @objc func didChangedDate(_ sender: UIDatePicker) {
        // Create date formatter
        let dateFormatter: DateFormatter = DateFormatter()
        
        // Set date format
        dateFormatter.dateFormat = "MM/dd/yyyy hh:mm a"
        
        // Apply date format
        let selectedDate: String = dateFormatter.string(from: sender.date)
        
        print("Selected value \(selectedDate)")
    }
    
    @objc func tappedCloseBtn() {
        delegate?.didTappedClose()
    }
    
    @objc func tappedSubmitBtn() {
        if eventTextField.text != "" {
            // 傳資料到VC
            delegate?.didTappedClose()
        } else {
            presentErrorAlert(message: "Please fill all the field")
        }
    }
    
}
