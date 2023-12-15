//
//  ScheduleViewController.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/18.
//

import UIKit
import FSCalendar
import FirebaseFirestore
import Firebase

final class ScheduleViewController: BaseViewController, UIGestureRecognizerDelegate {
    
    // MARK: - Properties

    @IBOutlet weak var menuBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var blackView: UIView!
    @IBOutlet weak var containerView: UIView!
    
    fileprivate weak var calendar: FSCalendar!
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        layout.scrollDirection = .vertical
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ScheduleCollectionViewCell.self,
                                forCellWithReuseIdentifier: ScheduleCollectionViewCell.cellIdentifier)
        collectionView.register(ScheduleHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: ScheduleHeaderView.headerIdentifier)
        return collectionView
    }()
    
    private lazy var longPressGesture: UILongPressGestureRecognizer = create {
        $0.addTarget(self, action: #selector(handleLongPress(gestureReconizer:)))
        $0.minimumPressDuration = 0.5
        $0.delaysTouchesBegan = true
        $0.delegate = self
    }
        
    private var userIDList: [String] = []
    private var datesWithEvent: [Schedule] = []
    private var monthWithEvent: [Schedule] = []
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.isHidden = true
        configueCalendarUI()
        configureUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    override func configureAfterFetchUserData() {
        guard let currentUser = currentUser else {
            return
        }
        userIDList = [currentUser.userID]
        if let paringUserID = currentUser.paringUser.first {
            userIDList.append(paringUserID)
        }
        for userID in userIDList {
            loadMonthEvent(date: Date(), userID: userID)
        }
        loadDateEvent(date: calendar.selectedDate ?? Date())
    }
    
    // MARK: - Configue UI

    private func configueCalendarUI() {
        view.backgroundColor = .lightGray
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
                        height: ScreenConstant.height * 3 / 8 )
    }
    
    private func configureUI() {
        blackView.backgroundColor = .black
        blackView.alpha = 0
        menuBottomConstraint.constant = ScreenConstant.hideMenuBottomConstraint
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

    @objc
    private func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state != UIGestureRecognizer.State.ended {
            return
        }
        
        let location = gestureReconizer.location(in: self.collectionView)
        let indexPath = self.collectionView.indexPathForItem(at: location)
        
        guard let indexPath = indexPath else {
            Log.e("Cant find indexpath")
            return
        }

        self.presentActionAlert(action: "Delete", title: "Delete Event",
                                message: "Do you want to delete this event?") {
            let deleteId = self.datesWithEvent[indexPath.row].id
            self.deleteEvent(deleteId: deleteId, row: indexPath.row)
        }
    }
    
    // MARK: - Firebase handler
    
    private func loadMonthEvent(date: Date, userID: String) {
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
                Log.e(error.localizedDescription)
            }
        }
    }
            
    /// fetch specific date's event by self & paring user ID
    private func loadDateEvent(date: Date) {
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
                    Log.e(error.localizedDescription)
                }
            }
        }
    }
    
    private func deleteEvent(deleteId: String, row: Int) {
        ScheduleManager.shared.deleteSchedule(id: deleteId) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.presentAlert()
                self.datesWithEvent.remove(at: row)
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    self.fetchUserData()
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
        var datesWithEventString: [String] = []
        for date in monthWithEvent {
            let eventString = Date.dateFormatter.string(from: date.eventDate)
            datesWithEventString.append(eventString)
        }
        return datesWithEventString.contains(dateString) ? 1 : 0
     }
}

// MARK: - Collection View

extension ScheduleViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datesWithEvent.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let eventCell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ScheduleCollectionViewCell.cellIdentifier,
            for: indexPath) as? ScheduleCollectionViewCell else {
            return UICollectionViewCell()
        }
        eventCell.configureCell(event: datesWithEvent[indexPath.row])
        return eventCell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: ScreenConstant.width - 60, height: 90)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return (ScreenConstant.width - 360) / 6
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: ScreenConstant.width - 40, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                         withReuseIdentifier: ScheduleHeaderView.headerIdentifier,
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
            self.menuBottomConstraint.constant = ScreenConstant.hideMenuBottomConstraint
            self.blackView.alpha = 0
        }
        fetchUserData()
    }
}
