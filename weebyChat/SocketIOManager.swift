//
//  SocketIOManager.swift
//  weebyChat
//
//  Created by Nithin Reddy Gaddam on 5/13/16.
//  Copyright © 2016 Nithin Reddy Gaddam. All rights reserved.
//

import UIKit

class SocketIOManager: NSObject {

    //Singleton
    static let sharedInstance = SocketIOManager()
    
    var socket: SocketIOClient = SocketIOClient(socketURL: NSURL(string: "http://ec2-52-39-177-107.us-west-2.compute.amazonaws.com:7007")!)
    
    override init() {
        super.init()
    }
    
    func establishConnection() {
        socket.connect()
    }
    
    
    func closeConnection() {
        socket.disconnect()
    }
    
    func registerUser(username: String, completionHandler: (user: [String: AnyObject]!) -> Void) {
        socket.emit("registerUser", username)
        
        socket.on("successRegistering") { ( dataArray, ack) -> Void in
            completionHandler(user: dataArray[0] as! [String: AnyObject])
        }
        
        socket.on("userExists") { ( dataArray, ack) -> Void in
            completionHandler(user: dataArray[0] as! [String: AnyObject])
        }
    }
    
    func addChatRoom(user: [String: AnyObject], roomName: String, completionHandler: (room: [String: AnyObject]!) -> Void) {
        socket.emit("addChatRoom", user, roomName)
        
        socket.on("successAddingRoom") { ( dataArray, ack) -> Void in
            completionHandler(room: dataArray[0] as! [String: AnyObject])
        }
    }

    func getChatRooms(completionHandler: (chatRooms: [[String: AnyObject]]!) -> Void) {
        socket.emit("getChatRooms")
        
        socket.on("chatRooms") { ( dataArray, ack) -> Void in
            completionHandler(chatRooms: dataArray[0] as! [[String: AnyObject]])
        }
    }
    
    func sendMessage(user: [String: AnyObject], room: [String: AnyObject], message: String) {
        socket.emit("chatMessage", user, room, message)
    }
    
    func getChatMessage(completionHandler: (messageInfo: [String: AnyObject]) -> Void) {
        socket.on("newChatMessage") { (dataArray, socketAck) -> Void in
            var messageDictionary = [String: AnyObject]()
            messageDictionary["username"] = dataArray[0]["username"] as! String
            messageDictionary["message"] = dataArray[1] as! String
            messageDictionary["date"] = dataArray[2] as! String
            
            completionHandler(messageInfo: messageDictionary)
        }
    }
    
    func joinChatRoom(user: [String: AnyObject], room: [String: AnyObject], completionHandler: () -> Void) {
        socket.emit("connectUser", user, room)
        // notify if user joined or exited
        listenForOtherMessages()
    }
    
    //for user to exit chat upon request
    func exitChatRoom(user: [String: AnyObject], room: [String: AnyObject], completionHandler: () -> Void) {
        socket.emit("exitUser", user, room)
        completionHandler()
    }
    
    private func listenForOtherMessages() {
        // the server listens to new users joining
        socket.on("userConnectUpdate") { (dataArray, socketAck) -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName("userWasConnectedNotification", object: dataArray[0] as! [String: AnyObject])
        }
        // the servers listens to users exiting
        socket.on("userExitUpdate") { (dataArray, socketAck) -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName("userWasDisconnectedNotification", object: dataArray[0] as! [String: AnyObject])
        }
        
    }
    
}
