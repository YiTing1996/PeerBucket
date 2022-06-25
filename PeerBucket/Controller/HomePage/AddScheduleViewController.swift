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
    //    func didChangeDate()
}

class AddScheduleViewController: UIViewController, UITextFieldDelegate {
    
    weak var delegate: AddScheduleViewControllerDelegate?
    
    var selectedDate: Date?
    
    var eventTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Type Event Name Here"
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 10
        textField.setLeftPaddingPoints(amount: 10)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        //        datePicker.frame = CGRect(x: 10, y: 50, width: 200, height: 50)
        datePicker.timeZone = TimeZone.current
        datePicker.backgroundColor = UIColor.lightGray
        datePicker.addTarget(self, action: #selector(didChangedDate(_:)), for: .valueChanged)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        return datePicker
    }()
    
    lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.lightGray
        button.addTarget(self, action: #selector(tappedCloseBtn), for: .touchUpInside)
        return button
    }()
    
    lazy var submitButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.lightGray
        button.addTarget(self, action: #selector(tappedSubmitBtn), for: .touchUpInside)
        button.setTitle("Submit", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        
        eventTextField.delegate = self
        
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
        selectedDate = sender.date
    }
    
    @objc func tappedCloseBtn() {
        delegate?.didTappedClose()
    }
    
    @objc func tappedSubmitBtn() {
        
        if eventTextField.text != "" {
            
            var schedule: Schedule = Schedule(
                senderId: testUserID,
                event: eventTextField.text ?? "",
                id: "",
                eventDate: selectedDate ?? Date()
            )
            
            ScheduleManager.shared.addSchedule(schedule: &schedule) { result in
                switch result {
                case .success:
                    self.presentSuccessAlert()
                case .failure(let error):
                    self.presentErrorAlert(message: error.localizedDescription + " Please try again")
                }
            }
            
            eventTextField.text = ""
            delegate?.didTappedClose()
            
        } else {
            presentErrorAlert(message: "Please fill all the field")
        }
    }
}
