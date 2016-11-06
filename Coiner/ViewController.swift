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
    @IBOutlet weak var Email: UITextField!
    @IBOutlet weak var Password: UITextField!
    @IBOutlet weak var Country: UITextField!
    @IBOutlet weak var Town: UITextField!
    
    @IBOutlet weak var CoutryPickerView: UIPickerView!
    
    @IBOutlet weak var AnimationView: CSAnimationView!
    @IBOutlet weak var Start: UIButton!
    @IBOutlet weak var PickerViewFinishButton: UIButton!
    
    @IBOutlet weak var Modes: UISegmentedControl!
    
    //  MARK: - Declarations of other variables
    var selectedMode : Int! = 0
    var selectedRow  : Int! = 0
    var selectedPickerView : Int! = 0
    
    var countries : [String] = []
    
    override func viewWillAppear(_ animated: Bool) {
        self.Email.text = ""
        self.Password.text = ""
        //self.Country.text = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        var result = getInput()
        //        print(result)
        
        // set delegates
        setDelegates()
        
        // hide guis
        hideGUI()
        
        // Set guis
        setStartButton()
        
        self.title = "Login"
        
        // Load country list
        for code in Locale.isoRegionCodes as [String] {
            let id = Locale.identifier(fromComponents: [NSLocale.Key.countryCode.rawValue: code])
            let name = (Locale(identifier: "en_US") as NSLocale).displayName(forKey: NSLocale.Key.identifier, value: id) ?? "Country not found for code: \(code)"
            countries.append(name)
        }
        
        countries.sort(){$0 < $1}
        countries.insert("Germany", at: 0)
    }
    
    // MARK: - GUI ACTIONS
    @IBAction func UserStart(_ sender: AnyObject) {
        
        if Password.text != "" && Email.text != "" && Country.text != "" && Email.text?.range(of: "@") != nil {
            start()
        } else {
            self.shakeButton()
        }
        
    }
    
    @IBAction func ModeChanged(_ sender: AnyObject) {
        
        self.Email.text = ""
        self.Password.text = ""
        self.Country.text = ""
        self.Town.text = ""
        
        self.selectedMode = self.Modes.selectedSegmentIndex
        
        view.endEditing(true)
    }
    
    @IBAction func UserTouchCountry(_ sender: AnyObject) {
        view.endEditing(true)
    }
    
    // When country text field is selected
    @IBAction func ShowCountryPicker(_ sender: AnyObject) {
        
        view.endEditing(true)
        
        self.Country.text = ""
        self.Country.isUserInteractionEnabled = false
        self.selectedPickerView = 0
        self.CoutryPickerView.isHidden = false
        self.PickerViewFinishButton.isHidden = false
    }
    
    // When country text field is unselected
    @IBAction func CloseCountryPicker(_ sender: AnyObject) {
        
        self.selectedPickerView = -1
        self.Country.isUserInteractionEnabled = true
        self.CoutryPickerView.isHidden = true
        self.PickerViewFinishButton.isHidden = true
    }
    
    @IBAction func PickerViewFinish(_ sender: AnyObject) {
        
        self.Country.isUserInteractionEnabled = true
        
        if self.selectedPickerView == 0 {
            // Country picker view
            self.Country.text = self.countries[self.selectedRow]
            self.PickerViewFinishButton.isHidden = true
            self.CoutryPickerView.isHidden = true
            
            self.Town.becomeFirstResponder()
        }
        
        view.endEditing(true)
    }
    
    // MARK: - FUNCS
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        view.endEditing(true)
        return true
    }
    
    // Login functions
    func Login() {
        
        FIRAuth.auth()?.signIn(withEmail: self.Email.text!, password: self.Password.text!, completion: { (user, error) in
            
            if error != nil {
                print("User : ", self.Email.text ?? "unknow", " login failed")
                self.shakeButton()
                
            }
            else {
                print("User : ", self.Email.text ?? "unknow", " login successfully")
                
                self.performSegue(withIdentifier: "toUserView", sender: nil)
            }
            
        })
        
    }
    
    func setStartButton() {
        self.Start.backgroundColor = UIColor.clear
        self.Start.layer.cornerRadius = 7
        self.Start.layer.borderWidth = 0.5
        self.Start.layer.borderColor = self.view.tintColor.cgColor
    }
    
    func shakeButton() {
        self.AnimationView.type = "shake"
        self.AnimationView.duration = 0.2
        self.AnimationView.delay = 0
        self.AnimationView.startCanvasAnimation()
    }
    
    func start() {
        
        if self.selectedMode == 0 {
            
            print("Try to login")
            self.Login()
            
            
        } else if self.selectedMode == 1 {
            
            print("Try to register")
            
            FIRAuth.auth()?.createUser(withEmail: self.Email.text!, password: self.Password.text!, completion: { (user, error) in
                
                if (error != nil) {
                    
                    self.shakeButton()
                    
                } else {
                    print("Registration successful")
                    self.performSegue(withIdentifier: "toUserView", sender: nil)
                }
                
            })
        }
    }
    
    func setDelegates() {
        self.Email.delegate = self
        self.Password.delegate = self
        self.Country.delegate = self
        self.Town.delegate = self
        
        self.CoutryPickerView.delegate = self
        self.CoutryPickerView.dataSource = self
    }
    
    func hideGUI() {
        
        self.CoutryPickerView.isHidden = true
        self.PickerViewFinishButton.isHidden = true
    }
    
    // MARK: - OVERRIDES
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toUserView" {
            let targetView = segue.destination as! UserViewController
            
            
            let temp = self.Email.text?.replacingOccurrences(of: ".", with: "", options: NSString.CompareOptions.literal, range: nil)
            
            targetView.useremail = temp
            targetView.country = self.Country.text! as String
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if selectedPickerView != -1 {
            self.selectedPickerView = -1
            self.Country.isUserInteractionEnabled = true
            self.CoutryPickerView.isHidden = true
            self.PickerViewFinishButton.isHidden = true
            
            self.Town.becomeFirstResponder()
        }
        
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
        self.selectedRow = row
    }
}

