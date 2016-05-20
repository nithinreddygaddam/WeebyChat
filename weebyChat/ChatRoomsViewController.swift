//
//  ChatRoomsViewController.swift
//  weebyChat
//
//  Created by Nithin Reddy Gaddam on 5/19/16.
//  Copyright © 2016 Nithin Reddy Gaddam. All rights reserved.
//

import UIKit

//global variables

var user = [String: AnyObject]()

var room = [String: AnyObject]()

var rooms = [[String: AnyObject]]()

var message = " "

class ChatRoomsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var LblWelcomeBanner: UILabel!
    @IBOutlet weak var tblRoomList: UITableView!

    override func viewDidLoad() {
    
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    
    //To dismiss keyboard
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    //to initialise the UI properly
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if user["username"] == nil {
            askForUsername("Welcome to Weeby Chat")
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.LblWelcomeBanner.text = message
        self.tblRoomList.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.tblRoomList.reloadData()

    }
    
    @IBAction func addChatRoom(sender: AnyObject) {
        addRoom()
    }
    
    @IBAction func logout(sender: AnyObject) {
        user = [:]
        askForUsername("Welcome to Weeby Chat")
    }
    
    func addRoom() {
        let alertController = UIAlertController(title: "Add Chat Room", message: "Room Name? ", preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addTextFieldWithConfigurationHandler(nil)
        
        //checks if the user entered a chat room name or not
        let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (action) -> Void in
            let textfield = alertController.textFields![0]
            if textfield.text?.characters.count == 0 {
                self.addRoom()
            }
            else {
                SocketIOManager.sharedInstance.addChatRoom(user, roomName: textfield.text!,  completionHandler: { (room) -> Void in
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        if room != nil {
                            rooms.append(room)
                            self.tblRoomList.reloadData()
                        }
                    })
                })
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) {
            UIAlertAction in
            NSLog("Cancel Pressed")
        }
        
        alertController.addAction(OKAction)
        alertController.addAction(cancelAction)

        presentViewController(alertController, animated: true, completion: nil)
    }

    
    @IBOutlet weak var lblBanner: UILabel!
    
    func askForUsername(label: String) {
        let alertController = UIAlertController(title: label, message: "Login Name? ", preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addTextFieldWithConfigurationHandler(nil)
        
        //checks if the user entered an username or not
        let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (action) -> Void in
            let textfield = alertController.textFields![0]
            if textfield.text?.characters.count == 0 {
                self.askForUsername("No Login name entered")
            }
            else {
                
                SocketIOManager.sharedInstance.registerUser(textfield.text!, completionHandler: { (registeredUser) -> Void in
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        let flag = registeredUser["_id"] as! String
                        if flag == "error"{
                            self.askForUsername("Login name already exists")
                        }
                        else{
                            user = registeredUser
                            message = (user["username"] as? String)!
                            message = "Welcome: " + message
                            self.LblWelcomeBanner.text = message
                        
                            SocketIOManager.sharedInstance.getChatRooms( { (chatRooms) -> Void in
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    if chatRooms != nil {
                                        rooms = chatRooms
                                        print(rooms)
                                        self.tblRoomList.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
                                        self.tblRoomList.reloadData()
                                    }
                                })
                            })
                        }
                    })
                })
                
            }
        }
        
        alertController.addAction(OKAction)
        presentViewController(alertController, animated: true, completion: nil)
    }

    
    // MARK: UITableView Delegate and Datasource methods
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms.count
    }
    
    //displays user's information
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.tblRoomList.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        
        cell.textLabel?.text = rooms[indexPath.row]["roomName"] as? String
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        room = rooms[indexPath.row]
        self.performSegueWithIdentifier("idSegueJoinRoom", sender: nil)
        
    }

}
