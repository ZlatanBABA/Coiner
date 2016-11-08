//
//  ViewController.swift
//  FirebaseAuth
//
//  Created by LiuKangping on 13/09/16.
//  Copyright © 2016 leomac. All rights reserved.
//

import UIKit
import Canvas
import Firebase

class ViewController: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    // MARK: - Declarations of GUI elements
    @IBOutlet weak var CoutryPickerView: UIPickerView!
    @IBOutlet weak var BTN_Country: UIButton!
    @IBOutlet weak var AnimationView: CSAnimationView!
    @IBOutlet weak var Start: UIButton!
    @IBOutlet weak var PickerViewFinishButton: UIButton!
    @IBOutlet weak var TXT_Username: UITextField!
    
    //  MARK: - Declarations of other variables
    var selectedMode : Int! = 0
    var selectedCountry  : Int! = 0
    var selectedPickerView : Int! = 0
    var countries : [String] = []
    var DataBaseRef : FIRDatabaseReference? = nil
    
    override func viewWillAppear(_ animated: Bool) {

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Init Database
        self.DataBaseRef = FIRDatabase.database().reference()
        
        // set delegates
        setDelegates()
        
        // hide guis
        hideGUI()
        
        // Set guis
        //setStartButton()
        
        LoadCountryList()
    }
    
    // MARK: - GUI ACTIONS
    @IBAction func UserStart(_ sender: AnyObject) {
        
        var IsUnique : Bool = true
        
        if self.BTN_Country.titleLabel?.text != "COUNTRY" && self.TXT_Username.text != "" {
            
            self.DataBaseRef?.child("Country").child((self.BTN_Country.titleLabel?.text)!).observeSingleEvent(of: .value, with: { (snapshot) in
                
                // check if user name is unique
                for snap in snapshot.children.allObjects {
                    let AChild = snap as! FIRDataSnapshot
                    
                    print(AChild.key)
                    
                    if AChild.key == self.TXT_Username.text {
                        
                        IsUnique = false
                        break
                    }
                }
                
                // register user if name is unique
                if IsUnique {
                    print("Register new user successful")
                    let UsernameItem : [String : String] = ["Occupied" : "No"]
                    self.DataBaseRef?.child("Country").child((self.BTN_Country.titleLabel?.text)!).child(self.TXT_Username.text!).setValue(UsernameItem)
                    
                    self.performSegue(withIdentifier: "toWalletView", sender: nil)
                } else {
                    self.shakeButton()
                }
                
            })
        } else {
            self.shakeButton()
        }
        
    }

    @IBAction func Action_CountrySelected(_ sender: Any) {
        self.CoutryPickerView.isHidden = false
        self.PickerViewFinishButton.isHidden = false
        view.endEditing(true)
        
    }
    
    @IBAction func Action_CountryPickerView_Done(_ sender: Any) {
        self.PickerViewFinishButton.isHidden = true
        self.CoutryPickerView.isHidden = true
        
        self.BTN_Country.setTitle(self.countries[self.selectedCountry], for: .normal)
    }
    
    @IBAction func Action_TXT_Username_Selected(_ sender: Any) {
        self.PickerViewFinishButton.isHidden = true
        self.CoutryPickerView.isHidden = true
    }
    
    // MARK: - FUNCS
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        view.endEditing(true)
        return true
    }
    
    func LoadCountryList() {
        // Load country list
        for code in Locale.isoRegionCodes as [String] {
            let id = Locale.identifier(fromComponents: [NSLocale.Key.countryCode.rawValue: code])
            let name = (Locale(identifier: "en_US") as NSLocale).displayName(forKey: NSLocale.Key.identifier, value: id) ?? "Country not found for code: \(code)"
            countries.append(name)
        }
        
        self.countries.sort(){$0 < $1}
        self.countries.insert("Germany", at: 0)
    }
    
    func setStartButton() {
        self.Start.backgroundColor = UIColor.clear
        self.Start.layer.cornerRadius = 7
        self.Start.layer.borderWidth = 0.5
        self.Start.layer.borderColor = self.view.tintColor.cgColor
    }
    
    func shakeButton() {
        self.AnimationView.type = "shake"
        self.AnimationView.duration = 0.1
        self.AnimationView.delay = 0
        self.AnimationView.startCanvasAnimation()
    }
    
    func setDelegates() {
        self.TXT_Username.delegate = self
        self.CoutryPickerView.delegate = self
        self.CoutryPickerView.dataSource = self
    }
    
    func hideGUI() {
        self.CoutryPickerView.isHidden = true
        self.PickerViewFinishButton.isHidden = true
    }
    
    // MARK: - OVERRIDES
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toWalletView" {
            let targetView = segue.destination as! WalletViewController
            
            targetView.username = self.TXT_Username.text
            targetView.country  = self.countries[selectedCountry]
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.PickerViewFinishButton.isHidden = true
        self.CoutryPickerView.isHidden = true
        view.endEditing(true)
    }
    
    // MARK: - PICKER VIEW METHODS
    // country picker view
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        var amount : Int = 0
        
        if pickerView == CoutryPickerView {
            amount = countries.count
        }
        
        return amount
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        var list : [String] = []
        
        if pickerView == CoutryPickerView {
            list = countries
        }
        
        return list[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedCountry = row
    }
}

