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
    
    // MARK: - Properties

    lazy var backButton: UIButton = create {
        $0.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        $0.addTarget(self, action: #selector(tappedBackBtn), for: .touchUpInside)
        $0.setTitle("Back", for: .normal)
        $0.setTitleColor(UIColor.darkGreen, for: .normal)
        $0.titleLabel?.font = UIFont.semiBold(size: 15)
    }
    
    lazy var menuBarItem = UIBarButtonItem(customView: self.backButton)
    
    private var docReference: DocumentReference?
    
    var user2UID: String = ""
    var currentUser: User?
    var messages: [Message] = []
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureChatRoomUI()
        maintainPositionOnKeyboardFrameChanged = true
        scrollsToLastItemOnKeyboardBeginsEditing = true
        
        messageInputBar.delegate = self
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self

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
    
    // MARK: - Configure UI

    func configureChatRoomUI() {
        self.title = "Chat"
        navigationItem.leftBarButtonItem = menuBarItem
        navigationItem.largeTitleDisplayMode = .never
        messagesCollectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        messagesCollectionView.backgroundColor = .lightGray
        messageInputBar.backgroundView.backgroundColor = .darkGreen
        messageInputBar.inputTextView.textColor = .white
    }
    
    // MARK: - User interaction handler

    @objc func tappedBackBtn() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    // MARK: - Firebase handler
    
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
                
                self.checkChat(userID: userID)
                
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
                self.checkChat(userID: currentUserUID)
            }
        }
        
    }
    
    func checkChat(userID: String) {
        
        // Fetch all the chats which has current user in it
        let database = Firestore.firestore().collection("Chats")
        
            .whereField("users", arrayContains: userID)
        
        database.getDocuments { (chatQuerySnap, error) in
            
            guard let queryCount = chatQuerySnap?.documents.count,
                  error == nil else {
                print("Error load chat")
                return
            }
            
            if queryCount == 0 {
                // create new chat room for user
                self.createNewChat()
            } else if queryCount >= 1 {
                
                for doc in chatQuerySnap!.documents {
                    self.loadChat(doc: doc)
                    
                }
            }
        }
    }
    
    func loadChat(doc: QueryDocumentSnapshot) {
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
        return isFromCurrentSender(message: message) ? .darkGreen: .hightlightYellow
    }
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .lightGray: .white
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
