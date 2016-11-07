//
//  UserViewController.swift
//  FirebaseAuth
//
//  Created by LiuKangping on 13/09/16.
//  Copyright © 2016 leomac. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class UserViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var PICKER_Currency: UIPickerView!
    @IBOutlet weak var BTN_Currency: UIButton!
    @IBOutlet weak var BTN_Currency_done: UIButton!
    @IBOutlet weak var TXT_Username: UITextField!
    
    // MARK: - UI Money Labels
    @IBOutlet weak var LBL_ZeroOne: UILabel!
    @IBOutlet weak var LBL_ZeroTwo: UILabel!
    @IBOutlet weak var LBL_ZeroFive: UILabel!
    @IBOutlet weak var LBL_One: UILabel!
    @IBOutlet weak var LBL_Two: UILabel!
    @IBOutlet weak var LBL_Five: UILabel!
    @IBOutlet weak var LBL_Ten: UILabel!
    @IBOutlet weak var LBL_TwoZero: UILabel!
    @IBOutlet weak var LBL_FiveZero: UILabel!
    
    
    var useremail : String? = nil
    var country   : String? = nil
    var town      : String? = nil
    var username  : String? = nil
    
    var Wallet = [String : String]()
    var currencies : [String] = ["Yuan", "Euro", "US dollars", "GBP"]
    var SelectedCurrency  : Int! = 0
    var DataBaseRef : FIRDatabaseReference? = nil
    var READY : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.TXT_Username.delegate = self
        self.PICKER_Currency.delegate = self
        self.PICKER_Currency.dataSource = self
        
        self.PICKER_Currency.isHidden = true
        self.BTN_Currency_done.isHidden = true
        
        self.title = "Prepare Your Changes"
        self.TXT_Username.text = ""
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "LOGOUT", style: UIBarButtonItemStyle.plain, target: self, action: #selector(UserViewController.logout(_:)))
        
        DataBaseRef = FIRDatabase.database().reference()
        // getUserMoneyAmount()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    
    //  MARK: - UI Actions
    @IBAction func StartButton(_ sender: AnyObject) {
        
        if self.username != nil {
            
            // post Country, Town, Coins to database
            
            let postItem: [String : String] = ["money" : self.TXT_Username.text!]
            
            DataBaseRef?.child("Country").child(self.country!).child(self.useremail!).setValue(postItem)
            
            print("Refresh user : ", self.useremail ?? "unknow", "'s money")
        }
        
    }
    
    @IBAction func Action_BTN_Currency_Clicked(_ sender: Any) {
        
        self.PICKER_Currency.isHidden = false
        self.BTN_Currency_done.isHidden = false
        
    }
    
    @IBAction func Action_BTN_Currency_done_Clicked(_ sender: Any) {
        self.PICKER_Currency.isHidden = true
        self.BTN_Currency_done.isHidden = true
        
        self.BTN_Currency.setTitle(self.currencies[self.SelectedCurrency], for: .normal)
        
    }
    
    @IBAction func Action_TXT_Finish_Edit(_ sender: Any) {
        
        var IsUnique : Bool = true
        
        self.DataBaseRef?.child("Country").child(self.country!).observeSingleEvent(of: .value, with: { (snapshot) in
            
            // check if user name is unique
            for snap in snapshot.children.allObjects {
                let AChild = snap as! FIRDataSnapshot
                let AChildUsername : String = AChild.childSnapshot(forPath: "username").value as! String
                
                print(AChildUsername)
                
                if AChildUsername == self.TXT_Username.text {
                    
                    IsUnique = false
                    break
                }
            }
            
            // register user if name is unique
            if IsUnique {
                print("I am unique")
                let UsernameItem : [String : String] = ["username" : self.TXT_Username.text!]
                self.DataBaseRef?.child("Country").child(self.country!).child(self.useremail!).setValue(UsernameItem)
            }
            
            self.CollectWallet()
            self.READY = true
        })
        
    }
    
    // Money Labels
    // 0.1
    @IBAction func Action_STPR_ZeroOne(_ sender: UIStepper) {
        
        self.LBL_ZeroOne.text = String(GetStepperValue(sender: sender))
    }
    
    // 0.2
    @IBAction func Action_STPR_ZeroTwo(_ sender: UIStepper) {
        self.LBL_ZeroTwo.text = String(GetStepperValue(sender: sender))
    }
    
    // 0.5
    @IBAction func Action_STPR_ZeroFive(_ sender: UIStepper) {
        self.LBL_ZeroFive.text = String(GetStepperValue(sender: sender))
    }
    
    // 1
    @IBAction func Action_STPR_One(_ sender: UIStepper) {
        self.LBL_One.text = String(GetStepperValue(sender: sender))
    }
    
    // 2
    @IBAction func Action_STPR_Two(_ sender: UIStepper) {
        self.LBL_Two.text = String(GetStepperValue(sender: sender))
    }
    
    // 5
    @IBAction func Action_STPR_Five(_ sender: UIStepper) {
        self.LBL_Five.text = String(GetStepperValue(sender: sender))
    }
    
    // 10
    @IBAction func Action_STPR_Ten(_ sender: UIStepper) {
        self.LBL_Ten.text = String(GetStepperValue(sender: sender))
    }
    
    // 20
    @IBAction func Action_STPR_TwoZero(_ sender: UIStepper) {
        self.LBL_TwoZero.text = String(GetStepperValue(sender: sender))
    }
    
    // 50
    @IBAction func Action_STPR_FiveZero(_ sender: UIStepper) {
        self.LBL_FiveZero.text = String(GetStepperValue(sender: sender))
    }
    
    //  MARK: - FIRBase wrapped funcs
    func RegisterUserName(username : String, country : String) {
        
        var IsUnique : Bool = true
        
        self.DataBaseRef?.child("Country").child(country).observeSingleEvent(of: .value, with: { (snapshot) in
            
            // check if user name is unique
            for snap in snapshot.children.allObjects {
                let AChild = snap as! FIRDataSnapshot
                let AChildUsername : String = AChild.childSnapshot(forPath: "username").value as! String
                
                print(AChildUsername)
                
                if AChildUsername == self.TXT_Username.text {
                    
                    IsUnique = false
                    break
                }
            }
            
            // register user if name is unique
            if IsUnique {
                print("I am unique")
                let UsernameItem : [String : String] = ["username" : self.TXT_Username.text!]
                self.DataBaseRef?.child("Country").child(country).child(self.useremail!).setValue(UsernameItem)
            }
            
        })
        
    }
    
    
    //  MARK: - Override functions
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showMapView" {
            let targetView = segue.destination as! MapViewController
            
            targetView.useremail = self.useremail
            targetView.username = self.username
            targetView.country = self.country
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.currencies.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return currencies[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.SelectedCurrency = row
    }
    
    func logout(_ sender: UIBarButtonItem) {
        print("User : ", self.username ?? "unknow", " Logout")
        
        // post my location to database
        /*let dataBaseRef = FIRDatabase.database().reference()
         
         let postItems: [String : Double] = ["latitude" : -1, "longitude" : -1]
         
         let username = self.useremail!.replacingOccurrences(of: ".", with: "", options: NSString.CompareOptions.literal, range: nil)
         
         dataBaseRef.child("users").child(username).updateChildValues(postItems)*/
        
        self.navigationController!.popToRootViewController(animated: true)
    }
    
    
    // MARK: - Others
    func GetStepperValue(sender: UIStepper) -> Int {
        
        if sender.value > 10.0 {
            sender.value = 10.0
        }
        
        var IntValue : Int = Int(sender.value)
        
        if IntValue > 10 {
            IntValue = 10
        }
        
        return IntValue
    }
    
    func CollectWallet() {
        self.Wallet["ZeroOne"] = self.LBL_ZeroOne.text
        self.Wallet["ZeroTwo"] = self.LBL_ZeroTwo.text
        self.Wallet["ZeroFive"] = self.LBL_ZeroFive.text
        self.Wallet["One"] = self.LBL_One.text
        self.Wallet["Two"] = self.LBL_Two.text
        self.Wallet["Five"] = self.LBL_Five.text
        self.Wallet["Ten"] = self.LBL_Ten.text
        self.Wallet["TwoZero"] = self.LBL_TwoZero.text
        self.Wallet["FiveZero"] = self.LBL_FiveZero.text
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

// get user's money from database - DOES NOT MAKE ANY SENSE
//    func getUserMoneyAmount () {
//
//        var money : Int = 0
//
//        let dataBaseRef = FIRDatabase.database().reference()
//
//        let username = self.useremail!.stringByReplacingOccurrencesOfString(".", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
//
//        dataBaseRef.child("users").child(username).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
//
//            if let temp = snapshot.value!["money"] {
//
//                print("Load user : ", self.useremail, "'s money")
//
//                if temp == nil {
//                    money = 0
//                } else
//                {
//                    money = Int(temp as! String)!
//                }
//
//
//            }
//            else
//            {
//                print("User not found or user's money is empty")
//                money = 0
//            }
//
//            self.MoneyAmount.text = String(money)
//
//            dataBaseRef.child("users").child(username).removeAllObservers()
//
//        }) { (error) in
//            print("Error : cant load user : ", self.useremail, "'s data")
//            money = 0
//
//            self.MoneyAmount.text = String(money)
//            dataBaseRef.child("users").child(username).removeAllObservers()
//        }
//
//    }
