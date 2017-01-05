//
//  FADDoctorInfoViewController.swift
//  FaDProvider
//
//  Created by Dileep Yadav.N on 4/29/16.
//  Copyright © 2016 FINDaDOCTOR. All rights reserved.
//

import UIKit
import SnapKit

enum FADPInfo: Int {
    
    case info = 0
    case speciality
    case subSpeciality
    case practiceLocation
    case hospitalAffliations
    case insurances
//    case termsAndConditions
}


class FADDoctorInfoViewController: FADBaseViewController {
    
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var termsConditionsSelected : Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        fetchDoctorDetails()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    @IBAction func confirmButtonTapped(_ sender: AnyObject) {
        
        let message = validateFields()
        if message.characters.count != 0 {
            
            self.showAlertView("", message: message, closeButtonText: "OK")
            return
        }
        
        FADNetwork.networkManager.request(put: doctorDetailsURN(), params: FADLocalUser.parameters(), authorizationRequired: true, blockUser: true, success: { (result) in
            
            FADUser.saveUserDetails(result as! [String : AnyObject])
            self.dismiss(animated: true, completion: nil)
            
            }, failure: { (error) in
                self.showAlert(alert: error)
        })

    }
    
    func loadAddLocationView() {
        
        let practiceLocationView = storyboard!.instantiateViewController(withIdentifier: "FADPracticeInfoViewController") as! FADPracticeInfoViewController
        practiceLocationView.delegate = self
        
        let navController = UINavigationController(rootViewController: practiceLocationView)
        navController.modalTransitionStyle = .coverVertical
        
        self.present(navController, animated: true, completion: nil)
    }
    
    func loadAddSpecialityView() {
        
        let addSpecialityView = storyboard!.instantiateViewController(withIdentifier: "FADSpecialtyViewController") as! FADSpecialtyViewController
        addSpecialityView.delegate = self
        addSpecialityView.addedSpecialties = NSMutableArray(array: FADLocalUser.localUser.specialties!)
        addSpecialityView.addedSubSpecialties = NSMutableArray(array: FADLocalUser.localUser.subspecialties!)
        
        let navController = UINavigationController(rootViewController: addSpecialityView)
        navController.modalTransitionStyle = .coverVertical
        navController.navigationBar.isTranslucent = false
        
        self.present(navController, animated: true, completion: nil)
    }
    
    //Private
    fileprivate func infoCell(_ indexPath: IndexPath) -> FADInfoCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCell", for: indexPath) as! FADInfoCell
        cell.configureCell()
        cell.delegate = self
        cell.tag = 0
        return cell
    }
    
    fileprivate func editableInfoCell(indexPath: IndexPath) -> FADEditableInfoCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FADEditableInfoCell", for: indexPath) as! FADEditableInfoCell
        cell.configureCell()
        cell.tag = 0
        cell.delegate = self
        return cell
    }
    
    fileprivate func specialityCell(_ indexPath: IndexPath) -> FADSpecialityCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SpecialityCell", for: indexPath) as! FADSpecialityCell
        cell.configureCell(FADLocalUser.localUser.specialties![(indexPath as NSIndexPath).row] as! FADPTaxonomy, specType: FADSpecType.specialty)
        cell.delegate = self
        cell.tag = 1
        
        return cell
    }
    
    fileprivate func subSpecialityCell(_ indexPath: IndexPath) -> FADSpecialityCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SpecialityCell", for: indexPath) as! FADSpecialityCell
        cell.configureCell(FADLocalUser.localUser.subspecialties![(indexPath as NSIndexPath).row] as! FADPTaxonomy, specType: FADSpecType.subSpecialty)
        cell.delegate = self
        cell.tag = 2
        
        return cell
    }
    
    fileprivate func practiceLocationCell(_ indexPath: IndexPath) -> FADPracticeLocationCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FADPracticeLocationCell", for: indexPath) as! FADPracticeLocationCell
        cell.configureCell(FADLocalUser.localUser.unverifiedLocations![(indexPath as NSIndexPath).row] as! FADPracticeLocation)
        cell.tag = 4
        cell.delegate = self
        return cell
    }
    
    fileprivate func hospitalCell(_ indexPath: IndexPath) -> FADHospitalCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FADHospitalCell", for: indexPath) as! FADHospitalCell
        cell.configureCell(FADLocalUser.localUser.hospitalAffliations![(indexPath as NSIndexPath).row] as! FADLocalHospital)
        cell.tag = 6
        cell.delegate = self
        return cell
    }
    
    fileprivate func addNewItemCell(indexPath: IndexPath) -> FADAddNewItemCell {
        
        let cell = FADAddNewItemCell.customView()
        
        let enumValue = FADPInfo(rawValue: indexPath.section)! as FADPInfo
        if enumValue == FADPInfo.hospitalAffliations {
            cell.configureCell(title: "Add a Hospital")
        } else if enumValue == FADPInfo.insurances {
            cell.configureCell(title: "Add an Insurance")
        } else if enumValue == FADPInfo.practiceLocation {
            cell.configureCell(title: "Add a Location")
        } else if enumValue == FADPInfo.speciality {
            cell.configureCell(title: "Add a Specialty")
        }
        
        return cell
    }
    
    fileprivate func insuranceCell(_ indexPath: IndexPath) -> FADDIInsuranceCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FADDIInsuranceCell", for: indexPath) as! FADDIInsuranceCell
        cell.configureCell(FADLocalUser.localUser.insurances![indexPath.row] as! String)
        cell.tag = 7
        cell.delegate = self
        return cell
    }
    
    fileprivate func termsandConditionCell(_ indexPath: IndexPath) -> FADTermsConditionCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TermsConditionCell", for: indexPath) as! FADTermsConditionCell
        cell.delegate = self
        cell.tag = 8
        return cell
    }
    
    
}

