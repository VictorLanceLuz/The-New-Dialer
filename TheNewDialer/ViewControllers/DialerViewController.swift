//
//  DialerViewController.swift
//  TheNewDialer
//
//  Created by Chaoqun Ding on 2019-10-25.
//  Copyright © 2019 Chaoqun Ding. All rights reserved.
//

import UIKit
import Contacts
import CoreData

class DialerViewController: UIViewController {

    @IBOutlet weak var similarContactsTableView: UITableView!
    @IBOutlet weak var dialerButton: UIButton!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var digitInputTextField: UITextField!
    @IBOutlet weak var speedIndicatorLabel: UILabel!
    @IBOutlet weak var dialerInsideButton: UIButton!
    @IBOutlet weak var eraseLastDigitButton: UIButton!
    var contacts = [Contact]()
    var Contacts = [CNContact]() // all contacts
    var filteredContacts: [CNContact] = [] // contacts with phone number that matches digits input text field
    var timer = Timer() // for digit increment automatically
    var numberToCall = "null"
    var contactToCall = "null"
    var longgesture = UILongPressGestureRecognizer()
    var maxTimeInterval = 1.0 // valid digit increment speed is set to 0.1s ~ 1s
    var minTimeInterval = 0.1
    var currentTimeInterval = 0.5
    let searchController = UISearchController(searchResultsController: nil) // method for filtering similar contacts
    
