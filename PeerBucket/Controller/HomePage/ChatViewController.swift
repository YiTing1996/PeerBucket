//
//  ChatViewController.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/20.
//

import UIKit
import Firebase
import FirebaseFirestore
import MessageKit
import InputBarAccessoryView
import Kingfisher
import IQKeyboardManagerSwift

class ChatViewController: MessagesViewController, InputBarAccessoryViewDelegate,
                          MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
        
    lazy var backButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        button.addTarget(self, action: #selector(tappedBackBtn), for: .touchUpInside)
        button.setTitle("Back", for: .normal)
        button.setTitleColor(UIColor.darkGreen, for: .normal)
        button.titleLabel?.font = UIFont.semiBold(size: 15)
        return button
    }()
    
    lazy var menuBarItem = UIBarButtonItem(customView: self.backButton)
    
    private var docReference: DocumentReference?
    
    var user2UID: String = ""
    var currentUser: User?
    var currentUserUID: String?
    var messages: [Message] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Chat"
        navigationItem.leftBarButtonItem = menuBarItem
        navigationItem.largeTitleDisplayMode = .never
        
        maintainPositionOnKeyboardFrameChanged = true
        scrollsToLastItemOnKeyboardBeginsEditing = true
        
        messageInputBar.delegate = self
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
//        messagesCollectionView.messageCellDelegate = self
        
        messagesCollectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        messagesCollectionView.backgroundColor = .lightGray
        messageInputBar.backgroundView.backgroundColor = .darkGreen
        messageInputBar.inputTextView.textColor = .white
        
        if isBeta {
            self.currentUserUID = "AITNzRSyUdMCjV4WrQxT"
        } else {
            self.currentUserUID = Auth.auth().currentUser?.uid ?? nil
        }
        
        guard let currentUserUID = currentUserUID else { return }
        fetchUserData(userID: currentUserUID)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // disable iq keyboard
        IQKeyboardManager.shared.enable = false
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // enable iq keyboard
        IQKeyboardManager.shared.enable = true
    }
    
    @objc func tappedBackBtn() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
