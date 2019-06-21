//
//  ChatLogController.swift
//  ChatAppClients
//
//  Created by Dushko Cizaloski on 2/2/19.
//  Copyright © 2019 Big Nerd Ranch. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import Swift
//import AlamofireObjectMapper
class ChatLogController: UICollectionViewController, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate, UITextFieldDelegate
{
 private let cellId = "cellId"
 var senderMessages = [String]()
 var isLoadingBool: Bool = false
 var userDefaultsUser = UserDefaults.standard
 var topRefreshController = UIRefreshControl()
 var bottomRefreshContol = UIRefreshControl()
 var sendMSG: ChatClients?
 var message = [Message]()
 var currentDate = ""
 var keyboardHeight: CGFloat = 0.0
 var xPositionOfcell : CGFloat = 0.0
 var clientSendMSG: [ChatClients] = [ChatClients]()
 var userInfo: ViewRecentClientsController?
 var friend: Friend!
 var notifyAccepted: Int? = 0
 var bottomConstraint: NSLayoutConstraint?
 var readedMessageIMG: ChatLogMessageCell?
 var r: Int?
 var p: Int?
 var lastIndexPath: IndexPath?
  {
    didSet {
    navigationItem.title = friend.name!
    }
  
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    if UIDevice.current.orientation.isLandscape
    {
    messageInputContainerView.addConstraintsWithFormat(format: "H:|-30-[v0][v1(60)]-30-|", views: inputTextField, sendButton)
      collectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 30)
      self.changeHeightInPortaritOrLandscape()
      collectionView?.reloadData()
    }
    messageInputContainerView.addConstraintsWithFormat(format: "H:|-8-[v0][v1(60)]|", views: inputTextField, sendButton)
    collectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 30)
  }
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
   
   r = 0
   p = 0
   navigationItem.title = friend.name!
   for fetchedMessages in (0..<fetchedResultsController.sections![0].numberOfObjects).reversed()
   {
    var fetchedMessage = fetchedResultsController.sections![0].objects?[fetchedMessages] as! Message
    print("pmsnotify2 before", fetchedMessage.pmsnotify!)
    print("status2 before", fetchedMessage.status!)
    if r == 1
    {
     //friend.lastMessage?.status = "0"
     fetchedMessage.status = "0"
    }
    if p == 1
    {
     //         friend.lastMessage?.pmsnotify = "0"
     fetchedMessage.pmsnotify = "0"
    }
    if fetchedMessage.status == "1" && fetchedMessage.isSender == "1"
    {
     r = 1
    }
    if fetchedMessage.pmsnotify == "1" && fetchedMessage.isSender == "1"
    {
     p = 1
     
    }
    print("pmsnotify2 after", fetchedMessage.pmsnotify!)
    print("status2 after", fetchedMessage.status!)
    readedMessageIMG?.setupViews()
   }
   
