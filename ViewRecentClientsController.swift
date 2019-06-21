//
//  ViewController.swift
//  ChatAppClients
//
//  Created by Dushko Cizaloski on 1/29/19.
//  Copyright © 2019 Big Nerd Ranch. All rights reserved.
//

import UIKit
import CoreData

class ViewRecentClientsController: UICollectionViewController, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate {
private let cellId = "cellId"
  var userDefaults = UserDefaults.standard
  var clientSendMsg: [ChatClients] = [ChatClients]()
  var clientMSG : ChatClients = ChatClients()
  var sendedMSGDate = [ChatClients]()
  var resultClientMSG : [Message] = []
  var inputFriendMSG : [Friend] = []
  var checkStatusMSG: Friend = Friend()
  var messageTimeLabel: MessageCell?
  var dateParser : DateParser?
//  var recivedNotification: String?
  var tableCell : UITableViewCell?
  var readedState : ChatLogController?
  var refreshController = UIRefreshControl()
  var activityIndicatorView = UIActivityIndicatorView()
  lazy var fetchedResultsController: NSFetchedResultsController = { () -> NSFetchedResultsController<NSFetchRequestResult> in
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Friend")
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lastMessage.date", ascending: false)]
    fetchRequest.predicate = NSPredicate(format: "lastMessage != nil")
    let context = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
    var timer: Timer?
    frc.delegate = self
    return frc
  }()
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    collectionView?.reloadData()
  }
  

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    if UIDevice.current.orientation.isPortrait
    {
      DispatchQueue.main.async {
      do
      {
        try  self.fetchedResultsController.performFetch()
        self.collectionView?.reloadData()
      //  self.setupData()
        
      } catch let err {
        print(err)
      }
        self.messageTimeLabel?.timeLabel.textAlignment = .center
     }
    // self.collectionView?.reloadData()
    }
    else {
    //  tableCell?.frame = CGRect(x: -15, y: (tableCell?.frame.origin.y)!, width: view.safeAreaLayoutGuide.layoutFrame.width, height: (tableCell?.frame.height)!)
      
      collectionView?.collectionViewLayout.invalidateLayout()
      messageTimeLabel?.setNeedsDisplay()
    }
     collectionView?.collectionViewLayout.invalidateLayout()
   // collectionView?.reloadData()
  }
  var blockOperation = [BlockOperation]()
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    if type == .insert
    {
      blockOperation.append(BlockOperation(block: {
        self.collectionView?.insertItems(at: [newIndexPath!])
        
      }))
    }
    collectionView?.reloadData()
  }
  
  // MARK: -Make changes here nothing Changed
//  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//    collectionView?.performBatchUpdates({
//      for operation in self.blockOperation
//      {
//        operation.start()
//
//      }
//
//    }, completion: { (completed) in
//      let lastItem = self.fetchedResultsController.sections![0].numberOfObjects - 1
//      if lastItem == -1
//      {
//        return
//      }
//      let indexPath = NSIndexPath(item: lastItem, section: 0)
//      self.collectionView?.scrollToItem(at: indexPath as IndexPath, at: .bottom, animated: true)
//    })
//    collectionView?.reloadData()
//
//  }
  var friend: [Friend]?
  var selectedFriend: [NSManagedObject] = []
  var friendMsg: NSManagedObject?
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    do {
      
      try fetchedResultsController.performFetch()
        self.collectionView?.reloadData()
    } catch let err {
      print(err)
    }
    collectionView?.reloadData()
    tabBarController?.tabBar.isHidden = false
  }
//  func setupCollectionViewRefresher()
//  {
//   // collectionView?.isHidden = true
//    //Add Refresh Control to Collection View
//    if #available(iOS 11.0, *)
//    {
//      collectionView?.refreshControl = refreshController
//    }
//    else {
//      collectionView?.addSubview(refreshController)
//    }
//    refreshController.addTarget(self, action: #selector(refreshClientData(_:)), for: .valueChanged)
//  }
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    if #available(iOS 11.0, *)
    {
      collectionView?.refreshControl = refreshController
    }
    else
    {
      refreshController.addSubview(refreshController)
    }
    //collectionView?.reloadData()
    //refreshController.addTarget(self, action: #selector(refreshClientData(_:)), for: .valueChanged)
   // setupCollectionViewRefresher()
    collectionView?.backgroundColor = UIColor.white
    collectionView?.alwaysBounceVertical = true
    collectionView?.register(MessageCell.self, forCellWithReuseIdentifier: cellId)
    navigationItem.title = "Users"
    
    
    print("viewHeight",self.view.frame.height, "Screen Height", UIScreen.main.bounds.height)
    var logedPersonMail = userDefaults.set("Ivica@gmail.com", forKey: "userMail") as Any
    var logedPersonPassword = userDefaults.set("123456", forKey: "userPass") as Any
