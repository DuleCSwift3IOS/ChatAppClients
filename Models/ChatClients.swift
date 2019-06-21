//
//  ChatClients.swift
//  ChatAppClients
//
//  Created by Dushko Cizaloski on 3/25/19.
//  Copyright © 2019 Big Nerd Ranch. All rights reserved.
//

import Foundation
import UIKit
//import ObjectMapper

//struct ChatClients: Mappable
//{
//  //var email : String?
//  var date: String?
//  var friend: String?
//  var id: String?
//  var inbox: String?
//  var is_Sender: String?
//  var message: String?
//  var pmsnotify: String?
//  var readState: String?
//  var recip_id: String?
//  var sender_id: String?
//  var sent_items: String?
//  var subject: String?
//  var firstname: String?
//  var profile_pic: String?
//  //var password: String?
//  var client_id: String?
//  var client_msg: String?
//
//  init?(map: Map) {
//
//  }
//
//  mutating func mapping(map: Map) {
//   // email <- map["email"]
//   // password <- map["password"]
//    date <- map["date"]
//    friend <- map["friend"]
//    id <- map["id"]
//    inbox <- map["inbox"]
//    is_Sender <- map["is_sender"]
//    message <- map["message"]
//    pmsnotify <- map["pmsnotify"]
//    readState <- map["readstate"]
//    recip_id <- map["recip_id"]
//    sender_id <- map["sender_id"]
//    sent_items <- map["sent_items"]
//    subject <- map["subject"]
//    firstname <- map ["firstname"]
//    profile_pic <- map["profile_pic"]
//
//  }
//
//
//}
struct ChatClients{
    //var email : String?
    var date: String?
    var friend: String?
    var id: String?
    var inbox: String?
    var is_Sender: String?
    var message: String?
    var pmsnotify: String?
    var readState: String?
    var recip_id: String?
    var sender_id: String?
    var sent_items: String?
    var subject: String?
    var firstName: String?
    var profile_pic: String?
    //var password: String?
    var client_id: String?
    var client_msg: String?
  enum CodingKeys: String, CodingKey {
    case date = "date"
    case friend = "friend"
    case id = "id"
    case inbox = "inbox"
    case is_sender = "is_sender"
    case message = "message"
    case pmsnotify = "pmsnotify"
    case readstate = "readstate"
    case recip_id = "recip_id"
    case sender_id = "sender_id"
    case sent_items = "sent_items"
    case subject = "subject"
    case firstname = "firstname"
    case profil_pic = "profil_pic"
    case client_id = "client_id"
    case client_msg = "client_msg"
  }
//  init()
//  {
//    self.date = ""
//    self.friend = ""
//    self.id = ""
//    self.inbox = ""
//    self.is_Sender = ""
//    self.message = ""
//    self.pmsnotify = ""
//    self.readState = ""
//    self.recip_id = ""
//    self.sender_id = ""
//    self.sent_items = ""
//    self.subject = ""
//    self.firstName = ""
//    self.profile_pic = ""
//    //var password: String?
//    self.client_id = ""
//    self.client_msg = ""
//  }
}

extension ChatClients: Decodable {
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    date = try values.decode(String.self, forKey: .date)
    friend = try values.decode(String.self, forKey: .friend)
    id =  try values.decode(String.self, forKey: .id)
    inbox = try values.decode(String.self, forKey: .inbox)
    is_Sender = try values.decode(String.self, forKey: .is_sender)
    message = try values.decode(String.self, forKey: .message)
    pmsnotify = try values.decode(String.self, forKey: .pmsnotify)
    readState = try values.decode(String.self, forKey: .readstate)
    recip_id = try values.decode(String.self, forKey: .recip_id)
    sender_id = try values.decode(String.self, forKey: .sender_id)
    sent_items = try values.decode(String.self, forKey: .sent_items)
    subject = try values.decode(String.self, forKey: .subject)
    firstName = try values.decodeIfPresent(String.self, forKey: .firstname) ?? ""
    profile_pic = try values.decodeIfPresent(String.self, forKey: .profil_pic) ?? ""
    client_id = try values.decodeIfPresent(String.self, forKey: .client_id) ?? ""
    client_msg = try values.decodeIfPresent(String.self, forKey: .client_msg) ?? ""
  }
}

extension ChatClients: Encodable{
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(date, forKey: .date)
    try container.encode(friend, forKey: .friend)
    try container.encode(id, forKey: .id)
    try container.encode(inbox, forKey: .inbox)
    try container.encode(is_Sender, forKey: .is_sender)
    try container.encode(message, forKey: .message)
    try container.encode(pmsnotify, forKey: .pmsnotify)
    try container.encode(readState, forKey: .readstate)
    try container.encode(recip_id, forKey: .recip_id)
    try container.encode(sender_id, forKey: .sender_id)
    try container.encode(sent_items, forKey: .sent_items)
    try container.encode(subject, forKey: .subject)
    try container.encode(firstName, forKey: .firstname)
    try container.encode(profile_pic, forKey: .profil_pic)
    try container.encode(client_id, forKey: .client_id)
    try container.encode(client_msg, forKey: .client_msg)
  }
}
/*
 struct Location: Codable {
 let latitude: CLLocationDegrees
 let longitude: CLLocationDegrees
 let altitude: CLLocationDistance
 let horizontalAccuracy: CLLocationAccuracy
 let verticalAccuracy: CLLocationAccuracy
 let speed: CLLocationSpeed
 let course: CLLocationDirection
 let timestamp: Date
 }
 extension CLLocation {
 convenience init(model: Location) {
 self.init(coordinate: CLLocationCoordinate2DMake(model.latitude, model.longitude), altitude: model.altitude, horizontalAccuracy: model.horizontalAccuracy, verticalAccuracy: model.verticalAccuracy, course: model.course, speed: model.speed, timestamp: model.timestamp)
 }
 }
 ///
 struct Person {
 let name: String
 let location: CLLocation
 enum CodingKeys: String, CodingKey {
 case name
 case location
 }
 }
 extension Person: Decodable {
 init(from decoder: Decoder) throws {
 let values = try decoder.container(keyedBy: CodingKeys.self)
 let name = try values.decode(String.self, forKey: .name)
 
 // Decode to `Location` struct, and then convert back to `CLLocation`.
 // It's very tricky
 let locationModel = try values.decode(Location.self, forKey: .location)
 location = CLLocation(model: locationModel)
 }
 }
 */
//extension ChatClients:Decodable {
//  enum CodingKeys: String, CodingKey {
//    case date
//    case friend
//    case id
//    case inbox
//    case is_Sender
//    case message
//    case pmnotify
//    case readState
//    case recip_id
//    case sender_id
//    case sent_items
//    case subject
//    case firstname
//    case profile_pic
//    case client_id
//    case client_msg
//  }
//  public func encode(to encoder: Encoder) throws {
//    var containter = encoder.container(keyedBy: CodingKeys.self)
//    var date = try containter.encode(ChatClients.self as! Encodable, forKey: .date)
//
//  }
//}