private extension FADDoctorInfoViewController {
    
    func fetchDoctorDetails() {
        
        FADNetwork.networkManager.request(get: doctorDetailsURN(), params: nil, authorizationRequired: true, blockUser: false, success: { (result) in
            
            FADLocalUser.localUser.convertResponseToLocalUser(response: result as! [String : AnyObject])
            self.tableView.reloadData()
            
        }) { (error) in
            // TODO: Show error message
        }
    }
    
    func doctorDetailsURN() -> String {
        return "\(DOCTOR_DETIALS_URN)\(FADUser.currentUserID())"
    }
    
    func configureView(){
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
    }
    
    func validateFields() -> String {
        
        var message: String = ""
        
        let whitespace = CharacterSet.whitespaces
        let firstName = FADLocalUser.localUser.firstName?.rangeOfCharacter(from: whitespace)
        if firstName?.lowerBound != nil {
            message = "Spaces are not allowed for first name"
            return message
        }
        
        let lastName = FADLocalUser.localUser.lastName?.rangeOfCharacter(from: whitespace)
        if lastName?.lowerBound != nil {
            message = "Spaces are not allowed for last name"
            return message
        }
        
        if (FADLocalUser.localUser.firstName ?? "").characters.count == 0{
            message = "Enter Your First Name"
            return message
        } else if (FADLocalUser.localUser.lastName ?? "").characters.count == 0 {
            message = "Enter Your Last Name"
            return message
        } else if FADLocalUser.localUser.specialties!.count == 0 {
            message = "Add at least one Specialty"
            return message
        } else if FADLocalUser.localUser.unverifiedLocations!.count == 0 {
            message = "Add at least one Practice Location"
            return message
        } else if FADLocalUser.localUser.insurances!.count == 0 {
            message = "Add at least one Insurance"
            return message
        }
//        else if termsConditionsSelected == false {
//            message = "Agree to the terms and conditions"
//            return message
//        }
        
        return String()
        
    }
    
    func loadCamera() {
        
        let cameraViewController = UIImagePickerController()
        cameraViewController.delegate = self
        cameraViewController.sourceType = .camera
        cameraViewController.allowsEditing = true
        
        self.present(cameraViewController, animated: true, completion: nil)
    }
    
    func loadGallery() {
        
        let cameraViewController = UIImagePickerController()
        cameraViewController.delegate = self
        cameraViewController.sourceType = .photoLibrary
        cameraViewController.allowsEditing = true
        
        self.present(cameraViewController, animated: true, completion: nil)
    }

}

//MARK:- TableView Delegates

