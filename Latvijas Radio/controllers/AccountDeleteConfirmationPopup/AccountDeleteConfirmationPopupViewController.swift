//
//  AccountDeleteConfirmationPopupViewController.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

protocol AccountDeleteConfirmationPopupDelegate: AnyObject {
    func onAccountDeleteConfirmed()
}

class AccountDeleteConfirmationPopupViewController: UIViewController {
    
    var TAG = String(describing: AccountDeleteConfirmationPopupViewController.classForCoder())

    @IBOutlet weak var buttonOk: UIButtonXI!
    @IBOutlet weak var buttonCancel: UIButtonXI!
    
    weak var delegate: AccountDeleteConfirmationPopupDelegate?
    
    var contentType: String!
    var content: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GeneralUtils.log(TAG, "viewDidLoad")
        
        // listeners
        buttonOk.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
        buttonCancel.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
    }
    
    deinit {
        GeneralUtils.log(TAG, "deinit")
    }
    
    @objc func clickHandler(_ sender: UIView) {
        if (sender == buttonOk) {
            dismiss(animated: true, completion: { [weak self] in
                self?.delegate?.onAccountDeleteConfirmed()
            })
        }
        if (sender == buttonCancel) {
            dismiss(animated: true, completion: nil)
        }
    }
}