//    func didTapMessage(in cell: MessageCollectionViewCell) {
//        // handle message here
//        guard let indexPath = messagesCollectionView.indexPath(for: cell) else {
//            print("Can't find indexPath")
//            return
//        }
//        self.presentActionAlert(action: "Pin", title: "Pin Message", message: "Pin a message to your favorrite") {
//            // 存？
//        }
//    }
    
    // fetch current user's paring user and current user name
    func fetchUserData(userID: String) {
        
        UserManager.shared.fetchUserData(userID: userID) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let user):
                guard user.paringUser != [] else {
                    print("Cant find paring user")
                    self.presentAlert(title: "Error", message: "Something went wrong. Please try again later.")
                    return
                }
                
                self.user2UID = user.paringUser[0]
                self.currentUser = user
                print("Find paring user: \(String(describing: user.paringUser[0]))")
                
                self.loadChat(userID: userID)
                
            case .failure(let error):
                self.presentAlert(message: error.localizedDescription + " Please try again")
                print("Can't find user in chatVC")
            }
        }
    }
    
    func downloadPhoto(imageToChange: UIImageView, userID: String) {
        
        // fetch background photo from firebase
        UserManager.shared.fetchUserData(userID: userID) { result in
            switch result {
            case .success(let user):
                
                let url = URL(string: user.userAvatar)
                imageToChange.kf.setImage(with: url)

            case .failure(let error):
                self.presentAlert(title: "Error", message: error.localizedDescription + " Please try again")
            }
        }
    }
    
    // MARK: - Custom messages handlers
    
    func createNewChat() {
        
        guard let currentUserUID = currentUserUID else {
            return
        }
        
        let users = [currentUserUID, user2UID]
        
        let data: [String: Any] = [
            "users": users
        ]
        
        let database = Firestore.firestore().collection("Chats")
        database.addDocument(data: data) { (error) in
            if let error = error {
                print("Unable to create chat! \(error)")
                return
            } else {
                self.loadChat(userID: currentUserUID)
            }
        }
    }
    
    func loadChat(userID: String) {
        
        // Fetch all the chats which has current user in it
        let database = Firestore.firestore().collection("Chats")
        
            .whereField("users", arrayContains: userID)
        
        database.getDocuments { (chatQuerySnap, error) in
            
            if let error = error {
                print("Error: \(error)")
                return
            } else {
                
                guard let queryCount = chatQuerySnap?.documents.count else {
                    return
                }
                
                if queryCount == 0 {
                    // create new chat room for user
                    self.createNewChat()
                } else if queryCount >= 1 {
                    
                    for doc in chatQuerySnap!.documents {
                        let chat = Chat(dictionary: doc.data())
                        
                        // Get the chat which has user2 id
                        guard chat?.users.contains(self.user2UID) != nil else {
                            print("Some errors happens in chatVC")
                            return
                        }
                        
                        self.docReference = doc.reference
                        doc.reference.collection("thread")
                            .order(by: "created", descending: false)
                            .addSnapshotListener(includeMetadataChanges: true, listener: { (threadQuery, error) in
                                if let error = error {
                                    print("Error: \(error)")
                                    return
                                } else {
                                    self.messages.removeAll()
                                    for message in threadQuery!.documents {
                                        
                                        let msg = Message(dictionary: message.data())
                                        self.messages.append(msg!)
                                    }
                                    self.messagesCollectionView.reloadData()
                                    self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
                                }
                            })
                    }
                    
                }
            }
        }
    }
    
    private func insertNewMessage(_ message: Message) {
        
        messages.append(message)
        messagesCollectionView.reloadData()
        
        DispatchQueue.main.async {
            self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
        }
    }
    
    private func save(_ message: Message) {
        
        let data: [String: Any] = [
            "content": message.content,
            "created": message.created,
            "id": message.id,
            "senderID": message.senderID,
            "senderName": message.senderName
        ]
        
        docReference?.collection("thread").addDocument(data: data, completion: { (error) in
            
            if let error = error {
                print("Error Sending message: \(error)")
                return
            }
            self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
            
        })
    }
    
    // MARK: - InputBarAccessoryViewDelegate
    
    func inputBar(_ inputBar: InputBarAccessoryView,
                  didPressSendButtonWith text: String) {
        
        guard let currentUser = currentUser else {
            return
        }
        
        let message = Message(id: UUID().uuidString,
                              content: text,
                              created: Timestamp(),
                              senderID: currentUser.userID,
                              senderName: currentUser.userName)
        
        // Insert new message on collection view
        insertNewMessage(message)
        // save message to firebase thread
        save(message)
        
        inputBar.inputTextView.text = ""
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToLastItem(animated: true)
    }
    
    // MARK: - MessagesDataSource
    
    func currentSender() -> SenderType {
        
        return ChatUser(senderId: currentUser!.userID, displayName: currentUser!.userName)
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        
        if messages.count == 0 {
            print("No messages to display")
            return 0
        } else {
            return messages.count
        }
    }
    
    // MARK: - MessagesLayoutDelegate
    
    func avatarSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return .zero
    }
    
    // MARK: - MessagesDisplayDelegate
    func backgroundColor(for message: MessageType, at indexPath: IndexPath,
                         in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .hightlightYellow: .lightYellow
    }
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white: .darkGray
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType,
                             at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        
        guard let currentUserUID = currentUserUID else {
            return
        }
        
        if message.sender.senderId == currentUserUID {
            downloadPhoto(imageToChange: avatarView, userID: currentUserUID)
        } else {
            downloadPhoto(imageToChange: avatarView, userID: user2UID)
        }
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight: .bottomLeft
        return .bubbleTail(corner, .curved)
        
    }
    
}
