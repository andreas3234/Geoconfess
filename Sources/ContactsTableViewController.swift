//
//  ContactsTableViewController.swift
//  geoconfess
//
//  Created by Arman Manukyan on 3/17/16.
//  Copyright © 2016 Andrei Costache. All rights reserved.
//

import UIKit
import APAddressBook
import MessageUI

class ContactsTableViewController: UITableViewController, MFMessageComposeViewControllerDelegate, ContactTabelViewCellDelegate {

    var arrayContacts:NSMutableArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.tableView.registerNib(UINib(nibName: "ContactsTableViewCell", bundle: nil), forCellReuseIdentifier: "ContactsTableViewCell")
        self.tableView.separatorStyle = .None
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func setarrayContacts(_arrayContacts:NSArray) {
        arrayContacts.removeAllObjects()
        for i in 0 ..< _arrayContacts.count {
            let apContact:APContact = _arrayContacts.objectAtIndex(i) as! APContact
            if ((apContact.name!.firstName == nil && apContact.name!.lastName == nil) || apContact.phones == nil) {
                continue
            }
            arrayContacts.addObject(apContact)
        }
        self.tableView.reloadData()
    }
    func sendMessage(appContact: APContact) {
       
        let messageVC:MFMessageComposeViewController = MFMessageComposeViewController()
        
        if MFMessageComposeViewController.canSendText() {
            messageVC.body = "Je viens de découvrir Geoconfess, une application pour trouver facilement une confession ! Regarde : lien";
            messageVC.recipients = [appContact.phones![0].number!]
            messageVC.messageComposeDelegate = self
            self.presentViewController(messageVC, animated: false, completion: nil)
        }
    }
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    // MARK: - ContactTableViewCellDelegate
    func contactSelectUnselect(_appContact: APContact) {
        sendMessage(_appContact)
    }
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return arrayContacts.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let apContact:APContact = arrayContacts[indexPath.row] as! APContact
        var cell = tableView.dequeueReusableCellWithIdentifier("ContactsTableViewCell") as! ContactsTableViewCell!
        if cell == nil {

            cell = tableView.dequeueReusableCellWithIdentifier("ContactsTableViewCell", forIndexPath: indexPath) as! ContactsTableViewCell
        }
        cell.fillWithAPContact(apContact)
        cell.delegate = self
        cell.selectionStyle = .None
        return cell
    }
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let vw = UIView()
        vw.backgroundColor = UIColor.whiteColor()

        let buttonSend:UIButton = UIButton(frame: CGRectMake(10, 0, UIScreen.mainScreen().bounds.width - 10, 55))
        buttonSend.setTitle("Faites-les rejoindre GéoConfees", forState: UIControlState.Normal)
        buttonSend.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left;
        buttonSend.setTitleColor(UIColor(red: 241.0 / 255.0, green: 7.0 / 255.0, blue: 5.0 / 255.0, alpha: 1), forState: UIControlState.Normal)
        buttonSend.tag = 22;
        buttonSend.titleLabel!.numberOfLines = 1;
        buttonSend.titleLabel!.adjustsFontSizeToFitWidth = true;
        buttonSend.titleLabel!.lineBreakMode = NSLineBreakMode.ByClipping;
        vw.addSubview(buttonSend)
        return vw
    }
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 55.0
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
