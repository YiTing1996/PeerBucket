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

class ChatViewController: MessagesViewController,
                          InputBarAccessoryViewDelegate, MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    
    //    var currentUser: User = Auth.auth().currentUser!
    
    var currentUserName: String = "DoreenName"
    var currentUserImgUrl: String?
    var currentUserUID: String = "DoreenID"
    
    var user2Name: String = "HamburgerName"
    var user2ImgUrl: String?
    var user2UID: String = "HamburgerID"
    
    //    var currentUserName: String = "HamburgerName"
    //    var currentUserImgUrl: String?
    //    var currentUserUID: String = "HamburgerID"
    //
    //    var user2Name: String = "DoreenName"
    //    var user2ImgUrl: String?
    //    var user2UID: String = "DoreenID"
    
    lazy var backButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        button.addTarget(self, action: #selector(tappedBackBtn), for: .touchUpInside)
        button.setTitle("Back", for: .normal)
        button.setTitleColor(UIColor.textGray, for: .normal)
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
        
        messageInputBar.sendButton.setTitleColor(.systemTeal, for: .normal)
        messageInputBar.delegate = self
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        loadChat()
    }
    
    @objc func tappedBackBtn() {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Custom messages handlers
    
    func createNewChat() {
        
        //  let users = [self.currentUser.uid, self.user2UID]
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
                self.loadChat()
            }
        }
    }
    
    func loadChat() {
        
        // Fetch all the chats which has current user in it
        let database = Firestore.firestore().collection("Chats")
        
        //  .whereField("users", arrayContains: Auth.auth().currentUser?.uid ?? "Not Found User 1")
        // for 測試用
            .whereField("users", arrayContains: currentUserUID )
        
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
                        // for 測試用
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
        
        // for 測試用
        let message = Message(id: UUID().uuidString, content: text, created: Timestamp(), senderID: currentUserUID, senderName: currentUserName)
        
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
        
        // for 測試用
        return ChatUser(senderId: currentUserUID, displayName: currentUserName)
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
        return isFromCurrentSender(message: message) ? .hightlightBg: .bgGray
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType,
                             at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        
        // for 測試用
        if message.sender.senderId == currentUserUID {
            avatarView.image = UIImage(named: "mock_avatar")
        } else {
            avatarView.image = UIImage(named: "mock_avatar1")
        }
        
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight: .bottomLeft
        return .bubbleTail(corner, .curved)
        
    }
    
}
