//
//  SignUpViewController.swift
//  Slindir
//
//  Created by admin on 08/05/2019.
//  Copyright © 2019 Batth. All rights reserved.
//

import UIKit

class SignUpViewController: FormViewController {
    enum Gender {
        case male
        case female
    }
    
    class UserForm {
        var phoneNumber: String?
        var firstName: String?
        var email: String?
        var password: String?
        var gender: Gender = .male
        var birthday: Date?
        	
        init() {
            //
        }
        
        init(phoneNumber: String?, firstName: String?, email: String?, password: String?, birthday: Date?, gender: Gender) {
            self.phoneNumber = phoneNumber
            self.birthday = birthday
            self.firstName = firstName
            self.email = email
            self.password = password
            self.gender = gender
        }
    }
    
    @IBOutlet weak var btnRegister: UIButton!
    
    @IBOutlet weak var lblPhone: UILabel!
    @IBOutlet weak var lblFirstName: UILabel!
    @IBOutlet weak var lblPassword1: UILabel!
    @IBOutlet weak var lblPassword2: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblEmailDescr: UILabel!
    @IBOutlet weak var lblGender: UILabel!
    @IBOutlet weak var lblMale: UILabel!
    @IBOutlet weak var lblFemale: UILabel!
    @IBOutlet weak var lblBirthday: UILabel!
    
    @IBOutlet weak var rbGenderMale: UIView!
    @IBOutlet weak var rbGenderFemale: UIView!
    
    @IBOutlet weak var editFirstName: CustomTextField!
    @IBOutlet weak var editPassword1: CustomTextField!
    @IBOutlet weak var editPassword2: CustomTextField!
    @IBOutlet weak var editEmail: CustomTextField!
    @IBOutlet weak var editBirthday: CustomTextField!
    
    @IBOutlet weak var dpContainer: UIView!
    @IBOutlet weak var dpDataPicker: UIDatePicker!
    @IBOutlet weak var dpContainerHeightConstraint: NSLayoutConstraint!

    var dpContainerHeightConstraintDefault: CGFloat = 0.0
    
    var currentPhoneNumber: String? = nil
    var currentGender: Gender? = nil
    var currentData: Date? = nil
    var userForm: UserForm = UserForm()
    
    var isValidateEmail: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // init forms
        self.initTextFields(fields: [
            editFirstName,
            editPassword1,
            editPassword2,
            editEmail,
            editBirthday
            ])
        
        // test values
//        editFirstName.text = "Test"
//        editEmail.text = "test@test.com"
//        editPassword1.text = "123456789"
//        editPassword2.text = "123456789"
//        isValidateEmail = true
//        currentGender = .male
//        currentData = Calendar.current.date(byAdding: .year, value: -18, to: Date())
        
        // set phone
        lblPhone.text = currentPhoneNumber
        
        // hide button
        
        // initial
        userForm.phoneNumber = currentPhoneNumber
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // buttons
        btnRegister.layer.cornerRadius = btnRegister.frame.size.height/2
        btnRegister.shadowButton(0.3, 2, .black, CGSize(width: 2, height: 2))
        btnRegister.isHidden = false;
        
        // init radio button
        initRadioButton(view: rbGenderMale)
        initRadioButton(view: rbGenderFemale)
        
        // text fields
        editBirthday.delegate = self
        editEmail.keyboardType = .emailAddress
        