//    var setUserM = userDefaults.set("proba1@gmail.com", forKey: "userReciverMail")
//    var setUserP = userDefaults.set("987654321", forKey: "userReciverPass")
//    var setUserEmail = userDefaults.set("proba1@gmail.com", forKey: "userMail")
//    var setUserPass = userDefaults.set("987654321", forKey: "userPass")
   
    if #available(iOS 11.0, *) {
      collectionView?.contentInsetAdjustmentBehavior = .always
//      let value = UIInterfaceOrientation.portrait.rawValue
//      UIDevice.current.setValue(value, forKey: "orientation")
    }
    do
    {
     // collectionView?.reloadData()
       try  fetchedResultsController.performFetch()
      setupData()
      collectionView?.reloadData()
    } catch let err {
      print(err)
    }
//    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add Mark", style: .plain, target: self, action: #selector(addMark))
//
  }
  
// @objc func addMark()
//  {
//    let context = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
//    let bugs_bunny = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
//
//    bugs_bunny.name = "bunny"
//    bugs_bunny.profileImageName = "bugs-bunny"
//    bugs_bunny.lastMessage?.status = "UnReaded"
//    
//    ViewRecentClientsController.createMessgeWithText(text: "Hello , my name is bugs bunny. Nice to meet you...", friend: bugs_bunny, minutesAgo: "0", context: context, status: (bugs_bunny.lastMessage?.status)!, id: bugs_bunny.id!)
//    print("Status bunny",bugs_bunny.lastMessage?.status!)
//    do {
//      try context.save()
//      //collectionView?.reloadData()
//    }
//    catch let err
//    {
//      print(err)
//    }
//    //collectionView?.reloadData()
//  }

  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if let count = fetchedResultsController.sections?[0].numberOfObjects
    {
      return count
    }
    return 0
//    guard let sections = fetchedResultsController.sections else { return 0 }
//    return sections[section].numberOfObjects
  }
  /*
   pravila za lista na korisnicia (prv kontroler)
   if($data[$i]['readstate']==1 and $data[$i]['is_sender']==1) SEEN(profile icon)
   else if($data[$i]['pmsnotify']==1 and $data[$i]['is_sender']==1) RECEIVED(checked)
   else ($data[$i]['is_sender']==1) SENT (check neoboen)
   */
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? MessageCell
    let friend =   fetchedResultsController.object(at: indexPath) as! Friend
  
    cell?.message = friend.lastMessage
    cell?.profileImageView.image = UIImage(named: friend.profileImageName!)
    cell?.messageLabel.text = friend.lastMessage?.text
    if friend.lastMessage?.isSender == "1"
    {
    cell?.senderName.text = "Me:"
    } else {
       cell?.senderName.text = ""
      //containerView.addConstraintsWithFormat(format: "H:|-25-[v0]-8-[v1(20)]-12-|", views: messageLabel, hasReadImageView)
      cell?.containerView.addConstraintsWithFormat(format: "H:|[v0]|", views: (cell?.messageLabel)!)
    }
    print("sendername",cell?.senderName.text!)
    cell?.hasReadImageView.image = UIImage(named: friend.profileImageName!)
    cell?.hasReadImageView.isHidden = true
    cell?.readedImage.isHidden = true
    //print("Status",friend.lastMessage?.status,"sender",friend.lastMessage?.isSender,"pmsnotify",friend.lastMessage?.pmsnotify)
    if friend.lastMessage?.status == "1" && friend.lastMessage!.isSender == "1" //&& recivedNotification == "1"
    {
      //IOS If
      cell?.readedImage.isHidden = true
     // cell?.reciveName.text = ""
      cell?.message = friend.lastMessage
      cell?.profileImageView.image = UIImage(named: friend.profileImageName!)
      cell?.hasReadImageView.isHidden = false
      cell?.profileImageView.isHidden = false
      cell?.messageLabel.text = friend.lastMessage?.text
      //cell?.messageLabel.font = UIFont.boldSystemFont(ofSize: 15)
      cell?.messageLabel.textColor = UIColor.lightGray
      cell?.readedImage.isHidden = true
      cell?.hasReadImageView.image = UIImage(named: friend.profileImageName!)
      if #available(iOS 11.0, *) {
        //First If
        if UIDevice.current.orientation.isPortrait
        {
          cell?.timeLabel.textAlignment = .center
          //cell?.readedImage.image = UIImage(named: "checked") //unchecked
        } // First If close here
        //Secound If
        if UIDevice.current.orientation.isLandscape
        {
          cell?.timeLabel.textAlignment = .center
          cell?.frame = CGRect(x: 0, y: (cell?.frame.origin.y)!, width: view.safeAreaLayoutGuide.layoutFrame.width, height: (cell?.frame.height)!)
       
         // cell?.readedImage.image = UIImage(named: "checked")
        cell?.readedImage.accessibilityFrame = CGRect(x: 0, y: 0, width: 50, height: 50)
          
        }
        //MARK: - Here if hasReadedImageView is true it's hide readed state of profiles which message is readed and notify is 1
        //Secound IF Close here
      } //IOS If close here