    override func viewDidLoad() {
        speedIndicatorLabel.text = String(currentTimeInterval)
        digitInputTextField.isUserInteractionEnabled = false // show digits only but now using systyem keyboard to type in
        dismissKeyboard()
        callButton.isHidden = true // initially show dialer button instead of call button
        callButton.isUserInteractionEnabled = false
        dialerButton.isHidden = false
        dialerButton.isUserInteractionEnabled = false
        dialerInsideButton.isHidden = false
        dialerInsideButton.isUserInteractionEnabled = true
        if let dialerImage = UIImage(named: "dialerImage") { // initially show dialer image with no highlights
            dialerButton.setImage(dialerImage, for: .normal)
        }
        dialerInsideButton.addTarget(self, action: #selector(runTimer), for: .touchDown) // when dialer button is pressed down, start timer and start digit increment
        dialerInsideButton.addTarget(self, action: #selector(stopIncrement), for: .touchUpInside) // stop digit increment and stop timer no matter if the dialer button has been touched up inside or outside
        dialerInsideButton.addTarget(self, action: #selector(stopIncrement), for: .touchUpOutside)
        super.viewDidLoad()
        
        longgesture = UILongPressGestureRecognizer(target: self, action: #selector(self.longPressDetect))
        longgesture.minimumPressDuration = 1 // minimum time needed for catching a long press
        callButton.addGestureRecognizer(longgesture) // catch long press on call button

        let ContactStore = CNContactStore()
        let authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
        if authorizationStatus == .notDetermined { // if user authorization for the app for accessing system contacts if not determined, pop up the access request
            ContactStore.requestAccess(for: .contacts) { [weak self] didAuthorize, error in
                if didAuthorize {
                    self?.retrieveContacts(from: ContactStore)
                }
            }
        } else if authorizationStatus == .authorized { // if authorized, import all system contacts to the app
            retrieveContacts(from: ContactStore)
        }
        
        searchController.searchResultsUpdater = self // calls the extension func updateSearchResults
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController.searchBar.isHidden = true // always hide the search bar
        searchController.searchBar.isUserInteractionEnabled = false // digit input for search bar should all from digit input text field, so disable the search bar user interaction
        navigationItem.hidesSearchBarWhenScrolling = false // make search bar invisible when scrolling down
      
    }
    
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    var isFiltering: Bool { // if search bar is not empty
        return !isSearchBarEmpty
    }
    var lastDigit = 0 // DON'T CHANGE THIS VALUE, WILL CAUSE PROBLEMS, ASK CANDICE IF NEEDED
    // default digit when user press and hold the dialer button for less than one period of time interval
    var dialerButtonReleasedTime = 0
    
    func retrieveContacts(from ContactStore: CNContactStore) { // fetch all system contacts to the app
        let containerId = ContactStore.defaultContainerIdentifier()
        let predicate = CNContact.predicateForContactsInContainer(withIdentifier: containerId)
        let keysToFetch = [CNContactGivenNameKey as CNKeyDescriptor, CNContactFamilyNameKey as CNKeyDescriptor, CNContactImageDataAvailableKey as
            CNKeyDescriptor, CNContactImageDataKey as CNKeyDescriptor, CNContactPhoneNumbersKey as CNKeyDescriptor]
        Contacts = try! ContactStore.unifiedContacts(matching: predicate, keysToFetch: keysToFetch)
        DispatchQueue.main.async { [weak self] in // keep contacts up to date
            self?.similarContactsTableView.reloadData()
        }
        print(Contacts)
    }
    
    func filterContentForSearchText(_ searchText: String) { // filter contacts with phone number that match current digits in the digit input text field, and save information of filtered contacts to filteredContacts
        filteredContacts = Contacts.filter({ (contact: CNContact) -> Bool in
            let last10digits = ((contact.phoneNumbers[0].value).value(forKey: "digits") as! String).suffix(10)
            return last10digits.contains(String(searchText))
        })
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        myIndex = indexPath.row
        let Contact = filteredContacts[indexPath.row] // all filtered contacts in rows
        let phone_number = Contact.phoneNumbers[0].value.stringValue;
        //call is only made to first number for this contact
        let phone_number_digits = phone_number.digits;
        print(phone_number_digits);
        digitInputTextField.text = phone_number_digits // there are 10 digits in text field by selected the similar contact
        dialerButton.isHidden = true // hide dialer button, disable the dialer button's user interaction, show call button, enable call button user interaction when digit in text field reaches 10
        dialerButton.isUserInteractionEnabled = false
        dialerInsideButton.isHidden = true
        dialerInsideButton.isUserInteractionEnabled = false
        callButton.isHidden = false
        callButton.isUserInteractionEnabled = true
        dialerButtonReleasedTime = 10
        
        //used to assign numberToCall preparing for saving to database - vluz
        numberToCall = phone_number_digits
    }

    // MARK: HELPER FUNCTIONS
    
    func removeLastDigitInTextField() { // remove last digit in the text field
        var currentString = digitInputTextField.text
        let currentLengthOfDigits = currentString?.count
        if currentLengthOfDigits != 0 {
            let newString = String((currentString?.prefix(currentLengthOfDigits!-1))!)
            digitInputTextField.text = newString
            searchController.searchBar.text = digitInputTextField.text
            similarContactsTableView.reloadData() // refresh similar contacts when searching digits have been modified
            dialerButtonReleasedTime -= 1 //
        }
        currentString = digitInputTextField.text
        let lengthOfCurrentString = currentString?.count
        if lengthOfCurrentString != 10 { // when digits not reach 10, show and enable user interaction of dialer button, hide and disable user interaction of call button
            dialerButton.isHidden = false
            dialerButton.isUserInteractionEnabled = false
            dialerInsideButton.isHidden = false
            dialerInsideButton.isUserInteractionEnabled = true
            callButton.isHidden = true
            callButton.isUserInteractionEnabled = false
        }
        print (dialerButtonReleasedTime)
        
    }
    
    func dismissKeyboard() { // hide system keyboard
        self.view.endEditing(false)
    }
    
    @objc func longPressDetect(_ sender: UILongPressGestureRecognizer) { // when long press of call button has been detacted, make a system call
        if (sender.state == .ended) {
        // fixes bug where this func calls twice because there is .start and .end
        longgesture.isEnabled = false;
        dismissKeyboard()
        makePhoneCall()
        
        }
    }
    
    @objc func lastDigitIncrement() { // increment last digit and transfer dialer button image with corresponding last digit highlights in respect
        if lastDigit == 9 {
            lastDigit = 0
        } else {
            lastDigit += 1
        }
        // print(lastDigit)
        
        if let dialerImageX = UIImage(named: "dialerImage\(lastDigit)") {
            dialerButton.setImage(dialerImageX, for: .normal)
        }
        
    }
    
    // This function will save phone numbers that was called into CoreData Database.
    // Still work in progress.
    func saveIntoCallHistory() {
        let contact = Contact(context: PersistenceService.context)
        // put time stamp
        let timeStamp = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short)
        contact.number = String(numberToCall) // assigning number
        contact.timeStamp = String(timeStamp) // assigning time stamp
        contact.contactName = contactToCall
        print (numberToCall)
        print (timeStamp)
        PersistenceService.saveContext() // Save everything that was assigned.
        self.contacts.append(contact) // add new contact object
    }
    
    @objc func makePhoneCall() { // system phone call logic
        print("called me")
        //saveIntoCallHistory() // this is commented out so it only works for non-simulator.
        longgesture.isEnabled = true;
        if let url = URL(string: "tel://\(numberToCall)"),
            UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:], completionHandler:nil)

            }
            else {
                UIApplication.shared.openURL(url)
            }
            saveIntoCallHistory() // added here so that only calls that are successful saves.

        }
        else {
            //error
        }
    }
    
    @objc func stopIncrement() { // when dialer button released, stop digit increment and set dialer image to default dialer image where there is no highlight of any digit
        // print("stop increment")
        timer.invalidate()
        dialerButtonReleasedTime += 1
        print(dialerButtonReleasedTime)
        if digitInputTextField.text?.count == dialerButtonReleasedTime - 1 {
            digitInputTextField.text = (String(digitInputTextField.text! + String(lastDigit)))
            searchController.searchBar.text = digitInputTextField.text
            similarContactsTableView.reloadData()
        }
    
        if let dialerImage = UIImage(named: "dialerImage") {
            dialerButton.setImage(dialerImage, for: .normal)
        }

        let currentString = digitInputTextField.text
        let lengthOfCurrentString = currentString?.count
        if lengthOfCurrentString == 10 { // when there are 10 digits in digit input text field, transfer dialer button to call button
            dialerButton.isHidden = true
            dialerButton.isUserInteractionEnabled = false
            dialerInsideButton.isHidden = true
            dialerInsideButton.isUserInteractionEnabled = false
            callButton.isHidden = false
            callButton.isUserInteractionEnabled = true
            numberToCall = currentString!

        }
    }
   
    @objc func runTimer() { // start timer
        lastDigit = 0
        timer = Timer.scheduledTimer(timeInterval: currentTimeInterval, target: self, selector: (#selector(self.lastDigitIncrement)), userInfo: nil, repeats: true)
    }

    
    // MARK: IBActions

    @IBAction func eraseLastDigitButtonTapped(_ sender: Any) { // when tapped on erase last digit button which is invisible and covers the text field, erase last digit in text field
        removeLastDigitInTextField()
    }
    
    @IBAction func increaseButtonTapped(_ sender: Any) { // increase time interval to slow down digit increment
        if currentTimeInterval == maxTimeInterval {
            currentTimeInterval = maxTimeInterval
        }
        else {
            currentTimeInterval += 0.1
        }
        currentTimeInterval = Double(round(100*currentTimeInterval)/100) // make sure the format for time interval is 0.x
        speedIndicatorLabel.text = String(currentTimeInterval)
    }
    
    @IBAction func decreaseButtonTapped(_ sender: Any) { // decrease time interval to fasten digit increment
        if currentTimeInterval == minTimeInterval {
            currentTimeInterval = minTimeInterval
        }
        else {
            currentTimeInterval -= 0.1
        }
        currentTimeInterval = Double(round(100*currentTimeInterval)/100)
        speedIndicatorLabel.text = String(currentTimeInterval)
    }
}

// MARK: EXTENSIONS
extension DialerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredContacts.count
        }
        return 0 // when there is no digit in text field, show 0 contacts
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50 // cell height for similar contact table view cell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let similarContactCell = tableView.dequeueReusableCell(withIdentifier: "SimilarContactTableViewCell", for: indexPath) as! SimilarContactTableViewCell
        let Contact = filteredContacts[indexPath.row]
        let last10DigitsPhoneNumber = ((Contact.phoneNumbers[0].value ).value(forKey: "digits") as! String).suffix(10) // 10 digit of filtered similar contact phone number in string
        let phoneNumberFirst3digits = last10DigitsPhoneNumber.prefix(3)
        let phoneNumberLast4digits = last10DigitsPhoneNumber.suffix(4)
        let phoneNumberMiddle3digits = last10DigitsPhoneNumber.dropFirst(3).dropLast(4)
        similarContactCell.fullNameLabel.text = "\(Contact.givenName) \(Contact.familyName)"
        similarContactCell.phoneNumberLabel.text = "\(phoneNumberFirst3digits)-\(phoneNumberMiddle3digits)-\(phoneNumberLast4digits)"
        
        if Contact.imageDataAvailable == true, let imageData = Contact.imageData {
            similarContactCell.avatarImageView.image = UIImage(data: imageData)
        }
        return similarContactCell
    }
    
}
extension DialerViewController: UITableViewDelegate { // since there is a table view in dialer page, should make dialer view controller confirm uitableviewdelegate protocal to make the table view work in dialer page
}

extension DialerViewController: UISearchResultsUpdating { // update the filtered contacts
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchBar.text!)
    }
}
