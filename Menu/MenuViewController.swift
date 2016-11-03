//
//  FADMenuViewController.swift
//  FINDaDOCTOR
//
//  Created by Mohan Reddy on 3/16/16.
//  Copyright © 2016 FINDaDOCTOR. All rights reserved.
//

import UIKit

enum FADSideMenuItem: Int {
//    case profile
    case home
//    case appointments
    case share
    case faq
//    case notifications
    case about
//    case settings
//    case logout
}

enum FADMenuCellColorState: Int {
    case white
    case gray
    case red
}

protocol FADMenuDelegate {
    
    func didSelectMenuItem(_ selctedIndexPath: IndexPath)
}

class FADMenuViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var delegate: FADMenuDelegate?
    
    var selectedMenuIndexPath: IndexPath!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        selectedMenuIndexPath = IndexPath(row: 0, section: 0)
        NotificationCenter.default.addObserver(self, selector: #selector(userProfileUpdated(_:)), name: NSNotification.Name(rawValue: "fad.user.profile_updated"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func reloadViewController() {
        tableView.reloadData()
    }
    
    func userProfileUpdated(_ notification: Notification) {
        
        self.tableView.reloadData()
    }
}

// MARK: -------------------------------------
// MARK: UITableViewDataSource
// MARK: -------------------------------------
extension FADMenuViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 4
       // return (FADUser.isUserLoggedin() == true ? 9 : 8)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
//        if (indexPath as NSIndexPath).row == 0 {
// 
//            let cell = tableView.dequeueReusableCell(withIdentifier: "FADMenuProfileCell", for: indexPath) as! FADMenuProfileCell
//            cell.configureCell(userDisplayName(), image: UIImage().fad_menu_profileImage())
//            return cell
//        } else {
        
            let cell = tableView.dequeueReusableCell(withIdentifier: "FADSideMenuCell", for: indexPath) as? FADSideMenuCell
            cell?.configureCell(imageForMenuItemAtIndex(indexPath), title: titleForMenuItemAtIndex(indexPath), state: stateForCellAtIndex(indexPath))
            
            return cell!
//        }
    }
    
    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let oldIndex = selectedMenuIndexPath
        selectedMenuIndexPath = indexPath
        
        if oldIndex != selectedMenuIndexPath {
            tableView.reloadData()
        }
        
        if let delegate = self.delegate {
            delegate.didSelectMenuItem(selectedMenuIndexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
//        if (indexPath as NSIndexPath).row == 0 {
//            return 120.0
//        } else {
            return 50.0
//        }
    }
}

// MARK: -------------------------------------
// MARK: Private Methods
// MARK: -------------------------------------
private extension FADMenuViewController {
    
    func userDisplayName() -> String {
        
        return (FADUser.name().characters.count == 0 ? "Welcome" : FADUser.name())
    }
    
    func imageForMenuItemAtIndex(_ indexPath: IndexPath) -> UIImage {
        
        let menuItemIndex = FADSideMenuItem(rawValue: (indexPath as NSIndexPath).row)! as FADSideMenuItem
        switch menuItemIndex {
//        case .profile:
//            return UIImage()
        case .home:
            return UIImage().fad_menu_homeImage()
//        case .appointments:
//            return UIImage().fad_menu_appointmentImage()
        case .share:
            return UIImage().fad_menu_shareFaDImage()
//        case .notifications:
//            return UIImage().fad_menu_notificationImage()
        case .about:
            return UIImage().fad_menu_aboutFaDImage()
//        case .settings:
//            return UIImage().fad_menu_settingsImage()
        case .faq:
            return UIImage().fad_menu_faqImage()
//        case .logout:
//            return UIImage().fad_menu_logoutImage()
        }
    }
    
    func titleForMenuItemAtIndex(_ indexPath: IndexPath) -> String {

        let menuItemIndex = FADSideMenuItem(rawValue: (indexPath as NSIndexPath).row)! as FADSideMenuItem
        switch menuItemIndex {
//        case .profile:
//            return ""
        case .home:
            return "FINDaDOCTOR"
//        case .appointments:
//            return "My Appointments"
        case .share:
            return "Share FaD App"
//        case .notifications:
//            return "Notifications"
        case .about:
            return "About FaD"
//        case .settings:
//            return "Settings"
        case .faq:
            return "Support"
//        case .logout:
//            return "Logout"
        }
    }
    
    func stateForCellAtIndex(_ indexPath: IndexPath) -> FADMenuCellColorState {
        
        if indexPath == selectedMenuIndexPath {
            return .red
        }

        if (indexPath as NSIndexPath).row % 2 == 0 {
            
            return .white
        } else {
            
            return .gray
        }
    }
}