//     // "MARK: - Here we try to check if user is not a sender but here is set this code if friend.lastMessage?.status == 0 " Here is finished where user status is 1 and user isSender == true
    }
    else if friend.lastMessage?.pmsnotify == "1" && friend.lastMessage?.isSender == "1"
    {
      cell?.hasReadImageView.isHidden = false
     // cell?.messageLabel.font = UIFont.boldSystemFont(ofSize: 15)
      cell?.messageLabel.textColor = UIColor.lightGray
      cell?.hasReadImageView.image = UIImage(named: "checked")
     // cell?.readedImage.image = UIImage(named: "checked")
      cell?.readedImage.isHidden = false
      //cell?.messageLabel.frame.origin = CGPoint(x: -10, y: 0)
      if #available(iOS 11.0, *)
      {
        if UIDevice.current.orientation.isPortrait
          {
            //cell?.hasReadImageView.isHidden = true //false
            cell?.timeLabel.textAlignment = .center
          }
       if UIDevice.current.orientation.isLandscape
          {
           // cell?.hasReadImageView.isHidden = true //false
            cell?.timeLabel.textAlignment = .center
            cell?.frame = CGRect(x: 0, y: (cell?.frame.origin.y)!, width: view.safeAreaLayoutGuide.layoutFrame.width, height: (cell?.frame.height)!)
          }
        
      }
      //print("text")
    } else if friend.lastMessage?.isSender == "1" {
      cell?.senderName.text = "Me:"
      cell?.hasReadImageView.isHidden = true
      cell?.readedImage.isHidden = true
      cell?.messageLabel.textColor = UIColor.lightGray
      cell?.hasReadImageView.image = UIImage(named: "unchecked")
      //cell?.messageLabel.frame.origin = CGPoint(x: -10, y: 0)
      cell?.hasReadImageView.isHidden = false
      if #available(iOS 11.0, *) {
        //          //IOS If isPortrait Unreaded
        if UIDevice.current.orientation.isPortrait
          {
            cell?.timeLabel.textAlignment = .center
          }//IOS If isPortrait Unreaded Close here
        //          //IOS IF isLandscape Unreaded
        if UIDevice.current.orientation.isLandscape
          {
            cell?.timeLabel.textAlignment = .center
            cell?.frame = CGRect(x: 0, y: (cell?.frame.origin.y)!, width: view.safeAreaLayoutGuide.layoutFrame.width, height: (cell?.frame.height)!)
          }//IOS If isLandscape Unreaded Close Here
        }   else
        //IOS If of Unreaded Message Close here
           //IOS Else Unreaded
          {
            if UIDevice.current.orientation.isLandscape
              {
                cell?.timeLabel.textAlignment = .center
                cell?.frame = CGRect(x: 15, y: (cell?.frame.origin.y)!, width: view.safeAreaLayoutGuide.layoutFrame.width, height: (cell?.frame.height)!)
              }
        //          //unread message
              //  cell?.messageLabel.font = UIFont.boldSystemFont(ofSize: 15)
          }
    }
    
    return cell!
  }
  
