//
//  ViewController.swift
//  My Contacts
//
//  Created by Mashqur Habib on 11/15/17.
//  Copyright © 2017 Himel's App. All rights reserved.
//

import UIKit
import  CoreData
import MessageUI

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMessageComposeViewControllerDelegate {

    @IBOutlet weak var contactListTable: UITableView!
    var context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    var contacts : [Contacts] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        contactListTable.delegate = self
        contactListTable.dataSource = self
        fetchContacts()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = contactListTable.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ContactCell
        cell.name.text = contacts[indexPath.row].name
        cell.number.text = contacts[indexPath.row].number
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .normal, title: "Delete", handler: { action, index in
            self.deleteMessageAlert(indexPath: self.contacts[indexPath.row])
        })
        delete.backgroundColor = UIColor.gray
        return [delete]
    }
    
    // MARK: Table view row selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let callMessageAlert = UIAlertController(title: "Choose", message: "", preferredStyle: .alert)
        let actionCall = UIAlertAction(title: "CALL", style: .default, handler: { (ACTION) -> Void in
            let call = self.contacts[indexPath.row].number
            UIApplication.shared.open(NSURL(string: "tel://\(String(describing: call!))")! as URL, options: [:], completionHandler: nil)
            self.contactListTable.reloadData()
        })
        
        let actionMessage = UIAlertAction(title: "MESSAGE", style: .default, handler: { (ACTION) -> Void in
            if (!MFMessageComposeViewController.canSendText()) {
                print("Message not Available")
            }else{
                let messageVC = MFMessageComposeViewController()
                messageVC.messageComposeDelegate = self
                messageVC.recipients = [self.contacts[indexPath.row].number!]
                self.present(messageVC, animated: true, completion: nil)
            }
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .default, handler: { (ACTION) -> Void in self.contactListTable.reloadData()})
        
        callMessageAlert.addAction(actionCall)
        callMessageAlert.addAction(actionMessage)
        callMessageAlert.addAction(cancel)
        present(callMessageAlert, animated: true, completion: nil)
    }
    func messageComposeViewController(_ controller: MFMessageComposeViewController,
                                      didFinishWith result: MessageComposeResult) {
        self.contactListTable.reloadData()
        controller.dismiss(animated: true, completion: nil)
    }
    // MARK: ADD NEW CONTACT
    @IBAction func addContact(_ sender: UIButton) {
        
        let addContactAlert = UIAlertController(title: "New Contact", message: "Write Name and Number", preferredStyle: .alert)
        addContactAlert.addTextField { (name: UITextField) in
            name.placeholder = "Name"
            name.resignFirstResponder()
        }
        addContactAlert.addTextField { (number: UITextField) in
            number.placeholder = "Number"
            number.keyboardType = UIKeyboardType.phonePad
        }
        addContactAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        addContactAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {ACTION in
            let nameField = addContactAlert.textFields?.first
            let numberField = addContactAlert.textFields?.last
            let newContact = NSEntityDescription.insertNewObject(forEntityName: "Contacts", into: self.context!)
            newContact.setValue(nameField?.text, forKey: "name")
            newContact.setValue(numberField?.text, forKey: "number")
            do{
                try self.context?.save()
                self.fetchContacts()
            }catch{
                print(error)
            }
            
        }))
        present(addContactAlert, animated: true, completion: nil)
    }
    
    func fetchContacts(){
        do{
            contacts = try self.context!.fetch(Contacts.fetchRequest())
            self.contactListTable.reloadData()
        }
        catch{
            print(error)
        }
    }
    //MARK: DELETE ALERT
    func deleteMessageAlert(indexPath: Any){
        let messageAlert = UIAlertController(title: "Delete?", message: "Do you want to delete", preferredStyle: .alert)
        messageAlert.addAction(UIAlertAction(title: "NO", style: .default, handler: nil))
        messageAlert.addAction(UIAlertAction(title: "YES", style: .default, handler: {ACTION in self.performDelte(indexPath: indexPath)}))
        present(messageAlert, animated: true, completion: nil)
    }
    
    // MARK: PERFORM DELETE CONTACT
    func performDelte(indexPath: Any){
        context?.delete(indexPath as! NSManagedObject)
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        fetchContacts()
    }
}

