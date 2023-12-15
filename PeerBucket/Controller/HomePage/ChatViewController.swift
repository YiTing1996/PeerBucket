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

final class ChatViewController: MessagesViewController {
    
    // MARK: - Properties

    private lazy var backButton: UIButton = create {
        $0.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        $0.addTarget(self, action: #selector(tappedBackBtn), for: .touchUpInside)
        $0.setTitle("Back", for: .normal)
        $0.setTitleColor(UIColor.darkGreen, for: .normal)
        $0.titleLabel?.font = UIFont.semiBold(size: 15)
    }
        
    private var docReference: DocumentReference?
    
    private var paringUserUID: String? {
        currentUser?.paringUser.first
    }
    var currentUser: User?
    private var messages: [Message] = []
    
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
        guard let currentUser = currentUser else {
            return
        }
        checkChat(userID: currentUser.userID)
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
    
    // MARK: - UI

    private func configureChatRoomUI() {
        self.title = "Chat"
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.backButton)
        navigationItem.largeTitleDisplayMode = .never
        messagesCollectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        messagesCollectionView.backgroundColor = .lightGray
        messageInputBar.backgroundView.backgroundColor = .darkGreen
        messageInputBar.inputTextView.textColor = .white
    }
    
    // MARK: - User interaction handler

    @objc
    private func tappedBackBtn() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    // MARK: - Firebase handler
    
    private func downloadPhoto(imageToChange: UIImageView, userID: String) {
        // fetch background photo from firebase
        UserManager.shared.fetchUserData(userID: userID) { [weak self] result in
            guard let self = self else { return }
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
    
    private func createNewChat() {
        guard let currentUserUID = currentUser?.userID, currentUserUID.isNotEmpty else {
            return
        }
        
        let users = [currentUserUID, paringUserUID]
        let data: [String: Any] = [
            "users": users
        ]
        
        let database = Firestore.firestore().collection("Chats")
        database.addDocument(data: data) { [weak self] error in
            guard error == nil else {
                Log.e(error)
                return
            }
            self?.checkChat(userID: currentUserUID)
        }
    }
    
    private func checkChat(userID: String) {
        // Fetch all the chats which has current user in it
        let database = Firestore.firestore().collection("Chats")
            .whereField("users", arrayContains: userID)
        
        database.getDocuments { [weak self] (snapshot, error) in
            guard let self = self, let snapshot = snapshot, error == nil else {
                Log.e(error?.localizedDescription)
                return
            }
            
            let queryCount = snapshot.documents.count
            if queryCount == 0 {
                self.createNewChat()
            } else if queryCount >= 1 {
                for doc in snapshot.documents {
                    self.loadChat(doc: doc)
                }
            }
        }
    }
    
    private func loadChat(doc: QueryDocumentSnapshot) {
        guard let chat = Chat(dictionary: doc.data()), let paringUserUID = paringUserUID,
              chat.users.contains(paringUserUID) else {
            Log.e("can't load chat")
            return
        }
        
        docReference = doc.reference
        doc.reference.collection("thread")
            .order(by: "created", descending: false)
            .addSnapshotListener(includeMetadataChanges: true) { [weak self] (threadQuery, error) in
                guard let self = self, error == nil, let query = threadQuery else {
                    Log.e(error?.localizedDescription)
                    return
                }
                self.messages.removeAll()
                for message in query.documents {
                    if let msg = Message(dictionary: message.data()) {
                        self.messages.append(msg)
                    }
                }
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
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
        
        docReference?.collection("thread").addDocument(data: data) { [weak self] error in
            guard error == nil else {
                Log.e(error?.localizedDescription)
                return
            }
            self?.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
        }
    }
}

extension ChatViewController: MessagesDataSource {
    func currentSender() -> SenderType {
        ChatUser(senderId: currentUser?.userID ?? .init(), displayName: currentUser?.userName ?? .init())
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        if messages.count == 0 {
            Log.v("empty messages")
            return 0
        } else {
            return messages.count
        }
    }
}

extension ChatViewController: MessagesLayoutDelegate {
    func avatarSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return .zero
    }
}

extension ChatViewController: MessagesDisplayDelegate {
    func backgroundColor(for message: MessageType, at indexPath: IndexPath,
                         in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .darkGreen: .hightlightYellow
    }
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .lightGray: .white
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType,
                             at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        guard let currentUserUID = currentUser?.userID else {
            return
        }
        if message.sender.senderId == currentUserUID {
            downloadPhoto(imageToChange: avatarView, userID: currentUserUID)
        } else if let paringUserUID = paringUserUID {
            downloadPhoto(imageToChange: avatarView, userID: paringUserUID)
        }
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight: .bottomLeft
        return .bubbleTail(corner, .curved)
    }
}

extension ChatViewController: InputBarAccessoryViewDelegate {
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
}
