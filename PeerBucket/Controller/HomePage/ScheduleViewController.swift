//
//  ScheduleViewController.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/18.
//

import Foundation
import UIKit
import FSCalendar
import FirebaseFirestore
import Firebase

class ScheduleViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var menuBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var blackView: UIView!
    @IBOutlet weak var containerView: UIView!
    
    fileprivate weak var calendar: FSCalendar!
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        layout.scrollDirection = .vertical
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ScheduleCollectionViewCell.self,
                                forCellWithReuseIdentifier: ScheduleCollectionViewCell.identifier)
        collectionView.register(ScheduleHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: ScheduleHeaderView.identifier)
        return collectionView
    }()
    
    lazy var longPressGesture: UILongPressGestureRecognizer = {
        let gesture = UILongPressGestureRecognizer()
        gesture.addTarget(self, action: #selector(handleLongPress(gestureReconizer:)))
        gesture.minimumPressDuration = 0.5
        gesture.delaysTouchesBegan = true
        gesture.delegate = self
        return gesture
    }()
    
    var currentUserUID: String?
    //    var currentUserUID = Auth.auth().currentUser?.uid
    
    var userIDList: [String] = []

    var dateString = ""
    var datesWithEvent: [Schedule] = []
    var screenWidth = UIScreen.main.bounds.width
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isBeta {
            self.currentUserUID = "AITNzRSyUdMCjV4WrQxT"
        } else {
            self.currentUserUID = Auth.auth().currentUser?.uid ?? nil
        }
        
        configueCalendarUI()
        configureUI()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let currentUserUID = currentUserUID else { return }
        userIDList.append(currentUserUID)
        getData(userID: currentUserUID, date: Date())

    }
    
    func configueCalendarUI() {
        
        self.view.backgroundColor = .lightGray
        collectionView.backgroundColor = .lightGray
        
        let calendar = FSCalendar(frame: CGRect(x: 0, y: 0, width: 320, height: 300))
        calendar.dataSource = self
        calendar.delegate = self
        view.addSubview(calendar)
        self.calendar = calendar
        
        calendar.appearance.titleFont = UIFont.regular(size: 14)
        calendar.appearance.headerTitleColor = .darkGray
        calendar.appearance.selectionColor = .hightlightYellow
        calendar.appearance.weekdayTextColor = .darkGray
        calendar.appearance.todayColor = .hightlightYellow
        calendar.layer.cornerRadius = 10
        calendar.backgroundColor = .clear
        
        calendar.anchor(top: view.topAnchor, left: view.leftAnchor,
                        right: view.rightAnchor, paddingTop: 100,
                        paddingLeft: 20, paddingRight: 20,
                        width: view.frame.width, height: view.frame.height*3/8)
    }
    
    func configureUI() {
        
        blackView.backgroundColor = .black
        blackView.alpha = 0
        menuBottomConstraint.constant = -500
        containerView.layer.cornerRadius = 10
        
        view.addSubview(collectionView)
        view.bringSubviewToFront(blackView)
        view.bringSubviewToFront(containerView)
        
        collectionView.addGestureRecognizer(longPressGesture)
        
        collectionView.anchor(top: calendar.bottomAnchor, left: view.leftAnchor,
                              bottom: view.bottomAnchor, right: view.rightAnchor,
                              paddingTop: 20, paddingLeft: 20, paddingBottom: 50, paddingRight: 20)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? AddScheduleViewController {
            destination.delegate = self
        }
    }
    
    // MARK: - Firebase data process
    
    @objc func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state != UIGestureRecognizer.State.ended {
            return
        }
        
        let location = gestureReconizer.location(in: self.collectionView)
        let indexPath = self.collectionView.indexPathForItem(at: location)
        
        if let indexPath = indexPath {
            
            self.presentDeleteAlert(title: "Delete Event", message: "Do you want to delete this event?") {
                
                let deleteId = self.datesWithEvent[indexPath.row].id
                print(deleteId)
                
                ScheduleManager.shared.deleteSchedule(id: deleteId) { result in
                    switch result {
                    case .success:
                        self.presentSuccessAlert()
                        self.datesWithEvent.remove(at: indexPath.row)
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                        }
                    case .failure(let error):
                        self.presentErrorAlert(message: error.localizedDescription + " Please try again")
                    }
                }
            }
            
        } else {
            print("Could not find index path")
        }
    }
        
    func getData(userID: String, date: Date) {
        
        UserManager.shared.fetchUserData(userID: userID) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let user):
                
                self.userIDList = [userID]
                if user.paringUser != [] {
                    self.userIDList.append(user.paringUser[0])
                }
                            
                self.datesWithEvent = []
                for userID in self.userIDList {
                    ScheduleManager.shared.fetchSpecificSchedule(userID: userID, date: date) { [weak self] result in
                        
                        guard let self = self else { return }
                        
                        switch result {
                        case .success(let events):
                            self.datesWithEvent += events
                            DispatchQueue.main.async {
                                self.collectionView.reloadData()
                            }
                        case .failure(let error):
                            print(error.localizedDescription)
                        }
                    }
                }

            case .failure(let error):
                self.presentErrorAlert(message: error.localizedDescription + " Please try again")
                print("Can't find user in scheduleVC")
            }
        }
    }
}

// MARK: - Calendar View

extension ScheduleViewController: FSCalendarDelegate, FSCalendarDataSource {
    
    // fetch schedule by self & paring user ID
    func loadDateEvent(date: Date) {
        self.datesWithEvent = []
        for userID in userIDList {
            ScheduleManager.shared.fetchSpecificSchedule(userID: userID, date: date) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let events):
                    self.datesWithEvent += events
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        loadDateEvent(date: date)
    }
    
    // 月曆下方事件圖片設定
    func calendar(_ calendar: FSCalendar, imageFor date: Date) -> UIImage? {
        // 設定參與者決定頭像
        return nil
    }
    
}

// MARK: - Collection View

extension ScheduleViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datesWithEvent.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let eventCell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ScheduleCollectionViewCell.identifier, for: indexPath) as? ScheduleCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        eventCell.avatarImageView.image = UIImage(named: "icon_avatar_none")

        eventCell.configureCell(event: datesWithEvent[indexPath.row])

        eventCell.backgroundColor = .lightGray
        eventCell.layer.borderWidth = 1
        eventCell.layer.borderColor = UIColor.darkGray.cgColor
        eventCell.layer.cornerRadius = 10
        
        return eventCell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: screenWidth-60, height: 90)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return (screenWidth-360)/6
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: screenWidth-40, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                         withReuseIdentifier: ScheduleHeaderView.identifier,
                                                                         for: indexPath)
        
        guard let headerView = headerView as? ScheduleHeaderView else { return headerView }
        headerView.delegate = self
        headerView.configureHeader(eventCount: datesWithEvent.count)
        
        return headerView
        
    }
    
}

// MARK: - Delegate

extension ScheduleViewController: ScheduleHeaderViewDelegate {
    
    func didTapAddButton() {
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0) {
            self.menuBottomConstraint.constant = 0
            self.blackView.alpha = 0.5
        }
    }
}

extension ScheduleViewController: AddScheduleViewControllerDelegate {
    func didTappedClose() {
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0) {
            self.menuBottomConstraint.constant = -500
            self.blackView.alpha = 0
        }
        
        // refetch & reload data
        guard let currentUserUID = currentUserUID else { return }
        getData(userID: currentUserUID, date: Date())
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
        
    }
}