        // targets
        editFirstName.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        editEmail.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        editPassword1.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        editPassword2.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        editEmail.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        
        // data picker
        dpContainer.layer.addBorder(edge: [.top], color: UIColor(red:0.00, green:0.65, blue:0.69, alpha:1.0), thickness: 1.5)
        dpDataPicker.maximumDate = Calendar.current.date(byAdding: .year, value: -18, to: Date())
        dpDataPicker.minimumDate = Calendar.current.date(byAdding: .year, value: -100, to: Date())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        dpContainerHeightConstraintDefault = dpContainerHeightConstraint.constant
        hideDataPicker(hide: true)
    }
    
    private func initRadioButton(view: UIView) {
        view.layer.cornerRadius = view.frame.size.height/2
        view.layer.borderColor = UIColor(red:0.00, green:0.65, blue:0.69, alpha:1.0).cgColor
        view.layer.borderWidth = 1.5
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTapRadioButton(_:)))
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tap)
    }
    
    private func hideDataPicker(hide: Bool) {
        if hide {
            dpContainerHeightConstraint.constant = 0
            dpContainer.isHidden = true
        } else {
            dpContainerHeightConstraint.constant = dpContainerHeightConstraintDefault
            dpContainer.isHidden = false
        }
    }
    
    func doUserError(message:String)->Bool{
        self.outAlertError(message:message)
        return false
    }
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    private func validateForm() ->Bool{
        if (editFirstName.text!.count < 1){
            return doUserError(message: "Please enter your name")
        }
        if (editPassword2.text!.count < 8){
            return doUserError(message: "password lengths must be at least 8 characters")
        }
        if (editPassword1.text != editPassword2.text){
            return doUserError(message:"The passwords must be the same");
        }
        if (!isValidEmail(testStr:editEmail.text!)){
            return doUserError(message:"You must enter a valid email address");
        }

        if (currentGender == nil){
            return doUserError(message:"Please select your gender");
        }
        if (currentData == nil){
            return doUserError(message:"Please select your birthday");
        }


        // check birth date at least 18
/*        Calendar now = Calendar.getInstance();
        
        int nowyear = now.get(Calendar.YEAR);
        int nowmonth = now.get(Calendar.MONTH)+1;
        int nowday = now.get(Calendar.DAY_OF_MONTH);
        if (nowyear - year <= 18)
        if (nowmonth <= month)
        if(nowday < day)
        return SLUtils.DoUserError( "You must be 18 years old to use Slindir, please check your birthday");*/
        return true
    }

    // MARK: - Touches

    @IBAction func btnRegister(_ sender: Any) {
        
        if (validateForm()){
            userForm = UserForm(phoneNumber: currentPhoneNumber, firstName: editFirstName.text, email: editEmail.text, password: editPassword1.text, birthday: currentData, gender: currentGender ?? .male)
            
            if let newViewController = UIStoryboard(name: "SignIn", bundle:nil).instantiateViewController(withIdentifier: "PhoneViewController") as? PhoneViewController
            {
                newViewController.currentPhoneNumber = currentPhoneNumber
                newViewController.currentUser = userForm
                newViewController.fbLoginType = 2
                self.present(newViewController, animated: true)
            }
        }
            
    }
    
    private func rbGenderChange(view: UIView) {
        switch view {
        case rbGenderMale:
            currentGender = .male
        default:
            currentGender = .female
        }
        
    }
    
    @IBAction func btnClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func dpCancel(_ sender: Any) {
        currentData = nil
        hideDataPicker(hide: true)
    }
    
    @IBAction func dpDone(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        editBirthday.text = dateFormatter.string(from: dpDataPicker.date)
        currentData = dpDataPicker.date
        
        hideDataPicker(hide: true)
    }
    
    
    // MARK: - Delegates
    
    @objc override func textFieldDidChange(_ textField: UITextField) {
        super.textFieldDidChange(textField)
        
        if textField == editEmail {
            isValidateEmail = false
            
            if textField.text != nil && textField.text!.isValidEmail() {
                isValidateEmail = true
            }
        }
        
    }
    
    override func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if super.textFieldShouldBeginEditing(textField) {
            if textField == editBirthday {
                hideDataPicker(hide: false)
                self.hideKeyboard()
                return false;
            }
            
            return true
        }
        
        return false
    }
    
    @objc func handleTapRadioButton(_ sender: UITapGestureRecognizer? = nil) {
        rbGenderMale.backgroundColor = .clear
        rbGenderFemale.backgroundColor = .clear
        
        sender?.view?.backgroundColor = UIColor(red:0.00, green:0.65, blue:0.69, alpha:1.0)
        
        if sender?.view != nil {
            rbGenderChange(view: sender!.view!)
        }
    }
}