//   if friend.lastMessage?.status == "1"
//   {
//   readedMessageIMG?.readedMessageIMG.image = UIImage(named: "bugs-bunny")
//   }
   DispatchQueue.main.async {
    do
    {
     try  self.fetchedResultsController.performFetch()
     self.collectionView?.reloadData()
    } catch let err {
     print(err)
    }
   }
    let contentHeight: CGFloat = self.collectionView!.contentSize.height
    let heightAfterInserts: CGFloat = self.collectionView!.frame.size.height - (self.collectionView!.contentInset.top + self.collectionView!.contentInset.bottom)
    print("contentHeight",contentHeight,"heightAfterInsert",heightAfterInserts)
    if UIDevice.current.orientation.isPortrait
    {
      self.changeCollectionViewHeight()
      collectionView?.reloadData()
    }
    messageInputContainerView.addConstraintsWithFormat(format: "H:|-30-[v0][v1(60)]-30-|", views: inputTextField, sendButton)
    self.changeCollectionViewHeight()
   
    self.collectionView?.reloadData()
  }
  var messageInputContainerView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor.red
    return view
  }()
  let inputTextField: UITextField = {
    let textField = UITextField()
    textField.placeholder = " Enter message..."
    textField.addPadding(.left(10))
   
    return textField
  }()
  let sendButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("Send", for: .normal)
    let titleColor = UIColor(red: 0, green: 137/255, blue: 249/255, alpha: 1)
    button.setTitleColor(titleColor, for: .normal)
    button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
    button.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
    return button
  }()
 //Here is type lebel when user start writhing she will show and when press send button she will dissapier and set a text
 let typingText : UILabel = {
  let typeText = UILabel()
  typeText.text = "Typing..."
  return typeText
 }()
 @objc func handleSend()
  {
    let delegate = UIApplication.shared.delegate as! AppDelegate
    let context = delegate.managedObjectContext
   
   do {
    //MARK: - Set another URL from where we get a message and send to another user(Client) here user_id == friend_id
   try! self.fetchedResultsController.performFetch()
    let URL_API_SEND_USER_MSG = URL(string: "https://bilbord.mk/api.php?key=3g5fg3f5gf2h32k2j&function=send_msg")
   print("Email",userDefaultsUser.string(forKey: "userMail")!,"Password",userDefaultsUser.string(forKey: "userPass")!)
   let parameters: Parameters = ["email" : userDefaultsUser.string(forKey: "userMail")!, "password" : userDefaultsUser.string(forKey: "userPass")!,"user_id" : friend.id!, "message": inputTextField.text!]
   
    AF.request(URL_API_SEND_USER_MSG!, method: .post, parameters: parameters as [String: AnyObject]).responseString { (response) in
     guard let data = response.data else { return }
     do {
      let decoder = JSONDecoder()
      let apiInfoUserRequest = try decoder.decode(ChatClients.self, from: data) as! NSDictionary
      
      print("message",apiInfoUserRequest["message"]!)
     } catch let error  {
      print(error)
     }
    }
   } catch let err {
    print(err)
   }
   let date = Date()
   let formatter = DateFormatter()
   formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
   let todayDate = formatter.string(from: date)
   self.friend.profileImageName = "jerry-mouse"
   //friend.lastMessage!.isSender!
//   ViewRecentClientsController.createMessgeWithText(text: inputTextField.text!, friend: friend!, minutesAgo: todayDate, context: context, isSender: friend.lastMessage!.isSender!, status: (friend.lastMessage?.status)!, id: friend.id!, pmsnotify: (friend.lastMessage?.pmsnotify!)!)
   ViewRecentClientsController.createMessgeWithText(text: inputTextField.text!, friend: friend, minutesAgo: todayDate, context: context, isSender: "1", status: "0", id: friend.id!, pmsnotify: "0")
   //readedMessageIMG?.profileImageView.isHidden = true
    do {
      try context.save()
     
      inputTextField.text = nil
     
     
    } catch let err {
      print(err)
    }
  }

  lazy var fetchedResultsController: NSFetchedResultsController = { () -> NSFetchedResultsController<NSFetchRequestResult> in
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Message")
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
   fetchRequest.predicate = NSPredicate(format: "friend.id = %@", self.friend.id!)  //predicate  //
    let delegate = UIApplication.shared.delegate as! AppDelegate
    let context = delegate.managedObjectContext
    let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
    frc.delegate = self
  return frc
  }()
  var blockOperation = [BlockOperation]()
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    if type == .insert
    {
      blockOperation.append(BlockOperation(block: {
        self.collectionView?.insertItems(at: [newIndexPath!])
      }))
    }
  }
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    collectionView?.performBatchUpdates({
      for operation in self.blockOperation
      {
        operation.start()
      }
    }, completion: { (completed) in
      self.changeCollectionViewHeight()
      self.collectionView?.reloadData()
    })
  }
  override func  viewDidLoad() {
    super.viewDidLoad()
   //Do any additional setup after loading the view typically from a nib.
   self.collectionView.register(UINib(nibName: "CustomFooterView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: cellId)
   self.collectionView.register(UINib(nibName: "ChatLogMessageCell", bundle: nil), forCellWithReuseIdentifier: cellId)
   //MARK: - This part when user pull from down to down on collection view to make scroll the collectionView form TOP and refresh the informations from SERVER
   self.topRefreshController = UIRefreshControl()
   self.topRefreshController.attributedTitle = NSAttributedString.init(string: "Pull down to reload new message")
   self.topRefreshController.addTarget(self, action: #selector(refreshTop), for: .valueChanged)
   self.collectionView?.addSubview(topRefreshController)
   inputTextField.delegate = self
   inputTextField.addTarget(self, action: #selector(LabelChanged(_:)), for:.editingChanged)
    if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
      if #available(iOS 11.0, *) {
        flowLayout.sectionInsetReference = .fromSafeArea
      }
    }
    self.tabBarController?.tabBar.isHidden = true
    do {
      try fetchedResultsController.performFetch()
     collectionView?.reloadData()
    } catch let err {
      print(err)
    }
    collectionView?.backgroundColor = UIColor.white
    collectionView?.register(ChatLogMessageCell.self, forCellWithReuseIdentifier: cellId)
    view.addSubview(messageInputContainerView)
    view.addConstraintsWithFormat(format: "H:|[v0]|", views: messageInputContainerView)
    view.addConstraintsWithFormat(format: "V:[v0(48)]", views: messageInputContainerView)
    bottomConstraint = NSLayoutConstraint(item: messageInputContainerView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
    view.addConstraint(bottomConstraint!)
   
    setupInputComponents()
   readedMessageIMG?.setupViews()
   //MARK: - Make changes with from Swift 4 before we used UINotification.Name.UIResponder.keyboardWillShowNotification and UINotification.Name.UIResponder.keyboardWillHideNotification but now into Swift 5 we use UIKeyboard.keyboardWillShowNotification and UIKeyboard.keyboardWillHideNotification but i am still not sure did this realy work let's check
   NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
   NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
   getApiReadedState { (EmptyResponse) in
    print(EmptyResponse)
   }
   
 }

 func getApiReadedState(completion: @escaping (EmptyResponse) -> Void)
 {
  let delegate = UIApplication.shared.delegate as! AppDelegate
  let context = delegate.managedObjectContext
  let API_URL_SEEN_USER_MSG = URL(string: "https://bilbord.mk/api.php?key=3g5fg3f5gf2h32k2j&function=seen_pm&friend="+(self.friend.id)!)
  let parameters: Parameters = ["email":userDefaultsUser.string(forKey: "userMail")!, "password":userDefaultsUser.string(forKey: "userPass")!]
  do {
  try fetchedResultsController.performFetch()
  AF.request(API_URL_SEEN_USER_MSG!, method: .post, parameters: parameters as [String: AnyObject]).responseJSON { (response) in
   switch response.result {
   case .success:
    let responseAcceptedMSG = response.value as! NSDictionary
     let responseMSG = String(describing:responseAcceptedMSG["success"]!)
     print("MSG MSG",responseMSG)
    print("last message status",self.friend.lastMessage?.status!)
   case .failure(let error):
    print(error)
   }
   }
  } catch let err {
   print(err)
  }
  do {
   try context.save()
   collectionView.reloadData()
  } catch let err {
   print(err)
  }
 }
 
 @objc func refreshTop(_ : Any)
 {
  let delayInSecound : Double = 1.0
  let popTime : DispatchTime = DispatchTime(uptimeNanoseconds: UInt64(delayInSecound) * NSEC_PER_SEC)
  DispatchQueue.main.asyncAfter(deadline: popTime) {
   var count = self.fetchedResultsController.sections?[0].numberOfObjects
  count = self.fetchedResultsController.sections![0].numberOfObjects - 1
   self.collectionView?.reloadData()
   self.topRefreshController.endRefreshing()
  }
 }

 @objc func LabelChanged(_ sender: Any) {
  self.typingText.text = "Typing ..."
 }
 
  @objc func handleKeyboardNotification(notification: NSNotification)
  {
    if let userInfo: NSDictionary = notification.userInfo! as NSDictionary {
     let keyboardFrame: NSValue = userInfo.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue
     let keyboardRectangle = keyboardFrame.cgRectValue
     print(keyboardRectangle)
      //MARK - put down keyboard in 16:53 for 30
     let isKeyboardShowing = notification.name == UIResponder.keyboardWillShowNotification
     print("here is keyboard Height", keyboardRectangle.height)
     keyboardHeight = keyboardRectangle.height
     collectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
     self.bottomConstraint?.constant = isKeyboardShowing ? -keyboardRectangle.height : 0
     UIView.animate(withDuration: 0, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
        self.view.layoutIfNeeded()
      }, completion: { (completed) in
        if isKeyboardShowing {
          self.changeCollectionViewHeight()
           self.collectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: self.keyboardHeight, right: 0)
          if UIDevice.current.orientation.isPortrait
          {
            if UIDevice.current.orientation == UIDeviceOrientation.landscapeRight
            {
              let safeAreaSpaceSendButton = self.view.safeAreaLayoutGuide.layoutFrame.width - self.view.safeAreaLayoutGuide.layoutFrame.height + self.inputTextField.frame.height - self.sendButton.frame.width - self.sendButton.frame.height / 2
              self.inputTextField.frame = CGRect(x: safeAreaSpaceSendButton, y: 0, width: self.view.safeAreaLayoutGuide.layoutFrame.width - 50, height: self.inputTextField.frame.height)
            }
            else if UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft {
              self.sendButton.frame = CGRect(x: 0, y: 0, width: self.view.safeAreaLayoutGuide.layoutFrame.width, height: self.sendButton.frame.height)
            }
          }
          else {
            //MARK: - For every type of device when rotated to set diferent LandscapeLeft and LandscapeRight
            if #available (iOS 11.0, *) {
              if UIDevice().userInterfaceIdiom == .phone {
                switch UIScreen.main.nativeBounds.height{
                case 1136:
                  print("iPhone 5 or 5S or 5C")
                  if UIDevice.current.orientation == UIDeviceOrientation.landscapeRight
                  {
                    let safeAreaSpaceSendButton = self.view.safeAreaLayoutGuide.layoutFrame.width - self.view.safeAreaLayoutGuide.layoutFrame.height + self.inputTextField.frame.height - self.sendButton.frame.width - self.sendButton.frame.height / 2
                    self.sendButton.frame = CGRect(x: safeAreaSpaceSendButton, y: 0, width: self.view.safeAreaLayoutGuide.layoutFrame.width, height: self.sendButton.frame.height)
                  }
                  else if UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft
                  {
                    self.inputTextField.frame = CGRect(x: 0, y: 0, width: self.view.safeAreaLayoutGuide.layoutFrame.width - 50, height: self.inputTextField.frame.height)
                   //Here set padding
                  }
                case 1334:
                  print("iPhone 6/6S/7/8")
                  if UIDevice.current.orientation == UIDeviceOrientation.landscapeRight
                  {
                    let safeAreaSpaceSendButton = self.view.safeAreaLayoutGuide.layoutFrame.width - self.view.safeAreaLayoutGuide.layoutFrame.height + self.inputTextField.frame.height - self.sendButton.frame.width - self.sendButton.frame.height / 2
                    print("safeArea",safeAreaSpaceSendButton)
                    self.sendButton.frame = CGRect(x: safeAreaSpaceSendButton, y: 0, width: self.view.safeAreaLayoutGuide.layoutFrame.width, height: self.sendButton.frame.height)
                  }
                  else if UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft
                  {
                    self.inputTextField.frame = CGRect(x: 0, y: 0, width: self.view.safeAreaLayoutGuide.layoutFrame.width - 50, height: self.inputTextField.frame.height)
                  }
                case 1920, 2208:
                  print("iPhone 6+/6S+/7+/8+")
                  if UIDevice.current.orientation == UIDeviceOrientation.landscapeRight
                  {
                    let safeAreaSpaceSendButton = self.view.safeAreaLayoutGuide.layoutFrame.width - self.view.safeAreaLayoutGuide.layoutFrame.height + self.inputTextField.frame.height - self.sendButton.frame.width - self.sendButton.frame.height / 2
                    print("safeArea",safeAreaSpaceSendButton)
                    self.sendButton.frame = CGRect(x: safeAreaSpaceSendButton, y: 0, width: self.view.safeAreaLayoutGuide.layoutFrame.width, height: self.sendButton.frame.height)
                  }
                  else if UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft
                  {
                    self.inputTextField.frame = CGRect(x: 0, y: 0, width: self.view.safeAreaLayoutGuide.layoutFrame.width - 50, height: self.inputTextField.frame.height)
                  }
                case 2436:
                  print("iPhone X, XS")
                  if UIDevice.current.orientation == UIDeviceOrientation.landscapeRight
                  {
                    let safeAreaSpaceSendButton = self.view.safeAreaLayoutGuide.layoutFrame.height + self.sendButton.frame.height
                    print("safeArea",safeAreaSpaceSendButton, "width:", self.sendButton.frame.width, "height:",self.sendButton.frame.height)
                    self.sendButton.frame = CGRect(x: safeAreaSpaceSendButton, y: 0, width: self.view.safeAreaLayoutGuide.layoutFrame.width, height: self.sendButton.frame.height)
                  }
                  else if UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft
                  {
                    let safeAreaSpace =  self.view.safeAreaLayoutGuide.layoutFrame.width -  self.inputTextField.frame.width + self.sendButton.frame.width
                    print("safeArea",safeAreaSpace)
                    self.inputTextField.frame = CGRect(x: safeAreaSpace, y: 0, width: self.view.safeAreaLayoutGuide.layoutFrame.width - 50, height: self.inputTextField.frame.height)
                   self.inputTextField.addPadding(.left(10))
                  }
                case 2688:
                  print("iPhone XS Max")
                  if UIDevice.current.orientation == UIDeviceOrientation.landscapeRight
                  {
                    let safeAreaSpaceSendButton = self.view.safeAreaLayoutGuide.layoutFrame.height + self.sendButton.frame.height
                    print("safeArea",safeAreaSpaceSendButton)
                    self.sendButton.frame = CGRect(x: safeAreaSpaceSendButton, y: 0, width: self.view.safeAreaLayoutGuide.layoutFrame.width, height: self.sendButton.frame.height)
                  }
                  else if UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft
                  {
                    let safeAreaSpace =  self.view.safeAreaLayoutGuide.layoutFrame.width -  self.inputTextField.frame.width + self.sendButton.frame.width
                    print("safeArea",safeAreaSpace)
                    self.inputTextField.frame = CGRect(x: safeAreaSpace, y: 0, width: self.view.safeAreaLayoutGuide.layoutFrame.width - 50, height: self.inputTextField.frame.height)
                  }
                case 1792:
                  print("iPhone XR")
                  if UIDevice.current.orientation == UIDeviceOrientation.landscapeRight
                  {
                    let safeAreaSpaceSendButton = self.view.safeAreaLayoutGuide.layoutFrame.height + self.sendButton.frame.height
                    print("safeArea",safeAreaSpaceSendButton)
                    self.sendButton.frame = CGRect(x: safeAreaSpaceSendButton, y: 0, width: self.view.safeAreaLayoutGuide.layoutFrame.width, height: self.sendButton.frame.height)
                  }
                  else if UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft
                  {
                    let safeAreaSpace =  self.view.safeAreaLayoutGuide.layoutFrame.width -  self.inputTextField.frame.width + self.sendButton.frame.width
                    print("safeArea",safeAreaSpace)
                    self.inputTextField.frame = CGRect(x: safeAreaSpace, y: 0, width: self.view.safeAreaLayoutGuide.layoutFrame.width - 50, height: self.inputTextField.frame.height)
                  }
                default:
                  print("Unknown")
                  if UIDevice.current.orientation == UIDeviceOrientation.landscapeRight
                  {
                    let safeAreaSpaceSendButton = self.view.safeAreaLayoutGuide.layoutFrame.height + self.sendButton.frame.height
                    print("safeArea",safeAreaSpaceSendButton)
                    self.sendButton.frame = CGRect(x: safeAreaSpaceSendButton, y: 0, width: self.view.safeAreaLayoutGuide.layoutFrame.width, height: self.sendButton.frame.height)
                  }
                  else if UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft
                  {
                    let safeAreaSpace =  self.view.safeAreaLayoutGuide.layoutFrame.width -  self.inputTextField.frame.width + self.sendButton.frame.width
                    print("safeArea",safeAreaSpace)
                    self.inputTextField.frame = CGRect(x: safeAreaSpace, y: 0, width: self.view.safeAreaLayoutGuide.layoutFrame.width - 50, height: self.inputTextField.frame.height)
                  }
                }
              }
            }
          }
          self.collectionView?.reloadData()
        }
        self.collectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 30)
      })
      if UIDevice.current.orientation.isPortrait {
      self.inputTextField.frame = CGRect(x: 0, y: 0, width: self.view.safeAreaLayoutGuide.layoutFrame.width - 50, height: self.inputTextField.frame.height)
      }
      self.collectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: self.keyboardHeight, right: 0)
      self.collectionView?.reloadData()
    }
  }
  //MARK: - Added when user change on Portrait or Landscape Device
  func changeHeightInPortaritOrLandscape()
  {
    let contentHeight: CGFloat = self.collectionView!.contentSize.height
    let heightAfterInserts: CGFloat = self.collectionView!.frame.size.height - (self.collectionView!.contentInset.top + self.collectionView!.contentInset.bottom)
    if contentHeight > heightAfterInserts {
      self.collectionView?.setContentOffset(CGPoint(x: 0, y: (self.collectionView?.contentSize.height)! + (self.collectionView?.frame.height)!), animated: false)
    }
  }
  
  func changeCollectionViewHeight()
  {
    let contentHeight: CGFloat = self.collectionView!.contentSize.height
    let heightAfterInserts: CGFloat = self.collectionView!.frame.size.height - (self.collectionView!.contentInset.top + self.collectionView!.contentInset.bottom)
    if contentHeight > heightAfterInserts {
      self.collectionView?.setContentOffset(CGPoint(x: 0, y: (self.collectionView?.contentSize.height)! - (self.collectionView?.frame.size.height)! + keyboardHeight), animated: false)
      print(keyboardHeight)
    }
  }
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    inputTextField.backgroundColor = UIColor.clear
    inputTextField.endEditing(true)
  }
  private func setupInputComponents()
  {
    let topBorderView = UIView()
    topBorderView.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
    messageInputContainerView.addSubview(inputTextField)
    messageInputContainerView.addSubview(sendButton)
    messageInputContainerView.addSubview(topBorderView)
   // if #available (iOS 11.0, *) {
    messageInputContainerView.addConstraintsWithFormat(format: "H:|-8-[v0][v1(60)]|", views: inputTextField, sendButton)
    messageInputContainerView.addConstraintsWithFormat(format: "H:|[v0]|", views: topBorderView)
    
    messageInputContainerView.addConstraintsWithFormat(format: "V:|[v0]|", views: inputTextField)
    messageInputContainerView.addConstraintsWithFormat(format: "V:|[v0]|", views: sendButton)
    messageInputContainerView.addConstraintsWithFormat(format: "V:|[v0(0.5)]", views: topBorderView)
 
  }
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if let count = fetchedResultsController.sections?[section].numberOfObjects
    {
      return count
    }
    return 0
