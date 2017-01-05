//
//  FADRegistrationTableViewController.swift
//  FaDProvider
//
//  Created by Dileep Yadav.N on 5/2/16.
//  Copyright © 2016 FINDaDOCTOR. All rights reserved.
//

import UIKit

enum FADRegisterItem: Int {
   
    case npiNumber = 0
    case email
    case mobile
    case password
    case confirmPassword
    
}

enum FADRegisterTableSection: Int {
    
    case coupon
    case information
    case termsCondition
}

class FADRegistrationViewController: FADBaseViewController {

    var param: NSMutableDictionary! = NSMutableDictionary()
    
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var tableviewBottomContraint: NSLayoutConstraint!
    @IBOutlet weak var buttonHeightContraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    var boolValue: Bool = false
    var termsConditionsSelected : Bool = false
    
    override func viewDidLoad() {

        super.viewDidLoad()
        configureView()
        
    }

    func backTapped(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func validateFields() -> String{
        
        var message: String = ""
        
        if ((param.value(forKey: "npi") ?? "") as AnyObject).length < 10 {
            message = "Enter valid NPI number"
            return message
        } else if ((param.value(forKey: "email") ?? "") as! String).isValidEmail() == false {
            message = "Enter valid email"
            return message
        } else if ((param.value(forKey: "email") ?? "") as AnyObject).length == 0 {
            message = "Enter valid email"
            return message
        } else if convertedMobileNumber(mobile: (param.value(forKey: "mobile") ?? "") as! String).characters.count < 10 {
            message = "Enter valid mobile"
            return message
        } else if ((param.value(forKey: "password") ?? "") as AnyObject).length == 0 {
            message = "Enter valid password"
            return message
        } else if isPasswordValid() == false {
            message = "Password must meet following criteria: \n • Between 8 to 12 characters \n • Alphanumeric \n • At least one uppercase and lowercase letter \n • No special characters"
            return message
        } else if ((param.value(forKey: "confirmPassword") ?? "") as AnyObject).length == 0 {
            message = "Please re-enter the password"
            return message
        } else if (param.value(forKey: "password") as! String == param.value(forKey: "confirmPassword") as! String) == false {
            message = "Password mis-matched"
            return message
        } else if (termsConditionsSelected == false) {
            message = "Agree to the Terms of Use and HIPAA Compliance"
            return message
        }
        
        return String()
        
    }
    
    func isPasswordValid() -> Bool {
        
        let regEx  = "^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])[A-Za-z\\d]{8,12}" // (?=.*[$@$!%*?&#])
        let predicate = NSPredicate(format:"SELF MATCHES %@", regEx)
        let result = predicate.evaluate(with: ((param.value(forKey: "password") ?? "") as! String))
        
        return result
    }

    @IBAction func registrationButtonTapped(_ sender: UIButton) {
        
        let message: String = validateFields()
      
        if message.characters.count == 0 {
            
            let params = [ NPI_KEY          : param.value(forKey: "npi") as! String ,
                           USER_NAME_KEY    : param.value(forKey: "email") as! String,
                           MOBILE_KEY       : convertedMobileNumber(mobile: param.value(forKey: "mobile") as! String),
                           USER_TYPE_KEY    : USER_TYPE_VALUE,
                           PASSWORD_KEY     : param.value(forKey: "password") as! String,
                           DEVICE_ID_KEY    : UIDevice.current.identifierForVendor!.uuidString,
                           COUNTRY_CODE_KEY : "+91"]

            FADNetwork.networkManager.request(post: SIGNUP_URN, params: params as [String : AnyObject], authorizationRequired: false, blockUser: true, success: { (result) in
                self.handleSuccess(result as! [String : AnyObject])
                }, failure: { (error) in
                    self.handleFailure(error)
            })
        } else {
            super.showAlertView("", message: message, closeButtonText: "OK")
        }
        
    }
    
    func convertedMobileNumber(mobile: String) -> String {
        
        var convertedNumber = mobile.replacingOccurrences(of: "(", with: "")
        convertedNumber = convertedNumber.replacingOccurrences(of: ")", with: "")
        convertedNumber = convertedNumber.replacingOccurrences(of: " ", with: "")
        convertedNumber = convertedNumber.replacingOccurrences(of: "-", with: "")
        
        return convertedNumber
        
    }
    
    // MARK: -------------------------------------
    // MARK: Notification Handlers
    // MARK: -------------------------------------
    func keyboardWillShown(_ notification: Notification) {
        
        var info = (notification as NSNotification).userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.tableviewBottomContraint.constant = keyboardFrame.size.height - self.buttonHeightContraint.constant + 10
            self.view.layoutIfNeeded()
        })
    }
    
    func keyboardWillHide(_ notification: Notification) {
        
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.tableviewBottomContraint.constant = 0
            self.view.layoutIfNeeded()
        })
    }
}