//   func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
//    if UIDevice.current.orientation.isPortrait{
//
//    return UIInterfaceOrientationMask.portrait
//    }else
//    {
//       return UIInterfaceOrientationMask.landscape
//    }
//  }
  
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    if UIDevice.current.orientation.isPortrait
    {
      messageTimeLabel?.timeLabel.textAlignment = .center
      
    }
    else
    {
      messageTimeLabel?.timeLabel.textAlignment = .center
      messageTimeLabel?.frame = CGRect(x: 0, y: (messageTimeLabel?.frame.origin.y)!, width: view.safeAreaLayoutGuide.layoutFrame.width, height: (messageTimeLabel?.frame.height)!)
    }
    
    collectionView?.reloadData()
  }
 
   func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
    if UIDevice.current.orientation.isPortrait
    {
      if indexPath.row == 0
      {
        return CGSize(width: view.frame.width, height: 80.0)
      }
      
       //return CGSize(width: view.frame.width, height: 80.0)
      
    }
    if #available(iOS 11.0, *) {
      
     if UIDevice.current.orientation.isLandscape
    {
      return CGSize(width:view.safeAreaLayoutGuide.layoutFrame.width, height: 80.0)
    }
      }
    else
    {
      if indexPath.row == 0 {
       return CGSize(width: view.frame.width, height: 80.0)
      }
    }
    return CGSize(width: view.frame.width, height: 80.0)
  }
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 2.0
  }
  
  func collectionView(_ collectionView: UICollectionView, layout
    collectionViewLayout: UICollectionViewLayout,
                      minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 2.0
  }
  
  //MARK: - Go to the next View Controller to see messsages from all Users
 override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
  let layout = UICollectionViewFlowLayout()
   //setupData()
  let controller = ChatLogController(collectionViewLayout: layout)
   let friend = fetchedResultsController.object(at: indexPath) as! Friend
  controller.friend = friend
        navigationController?.pushViewController(controller, animated: true)
  }
}