//   guard let sections = fetchedResultsController.sections else { return 0 }
//   return sections[section].numberOfObjects
  }
//  override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//   let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatLogMessageCell
//   cell.readedMessageIMG.isHidden = false
//  }
 
  //MARK:- Rotate screen lanscape or portrait
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    
    if UIDevice.current.orientation.isPortrait
    {
      self.inputTextField.frame = CGRect(x: 0, y: 0, width: self.view.safeAreaLayoutGuide.layoutFrame.width, height: self.inputTextField.frame.height)
       self.sendButton.frame = CGRect(x: 0, y: 0, width: self.view.safeAreaLayoutGuide.layoutFrame.width, height: self.sendButton.frame.height)
    }
    else if UIDevice.current.orientation.isLandscape {
      
      if UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft {
        self.sendButton.frame = CGRect(x: 0, y: 0, width: self.view.safeAreaLayoutGuide.layoutFrame.width, height: self.sendButton.frame.height)
      }
      else if UIDevice.current.orientation == UIDeviceOrientation.landscapeRight {
        self.inputTextField.frame = CGRect(x: 0, y: 0, width: self.view.safeAreaLayoutGuide.layoutFrame.width, height: self.inputTextField.frame.height)
      }
      self.inputTextField.frame = CGRect(x: 0, y: 0, width: self.view.safeAreaLayoutGuide.layoutFrame.width, height: self.inputTextField.frame.height)
    }
    self.changeHeightInPortaritOrLandscape()
    collectionView?.reloadData()
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatLogMessageCell
    let message = fetchedResultsController.object(at: indexPath) as! Message
   print("print the msg", message.text!,"date",message.date)
    cell.messageTextView.text = message.text
    if let messageText = message.text, let profileImageName = message.friend?.profileImageName {
      cell.profileImageView.image = UIImage(named: profileImageName)
      let size = CGSize(width: 250, height: 1000)
      let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
     let estimatedFrame = NSString(string: messageText).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)], context: nil)
     print("print just message", message.isSender!, message.text!)
      if message.isSender == nil || message.isSender == "0" {
       print("message status", message.status!)
       print("message isSender",message.isSender)
       //Here was set + 8 i just remove this for change some parameters into desing stily and move - 10 from textBubbleView.frame x - 10     48 + 10
      cell.messageTextView.frame = CGRect(x: 24, y: 0, width: estimatedFrame.width + 16, height: estimatedFrame.height + 30)
       //MARK : - 48 - 10
      cell.textBubbleView.frame = CGRect(x: 7, y: -4, width: estimatedFrame.width + 16 + 8 + 16 + 20, height: estimatedFrame.height + 20 + 6)
//       cell.textBubbleView.addConstraintsWithFormat(format: "H:|-107-[v0(12)]-20-|", views: cell.readedMessageImage)
//       cell.textBubbleView.addConstraintsWithFormat(format: "V:|-35-[v0(12)]-10-|", views: cell.readedMessageImage)
        cell.profileImageView.isHidden = false
        cell.bubbleImageView.image = ChatLogMessageCell.grayBubbleImage_received
        cell.textBubbleView.tintColor = UIColor(white: 0.95, alpha: 1)
        cell.messageTextView.textColor = UIColor.black
       cell.readedMessageImage.isHidden = true
       
       //append new label when user start writing some text int teextfield jsut checked did this workr
        cell.typeTextLabel.text = self.typingText.text
      } else
      {
       if message.status == "1" && message.isSender == "1"
       {
        // if indexPath.row == fetchedResultsController.sections![indexPath.section].numberOfObjects - 1
        //{
        cell.readedMessageImage.image = UIImage(named: "bugs-bunny")
        cell.readedMessageImage.isHidden = false
//        cell.textBubbleView.addConstraintsWithFormat(format: "H:|-107-[v0(12)]-20-|", views: cell.readedMessageImage)
//        cell.textBubbleView.addConstraintsWithFormat(format: "V:|-35-[v0(12)]-10-|", views: cell.readedMessageImage)
        
        //}
       } else if message.pmsnotify == "1"
      
       
       {
        //if indexPath.row == fetchedResultsController.sections![indexPath.section].numberOfObjects - 1
        // {
        cell.recivedMessageIMG.image = UIImage(named: "checked")
        cell.recivedMessageIMG.isHidden = false
        
        // }
       } else {
        cell.readedMessageImage.isHidden = true
        cell.recivedMessageIMG.isHidden = true
        cell.textBubbleView.frame = CGRect(x: 7, y: -4, width: estimatedFrame.width + 16 + 8 + 16 + 20, height: estimatedFrame.height + 20 + 6)
       }
        
       
        if #available(iOS 11.0, *) {
         //MARK: - view.safeAreaLayoutGuide.layoutFrame.width - estimatedFrame.width - 16 - 16 - 8 + 10
         cell.messageTextView.frame = CGRect(x: view.safeAreaLayoutGuide.layoutFrame.width - estimatedFrame.width - 16 - 16 - 8 - 50, y: 0, width: estimatedFrame.width + 16, height: estimatedFrame.height + 20)
         //MARK: - view.safeAreaLayoutGuide.layoutFrame.width - estimatedFrame.width - 16 - 8 - 16 - 10
         cell.textBubbleView.frame = CGRect(x: view.safeAreaLayoutGuide.layoutFrame.width - estimatedFrame.width - 16 - 8 - 16 - 53, y: -4, width: estimatedFrame.width + 16 + 8 + 10 + 56, height: estimatedFrame.height + 20 + 6) //move receiver
//         cell.textBubbleView.addConstraintsWithFormat(format: "H:|-107-[v0(12)]-20-|", views: cell.readedMessageImage)
//         cell.textBubbleView.addConstraintsWithFormat(format: "V:|-35-[v0(12)]-10-|", views: cell.readedMessageImage)
         if UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft
         {
          //MARK: - view.safeAreaLayoutGuide.layoutFrame.width - estimatedFrame.width - 16 - 16 - 8 + 10
          cell.messageTextView.frame = CGRect(x: view.safeAreaLayoutGuide.layoutFrame.width - estimatedFrame.width - 16 - 16 - 8 - 50, y: 0, width: estimatedFrame.width + 16, height: estimatedFrame.height + 20)
          //MARK: - view.safeAreaLayoutGuide.layoutFrame.width - estimatedFrame.width - 16 - 8 - 16 - 10
          cell.textBubbleView.frame = CGRect(x: view.safeAreaLayoutGuide.layoutFrame.width - estimatedFrame.width - 16 - 8 - 16 - 66, y: -4, width: estimatedFrame.width + 16 + 8 + 10 + 56, height: estimatedFrame.height + 20 + 6) //move receiver
//          cell.textBubbleView.addConstraintsWithFormat(format: "H:|-107-[v0(12)]-20-|", views: cell.readedMessageImage)
//          cell.textBubbleView.addConstraintsWithFormat(format: "V:|-35-[v0(12)]-10-|", views: cell.readedMessageImage)
         }
         if UIDevice.current.orientation == UIDeviceOrientation.landscapeRight
         {
          //MARK: - view.safeAreaLayoutGuide.layoutFrame.width - estimatedFrame.width - 16 - 16 - 8 + 10
          cell.messageTextView.frame = CGRect(x: view.safeAreaLayoutGuide.layoutFrame.width - estimatedFrame.width - 16 - 16 - 8 - 50, y: 0, width: estimatedFrame.width + 16, height: estimatedFrame.height + 20)
          //MARK: - view.safeAreaLayoutGuide.layoutFrame.width - estimatedFrame.width - 16 - 8 - 16 - 10
          cell.textBubbleView.frame = CGRect(x: view.safeAreaLayoutGuide.layoutFrame.width - estimatedFrame.width - 16 - 8 - 16 - 56, y: -4, width: estimatedFrame.width + 16 + 8 + 10 + 56, height: estimatedFrame.height + 20 + 6) //move receiver
//          cell.textBubbleView.addConstraintsWithFormat(format: "H:|-107-[v0(12)]-20-|", views: cell.readedMessageImage)
//          cell.textBubbleView.addConstraintsWithFormat(format: "V:|-35-[v0(12)]-10-|", views: cell.readedMessageImage)
         }
       } else
        {
         //Here minus 10 for textBubbleView into x coordinate view.frame.width - estimatedFrame.width - 16 - 16 - 8 - 10
          cell.messageTextView.frame = CGRect(x: view.frame.width - estimatedFrame.width - 16 - 16 - 8 - 28, y: 0, width: estimatedFrame.width + 16, height: estimatedFrame.height + 20)
         //MARK: - view.frame.width - estimatedFrame.width - 16 - 8 - 16 - 10
          cell.textBubbleView.frame = CGRect(x: view.frame.width - estimatedFrame.width - 16 - 8 - 16 - 66, y: -4, width: estimatedFrame.width + 16 + 8 + 10 + 66, height: estimatedFrame.height + 20 + 6)
       }
        cell.profileImageView.isHidden = true
       // cell.readedMessageIMG.isHidden = false
        cell.bubbleImageView.image = ChatLogMessageCell.blueBubbleImage_sent