extension FADDoctorInfoViewController: UITableViewDelegate,UITableViewDataSource, UITextFieldDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 6
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let sectionType = FADPInfo(rawValue: section)! as FADPInfo
        switch sectionType {
            
        case .info:
            return 1
            
        case .speciality:
            return FADLocalUser.localUser.specialties!.count + 1
            
        case .subSpeciality:
            return FADLocalUser.localUser.subspecialties!.count
            
        case .practiceLocation:
            return FADLocalUser.localUser.unverifiedLocations!.count + 1
            
        case .hospitalAffliations:
            return FADLocalUser.localUser.hospitalAffliations!.count + 1
            
        case .insurances:
            return FADLocalUser.localUser.insurances!.count + 1
            
//        case .termsAndConditions:
//            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let sectionType = FADPInfo(rawValue: (indexPath as NSIndexPath).section)! as FADPInfo
        switch sectionType {
            
        case .info:
            
            if FADLocalUser.localUser.userFullName().characters.count == 0 {
                return editableInfoCell(indexPath: indexPath)
            } else {
                return infoCell(indexPath)
            }
            
        case .speciality:
            
            if FADLocalUser.localUser.specialties!.count > indexPath.row {
                return specialityCell(indexPath)
            } else {
                return addNewItemCell(indexPath: indexPath)
            }
            
        case .subSpeciality:
            return subSpecialityCell(indexPath)
            
        case .practiceLocation:
        
            if FADLocalUser.localUser.unverifiedLocations!.count > indexPath.row {
                return practiceLocationCell(indexPath)
            } else {
                return addNewItemCell(indexPath: indexPath)
            }
            
        case .hospitalAffliations:
            if FADLocalUser.localUser.hospitalAffliations!.count > indexPath.row {
                return hospitalCell(indexPath)
            } else {
                return addNewItemCell(indexPath: indexPath)
            }
            
        case .insurances:
            if FADLocalUser.localUser.insurances!.count > indexPath.row {
                return insuranceCell(indexPath)
            } else {
                return addNewItemCell(indexPath: indexPath)
            }

//        case .termsAndConditions:
//            return termsandConditionCell(indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let sectionType = FADPInfo(rawValue: section)! as FADPInfo
        let sectionView = FADHeaderView(frame: CGRect.zero)
        
        switch sectionType {
            
        case .speciality:
            
            sectionView.configureViewWithTitle("Specialties")
            return sectionView
            
        case .subSpeciality:
            
            sectionView.configureViewWithTitle("Sub-Specialties")
            return sectionView
            
        case .practiceLocation:
            sectionView.configureViewWithTitle("Practice Locations")
            return sectionView
            
        case .hospitalAffliations:
            sectionView.configureViewWithTitle("Hospital Affiliations")
            return sectionView
            
        case .insurances:
            sectionView.configureViewWithTitle("Insurances Accepted")
            return sectionView
            
        default:
            return UIView()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        
        let sectionType = FADPInfo(rawValue: section)! as FADPInfo
        switch sectionType {
            
        case .speciality:
            return 40
            
        case .practiceLocation:
            return 40
            
        case .subSpeciality:
            return 40
            
        case .hospitalAffliations:
            return 40
            
        case .insurances:
            return 40
            
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let sectionType = FADPInfo(rawValue: indexPath.section)! as FADPInfo
        if sectionType == FADPInfo.info {
            if FADLocalUser.localUser.userFullName().characters.count == 0 {
                return 355
            } else {
                return 315
            }
        }

        return UITableViewAutomaticDimension
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        
        let sectionType = FADPInfo(rawValue: indexPath.section)! as FADPInfo
        if sectionType == FADPInfo.hospitalAffliations {
            loadAddHospitalView()
        } else if sectionType == FADPInfo.insurances {
            loadInsurancesView()
        } else if sectionType == FADPInfo.practiceLocation {
            loadAddLocationView()
        } else if sectionType == FADPInfo.speciality {
            loadAddSpecialityView()
        }
        
        return
    }
    
    func loadAddHospitalView() {
        
        let hospitalSearchVC = storyboard!.instantiateViewController(withIdentifier: "FADHospitalSearchViewController") as! FADHospitalSearchViewController
        hospitalSearchVC.delegate = self
        
        let navController = UINavigationController(rootViewController: hospitalSearchVC)
        navController.navigationBar.isTranslucent = false
        
        self.present(navController, animated: true, completion: nil)
        
    }
    
    func loadInsurancesView() {
        
        let insuranceSearchVC = storyboard!.instantiateViewController(withIdentifier: "FADInsurancesViewController") as! FADInsurancesViewController
        insuranceSearchVC.delegate = self
        
        let navVC = UINavigationController(rootViewController: insuranceSearchVC)
        navVC.navigationBar.isTranslucent = false
        
        self.present(navVC, animated: true, completion: nil)
        
    }
    
    func showActionSheet() {
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            actionSheet.dismiss(animated: true, completion: nil)
            self.loadCamera()
        }
        
        let libraryAction = UIAlertAction(title: "Gallery", style: .default) { (action) in
            actionSheet.dismiss(animated: true, completion: nil)
            self.loadGallery()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            actionSheet.dismiss(animated: true, completion: nil)
        }
        
        actionSheet.addAction(cameraAction)
        actionSheet.addAction(libraryAction)
        actionSheet.addAction(cancelAction)
        
        self.present(actionSheet, animated: true, completion: nil)
        
    }
    
}

//MARK:- PracticeLocation Delegate

extension FADDoctorInfoViewController: FADpracticeLocationDelegate{
    
    func didSelectPracticeView(_ cell: FADPracticeLocationCell) {
        
    }
    
    func didDeletePracticeLocation(_ location: FADPracticeLocation) {
        
        if location.organizationID != nil {
            FADLocalUser.localUser.verifiedLocations?.remove(location)
        } else {
            FADLocalUser.localUser.unverifiedLocations?.remove(location)
        }
        tableView.reloadData()
        
    }
}

//MARK:- Speciality Delegate

extension FADDoctorInfoViewController : FADSpecialtyDelegate {
   
    func didFinishWithSpecialties(_ specialties: NSArray, subSpecialties: NSArray) {
        
        FADLocalUser.localUser.specialties = NSMutableArray(array: specialties)
        FADLocalUser.localUser.subspecialties = NSMutableArray(array: subSpecialties)
        
        self.dismiss(animated: true, completion: nil)
        
        tableView.reloadData()
    }
}

//MARK:- Speciality Delegate

extension FADDoctorInfoViewController: FADTrayRemoveDelegate {
    
    func didRemoveSpeciality(_ taxonomy: FADPTaxonomy, specType: FADSpecType) {
        
        if specType == FADSpecType.specialty {
           
            FADLocalUser.localUser.specialties!.remove(taxonomy)
            
            let predicate = NSPredicate(format: "parentId = %@", taxonomy.taxonomyId!)
            let subSpecialties = FADLocalUser.localUser.subspecialties?.filtered(using: predicate)
            if subSpecialties!.count > 0 {
                FADLocalUser.localUser.subspecialties?.removeObjects(in: subSpecialties!)
            }
            
        } else {
            FADLocalUser.localUser.subspecialties!.remove(taxonomy)
        }
        
        tableView.reloadData()
    }
}

extension FADDoctorInfoViewController: FADTermsConditionDelegate {
    
    func didTermsConditionButtonTapped(_ button: FADTermsConditionCell) {
        termsConditionsSelected = button.selectedState
    }
}

extension FADDoctorInfoViewController: FADPracticeLocationViewDelegate {
    
    func didAddPracticeLocation(_ location: FADPracticeLocation) {
        
        FADLocalUser.localUser.unverifiedLocations!.add(location)
//        tableView.reloadSections(IndexSet(integer: 3), with: .automatic)
        tableView.reloadData()
        self.dismiss(animated: true, completion: nil)
    }
}

extension FADDoctorInfoViewController: FADEditableInfoCellDelegate, FADInfoCellDelegate {
    
    func firstNameChanged(firstName: String) {
        
        FADLocalUser.localUser.firstName = firstName
        
    }
    
    func lastNameChanged(lastName: String) {
        
        FADLocalUser.localUser.lastName = lastName
        
    }
    
    func genderChanged(gender: String) {
        
        FADLocalUser.localUser.gender = gender
//        self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        
    }
    
    func didProfileImageViewTapped() {
        showActionSheet()
    }
    
}

extension FADDoctorInfoViewController : FADHospitalDelegate {
    
    func didRemoveHospital(_ hospital: FADLocalHospital) {
        
        FADLocalUser.localUser.hospitalAffliations?.remove(hospital)
        tableView.reloadSections(IndexSet(integer: 4), with: .automatic)
        
    }
    
}

extension FADDoctorInfoViewController: FADHospitalSearchViewDelegate {
    
    func didChooseHospital(hospital: FADLocalHospital) {
        
        self.dismiss(animated: true, completion: nil)
        if FADLocalUser.localUser.hospitalAffliations?.contains(hospital) == false {
            
            FADLocalUser.localUser.hospitalAffliations?.add(hospital)
            tableView.reloadData()
            
        }
    }
    
}

extension FADDoctorInfoViewController: FADDIInsuranceDelegate {
    
    func didRemoveInsurance(_ insuranceID: String) {
        FADLocalUser.localUser.insurances?.remove(insuranceID)
        tableView.reloadSections(IndexSet(integer: 5), with: .automatic)
    }
    
}

extension FADDoctorInfoViewController: FADInsurancesViewDelegate {
    
    func didChooseInsurances(insurances: NSArray) {
        
        self.dismiss(animated: true, completion: nil)
        FADLocalUser.localUser.insurances = NSMutableArray(array: insurances)
        tableView.reloadSections(IndexSet(integer: 5), with: .automatic)
    }
    
}

extension FADDoctorInfoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let imagePicked = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        var imageData: Data
        if let croppedImage = info[UIImagePickerControllerEditedImage] {
            imageData = UIImagePNGRepresentation(croppedImage as! UIImage)! as Data
        } else {
            imageData = UIImagePNGRepresentation(imagePicked)! as Data
        }
        
        FADNetwork.networkManager.upload(imageUpload: IMAGE_UPLOAD_URN, fileData: imageData, success: { (result) in
            
            let response = result as! [String : AnyObject]
            FADLocalUser.localUser.imageID = response[IMAGE_ID_KEY] as? String
            
            let filePath = String.profileImagePath()
            try? imageData.write(to: URL(fileURLWithPath: filePath), options: [.atomic])
            
            self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
            
        }) { (error) in
            // TODO: Handle Failure
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
