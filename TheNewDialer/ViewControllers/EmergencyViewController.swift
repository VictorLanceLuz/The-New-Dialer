//
//  EmergencyViewController.swift
//  TheNewDialer
//
//  Created by Chaoqun Ding on 2019-10-25
//  Copyright © 2019 Chaoqun Ding. All rights reserved.
//
//


import UIKit
import os.log
import ContactsUI


class EmergencyViewController: UIViewController {
    
    var current_contact_change = 0;
    // added by vluz for call history
    var numberToCall = "null"
    var contactToCall = "null"
    var historyContacts = [Contact]()
    
    
    /* DispatchGroup object handle waiting and notification events */
    private let dg = DispatchGroup();
    
    /* Outlets used to reference button presses in the code */
    @IBOutlet weak var b1_outlet: UIButton!
    @IBOutlet weak var b2_outlet: UIButton!
    @IBOutlet weak var b3_outlet: UIButton!
    
    /*
     * This struct is used to store the saved or loaded contacts
     * in this particular instance
     */
    struct selected_contact {
        var this_name: String
        var this_num: String
    }
    
    /*
     * The sc object is initialized here and modified if the
     * user chooses a contact from their contact list
     */
    var sc = selected_contact(this_name: "noname", this_num: "nonum");
    
    /*
     * Store the saved or loaded contacts in this particular instance
     */
    var current_contact1 = selected_contact(this_name: "noname", this_num: "nonum");
    var current_contact2 = selected_contact(this_name: "noname", this_num: "nonum");
    var current_contact3 = selected_contact(this_name: "noname", this_num: "nonum");
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
         * Retrieve the three stored default contacts
         */
        if isKeyPresentInUserDefaults(key: "EC1_name"){
            current_contact1.this_name = UserDefaults.standard.string(forKey: "EC1_name")!
            current_contact1.this_num = UserDefaults.standard.string(forKey: "EC1_num")!
            self.b1_outlet.setTitle(current_contact1.this_name, for: .normal)
        }
        if isKeyPresentInUserDefaults(key: "EC2_name"){
            current_contact2.this_name = UserDefaults.standard.string(forKey: "EC2_name")!
            current_contact2.this_num = UserDefaults.standard.string(forKey: "EC2_num")!
            self.b2_outlet.setTitle(current_contact2.this_name, for: .normal)
            
        }
        if isKeyPresentInUserDefaults(key: "EC3_name"){
            current_contact3.this_name = UserDefaults.standard.string(forKey: "EC3_name")!
            current_contact3.this_num = UserDefaults.standard.string(forKey: "EC3_num")!
            self.b3_outlet.setTitle(current_contact3.this_name, for: .normal)
            
        }
        
