//
//  FriendsControllerHelper.swift
//  ChatAppClients
//
//  Created by Dushko Cizaloski on 2/1/19.
//  Copyright © 2019 Big Nerd Ranch. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
//import AlamofireObjectMapper
//This part of code is replaced with CoreDate part which is automaticaly created
//class Friend: NSObject {
//  var name: String?
//  var profileImageName: String?
//}
//
//class Message: NSObject
//{
//  var text: String?
//  var date: NSDate?
//  var friend: Friend?
//}

extension ViewRecentClientsController
{
  
  //MARK : -  here we would make our clearData from CoreData in which will catch and deleted object of messages into CoreData which we catch them into loadData func
  
  func clearData()
  {
    let delegate = UIApplication.shared.delegate as? AppDelegate
    if let context = delegate?.managedObjectContext
    {
      do
      {
        let entityNames = ["Friend","Message"]
        
        for entityName in entityNames
        {
          let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: entityName)
          let objects = try (context.fetch(fetchRequest)) as? [NSManagedObject]
          for object in objects!
          {
            context.delete(object)
//            collectionView?.reloadData()
          }
        }
       
        try (context.save())
      } catch let err {
        print(err)
      }
    }
  }
  
  func setupData()
  {
    
    let delegate = UIApplication.shared.delegate as? AppDelegate
    
    refreshController.addTarget(self, action: #selector(refreshClientData(_:)), for: .valueChanged)
    self.clearData()
   // self.refreshController.beginRefreshing()
    if let context = delegate?.managedObjectContext
    {
      weak var weakSelf = self
      
      //MARK: - Set up information from API with Alamofire here just read data from API
      getApiInfoUser(completion: {chatClients in
       // self.clearData()
        let allUserInfos = [chatClients]
        if allUserInfos.count == nil
        {
          self.clearData()
        }
        //       print("print model info",chatClients!)
      self.clientSendMsg = [chatClients] as! [ChatClients]
        // self.clearData()
        //for sendMSG in self.clientSendMsg
        if self.clientSendMsg.count == 0
        {
          self.clearData()
        }
      //  {
          let fetchFriendName = NSFetchRequest<NSFetchRequestResult>(entityName: "Friend")
        let nameSort = NSSortDescriptor(key:"lastMessage.date", ascending:true)
        fetchFriendName.sortDescriptors = [nameSort]
        let predicateName = NSPredicate(format: "id == %@", (self.clientSendMsg.first?.friend!)!)
          fetchFriendName.predicate = predicateName
          print("name",self.clientSendMsg.first?.friend!)
          do {
            try self.fetchedResultsController.performFetch()
            let count = try context.count(for: fetchFriendName)
            print(count)
            if count < 1
            {
              
              let daffu_duck = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
              for clientSendMessage in self.clientSendMsg
              {
              daffu_duck.name = clientSendMessage.firstName //"duck"
              daffu_duck.profileImageName = "daffy-duck"
                //MARK: - I make a change on one variable that is isSender.I set value 1 for that isSender but for 0 that is not isSender
             // daffu_duck.lastMessage?.pmsnotify = clientSendMessage.pmsnotify
              print("message and pmsnotify",self.clientSendMsg.first?.pmsnotify, clientSendMessage.firstName!)
                ViewRecentClientsController.createMessgeWithText(text: (clientSendMessage.message!), friend: daffu_duck, minutesAgo: (clientSendMessage.date!), context: context, isSender: (clientSendMessage.is_Sender!), status: (clientSendMessage.readState!), id: (clientSendMessage.friend!), pmsnotify: clientSendMessage.pmsnotify!)//createMessgeWithText(text: sendMSG.message!, friend: daffu_duck, minutesAgo: stringDate, context: context, status: sendMSG.readState!, id: sendMSG.friend!)
                print("clientSendMsg1", self.clientSendMsg.first?.is_Sender)
                //
              }
            }
            else
            {
              let friendCount = try context.fetch(fetchFriendName) as! [Friend]
             // for friend in friendCount
             // {
              for clientSendMessage in self.clientSendMsg
              {
              print("clientSendMsg2",clientSendMessage.is_Sender)
                ViewRecentClientsController.createMessgeWithText(text: (clientSendMessage.message!), friend: friendCount.first!, minutesAgo: (clientSendMessage.date!), context: context, isSender: (clientSendMessage.is_Sender!), status: (clientSendMessage.readState!), id: (clientSendMessage.friend!), pmsnotify: (clientSendMessage.pmsnotify!))
            //  }
              }
            }
            
          } catch let err
          {
            print(err)
          }
          DispatchQueue.main.async {
            self.collectionView?.reloadData()
         //   self.refreshController.endRefreshing()
            }
        self.createDuffyMessagesWithContext(context: context)
       // }
      })
//      AF.request(API_URL_LOGIN_CLIENT!, method: .post, parameters: parameters as [String: AnyObject]).responseArray{ (response: DataResponse<[ChatClients]>) in
////        dispatch_async(dispatch_get_main_queue(), { () -> Void in
////
////        })
//        let responseAnswers = response.result.value
//        self.clearData()
//        //var found = ""
////        if (responseAnswers?.count)! == 0 {
////          return self.clearData()
////        }
////        if response.data?.count != 0
////        {
//        print("from server",responseAnswers)
//        self.clientSendMsg = responseAnswers!
//        for sendMSG in self.clientSendMsg
//        {
//
//
////          let sortedClientSendMSG = self.clientSendMsg.sort {
////          if $0.date != $1.date {
////              return $0.date! < $1.date!
////            }
////              return $0.date! < $1.date!
////          }
////          let sortedByDate = self.friend?.sort {
////            if $0.lastMessage?.date != $1.lastMessage?.date
////            {
////              return $0.lastMessage!.date! < $1.lastMessage!.date!
////            }
////            return $0.lastMessage!.date! < $1.lastMessage!.date!
////          }
//          //if(found == "") {
//         // let friendMessage = NSFetchRequest<NSFetchRequestResult>(entityName: "Message")
//            let fetchFriendName = NSFetchRequest<NSFetchRequestResult>(entityName: "Friend")
////            let nameSort = NSSortDescriptor(key:"lastMessage.date", ascending:false)
////            fetchFriendName.sortDescriptors = [nameSort]
//            let predicateName = NSPredicate(format: "id == %@", sendMSG.friend!)
//            fetchFriendName.predicate = predicateName
//            print("name",sendMSG.friend)
//            //fetchFriendName.fetchLimit = 1
//
//            do
//            {
//              try self.fetchedResultsController.performFetch()
//              let count = try context.count(for: fetchFriendName)
//
//              print(count)
//              if count < 1
//              {
////                if ((sendMSG.friend != nil))
////                {
//                let daffu_duck = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
//
//                daffu_duck.name = sendMSG.firstname //"duck"
//                daffu_duck.profileImageName = "daffy-duck"
//                  ViewRecentClientsController.createMessgeWithText(text: sendMSG.message!, friend: daffu_duck, minutesAgo: sendMSG.date!, context: context, isSender: sendMSG.is_Sender == "1", status: sendMSG.readState!, id: sendMSG.friend!)//createMessgeWithText(text: sendMSG.message!, friend: daffu_duck, minutesAgo: stringDate, context: context, status: sendMSG.readState!, id: sendMSG.friend!)
////                }
//              }
//                else
//                {
//                  //let fetchFName = NSFetchRequest<NSFetchRequestResult>(entityName: "Friend") as! Friend
//
//                  let friendCount = try context.fetch(fetchFriendName) as! [Friend]
//
//                  for frend in friendCount
//                  {
//
//                 // let predicateFName = NSPredicate(format: "id == %@", sendMSG.friend!)
//                    ViewRecentClientsController.createMessgeWithText(text: sendMSG.message!, friend: frend, minutesAgo: sendMSG.date!, context: context, isSender: (sendMSG.is_Sender == "1"), status: sendMSG.readState!, id: sendMSG.friend!)
//                  }
//
//              }
////
//
//            } catch let err
//            {
//              print(err)
//            }
//          //self.collectionView?.reloadData()
//        }
//
//        DispatchQueue.main.async {
//          self.collectionView?.reloadData()
//          self.refreshController.endRefreshing()
//         //
//        }
//       self.createDuffyMessagesWithContext(context: context)
//      }
     
      do {
        try (context.save())
        collectionView?.reloadData()
      }catch let err{
        print(err)
      }
    }
   // loadData()
  }
  func getApiInfoUser(completion: @escaping (ChatClients?) -> Void)
  {
    
    let API_URL_LOGIN_CLIENT = URL(string: "https://bilbord.mk/api.php?key=3g5fg3f5gf2h32k2j&function=get_pm")
    print("mail",userDefaults.string(forKey: "userMail")!, "pass", userDefaults.string(forKey: "userPass")!)
    let parameters: Parameters = ["email":userDefaults.string(forKey: "userMail")!, "password":userDefaults.string(forKey: "userPass")!]
    
    self.refreshController.beginRefreshing()
   // let headers: HTTPHeaders = ["Accept": "application/json"]
    
    AF.request(API_URL_LOGIN_CLIENT!, method: .post, parameters: parameters as [String: AnyObject]).responseJSON { (response) in
      
    //  guard let data = response.data else { return }
      
      let data = response.data
      
      if data!.count != 0
      {
        
        let decoder = JSONDecoder()
        
      do {
        
        let apiInfoUserRequest = try decoder.decode([ChatClients].self, from: data!)
       // completion(apiInfoUserRequest)
        print(apiInfoUserRequest)
        for apiUserInfo in apiInfoUserRequest
        {
        completion(apiUserInfo)


          print("firstname",apiUserInfo.firstName!)
        }
      } catch let error  {
        print(error)
        completion(nil)
      }
        
      /*
         // Encode data
         let jsonEncoder = JSONEncoder()
         do {
         let jsonData = try jsonEncoder.encode(upMovie)
         let jsonString = String(data: jsonData, encoding: .utf8)
         print("JSON String : " + jsonString!)
         }
         catch {
         }
         */
      DispatchQueue.main.async {
        self.collectionView?.reloadData()
        self.refreshController.endRefreshing()
        
      }
      }
      else {
        return
      }
    }
    
  }
  
   @objc private func refreshClientData(_ sender: Any)
   {
    let delegate = UIApplication.shared.delegate as? AppDelegate
    self.refreshController.beginRefreshing()
    if (delegate?.managedObjectContext) != nil {
    weak var weakSelf = self

    //MARK: - Set up information from API with Alamofire here just read data from API
//    var API_URL_LOGIN_CLIENT = URL(string: "https://bilbord.mk/api.php?key=3g5fg3f5gf2h32k2j&function=get_pm")
//    print("mail",userDefaults.string(forKey: "userMail")!, "pass", userDefaults.string(forKey: "userPass")!)
//    let parameters: Parameters = ["email":userDefaults.string(forKey: "userMail")!, "password":userDefaults.string(forKey: "userPass")!]
//      AF.request(API_URL_LOGIN_CLIENT!, method: .post, parameters: parameters).response { (response) in
//        guard let data = response.data else { return }
//        do {
//          let decoder = JSONDecoder()
//          let apiInfoUserRequest = try decoder.decode(ChatClients.self, from: data)
//
//          print("message",apiInfoUserRequest.message)
//        } catch let error  {
//          print(error)
//        }
//      }
      
//      getApiInfoUser(completion: {chatClients in
//       // print("print model info",chatClients!)
//
//        ////var found = ""
//
//        self.clientSendMsg = [chatClients] as! [ChatClients]
//
//        DispatchQueue.main.async {
//         // for sendMSG in self.clientSendMsg
//         // {
//            let fetchFriendName = NSFetchRequest<NSFetchRequestResult>(entityName: "Friend")
//            let nameSort = NSSortDescriptor(key:"lastMessage.date", ascending:true)
//            fetchFriendName.sortDescriptors = [nameSort]
//          let predicateName = NSPredicate(format: "id == %@", (self.clientSendMsg.first?.friend!)!)
//            fetchFriendName.predicate = predicateName
//           // print("name",sendMSG.friend!)
//            do {
//              try self.fetchedResultsController.performFetch()
//              let count = try context.count(for: fetchFriendName)
//
//              if count < 1
//              {
//
//                let daffu_duck = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
//                daffu_duck.name = self.clientSendMsg.first?.firstName //sendMSG.firstName //"duck"
//                daffu_duck.profileImageName = "daffy-duck"
//                ViewRecentClientsController.createMessgeWithText(text: (self.clientSendMsg.first?.message!)!, friend: daffu_duck, minutesAgo: (self.clientSendMsg.first?.date!)!, context: context, isSender: self.clientSendMsg.first?.is_Sender! == "1", status: (self.clientSendMsg.first?.readState!)!, id: (self.clientSendMsg.first?.friend!)!)//createMessgeWithText(text: sendMSG.message!, friend: daffu_duck, minutesAgo: stringDate, context: context, status: sendMSG.readState!, id: sendMSG.friend!)
//              }
//              else
//              {
//                let friendCount = try context.fetch(fetchFriendName) as! [Friend]
//             //   for friend in friendCount
//              //  {
//                ViewRecentClientsController.createMessgeWithText(text: (self.clientSendMsg.first?.message!)!, friend: friendCount.first!, minutesAgo: (self.clientSendMsg.first?.date!)!, context: context, isSender: (self.clientSendMsg.first?.is_Sender == "1"), status: (self.clientSendMsg.first?.readState!)!, id: (self.clientSendMsg.first?.friend!)!)
//              //  }
//              }
//
//            } catch let err
//            {
//              print(err)
//            }
//            DispatchQueue.main.async {
//              self.refreshController.endRefreshing()
//              self.activityIndicatorView.stopAnimating()
//              // self.createDuffyMessagesWithContext(context: context)
//              self.collectionView?.reloadData()
//            }
//         // }
//        }
//
//      })
//    AF.request(API_URL_LOGIN_CLIENT!, method: .post, parameters: parameters as [String: AnyObject]).responseArray{ (response: DataResponse<[ChatClients]>) in
//
//      let responseAnswers = response.result.value
//      //var found = ""
//
//      self.clientSendMsg = responseAnswers!
//
//
//      DispatchQueue.main.async {
//      for sendMSG in self.clientSendMsg
//      {
//
////        let sortedByDate = self.friend?.sort
      //{
////          if $0.lastMessage?.date != $1.lastMessage?.date
////          {
////            return $0.lastMessage!.date! < $1.lastMessage!.date!
////          }
////          return $0.lastMessage!.date! < $1.lastMessage!.date!
////        }
//        //self.clearData()
//
//        //if(found == "") {
//      //  let friendMessage = NSFetchRequest<NSFetchRequestResult>(entityName: "Message")
//        let fetchFriendName = NSFetchRequest<NSFetchRequestResult>(entityName: "Friend")
//                    let nameSort = NSSortDescriptor(key:"lastMessage.date", ascending:true)
//                    fetchFriendName.sortDescriptors = [nameSort]
////        let predicateName = NSPredicate(format: "id == %@", sendMSG.friend!)
////        fetchFriendName.predicate = predicateName
//        print("name",sendMSG.friend!)
//        //fetchFriendName.fetchLimit = 1
//        do
//        {
//          try self.fetchedResultsController.performFetch()
//          let count = try context.count(for: fetchFriendName)
//
//          if count < 0
//          {
////            if ((sendMSG.friend != nil))
////            {
//              let daffu_duck = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
//              daffu_duck.name = sendMSG.friend //"duck"
//              daffu_duck.profileImageName = "daffy-duck"
//              ViewRecentClientsController.createMessgeWithText(text: sendMSG.message!, friend: daffu_duck, minutesAgo: sendMSG.date!, context: context, status: sendMSG.readState!, id: sendMSG.friend!)
//           // }
//          }
//          else
//          {
//            let friendCount = try context.fetch(fetchFriendName) as! [Friend]
////            let predicateFName = NSPredicate(format: "id == %@", sendMSG.friend!)
////            fetchFriendName.predicate = predicateFName
//            for frendMSG in friendCount
//            {
//          //  if sendMSG.message != "" || sendMSG.message != frendMSG.lastMessage?.text
//           // {
//              ViewRecentClientsController.createMessgeWithText(text: sendMSG.message!, friend:  friendCount[0], minutesAgo: sendMSG.date!, context: context, isSender: (sendMSG.is_Sender == "1"), status: sendMSG.readState!, id: sendMSG.friend!)
////              print("state of msg read/unreaded",sendMSG.readState!)
////           //}
////              if sendMSG.message != "" && frendMSG.lastMessage?.text != ""
////              {
////                print("server message", sendMSG.message, "Core Data MSG", frendMSG.lastMessage?.text)
////                ViewRecentClientsController.createMessgeWithText(text: (frendMSG.lastMessage?.text!)!, friend: frendMSG, minutesAgo: stringDate, context: context, isSender: (sendMSG.is_Sender == "1"), status: sendMSG.readState!)
////                frendMSG.lastMessage?.text = sendMSG.message
////
////              }
////              else if frendMSG.lastMessage?.text == sendMSG.message
////              {
////                return
////              }
//
//            }
//          }
//        } catch let err
//        {
//          print(err)
//        }
//        DispatchQueue.main.async {
//          self.refreshController.endRefreshing()
//          self.activityIndicatorView.stopAnimating()
//         // self.createDuffyMessagesWithContext(context: context)
//          self.collectionView?.reloadData()
//        }
//
//      }
//      }
////      DispatchQueue.main.async {
////        self.collectionView?.reloadData()
////      }
//      }
      self.setupData()
//      do {
//
//        //self.collectionView?.reloadData()
//        try (context.save())
//        self.collectionView?.reloadData()
//      }catch let err{
//        print(err)
//      }
    }
    // self.collectionView?.reloadData()
   }

  public func createDuffyMessagesWithContext(context: NSManagedObjectContext)
  {
    //createDuffyMessagesWithContext(context: context)
//    let daffy_duck = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
//    daffy_duck.name = "duck"
//    daffy_duck.profileImageName = "daffy-duck"
//    ViewRecentClientsController.createMessgeWithText(text: "Good morning...", friend: daffy_duck, minutesAgo: 3, context: context, status: "Readed")
//    ViewRecentClientsController.createMessgeWithText(text: "Hello, how are you? Hope you are having a good morning!", friend: daffy_duck, minutesAgo: 2 ,context: context, status: "Readed")
//    ViewRecentClientsController.createMessgeWithText(text: "Are you interesed to buy my Iphone 7 with smaller price? We have a wide variety of Apple devices that will suit your needs. Please make your purchase with us.", friend: daffy_duck,minutesAgo: 1, context: context, status: "Readed")
//    //response message
//    ViewRecentClientsController.createMessgeWithText(text: "Yes, totaly looking to buy an iPhone 7.", friend: daffy_duck,minutesAgo: 1, context: context, isSender: true, status: "Readed")
//    ViewRecentClientsController.createMessgeWithText(text: "Totally understand that you want the new iPhone 7, but you'll have to wait until September for the new release. Sorry but thats just how Apple likes to do things.", friend: daffy_duck, minutesAgo: 1, context: context, status:"Readed")
//    ViewRecentClientsController.createMessgeWithText(text: "Absolutely, I'll just use my gigantic iPhone 6 Plus until then!!!", friend: daffy_duck, minutesAgo: 1, context: context, isSender: true, status: "Readed")
//    /*let fetchRequest = NSFetchRequest<Person>(entityName: "Person")
//     do {
//     let fetchedResults = try managedObjectContext!.fetch(fetchRequest)
//     for item in fetchedResults {
//     print(item.value(forKey: "name")!)
//     }
//     } catch let error as NSError {
//     // something went wrong, print the error.
//     print(error.description)
//     }*/
//    ViewRecentClientsController.createMessgeWithText(text: "Yes, totally understand that you want the new iPhone 7, but you'll have to wait until September for the new release. Sorry but thats just how Apple likes to do things.", friend: daffy_duck,minutesAgo: 1, context: context, status: "Readed")
    
    
  }
  //MARK: - Create more messages with this func
  static func createMessgeWithText(text: String, friend: Friend, minutesAgo: String , context: NSManagedObjectContext, isSender: String, status: String, id: String, pmsnotify: String) -> Message
  {
    let message = NSEntityDescription.insertNewObject(forEntityName: "Message", into: context) as! Message
    message.friend = friend
    message.text = text
    message.friend?.id = id
    message.date = minutesAgo  //Date.init(timeIntervalSinceNow: TimeInterval(-minutesAgo * 60)) as NSDate
    message.isSender = isSender
    message.status = status
    friend.lastMessage = message
    friend.lastMessage?.pmsnotify = pmsnotify
    
    return message
  }
  
  func fetchMessage() -> [Message]?
  {
    let delegate = UIApplication.shared.delegate as? AppDelegate
    let context = delegate?.managedObjectContext
    let messagesFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Message")
    do
    {
      let message = try context?.fetch(messagesFetchRequest) as! [Message]
      return message
    } catch let err {
      print(err)
      return nil
    }
  }
  //MARK : - Here we will make some func which will make fetching duplicate data and return just not duplicated datas
//  func loadData()
//  {
//    let delegate = UIApplication.shared.delegate as? AppDelegate
//    if let context = delegate?.managedObjectContext
//    {
//      //MARK: - here we will make a fetch for all firends which like to do fetchReqest of messages
//     if let friends = fetchFriends()
//     {
//      messages = [Message]()
//
//      for friend in friends
//      {
//
//        //print(friend.name)
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Message")
//        //MARK : - here we fillter a messages by time when they are created
//        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
//        //MARK : - Here we will return just person which recive last message
//        fetchRequest.predicate =  NSPredicate(format: "friend.name = %@", friend.name!)
//        fetchRequest.fetchLimit = 1
//        do
//        {
//          let fetchMessages = try (context.fetch(fetchRequest))
//          messages?.append(contentsOf: fetchMessages as! [Message]) //MARK: - We must make this casting here because we must know what kind of content we set into array of messages.They must be with same type
//
//        } catch let err {
//          print(err)
//        }
//      }
//
//      messages = messages?.sorted(by: { $0.date!.compare($1.date! as Date) == .orderedDescending })
//     }
//    }
//  }
//
//  private func fetchFriends() -> [Friend]?
//  {
//    let delegate = UIApplication.shared.delegate as? AppDelegate
//    if let context = delegate?.managedObjectContext
//    {
//      let request = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Friend")
//      do
//      {
//        return try (context.fetch(request)) as? [Friend]
//      } catch let err
//      {
//        print(err)
//      }
//    }
//    return nil
//  }
//  public func fetchFriendMessages() -> [Message]?
//  {
//    let delegate = UIApplication.shared.delegate as? AppDelegate
//    if let context = delegate?.managedObjectContext
//    {
//      let request = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Message")
//      do
//      {
//        return try (context.fetch(request)) as? [Message]
//      } catch let err
//      {
//        print(err)
//      }
//    }
//    return nil
//  }
}
//extension String {
//  func toDouble() -> Double? {
//    return NumberFormatter().number(from: self)?.doubleValue
//  }
//}