// MARK: -------------------------------------
// MARK: Private Methods
// MARK: -------------------------------------
private extension FADRegistrationViewController {
    
    func configureView() {
        
        self.tableView.allowsSelection = false
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(FADRegistrationViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        signUpButton.titleLabel?.font = UIFont().fad_boldFont14()
        signUpButton.backgroundColor = UIColor().fad_primaryColor()
        
        super.configureBackButton()
        configureTitleView()
        configuringKeyboardNotification()
    }
    
    func configureTitleView() {
        
        let titleLabel = UILabel().fad_nav_titleLabel("List Your Practice")
        self.navigationItem.titleView = titleLabel
    }
    
    func configuringKeyboardNotification(){
        
        NotificationCenter.default.addObserver(self, selector: #selector(FADRegistrationViewController.keyboardWillShown(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(FADRegistrationViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func handleSuccess(_ result: [String : AnyObject]) {

        UserDefaults.standard.set(false, forKey: FAD_PROVIDER_IS_LOGGEDIN_BEFORE)
        let doctorInfoViewController = storyboard?.instantiateViewController(withIdentifier: "FADOTPViewController") as! FADOTPViewController
        doctorInfoViewController.username = result[USER_ID_KEY] as! String
        doctorInfoViewController.mobileNumber = param.value(forKey: "mobile") as! String
        
        doctorInfoViewController.params = [ NPI_KEY          : param.value(forKey: "npi") as! String ,
                                            USER_NAME_KEY    : param.value(forKey: "email") as! String,
                                            MOBILE_KEY       : convertedMobileNumber(mobile: param.value(forKey: "mobile") as! String),
                                            USER_TYPE_KEY    : USER_TYPE_VALUE,
                                            PASSWORD_KEY     : param.value(forKey: "password") as! String,
                                            DEVICE_ID_KEY    : UIDevice.current.identifierForVendor!.uuidString,
                                            COUNTRY_CODE_KEY : "+1"]
        navigationController?.pushViewController(doctorInfoViewController, animated: true)
    }
    
    func handleFailure(_ error: FADError) {
        print("Failed: \(error)")
    }
}

// MARK: -------------------------------------
// MARK: UITableViewDelegate and Datasource
// MARK: -------------------------------------
extension FADRegistrationViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        let sectionType = FADRegisterTableSection(rawValue: section)! as FADRegisterTableSection
        
        switch sectionType {
            case .coupon:
                return 1
            case .information:
                return 5
            case .termsCondition:
                return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        tableView.separatorStyle = .none
        let sectionType = FADRegisterTableSection(rawValue: (indexPath as NSIndexPath).section)! as FADRegisterTableSection
        
        switch sectionType {
            
            case .coupon:
                let cell = tableView.dequeueReusableCell(withIdentifier: "FADStaticCell", for: indexPath)
                return cell
           
            case .information:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "FADTextfieldCell", for: indexPath) as! FADTextfieldCell
                cell.delegate = self
                let enumIndex = FADRegisterItem(rawValue: (indexPath as NSIndexPath).row)! as FADRegisterItem
                
                switch enumIndex {
                    
                case .npiNumber:
                    cell.configureNPITextField((param.value(forKey: "npi") ?? "") as! String, index: .npiNumber)
                    return cell
                    
                case .email:
                    cell.configureEmailTextField((param.value(forKey: "email") ?? "")  as! String , index: .email)
                    return cell
                    
                case .mobile:
                    cell.configureMobileTextField((param.value(forKey: "mobile") ?? "")  as! String , index: .mobile)
                    return cell
                    
                case .password:
                    cell.configurePasswordTextField((param.value(forKey: "password") ?? "")  as! String , index: .password)
                    return cell
                
                case .confirmPassword:
                    cell.configureConfirmPasswordTextField((param.value(forKey: "confirmPassword") ?? "")  as! String , index: .confirmPassword)
                    return cell
                }
            
            case .termsCondition:
                let termsCell = tableView.dequeueReusableCell(withIdentifier: "FADRegisterTermsConditionCell", for: indexPath) as! FADRegisterTermsConditionCell
                termsCell.delegate = self
                return termsCell
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let sectionType = FADRegisterTableSection(rawValue: (indexPath as NSIndexPath).section)! as FADRegisterTableSection
        
        switch sectionType {
            
            case .coupon:
                return 150
            case .information:
                return 60
            case .termsCondition:
                return 90
        }
    }
}

extension FADRegistrationViewController: FADRegistrationDelegate {
    
