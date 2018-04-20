//
//  ViewController.swift
//  SQLiteDatabase
//
//  Created by Douglas Alexander on 4/19/18.
//  Copyright © 2018 Douglas Alexander. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var address: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var status: UILabel!
    
    var databasePath = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initDB()
    }
    
    func initDB() {
        let fileMgr = FileManager.default
        let dirPaths = fileMgr.urls(for: .documentDirectory, in: .userDomainMask)
        
        // create the url (path) to the document
        databasePath = dirPaths[0].appendingPathComponent("contact.db").path
        
        // check to see if the database file exists
        if !fileMgr.fileExists(atPath: databasePath) {
            
            // create the database with the database path
            let contactDB = FMDatabase(path: databasePath)
        
           
            // attempt to openthe database
            if (contactDB.open()) {
                
                // prepare the sql statement
                let sql_stmt = "CREATE TABLE IF NOT EXISTS CONTACTS (ID INTEGER PRIMARY KEY AUTOINCREMENT, NAME TEXT, ADDRESS TEXT, PHONE TEXT)"
                
                // execute the statement
                if !(contactDB.executeStatements(sql_stmt)) {
                    print("Error: \(contactDB.lastErrorMessage())")
                }
                
                // close the DB
                contactDB.close()
            } else {
                print("Error: \(contactDB.lastErrorMessage())")
            }
        }
    }

    @IBAction func saveData(_ sender: Any) {
        let contactDB = FMDatabase(path: databasePath)
        
        // open the DB
        if (contactDB.open()) {
            
            // construct the insert statement
            let insertSQL = "INSERT INTO CONTACTS (name, address, phone) VALUES ('\(name.text ?? "")', '\(address.text ?? "")', '\(phone.text ?? "")')"
            
            do {
                try contactDB.executeUpdate(insertSQL, values: nil)
            } catch {
                status.text = "Failerd to add contact"
                print("error: \(error.localizedDescription)")
            }
            
            // update the status
            status.text = "Contact Added"
            
            // clear the input fields
            name.text = ""
            address.text = ""
            phone.text = ""
            
        } else {
            print("Error: \(contactDB.lastErrorMessage())")
        }
    }
    
    // find the contact
    @IBAction func findContact(_ sender: Any) {
        let contactDB = FMDatabase(path: databasePath)
        
        // open the DB
        if contactDB.open() {
            
            // constuct query statement
            let querySQL = "SELECT address, phone FROM CONTACTS WHERE name = '\(name.text!)'"
            
            do {
                // execute the query statement
                let results:FMResultSet? = try contactDB.executeQuery(querySQL, values: nil)
                
                // does the ersult contain a match
                if results?.next() == true {
                    // display the results
                    address.text = results?.string(forColumn: "address")
                    phone.text = results?.string(forColumn: "phone")
                    status.text = ""
                } else {
                    // nothing found - clear the text fields
                    status.text = "Record not found."
                    address.text = ""
                    phone.text = ""
                }
            } catch {
                print("Error: \(error.localizedDescription)")
            }
            // close the DB
            contactDB.close()
        } else {
            print("Error: \(contactDB.lastErrorMessage())")
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

