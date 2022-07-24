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
    
    // MARK: - Properties

    weak var delegate: AddScheduleViewControllerDelegate?
    
    var selectedDate: Date?
    var buckteListTitle: String? {
        didSet {
            eventTextField.text = buckteListTitle
        }
    }
    
    lazy var eventLabel: UILabel = create {
        $0.textColor = .darkGray
        $0.font = UIFont.semiBold(size: 20)
        $0.text = "Add a new event below !"
    }
    
    lazy var eventTextField: UITextField = create {
        $0.setTextField(placeholder: "Type Event Name Here")
    }
    
    lazy var datePicker: UIDatePicker = create {
        $0.timeZone = TimeZone.current
        $0.addTarget(self, action: #selector(didChangedDate(_:)), for: .valueChanged)
        $0.setValue(UIColor.darkGray, forKeyPath: "textColor")
        $0.backgroundColor = .lightGray
        $0.preferredDatePickerStyle = .wheels
    }
    
    lazy var cancelButton: UIButton = create {
        $0.setImage(UIImage(named: "icon_func_cancel"), for: .normal)
        $0.addTarget(self, action: #selector(tappedCloseBtn), for: .touchUpInside)
    }
    
    lazy var submitButton: UIButton = create {
        $0.setTitle("SUBMIT", for: .normal)
        $0.addTarget(self, action: #selector(tappedSubmitBtn), for: .touchUpInside)
        $0.setTextButton(bgColor: .mediumGray, titleColor: .white, font: 15)
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    // MARK: - User interaction processor

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
            
            createNotification(event: schedule)
            eventTextField.text = ""
            delegate?.didTappedClose()
            
        } else {
            presentAlert(title: "Error", message: "Please fill all the field")
        }
    }
}

// MARK: - Notification

extension AddScheduleViewController {
    
    func createNotification(event: Schedule) {

        let content = UNMutableNotificationContent()
        content.title = "Schedule Today"
        content.subtitle = Date.dateFormatter.string(from: event.eventDate)
        content.body = event.event
        content.sound = .default

        let calendar = Calendar.current
        let component = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: event.eventDate)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: component, repeats: false)

        let request = UNNotificationRequest(identifier: event.id, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if error != nil {
                print("add notification failed")
                self.presentAlert(title: "Error", message: "Notification Error. Please try again later.")
            }
        }
    }
    
}
