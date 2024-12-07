//
//  ForgotPasswordCheckEmailViewController.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class ForgotPasswordCheckEmailViewController: UIViewController {
    
    static var TAG = String(describing: ForgotPasswordCheckEmailViewController.classForCoder())

    @IBOutlet weak var buttonBack: UIButtonQuinary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GeneralUtils.log(ForgotPasswordCheckEmailViewController.TAG, "viewDidLoad")
        
        // listeners
        buttonBack.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
    }
    
    deinit {
        GeneralUtils.log(ForgotPasswordCheckEmailViewController.TAG, "deinit")
    }

    // MARK: Custom

    @objc func clickHandler(_ sender: UIView) {
        if (sender == buttonBack) {
            navigationController?.popViewController(animated: true)
        }
    }
}