//       cell.textBubbleView.addConstraintsWithFormat(format: "H:|-127-[v0(12)]-20-|", views: cell.readedMessageImage)
//       cell.textBubbleView.addConstraintsWithFormat(format: "V:|-35-[v0(12)]-10-|", views: cell.readedMessageImage)
       
        cell.textBubbleView.tintColor = UIColor(red: 0, green: 137/255, blue: 249/255, alpha: 1)
        cell.messageTextView.textColor = UIColor.white
      }
     
    }
    return cell
   
  }
 //MARK: - This part with collectionview is for BottomRefreser don't touch
   func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let message = fetchedResultsController.object(at: indexPath) as! Message
    if let messageText = message.text {
      let size = CGSize(width: 250, height: 1000.0)
      let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
     let estimateFrame = NSString(string: messageText).boundingRect(with: size, options: options, attributes: [kCTFontAttributeName as NSAttributedString.Key: UIFont.boldSystemFont(ofSize: 18)], context: nil)
      self.changeCollectionViewHeight()
     collectionView.backgroundColor = UIColor.gray
      return CGSize(width: view.frame.width - 33, height: estimateFrame.height + 20)
    }
    self.changeHeightInPortaritOrLandscape()
    //MARK: - Here is addded code for all type of devices and early of 11.0 and for last version of swift
    if #available(iOS 11.0, *) {
      return CGSize(width: collectionView.safeAreaLayoutGuide.layoutFrame.width, height: collectionView.safeAreaLayoutGuide.layoutFrame.height)
    } else {
      if UIDevice.current.orientation.isPortrait
      {
        messageInputContainerView.addConstraintsWithFormat(format: "H:|-8-[v0][v1(60)]|", views: inputTextField, sendButton)
        messageInputContainerView.addConstraintsWithFormat(format: "V:|[v0]|", views: inputTextField)
        messageInputContainerView.addConstraintsWithFormat(format: "V:|[v0]|", views: sendButton)
      }
      else if UIDevice.current.orientation.isLandscape {
        messageInputContainerView.addConstraintsWithFormat(format: "H:|-30-[v0][v1(60)]-30-|", views: inputTextField, sendButton)
        messageInputContainerView.addConstraintsWithFormat(format: "V:|[v0]|", views: inputTextField)
      }
      // Fallback on earlier versions
      return CGSize(width: view.frame.width, height: 100)
    }
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsets(top: 8, left: 0, bottom: 48, right: 0)
  }