    func didSelectNPIInfoButton() {
        
        self.showAlertView("NPI-National Provider Identifier", message: "A unique 10-digit identification number issued to healthcare providers in the United States by the Centers for Medicare and Medicaid Services (CMS). Both individual (doctors, nurses, dentists) and organizational (hospitals, clinics, nursing homes) healthcare providers are required to obtain an NPI", closeButtonText: "OK")
        
    }
    
    func didChangeText(_ text: String, forCellType: FADRegisterItem) {
        
        switch forCellType {
            
        case .npiNumber:
            param.setObject(text, forKey: "npi" as NSCopying)
            break
            
        case .email:
            param.setObject(text, forKey: "email" as NSCopying)
            break
            
        case .mobile:
            param.setObject(text, forKey: "mobile" as NSCopying)
            break
            
        case .password:
            param.setObject(text, forKey: "password" as NSCopying)
            break
            
        case .confirmPassword:
            param.setObject(text, forKey: "confirmPassword" as NSCopying)
            break
            
        }
    }
    
    func didReturnKeyboard(celltype: FADRegisterItem) {
        
        switch celltype {
        case .npiNumber:
            
            let rect = self.tableView.rectForRow(at: IndexPath(row: 1, section: 1))
            tableView.beginUpdates()
            self.tableView.scrollRectToVisible(rect, animated: true)
            tableView.endUpdates()
            
            self.perform(#selector(performBecomeFirstResponderOperation), with: 111, afterDelay: 0.1)
            
            break
            
        case .email:
            
            let rect = self.tableView.rectForRow(at: IndexPath(row: 2, section: 1))
            tableView.beginUpdates()
            self.tableView.scrollRectToVisible(rect, animated: true)
            tableView.endUpdates()
            
            self.perform(#selector(performBecomeFirstResponderOperation), with: 112, afterDelay: 0.1)

            break
            
        case .mobile:
            
            let rect = self.tableView.rectForRow(at: IndexPath(row: 3, section: 1))
            tableView.beginUpdates()
            self.tableView.scrollRectToVisible(rect, animated: true)
            tableView.endUpdates()
            
            self.perform(#selector(performBecomeFirstResponderOperation), with: 113, afterDelay: 0.1)
            
            break
            
        case .password:
            
            let rect = self.tableView.rectForRow(at: IndexPath(row: 4, section: 1))
            tableView.beginUpdates()
            self.tableView.scrollRectToVisible(rect, animated: true)
            tableView.endUpdates()
            
            self.perform(#selector(performBecomeFirstResponderOperation), with: 114, afterDelay: 0.1)
            
            break
            
        case .confirmPassword:
            
            let textField = self.view.viewWithTag(114) as! UITextField
            textField.resignFirstResponder()
//            self.registrationButtonTapped(UIButton())
            
            break

        }
        
    }
    
    func performBecomeFirstResponderOperation(tag: Any?) {
        
        let textField = self.view.viewWithTag(tag as! Int) as! UITextField
        textField.becomeFirstResponder()
        
    }
}


extension FADRegistrationViewController:FADRegisterTermsDelegate {
    
    func didTermsConditionButtonTapped(cell: FADRegisterTermsConditionCell) {
        termsConditionsSelected = cell.selectedState
    }
    
}
