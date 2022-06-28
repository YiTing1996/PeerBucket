//
//  ChatViewController.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/20.
//

import UIKit
import InputBarAccessoryView
import Firebase
import MessageKit
import FirebaseFirestore

class ChatViewController: MessagesViewController, InputBarAccessoryViewDelegate,
                            MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    
    var user2UID: String = ""
    var currentUserName: String = ""
    
    var currentUID = "AITNzRSyUdMCjV4WrQxT"
    
    lazy var backButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        button.addTarget(self, action: #selector(tappedBackBtn), for: .touchUpInside)
        button.setTitle("Back", for: .normal)
        button.setTitleColor(UIColor.darkGreen, for: .normal)
        return button
    }()
    
    lazy var menuBarItem = UIBarButtonItem(customView: self.backButton)
    
    private var docReference: DocumentReference?
    
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
        
        messagesCollectionView.contentInset = UIEdgeInsets(top: 45, left: 0, bottom: 0, right: 0)
        messagesCollectionView.backgroundColor = .lightGray
        messageInputBar.backgroundView.backgroundColor = .darkGreen
        messageInputBar.tintColor = .white
        
        loadChat()
        
        fetchUserData(userID: currentUID)
        
    }
    
    @objc func tappedBackBtn() {
        self.navigationController?.popViewController(animated: true)
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
//    func didTapAvatar(in cell: MessageCollectionViewCell) {
//        print("Avatar tapped")
//    }
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        // handle message here
        print("Tapped message")
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else {
            print("Can't find indexPath")
            return }
        self.presentSuccessAlert(title: "Pin Message", message: "Pin a message to your favorrite") {
            print(self.messages[indexPath.item].content)
        }
    }
    
    // fetch current user's paring user and current user name
    func fetchUserData(userID: String) {
        
        UserManager.shared.fetchUserData(userID: userID) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let user):
                self.user2UID = user.paringUser[0]
                self.currentUserName = user.userName
                print("Find paring user: \(String(describing: user.paringUser[0]))")
                
            case .failure(let error):
                self.presentErrorAlert(message: error.localizedDescription + " Please try again")
                print("Can't find user in chatVC")
            }
        }
    }
    
    func downloadPhoto(imageToChange: UIImageView, userID: String) {
        
        // fetch background photo from firebase
        UserManager.shared.fetchUserData(userID: userID) { result in
            switch result {
            case .success(let user):
                
                guard let urlString = user.userAvatar as String?,
                      let url = URL(string: urlString) else {
                    return
                }
                
                let task = URLSession.shared.dataTask(with: url, completionHandler: { data, _, error in
                    guard let data = data, error == nil else {
                        return
                    }
                    
                    DispatchQueue.main.async {
                        let image = UIImage(data: data)
                        imageToChange.image = image
                    }
                })
                task.resume()
                
            case .failure(let error):
                self.presentErrorAlert(message: error.localizedDescription + " Please try again")
            }
        }
    }
    
    // MARK: - Custom messages handlers
    
    func createNewChat() {
        
        //  let users = [self.currentUser.uid, self.user2UID]
        let users = [currentUID, user2UID]
        
        let data: [String: Any] = [
            "users": users
        ]
        
        let database = Firestore.firestore().collection("Chats")
        database.addDocument(data: data) { (error) in
            if let error = error {
                print("Unable to create chat! \(error)")
                return
            } else {
                self.loadChat()
            }
        }
    }
    
    func loadChat() {
        
        // Fetch all the chats which has current user in it
        let database = Firestore.firestore().collection("Chats")
        
        //  .whereField("users", arrayContains: Auth.auth().currentUser?.uid ?? "Not Found User 1")
        // for 測試用
            .whereField("users", arrayContains: currentUID )
        
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
                                        print("Data: \(msg?.content ?? "No message found")")
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
        
        let message = Message(id: UUID().uuidString, content: text, created: Timestamp(), senderID: currentUID, senderName: currentUserName)
        
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
        
        //        return Sender(id: Auth.auth().currentUser!.uid,
        //                      displayName: Auth.auth().currentUser?.displayName ?? "Name not found")
        
        return ChatUser(senderId: currentUID, displayName: currentUserName)
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
        return isFromCurrentSender(message: message) ? .hightlightYellow: .white
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType,
                             at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        
        if message.sender.senderId == currentUID {
            downloadPhoto(imageToChange: avatarView, userID: currentUID)
        } else {
            downloadPhoto(imageToChange: avatarView, userID: user2UID)
        }
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight: .bottomLeft
        return .bubbleTail(corner, .curved)
        
    }
    
}