        /*
         Enables long press recognition, sets duration and connects handlers for emergency contact buttons 1,2,3
         */
        let longButtonPress1 = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction1))
        longButtonPress1.minimumPressDuration = 1;
        b1_outlet.addGestureRecognizer(longButtonPress1)

        
        let longButtonPress2 = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction2))
        longButtonPress2.minimumPressDuration = 1;
        b2_outlet.addGestureRecognizer(longButtonPress2)
        
        let longButtonPress3 = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction3))
        longButtonPress3.minimumPressDuration = 1;
        b3_outlet.addGestureRecognizer(longButtonPress3)
        

    }
    
    


    
    @objc func longPressAction1(/*_ sender: Any*/){

        /* specify that emergency contact 1 is being changed */
        current_contact_change =  1;
        /* bring up contact selection screen */
        onClickPickContact()
    }
    
    @objc func longPressAction2(){
        /* specify that emergency contact 2 is being changed */
        current_contact_change = 2;
        onClickPickContact()

    }
    
    @objc func longPressAction3(){
        /* specify that emergency contact 3 is being changed */
        current_contact_change = 3;
        onClickPickContact()
       
    }
    
    /*
     * Precondition:
     * Postcondition: Emergency contact #1 is dialed when pressed
     */
    @IBAction func ecButton1(_ sender: UIButton) {
        current_contact_change = 0;
        /* Check if a default contact exists */
        if strcmp(current_contact1.this_name, "noname") == 0{
            
            /*
             * We need a DispatchGroup object here because a serperate thread
             * lets the user pick a contact from their own contact list.
             * This prevents a race condition where the main thread always wins
             * and therefore 'noname' as the name on the button
             */
            
            dg.enter();
            
            /* start contact list selection */
            onClickPickContact()
            /* wait until contact list selection is completed before continuing */
            dg.notify(queue:.main){
                /* save sc values as default contacts */
                self.b1_outlet.setTitle(self.sc.this_name, for: .normal)
                self.current_contact1.this_num = self.sc.this_num;
                self.current_contact1.this_name = self.sc.this_name;
                UserDefaults.standard.set(self.sc.this_name, forKey: "EC1_name") //setObject
                UserDefaults.standard.set(self.sc.this_num, forKey: "EC1_num") //setObject
                
                
                
                /* reset sc values */
                self.sc.this_name = "noname"
                self.sc.this_num = "nonum"
            }
            
        }
        else{
            //Testing by vluz
            contactToCall = self.current_contact1.this_name
            //End of testing by vluz
            
            /* A contact exists, therefore we make a call to the saved number */
            var phone_number_digits = self.current_contact1.this_num
            /* parse the number to include only digits */
            phone_number_digits = phone_number_digits.filter("0123456789".contains)
            numberToCall = phone_number_digits
            let url = URL(string: "tel://\(phone_number_digits)")!
            /* Check if call can be made */
            if UIApplication.shared.canOpenURL(url){
                /* Make the call */
                UIApplication.shared.open(url)
                saveIntoCallHistory()
            }
            else{
                /*  Give an error message */
                let alert = UIAlertController(title: "Invalid Phone Number", message: "Cannot make call to number \(phone_number_digits)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                    NSLog("The \"OK\" alert occured.")
                }))
                self.present(alert, animated: true, completion: nil)
            }

        }

        
    }
    
    
    /*
     * Precondition:
     * Postcondition: Emergency contact #2 is dialed when pressed
     */
    @IBAction func ecButton2(_ sender: Any) {
        current_contact_change = 0;
        if strcmp(current_contact2.this_name, "noname") == 0{
            
            dg.enter(); //to handle concurrency
            onClickPickContact()
            dg.notify(queue:.main){
                self.b2_outlet.setTitle(self.sc.this_name, for: .normal)
                
                self.current_contact2.this_num = self.sc.this_num;
                self.current_contact2.this_name = self.sc.this_name;
                
                UserDefaults.standard.set(self.sc.this_name, forKey: "EC2_name") //setObject
                UserDefaults.standard.set(self.sc.this_num, forKey: "EC2_num") //setObject
                
                //reset values
                self.sc.this_name = "noname"
                self.sc.this_num = "nonum"
                
            }
            
        }
        else{
            //Testing by vluz
            contactToCall = self.current_contact2.this_name
            //End of testing by vluz
            
            var phone_number_digits = self.current_contact2.this_num
            phone_number_digits = phone_number_digits.filter("0123456789".contains)
            numberToCall = phone_number_digits
            let url = URL(string: "tel://\(phone_number_digits)")!
            if UIApplication.shared.canOpenURL(url){
                UIApplication.shared.open(url)
                saveIntoCallHistory()
            }
            else{
                let alert = UIAlertController(title: "Invalid Phone Number", message: "Cannot make call to number \(phone_number_digits)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                    NSLog("The \"OK\" alert occured.")
                }))
                self.present(alert, animated: true, completion: nil)
            }
            
        }
        
    }
    
    
    /*
     * Precondition:
     * Postcondition: Emergency contact 3 is dialed when pressed
     */
    @IBAction func ecButton3(_ sender: Any) {
        current_contact_change = 0;
        if strcmp(current_contact3.this_name, "noname") == 0{
            
            dg.enter(); //to handle concurrency
            onClickPickContact()
            dg.notify(queue:.main){
                self.b3_outlet.setTitle(self.sc.this_name, for: .normal)
                
                self.current_contact3.this_num = self.sc.this_num;
                self.current_contact3.this_name = self.sc.this_name;
                
                UserDefaults.standard.set(self.sc.this_name, forKey: "EC3_name") //setObject
                UserDefaults.standard.set(self.sc.this_num, forKey: "EC3_num") //setObject
                
                //reset values
                self.sc.this_name = "noname"
                self.sc.this_num = "nonum"
                
            }
            
        }
        else{
            //Testing by vluz
            contactToCall = self.current_contact3.this_name
            //End of testing by vluz
            
            var phone_number_digits = self.current_contact3.this_num
            phone_number_digits = phone_number_digits.filter("0123456789".contains)
            numberToCall = phone_number_digits
            let url = URL(string: "tel://\(phone_number_digits)")!
            if UIApplication.shared.canOpenURL(url){
                UIApplication.shared.open(url)
                saveIntoCallHistory()
            }
            else{
                let alert = UIAlertController(title: "Invalid Phone Number", message: "Cannot make call to number \(phone_number_digits)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                    NSLog("The \"OK\" alert occured.")
                }))
                self.present(alert, animated: true, completion: nil)
            }            
        }
        
        
    }
    /*
     * Precondition:
     * Postcondition: 911 is dialed
     */
    @IBAction func call_911(_ sender: Any) {
        current_contact_change = 0;
        let url = URL(string: "tel://911")!
        
        if UIApplication.shared.canOpenURL(url){
            UIApplication.shared.open(url)
            // Note that we are not going to save the 911 call to the database.
        }
        else{
            let alert = UIAlertController(title: "Invalid Phone Number", message: "Cannot make call to number 911", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                NSLog("The \"OK\" alert occured.")
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    
    
    
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
    
    func saveIntoCallHistory() {
        let contact = Contact(context: PersistenceService.context)
        // put time stamp
        let timeStamp = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short)
        contact.number = String(numberToCall) // assigning number
        contact.timeStamp = String(timeStamp) // assigning time stamp
        contact.contactName = contactToCall
        print (numberToCall)
        print (timeStamp)
        print (contactToCall)
        PersistenceService.saveContext() // Save everything that was assigned.
        self.historyContacts.append(contact) // add new contact object
    }
    
    
}



extension EmergencyViewController: CNContactPickerDelegate {
    
    /*
     * Precondition: No default emergency contacts saved
     * Postcondition: Emergency contact chosen from contact list and saved
     */
    func onClickPickContact(){
        let contactPicker = CNContactPickerViewController()
        contactPicker.delegate = self
        contactPicker.displayedPropertyKeys =
            [CNContactGivenNameKey
                , CNContactPhoneNumbersKey]
        self.present(contactPicker, animated: true, completion: nil)
        
    }
    
    func contactPicker(_ picker: CNContactPickerViewController,
                       didSelect contactProperty: CNContactProperty) {
        
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        
        let userName:String = contact.givenName
        let userPhoneNumbers:[CNLabeledValue<CNPhoneNumber>] = contact.phoneNumbers
        let firstPhoneNumber:CNPhoneNumber = userPhoneNumbers[0].value
        let primaryPhoneNumber:String = firstPhoneNumber.stringValue
        
        sc.this_name = userName
        sc.this_num = primaryPhoneNumber
        
        /* Notify that contact selection is complete */
        
        
        /* save sc values as default contacts */
        if (current_contact_change==1){
            self.b1_outlet.setTitle(self.sc.this_name, for: .normal)
            self.current_contact1.this_num = self.sc.this_num;
            self.current_contact1.this_name = self.sc.this_name;
            UserDefaults.standard.set(self.sc.this_name, forKey: "EC1_name") //setObject
            UserDefaults.standard.set(self.sc.this_num, forKey: "EC1_num") //setObject
        }
        else if (current_contact_change==2){
            self.b2_outlet.setTitle(self.sc.this_name, for: .normal)
            self.current_contact2.this_num = self.sc.this_num;
            self.current_contact2.this_name = self.sc.this_name;
            UserDefaults.standard.set(self.sc.this_name, forKey: "EC2_name") //setObject
            UserDefaults.standard.set(self.sc.this_num, forKey: "EC2_num") //setObject
        }
        else if (current_contact_change==3){
            self.b3_outlet.setTitle(self.sc.this_name, for: .normal)
            self.current_contact3.this_num = self.sc.this_num;
            self.current_contact3.this_name = self.sc.this_name;
            UserDefaults.standard.set(self.sc.this_name, forKey: "EC3_name") //setObject
            UserDefaults.standard.set(self.sc.this_num, forKey: "EC3_num") //setObject
        }
        else{
            dg.leave()

        }

        
        current_contact_change = 0;
        
        
    }
    
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        
    }
}
