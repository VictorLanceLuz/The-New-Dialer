//
//  CallHistoryViewController.swift
//  TheNewDialer
//
//  Created by vluz on 2019-11-15.
//  Copyright © 2019 Chaoqun Ding. All rights reserved.
//

import UIKit
import CoreData



class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // this "var context" is used to save using a different procedure.
    // Which was only used in this viewController->saveIntoCallHistory()
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var contacts = [Contact]()
    var contactArray:[Contact] = []
    var numberToCall = "null"
    var contactToCall = "null"

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var clearAllButton: UIBarButtonItem!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        // Main function does this first.
        super.viewDidLoad()

        clearAllButton.title = ""
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.fetchData()
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animation: Bool) {
        //print("I OPENED THE TAB")
        clearAllButton.title = "" // To hide the clearAll button
        
        // When we go leave and go back to tab, we want to not be in
        // the middle of editing entires. So reset to not editing mode
        self.tableView.isEditing = false
        editButton.title = (self.tableView.isEditing) ? "Done" : "Edit"
        clearAllButton.title = (self.tableView.isEditing) ? "Clear All" : ""
        clearAllButton.isEnabled = (self.tableView.isEditing) ? true : false
        
        // reload data everytime we enter the tab. Refresh button is used for calling
        // from within this view controller, HistoryViewController.
        self.fetchData()
        self.tableView.reloadData()
    }
    
    // IN PROGRESS: update the table after calling. Refresh
    // use to refresh the table
    @IBAction func refreshButtonTapped(_ sender: Any) {
        print ("Refreshing...")
        self.fetchData()
        self.tableView.reloadData()
    }
    
    // use to delete using button
    @IBAction func editButtonTapped(_ sender: UIBarButtonItem) {
        print ("Editing...")
        self.tableView.isEditing = !self.tableView.isEditing
        sender.title = (self.tableView.isEditing) ? "Done" : "Edit"
        clearAllButton.title = (self.tableView.isEditing) ? "Clear All" : ""
        clearAllButton.isEnabled = (self.tableView.isEditing) ? true : false
    }
    
    //remove all columns and data from CoreData database
    @IBAction func clearAllButtonTapped(_ sender: UIBarButtonItem) {
        print ("Clearing All...")
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Contact.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        let persistentContainer = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        do {
            try persistentContainer.viewContext.execute(deleteRequest)
        } catch let error as NSError {
            print(error)
        }
        contactArray.removeAll()
        self.tableView.reloadData()
    }
    
    // num of Cols
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // num of Rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactArray.count
    }
    
    // tableView function for calling number when tapping a row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        myIndex = indexPath.row
        let contact = contactArray[indexPath.row]
        //print(contact.contactName)
        contactToCall = String(contact.contactName!)
        let phoneNum = contact.number!
        numberToCall = phoneNum
        //let last10DigitsPhoneNum = phoneNum.suffix(10)
        let first3DigitsPhoneNum = phoneNum.prefix(3)
        let middle3DigitsPhoneNum = phoneNum.dropFirst(3).dropLast(4)
        let last4DigitsPhoneNum = phoneNum.suffix(4)
        let phoneNumWithHyphens = "\(first3DigitsPhoneNum)-\(middle3DigitsPhoneNum)-\(last4DigitsPhoneNum)"
        
        let url = URL(string: "tel://\(phoneNum)")!
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
            saveIntoCallHistory()
        }
        else {
            
            let alert = UIAlertController(title: "Invalid Phone Number", message: "Cannot make call to number \(phoneNumWithHyphens)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                NSLog("The \"OK\" alert occured.")}))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    // tableView function for displaying numbers and timeStamps + name if given
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryTableViewCell", for: indexPath) as! HistoryTableViewCell
        let contact = contactArray.reversed()[indexPath.row]
        //let name = contact.contactName
        let phoneNum = contact.number!
        //let last10DigitsPhoneNum = phoneNum.suffix(10)
        let first3DigitsPhoneNum = phoneNum.prefix(3)
        let middle3DigitsPhoneNum = phoneNum.dropFirst(3).dropLast(4)
        let last4DigitsPhoneNum = phoneNum.suffix(4)
        let phoneNumWithHyphens = "\(first3DigitsPhoneNum)-\(middle3DigitsPhoneNum)-\(last4DigitsPhoneNum)"
        
        cell.numberLabel.text = phoneNumWithHyphens
        cell.contactLabel.text = contact.contactName
        cell.timeLabel.text = contact.timeStamp
        
        if (contact.contactName != "null")
        {
            cell.contactLabel.isHidden = false
            cell.numberLabel.isHidden = true
            cell.contactLabel.text = contact.contactName
        }
        else
        {
            cell.numberLabel.isHidden = false
            cell.contactLabel.isHidden = true
            cell.numberLabel.text = phoneNumWithHyphens
        }
 
        return cell
    }
    
    // consider commenting this out if we don't want swiping action to delete rows.
    // tableView function for deleting rows using SWIPING IMPLEMENTATION
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        if editingStyle == .delete {
            let contact = contactArray[indexPath.row]
            context.delete(contact)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
            do {
                contactArray = try context.fetch(Contact.fetchRequest())
            }
            catch {
                print(error)
            }
        }
        tableView.reloadData()
    }
    
    // collect all data from database.
    func fetchData() {
        
        //fetching prepare
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        //try to fetch
        do {
            contactArray = try context.fetch(Contact.fetchRequest())
        }
        catch {
            print(error)
        }
        
    }
    
    // saving a call that happened inside the recents into the database.
    func saveIntoCallHistory() {
        // put time stamp
        let timeStamp = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short)
        //let contact = Contact(context: PersistenceService.context)
        let newContact = NSEntityDescription.insertNewObject(forEntityName: "Contact", into: context)
        newContact.setValue(numberToCall, forKey: "number")
        newContact.setValue(timeStamp, forKey: "timeStamp")
        newContact.setValue(contactToCall, forKey: "contactName")
        
        do {
            print("SAVING TO DATABASE FROM HISTORY VIEW")
            print(numberToCall)
            print(timeStamp)
            try context.save() // save the contact
        }
            
        catch{
            print (error)
        }
    }
    
}