//  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
//  return CGSize.zero
// }
// func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
//  if isLoadingBool {
//   return CGSize.zero
//  }
//  return CGSize(width: self.collectionView.bounds.size.width, height: 55)
// }
}
extension UITextField {
  func setLeftPaddingPoints(_ amount:CGFloat){
    let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
    self.leftView = paddingView
    self.leftViewMode = .always
  }
  func setRightPaddingPoints(_ amount:CGFloat) {
    let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
    self.rightView = paddingView
    self.rightViewMode = .always
  }
}
class ChatLogMessageCell : BaseCell
{
 
// override func awakeFromNib() {
//  super.awakeFromNib()
// }
 var messageTextView: UITextView = {
    let textView = UITextView()
    textView.font = UIFont.systemFont(ofSize: 18)
    textView.text = "Simple message"
    textView.backgroundColor = UIColor.clear
    //textView.backgroundColor = UIColor.red
    return textView
  }()
 let typeTextLabel : UILabel = {
  let typingLabelText = UILabel()
  typingLabelText.text = "Typing Here ..."
  return typingLabelText
 }()
  let textBubbleView: UIView = {
    let view = UIView()
    view.layer.cornerRadius = 15
    view.layer.masksToBounds = true
    view.backgroundColor = UIColor.cyan
    return view
  }()
 //MARK: - Just see how it is look profileImage did have circle form
 var profileImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFill
    imageView.layer.cornerRadius = 8
    imageView.layer.masksToBounds = true
    imageView.backgroundColor = UIColor.blue
    imageView.translatesAutoresizingMaskIntoConstraints = false
    return imageView
  }()
 let readedMessageImage: UIImageView = {
  let imageView = UIImageView()
  imageView.contentMode = .scaleAspectFill
  imageView.layer.cornerRadius = 2
  imageView.layer.masksToBounds = false
  imageView.translatesAutoresizingMaskIntoConstraints = false
  return imageView
 }()
 let recivedMessageIMG: UIImageView = {
  let imageView = UIImageView()
  imageView.contentMode = .scaleAspectFill
  imageView.layer.cornerRadius = 2
  imageView.layer.masksToBounds = true
  imageView.translatesAutoresizingMaskIntoConstraints = false
  return imageView
 }()
 let readView: UIView = {
  let view = UIView()
  view.contentMode = .scaleAspectFill
  view.layer.masksToBounds = false
  view.backgroundColor = UIColor.blue
  return view
 }()
 //Here is bubbles for left received message and right for sended message send message check did this can make some changes on them
  static let grayBubbleImage_received = UIImage(named: "bubble_received")!.resizableImage(withCapInsets: UIEdgeInsets(top: 22,left: 26,bottom: 22,right: 26)).withRenderingMode(.alwaysTemplate)
  static let blueBubbleImage_sent = UIImage(named: "bubble_sent")!.resizableImage(withCapInsets: UIEdgeInsets(top: 17,left: 21,bottom: 17,right: 21),resizingMode: .stretch).withRenderingMode(.alwaysTemplate)
  let bubbleImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = ChatLogMessageCell.grayBubbleImage_received
    imageView.translatesAutoresizingMaskIntoConstraints = true
    return imageView
  }()
  override func setupViews() {
    super.setupViews()
    addSubview(textBubbleView)
    addSubview(messageTextView)
   addSubview(bubbleImageView)
    addSubview(profileImageView)
 //  addSubview(readedMessageImage)
//    addSubview(recivedMessageIMG)
//   addConstraintsWithFormat(format: "H:|-390-[v0(25)]|", views: readView)
//   addConstraintsWithFormat(format: "V:|-[v0(25)]-|", views: readView)
    addConstraintsWithFormat(format: "H:|-(-14)-[v0(18)]", views: profileImageView)
    addConstraintsWithFormat(format: "V:|-26-[v0(18)]-26-|", views: profileImageView)
   addConstraintsWithFormat(format:"H:|-10-[v0]-10-|" , views: bubbleImageView)
   addConstraintsWithFormat(format: "V:|[v0]|", views: bubbleImageView)
//   addConstraintsWithFormat(format: "H:|-390-[v0(23)]", views: recivedMessageIMG)
//   addConstraintsWithFormat(format: "V:[v0(23)]|", views: recivedMessageIMG)
//     addConstraintsWithFormat(format: "H:|-390-[v0(12)]|", views: readedMessageImage)
//    addConstraintsWithFormat(format: "V:|[v0(12)]|", views: readedMessageImage)
    textBubbleView.addSubview(bubbleImageView)
    textBubbleView.addSubview(readedMessageImage)
    textBubbleView.addSubview(recivedMessageIMG)
    textBubbleView.addConstraintsWithFormat(format: "H:|-13-[v0]-13-|", views: bubbleImageView)
    textBubbleView.addConstraintsWithFormat(format: "V:|-3-[v0]-3-|", views: bubbleImageView)
   //textBubbleView.addConstraintsWithFormat(format: "H:|-87-[v0(12)]-20-|", views: readedMessageImage)
   //textBubbleView.leadingAnchor.constraint(equalTo: readedMessageImage.trailingAnchor, constant: 120).isActive = true
   textBubbleView.centerXAnchor.constraint(equalToSystemSpacingAfter: readedMessageImage.centerXAnchor, multiplier: 2.0).isActive = true
   //bubbleImageView.trailingAnchor.constraint(equalTo: readedMessageImage.trailingAnchor, constant: 30).isActive = true
  // bubbleImageView.leadingAnchor.constraint(equalTo: readedMessageImage.leadingAnchor, constant: 50).isActive = true
   readedMessageImage.layoutMarginsGuide.leadingAnchor.constraint(equalTo: bubbleImageView.layoutMarginsGuide.leadingAnchor, constant: 130).isActive = true
   //readedMessageImage.topAnchor.constraint(equalTo: textBubbleView.topAnchor, constant: 35).isActive = true
//   readedMessageImage.trailingAnchor.constraint(greaterThanOrEqualTo: textBubbleView.trailingAnchor, constant: -30).isActive = true
   //textBubbleView.trailingAnchor.constraint(equalTo: readedMessageImage.trailingAnchor, constant: 140).isActive = true
   //readedMessageImage.bottomAnchor.constraint(equalTo: textBubbleView.bottomAnchor).isActive = true
  // readedMessageImage.leadingAnchor.constraint(equalTo: textBubbleView.leadingAnchor, constant: 90).isActive = true
  // bubbleImageView.topAnchor.constraint(equalTo: textBubbleView.topAnchor).isActive = true
//   bubbleImageView.leadingAnchor.constraint(equalTo: textBubbleView.leadingAnchor).isActive = true
//   bubbleImageView.bottomAnchor.constraint(equalTo: textBubbleView.bottomAnchor).isActive = true
   
  // bubbleImageView.addConstraintsWithFormat(format: "H:|[v0(12)]-|", views: readedMessageImage)
  // bubbleImageView.addConstraintsWithFormat(format: "V:|-35-[v0(12)]", views: readedMessageImage)
   textBubbleView.addConstraintsWithFormat(format: "V:|-35-[v0(12)]-10-|", views: readedMessageImage)
   textBubbleView.addConstraintsWithFormat(format: "H:|-30-[v0]-(20)-[v1(12)]|", views: bubbleImageView, recivedMessageIMG)
   textBubbleView.addConstraintsWithFormat(format: "V:|-3-[v0]-3-[v1(12)]|", views: bubbleImageView, recivedMessageIMG)
   textBubbleView.addConstraintsWithFormat(format: "H:|-80-[v0(12)]|", views: recivedMessageIMG)
   textBubbleView.addConstraintsWithFormat(format: "V:|-25-[v0(12)]-10-|", views: recivedMessageIMG)
   textBubbleView.addConstraintsWithFormat(format: "H:|-10-[v0]-[v1(12)]-|", views: bubbleImageView, readedMessageImage)
   //textBubbleView.addConstraintsWithFormat(format: "H:|-120-[v0(12)][v1]|", views: readedMessageImage,bubbleImageView)
//   textBubbleView.leadingAnchor.constraint(greaterThanOrEqualToSystemSpacingAfter: readedMessageImage.trailingAnchor, multiplier: 1.0).isActive = true
   //textBubbleView.leadingAnchor.constraint(lessThanOrEqualToSystemSpacingAfter: readedMessageImage.trailingAnchor, multiplier: 1.0).isActive = true
//   NSLayoutConstraint.activate([bubbleImageView.centerXAnchor.constraint(equalTo: self.readedMessageImage.centerXAnchor, constant: 40), bubbleImageView.centerYAnchor.constraint(equalTo: self.readedMessageImage.centerYAnchor, constant: -40)])
   //textBubbleView.centerXAnchor.constraint(equalTo: self.readedMessageImage.centerXAnchor, constant: 40).isActive = true
   textBubbleView.addConstraintsWithFormat(format: "V:|-3-[v0]-(<=0)-[v1(12)]|", views: bubbleImageView, readedMessageImage)
   
   
   
//   bubbleImageView.addSubview(messageTextView)
//   bubbleImageView.addConstraintsWithFormat(format: "H:|-10-[v0]-10-|", views: messageTextView)
//   bubbleImageView.addConstraintsWithFormat(format: "V:|-3-[v0]-3-|", views: messageTextView)
  }
  
}
extension UITextField {
 
 enum PaddingSide {
  case left(CGFloat)
  case right(CGFloat)
  case both(CGFloat)
 }
 
 func addPadding(_ padding: PaddingSide) {
  
  self.leftViewMode = .always
  self.layer.masksToBounds = true
  
  
  switch padding {
   
  case .left(let spacing):
   let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: spacing, height: self.frame.height))
   self.leftView = paddingView
   self.rightViewMode = .always
   
  case .right(let spacing):
   let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: spacing, height: self.frame.height))
   self.rightView = paddingView
   self.rightViewMode = .always
   
  case .both(let spacing):
   let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: spacing, height: self.frame.height))
   // left
   self.leftView = paddingView
   self.leftViewMode = .always
   // right
   self.rightView = paddingView
   self.rightViewMode = .always
  }
 }
}