//MARK : - This part is actualy for creating desing of rows into CollectionView
class MessageCell : BaseCell
{
  override var isHighlighted: Bool
  {
    didSet {
      backgroundColor = isHighlighted ? UIColor(red: 0, green: 134/255, blue: 249/255, alpha: 1) : UIColor.white
      nameLabel.textColor = isHighlighted ? UIColor.white : UIColor.black
      timeLabel.textColor = isHighlighted ? UIColor.white : UIColor.black
      messageLabel.textColor = isHighlighted ? UIColor.white : UIColor.black
    }
  }
  var message: Message? {
    didSet {
      nameLabel.text = message?.friend?.name
      
      if let profileImageName = message?.friend?.profileImageName {
        profileImageView.image = UIImage(named: profileImageName)
        
       // readedImage.isHidden = false
       // hasReadImageView.image = UIImage(named: profileImageName)
      }
      messageLabel.text = message?.text
//      if reciveName.text == "" && senderName.text == "Me"
//      {
//        messageLabel.frame.origin.x = -15
//      }
      if let date = message?.date {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        
        let dateString = date
        let dateFormatter = DateFormatter()
        // This is important - we set our input date format to match our input string
        // if the format doesn't match you'll get nil from your string, so be careful
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "CET")
        let dateFromString = dateFormatter.date(from: dateString)
        print(dateFromString!)
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM HH:mm"
        dateFormatter.timeZone = TimeZone(abbreviation: "CET")
        // dateFormatter.timeZone = TimeZone.current
        let stringDate: String = formatter.string(from: dateFromString!)
        print(stringDate)
        
      //  let elapsedTimeInSeconds = date //NSDate().timeIntervalSince(date as Date)
        
       // let secondInDays: TimeInterval = 60 * 60 * 24
        
//        if elapsedTimeInSeconds > 7 * secondInDays {
//          dateFormatter.dateFormat = "MM/dd/yy"
//        } else if elapsedTimeInSeconds > secondInDays {
//          dateFormatter.dateFormat = "EEE"
//        }
        timeLabel.textAlignment = .center
        MessageCell().frame = CGRect(x: -40, y: MessageCell().frame.origin.y, width: containerView.safeAreaLayoutGuide.layoutFrame.width, height: MessageCell().frame.height)
        if UIDevice.current.orientation.isLandscape {
         //timeLabel.frame.origin.x += 30
          timeLabel.textAlignment = .center
          //MARK: - Make changes on part with desing to set space between timeLabel and hasReadImageView
        //  timeLabel.frame.origin = CGPoint(x: containerView.safeAreaLayoutGuide.layoutFrame.width - 115, y: 0)
          MessageCell().frame = CGRect(x: -60, y: MessageCell().frame.origin.y, width: containerView.safeAreaLayoutGuide.layoutFrame.width, height: MessageCell().frame.height)
        }
        else
        {
//          timeLabel.textAlignment = .center
//          MessageCell().frame = CGRect(x: -40, y: MessageCell().frame.origin.y, width: containerView.safeAreaLayoutGuide.layoutFrame.width, height: MessageCell().frame.height)
         // timeLabel.textAlignment = .left
          //MARK: - Make changes on part with desing to set space between timeLabel and hasReadImageView
         // timeLabel.frame.origin = CGPoint(x: containerView.safeAreaLayoutGuide.layoutFrame.width - 115, y: 0)
          
        }
//        let currentDateFormat = dateFormatter.date(from: stringDate)
//        var stringDateFormat = dateFormatter.string(from: currentDateFormat!)
//        print("timelabel Width",timeLabel.frame.width,"timeLabel Height",timeLabel.frame.height)
        timeLabel.text = stringDate //dateFormatter.string(from: date as Date)
        
      }
    }
  }
 
  //MARK: - Here we will implement a new code for insert image into FrendCell
  let containerView : UIView = {
    let view = UIView()
    view.backgroundColor = UIColor.cyan
    return view
  }()
  let containterViewReadedIMG : UIView = {
    let view = UIView()
    view.backgroundColor = UIColor.purple
    return view
  }()
  let profileImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFill
    imageView.layer.cornerRadius = 25
    imageView.layer.masksToBounds = true
    //MARK: - First -> Just check to see which element goes into ContainerView
   // imageView.backgroundColor = UIColor.red
    return imageView
  }()
  
  let dividerLineView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
    return view
  }()
  
  let nameLabel: UILabel = {
    let label = UILabel()
    label.text = "Bugs Bunny"
    label.font = UIFont.systemFont(ofSize: 18)
    return label
  }()
  //Who was sended the last message(person)
  var senderName : UILabel = {
    let sender = UILabel()
    sender.font = UIFont.systemFont(ofSize: 13)
    return sender
  }()
  var reciveName : UILabel = {
    let recived = UILabel()
    recived.text = ""
    recived.font = UIFont.systemFont(ofSize: 13)
    return recived
  }()
  var messageLabel: UILabel = {
    let label = UILabel()
    label.text = "Your friend' message and something else..."
    label.textColor = UIColor.darkGray
    label.font = UIFont.systemFont(ofSize: 14)
    return label
  }()
  var timeLabel: UILabel = {
    let label = UILabel()
    label.text = "12:05 pm"
    label.lineBreakMode = .byWordWrapping
    label.contentMode = ContentMode.center
    label.font = UIFont.systemFont(ofSize: 16)
    //label.frame.size = CGSize(width: 250, height: 20)
    label.numberOfLines = 0
    //label.textAlignment = .right
    return label
  }()
  let hasReadImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFill
    imageView.layer.cornerRadius = 10
    imageView.layer.masksToBounds = true
    //imageView.backgroundColor = UIColor.blue
    return imageView
  }()
  let readedImage: UIImageView = {
    let readedIMG = UIImageView()
    readedIMG.contentMode = .scaleAspectFill
    readedIMG.layer.cornerRadius = 10
   // readedIMG.frame.size = CGSize(width: 50, height: 50)
    readedIMG.layer.masksToBounds = true
    //readedIMG.backgroundColor = UIColor.red
    return readedIMG
  }()
 override func setupViews()
  {
    super.setupViews()
    addSubview(profileImageView)
    addSubview(dividerLineView)
    addSubview(reciveName)
    addSubview(senderName)
    addSubview(readedImage)
    
    setupContainerView()
    
    profileImageView.image = UIImage(named: "bugs-bunny")
   // hasReadImageView.isHidden = false
    readedImage.image = UIImage(named: "checked")
    readedImage.isHidden = false
   // hasReadImageView.image = UIImage(named: "bugs-bunny")
    //ProfileImage constraints
    addConstraintsWithFormat(format: "H:|-13-[v0(53)]", views: profileImageView)
    addConstraintsWithFormat(format: "V:[v0(53)]", views: profileImageView)

//    addConstraintsWithFormat(format: "H:|-90-[v0]|", views: senderName)
//    addConstraintsWithFormat(format: "V:|-25-[v0]|", views: senderName)
    
//    addConstraintsWithFormat(format: "H:|-70-[v0]|", views: reciveName)
//    addConstraintsWithFormat(format: "V:|-25-[v0]|", views: reciveName)
    //MARK: - Now i check to make changes here to see did this
    if UIDevice.current.orientation == UIDeviceOrientation.portrait
    {
          addConstraintsWithFormat(format: "H:[v0(20)]-11-|", views: readedImage)
          addConstraintsWithFormat(format: "V:|-75-[v0(20)]|", views: readedImage)
    }
    //MARK: - This part of code is for center the profile image into the cell
    addConstraints([NSLayoutConstraint.init(item: profileImageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)])
    //dividerLineView
    addConstraintsWithFormat(format: "H:|-82-[v0]|", views: dividerLineView)
    addConstraintsWithFormat(format: "V:[v0(1)]|", views: dividerLineView)
  }
  private func setupContainerView()
  {
    //let containerView = UIView()
    addSubview(containerView)
    
    //MARK : - Add Container for name of user and text Message
    addConstraintsWithFormat(format: "H:|-90-[v0]|", views:containerView)
    addConstraintsWithFormat(format: "V:[v0(50)]", views:containerView)
    
    //MARK: - This part of code is for center the profile image into the cell
    addConstraints([NSLayoutConstraint.init(item: containerView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)])
    //MARK: - Add NameLabel into container view, messageLabel, timeLabel and readerImage
    containerView.addSubview(nameLabel)
    containerView.addSubview(senderName)
    containerView.addSubview(messageLabel)
    containerView.addSubview(timeLabel)
    containerView.addSubview(hasReadImageView)
    //MARK: - Make a chaing from bottom is 12 will be changed with new value to see did will be changed some constraint for time label
    containerView.addConstraintsWithFormat(format: "H:|[v0][v1(80)]-32-|", views: nameLabel,timeLabel)
    containerView.addConstraintsWithFormat(format: "V:|[v0][v1(24)]|", views: nameLabel, messageLabel)
    containerView.addConstraintsWithFormat(format: "H:|[v0]|", views: senderName)
    containerView.addConstraintsWithFormat(format: "V:|-25-[v0]|", views: senderName)
    
    containerView.addConstraintsWithFormat(format: "H:|-25-[v0]-8-[v1(20)]-12-|", views: messageLabel, hasReadImageView)
    //MARK: - CHange the width of timeLabel and the current value is 24
    containerView.addConstraintsWithFormat(format: "V:|[v0(60)]", views: timeLabel)
    
    containerView.addConstraintsWithFormat(format: "V:[v0(20)]|", views: hasReadImageView)
  }
}

//MARK: - Minimization of code for Contstraints with one line of code
extension UIView
{
  func addConstraintsWithFormat(format: String, views: UIView...)
  {
    var viewsDictionary = [String: UIView]()
    for (index, view) in views.enumerated()
    {
      let key = "v\(index)"
      viewsDictionary[key] = view
      view.translatesAutoresizingMaskIntoConstraints = false
    }
    addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: viewsDictionary))
  }
  
}

//MARK - : Make more space for another code from first class FrendCell
class BaseCell: UICollectionViewCell
{  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setupViews()
  }
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder) has not been implemented")
  }
  func setupViews()
  {
  }
}


