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

class UserViewController: UIViewController {
    
    // MARK: - UI Money Labels
    
    @IBOutlet weak var LBL_ZeroZeroOne: UILabel!
    @IBOutlet weak var LBL_ZeroZeroTwo: UILabel!
    @IBOutlet weak var LBL_ZeroZeroFive: UILabel!
    @IBOutlet weak var LBL_ZeroOne: UILabel!
    @IBOutlet weak var LBL_ZeroTwo: UILabel!
    @IBOutlet weak var LBL_ZeroFive: UILabel!
    @IBOutlet weak var LBL_One: UILabel!
    @IBOutlet weak var LBL_Two: UILabel!
    @IBOutlet weak var LBL_Five: UILabel!
    @IBOutlet weak var LBL_Ten: UILabel!
    @IBOutlet weak var LBL_TwoZero: UILabel!
    @IBOutlet weak var LBL_FiveZero: UILabel!
    
    var country   : String? = nil
    var username  : String? = nil
    
    var Wallet = [String : String]()
    var currencies : [String] = ["Yuan", "Euro", "US dollars", "GBP"]
    var SelectedCurrency  : Int! = 0
    var DataBaseRef : FIRDatabaseReference? = nil
    var READY : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Prepare Your Changes"
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "LOGOUT", style: UIBarButtonItemStyle.plain, target: self, action: #selector(UserViewController.logout(_:)))
        
        DataBaseRef = FIRDatabase.database().reference()
        // getUserMoneyAmount()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    //  MARK: - UI Actions
    @IBAction func StartButton(_ sender: AnyObject) {
        
        CollectWallet()
        self.DataBaseRef?.child("Country").child(self.country!).child(self.username!).child("wallet").updateChildValues(self.Wallet)
        
    }
    
    // Money Labels
    // 0.01
    @IBAction func Action_STPR_ZeroZeroOne(_ sender: UIStepper) {
        self.LBL_ZeroZeroOne.text = String(GetStepperValue(sender: sender))
    }
    
    // 0.02
    @IBAction func Action_STPR_ZeroZeroTwo(_ sender: UIStepper) {
        self.LBL_ZeroZeroTwo.text = String(GetStepperValue(sender: sender))    }


    // 0.05
    @IBAction func Action_STPR_ZeroZeroFive(_ sender: UIStepper) {
        self.LBL_ZeroZeroFive.text = String(GetStepperValue(sender: sender))
   }

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
    
    //  MARK: - Override functions
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showMapView" {
            let targetView = segue.destination as! MapViewController
            
            targetView.username = self.username
            targetView.country = self.country
        }
    }
    
    func logout(_ sender: UIBarButtonItem) {
        print("User : ", self.username ?? "unknow", " Logout")
        
        DataBaseRef?.child("Country").child(self.country!).child(self.username!).removeValue()
        
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
        self.Wallet["ZeroZeroOne"] = self.LBL_ZeroOne.text
        self.Wallet["ZeroZeroTwo"] = self.LBL_ZeroZeroTwo.text
        self.Wallet["ZeroZeroFive"] = self.LBL_ZeroZeroFive.text
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
