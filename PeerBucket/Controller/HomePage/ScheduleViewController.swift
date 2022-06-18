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

class ScheduleViewController: UIViewController {
    
    @IBOutlet weak var menuBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var blackView: UIView!
    @IBOutlet weak var containerView: UIView!
    
    fileprivate weak var calendar: FSCalendar!
    
    // TBC
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-mm-dd"
        return formatter
    }()
    
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
    
    var dateString = ""
    var datesWithEvent = [String]()
    var screenWidth = UIScreen.main.bounds.width
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configueCalendarUI()
        configureUI()
        
        blackView.backgroundColor = .black
        blackView.alpha = 0
        menuBottomConstraint.constant = -500
        containerView.layer.cornerRadius = 10
        
        view.bringSubviewToFront(blackView)
        view.bringSubviewToFront(containerView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadDateEvent()
        calendar.reloadData()
    }
    
    func configueCalendarUI() {

        let calendar = FSCalendar(frame: CGRect(x: 0, y: 0, width: 320, height: 300))
        calendar.dataSource = self
        calendar.delegate = self
        view.addSubview(calendar)
        self.calendar = calendar
        
        calendar.appearance.headerTitleColor = .hightlightColor
        calendar.appearance.selectionColor = .hightlightColor
        calendar.appearance.weekdayTextColor = .textGray
        calendar.appearance.todayColor = .orange
        calendar.layer.cornerRadius = 10
        calendar.backgroundColor = .bgGray
        
        calendar.anchor(top: view.topAnchor, left: view.leftAnchor,
                        right: view.rightAnchor, paddingTop: 100,
                        paddingLeft: 20, paddingRight: 20,
                        width: view.frame.width, height: view.frame.height*3/8)
    }
    
    func configureUI() {
        view.addSubview(collectionView)

        collectionView.anchor(top: calendar.bottomAnchor, left: view.leftAnchor,
                              bottom: view.bottomAnchor, right: view.rightAnchor,
                              paddingTop: 20, paddingLeft: 20, paddingBottom: 50, paddingRight: 20)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? AddScheduleViewController {
            destination.delegate = self
        }
    }
    
}

// MARK: - Calendar View

extension ScheduleViewController: FSCalendarDelegate, FSCalendarDataSource {
    
    func loadDateEvent() {
        
    }
    
    // 點擊後的事件
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        dateString = self.dateFormatter.string(from: date)
        print("Date: \(date)")
        print("Formate date: \(dateString)")
        // 點擊後跳出tableview cell
        
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
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let eventCell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ScheduleCollectionViewCell.identifier, for: indexPath) as? ScheduleCollectionViewCell else {
            return UICollectionViewCell()
        }
//        eventCell.configureCell(eventText: dateString)
        eventCell.backgroundColor = .bgGray
        eventCell.layer.cornerRadius = 10
        eventCell.eventLabel.text = "hahahha"
        
        return eventCell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: screenWidth-40, height: 120)
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
        
        return headerView
        
    }
    
}

// MARK: - Extension

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
    }
    
    func didChangeDate() {
        
    }
    
}
