//
//  UsersViewController.swift
//  weebyChat
//
//  Created by Nithin Reddy Gaddam on 5/13/16.
//  Copyright © 2016 Nithin Reddy Gaddam. All rights reserved.
//

import UIKit

var users = [String]()

class UsersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    @IBOutlet weak var tblUserList: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        users = (room["users"] as? [String])!
        print(users)
        
        tblUserList.reloadData()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tblUserList.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.tblUserList.reloadData()
        
    }
    
    //to initialise the UI properly
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.tblUserList.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.tblUserList.reloadData()
    }
    
    //To dismiss keyboard
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            if identifier == "idSegueJoinChat" {
                SocketIOManager.sharedInstance.joinChatRoom(user, room: room) { () -> Void in
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                    })
                }
            }
        }
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    //displays user's information
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.tblUserList.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        
        cell.textLabel?.text = users[indexPath.row]
        return cell
    }
    


    
      
    
}