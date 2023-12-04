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

final class AddScheduleViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - Properties

    weak var delegate: AddScheduleViewControllerDelegate?
    
    private var selectedDate: Date?

    private lazy var eventLabel: UILabel = create {
        $0.textColor = .darkGray
        $0.font = UIFont.semiBold(size: 20)
        $0.text = "Add a new event below !"
    }
    
    private(set) lazy var eventTextField: UITextField = create {
        $0.setThemeTextField(placeholder: "Type Event Name Here")
    }
    
    private lazy var datePicker: UIDatePicker = create {
        $0.timeZone = TimeZone.current
        $0.addTarget(self, action: #selector(didChangedDate(_:)), for: .valueChanged)
        $0.setValue(UIColor.darkGray, forKeyPath: "textColor")
        $0.backgroundColor = .lightGray
        $0.preferredDatePickerStyle = .wheels
    }
    
    private lazy var cancelButton: UIButton = create {
        $0.setImage(UIImage(named: "icon_func_cancel"), for: .normal)
        $0.addTarget(self, action: #selector(tappedCloseBtn), for: .touchUpInside)
    }
    
    private lazy var submitButton: UIButton = create {
        $0.setTitle("SUBMIT", for: .normal)
        $0.addTarget(self, action: #selector(tappedSubmitBtn), for: .touchUpInside)
        $0.setTextBtn(bgColor: .mediumGray, titleColor: .white, font: 15)
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        eventTextField.delegate = self
    }
    
    func configureUI() {
        view.addSubviews([eventLabel, eventTextField, datePicker, cancelButton, submitButton])
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
    
    // MARK: - User interaction handler

    @objc
    private func didChangedDate(_ sender: UIDatePicker) {
        selectedDate = sender.date
    }
    
    @objc
    private func tappedCloseBtn() {
        delegate?.didTappedClose()
    }
    
    @objc
    private func tappedSubmitBtn() {
        guard let currentUserUID = currentUserUID else { return }
        if let text = eventTextField.text, text.isNotEmpty {
            addSchedule(userID: currentUserUID)
            eventTextField.text = ""
            delegate?.didTappedClose()
        } else {
            presentAlert(title: "Error", message: "Please fill all the field")
        }
    }
    
    private func addSchedule(userID: String) {
        var schedule: Schedule = Schedule(
            senderId: userID,
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
    }
    
    private func createNotification(event: Schedule) {
        let content = UNMutableNotificationContent()
        content.title = "Schedule Today"
        content.subtitle = Date.dateFormatter.string(from: event.eventDate)
        content.body = event.event
        content.sound = .default

        let calendar = Calendar.current
        var component = calendar.dateComponents([.year, .month, .day], from: event.eventDate)
        component.hour = 12
        component.minute = 5
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: component, repeats: false)
        let request = UNNotificationRequest(identifier: event.id, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                self.presentAlert(title: "Error", message: error.localizedDescription)
            }
        }
    }
}
