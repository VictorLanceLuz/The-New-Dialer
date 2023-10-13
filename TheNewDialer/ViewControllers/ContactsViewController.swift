//
//  ViewController.swift
//  TheNewDialer
//
//  Created by Chaoqun Ding on 2019-10-25.
//  Copyright © 2019 Chaoqun Ding. All rights reserved.
//


// this page is similar as in dialer page, check dialer page for more details
import UIKit
import Contacts
var myIndex = 0

class ContactsViewController: UIViewController{
    @IBOutlet weak var contactsTableView: UITableView!
    
    // added by vluz for call history
    var numberToCall = "null"
    var contactToCall = "null"
    var historyContacts = [Contact]()
    // end of addition
    
    var contacts = [CNContact]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Contacts"
        let store = CNContactStore()
        let authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
        if authorizationStatus == .notDetermined {
            store.requestAccess(for: .contacts) { [weak self] didAuthorize, error in
                if didAuthorize {
                    self?.retrieveContacts(from: store)
                }
            }
        } else if authorizationStatus == .authorized {
            retrieveContacts(from: store)
        }
      }
    
    func retrieveContacts(from store: CNContactStore) {
        let containerId = store.defaultContainerIdentifier()
        let predicate = CNContact.predicateForContactsInContainer(withIdentifier: containerId)
        let keysToFetch = [CNContactGivenNameKey as CNKeyDescriptor, CNContactFamilyNameKey as CNKeyDescriptor, CNContactImageDataAvailableKey as
                           CNKeyDescriptor, CNContactImageDataKey as CNKeyDescriptor, CNContactPhoneNumbersKey as CNKeyDescriptor]

        contacts = try! store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch)
        DispatchQueue.main.async { [weak self] in // keep contacts up to date
          self?.contactsTableView.reloadData()
        }
    }
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        myIndex = indexPath.row
        let contact = contacts[indexPath.row]
        contactToCall = "\(contact.givenName) \(contact.familyName)"
        print("\(contact.givenName) \(contact.familyName)")
        let phone_number = contact.phoneNumbers[0].value.stringValue;
        let phone_number_digits = phone_number.digits;
        print(phone_number_digits);
        numberToCall = String(phone_number_digits)
        
        let url = URL(string: "tel://\(phone_number_digits)")!
        
        if UIApplication.shared.canOpenURL(url){
            UIApplication.shared.open(url)
            saveIntoCallHistory() // used to save to database
        }
        else{
            let alert = UIAlertController(title: "Invalid Phone Number", message: "Cannot make call to number \(phone_number)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                NSLog("The \"OK\" alert occured.")
            }))
            self.present(alert, animated: true, completion: nil)
        }
        // DELETE THIS LATER
        saveIntoCallHistory() // used for testing in simulator
    }
    
    // used to save to database -vluz
    func saveIntoCallHistory() {
        let contact = Contact(context: PersistenceService.context)
        // put time stamp
        let timeStamp = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short)
        contact.number = String(numberToCall) // assigning number
        contact.timeStamp = String(timeStamp) // assigning time stamp
        contact.contactName = contactToCall // assigning the name of the contact.
        print (numberToCall)
        print (timeStamp)
        PersistenceService.saveContext() // Save everything that was assigned.
        self.historyContacts.append(contact) // add new contact object
    }
}

extension ContactsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactTableViewCell") as! ContactTableViewCell
        let contact = contacts[indexPath.row]
        cell.fullNameLabel.text = "\(contact.givenName) \(contact.familyName)"
        let phoneNumber = (contact.phoneNumbers[0].value ).value(forKey: "digits") as! String
        let last10DigitsPhoneNumber = phoneNumber.suffix(10)
        let phoneNumberFirst3digits = last10DigitsPhoneNumber.prefix(3)
        let phoneNumberLast4digits = last10DigitsPhoneNumber.suffix(4)
        let phoneNumberMiddle3digits = last10DigitsPhoneNumber.dropFirst(3).dropLast(4)

        cell.phoneNumberLabel.text = "\(phoneNumberFirst3digits)-\(phoneNumberMiddle3digits)-\(phoneNumberLast4digits)"

        if contact.imageDataAvailable == true, let imageData = contact.imageData {
            cell.avatarImageView.image = UIImage(data: imageData)
        }
        return cell
    }
}
extension ContactsViewController: UITableViewDelegate {

}

extension String {
    var digits: String {
        return components(separatedBy: CharacterSet.decimalDigits.inverted)
            .joined()
    }
}

