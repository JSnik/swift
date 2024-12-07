//
//  RegistrationCheckEmailViewController.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class RegistrationCheckEmailViewController: UIViewController {
    
    static var TAG = String(describing: RegistrationCheckEmailViewController.classForCoder())

    @IBOutlet weak var buttonBack: UIButtonQuinary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GeneralUtils.log(RegistrationCheckEmailViewController.TAG, "viewDidLoad")
        
        // listeners
        buttonBack.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
    }
    
    deinit {
        GeneralUtils.log(RegistrationCheckEmailViewController.TAG, "deinit")
    }
    
    // MARK: Custom

    @objc func clickHandler(_ sender: UIView) {
        if (sender == buttonBack) {
            navigationController?.popViewController(animated: true)
        }
    }
}

