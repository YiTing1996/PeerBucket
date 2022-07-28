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
    
    // MARK: - Properties

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
    
    lazy var longPressGesture: UILongPressGestureRecognizer = create {
        $0.addTarget(self, action: #selector(handleLongPress(gestureReconizer:)))
        $0.minimumPressDuration = 0.5
        $0.delaysTouchesBegan = true
        $0.delegate = self
    }
        
    var userIDList: [String] = []

    var datesWithEventString: [String] = []
    var datesWithEvent: [Schedule] = []
    var monthWithEvent: [Schedule] = []
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configueCalendarUI()
        configureUI()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let currentUserUID = currentUserUID else { return }
        getData(userID: currentUserUID, date: Date())
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - Configue UI

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
        calendar.appearance.eventDefaultColor = .hightlightYellow
        calendar.appearance.eventSelectionColor = .hightlightYellow
        calendar.layer.cornerRadius = 10
        calendar.backgroundColor = .clear
        
        calendar.anchor(top: view.topAnchor, left: view.leftAnchor,
                        right: view.rightAnchor, paddingTop: 100,
                        paddingLeft: 20, paddingRight: 20,
                        height: screenHeight * 3 / 8 )
    }
    
    func configureUI() {
        
        blackView.backgroundColor = .black
        blackView.alpha = 0
        menuBottomConstraint.constant = hideMenuBottomConstraint
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
    
    // MARK: - User interaction handler

    @objc func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state != UIGestureRecognizer.State.ended {
            return
        }
        
        let location = gestureReconizer.location(in: self.collectionView)
        let indexPath = self.collectionView.indexPathForItem(at: location)
        
        guard let indexPath = indexPath else {
            print("Could not find index path")
            return
        }

        self.presentActionAlert(action: "Delete", title: "Delete Event",
                                message: "Do you want to delete this event?") {
            let deleteId = self.datesWithEvent[indexPath.row].id
            self.deleteEvent(deleteId: deleteId, row: indexPath.row)
        }
    }
    
    // MARK: - Firebase handler
        
    // get user data and event of the month by self & paring user ID
    func getData(userID: String, date: Date) {
        UserManager.shared.fetchUserData(userID: userID) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let user):
                self.userIDList = [userID]
                
                if user.paringUser != [] {
                    self.userIDList.append(user.paringUser[0])
                }
                
                for userID in self.userIDList {
                    self.loadMonthEvent(date: Date(), userID: userID)
                }
                
                self.loadDateEvent(date: date)
                
            case .failure(let error):
                self.presentAlert(title: "Error", message: error.localizedDescription + " Please try again")
                print("Can't find user in scheduleVC")
            }
        }
    }
    
    func loadMonthEvent(date: Date, userID: String) {
        self.monthWithEvent = []
        ScheduleManager.shared.fetchMonthSchedule(userID: userID, date: date) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let events):
                self.monthWithEvent += events
                DispatchQueue.main.async {
                    self.calendar.reloadData()
                }
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
            
    // fetch specific date's event by self & paring user ID
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
    
    func deleteEvent(deleteId: String, row: Int) {

        ScheduleManager.shared.deleteSchedule(id: deleteId) { result in
            switch result {
            case .success:
                self.presentAlert()
                self.datesWithEvent.remove(at: row)
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    self.getData(userID: currentUserUID ?? "",
                                 date: self.calendar.selectedDate ?? Date())
                }
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [deleteId])

            case .failure(let error):
                self.presentAlert(title: "Error", message: error.localizedDescription + " Please try again")
            }
        }
    }
}

// MARK: - Calendar View

extension ScheduleViewController: FSCalendarDelegate, FSCalendarDataSource {
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        loadDateEvent(date: date)
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {

        let dateString = Date.dateFormatter.string(from: date)

        datesWithEventString = []

        for date in monthWithEvent {
            let eventString = Date.dateFormatter.string(from: date.eventDate)
            datesWithEventString.append(eventString)
        }

        if datesWithEventString.contains(dateString) {
             return 1
         }

         return 0
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
            self.menuBottomConstraint.constant = hideMenuBottomConstraint
            self.blackView.alpha = 0
        }
        
        // refetch & reload data
        guard let currentUserUID = currentUserUID else { return }
        getData(userID: currentUserUID, date: calendar.selectedDate ?? Date())
        
    }
}
