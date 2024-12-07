//
//  Dropdown.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class Dropdown: UITextField, UIPickerViewDataSource, UIPickerViewDelegate {

    var pickerView: UIPickerView!
    var currentlySelectedItemIndex = 0
    var onItemSelectionConfirmed: ((_ position: Int, _ object: GenericDropdownItemModel) -> (Void))! // 1st - params that callback receives, 2nd - callbacks type
    var dataset: [GenericDropdownItemModel]!
    
    // initialised from Interface Builder
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    // initialised from code
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
        
    //MARK: UIPickerViewDelegate
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let genericDropdownItemModel = dataset[row]

        return genericDropdownItemModel.getTitle()
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataset.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //print("selected: ", dataset[row])
        //label.text = data[row]
    }
    
    // MARK: Custom
    
    func commonInit() {
        pickerView = UIPickerView()
        pickerView.delegate = self
        
        // toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        // toolbar buttons
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)

        let cancelButton = UIBarButtonItem(title: "cancel".localized(), style: .plain, target: nil, action: #selector(actionCancel))

        let doneButton = UIBarButtonItem(title: "ok".localized(), style: .plain, target: nil, action: #selector(actionDone))

        toolbar.setItems([flexibleSpace, cancelButton, doneButton], animated: true)
        
        inputAccessoryView = toolbar
        inputView = pickerView
    }

    func setDropdownData(_ dataset: [GenericDropdownItemModel]) {
        self.dataset = dataset
    }
    
    func show() {
        pickerView.selectRow(currentlySelectedItemIndex, inComponent: 0, animated: false)
        
        becomeFirstResponder()
    }
    
    @objc func actionDone() {
        currentlySelectedItemIndex = pickerView.selectedRow(inComponent: 0)
        
        let selectedItem = dataset[currentlySelectedItemIndex]

        onItemSelectionConfirmed(currentlySelectedItemIndex, selectedItem)
        
        self.endEditing(true)
    }
    
    @objc func actionCancel() {
        self.endEditing(true)
    }
    
    func selectItemById(_ id: String) {
        for i in (0..<dataset.count) {
            let genericDropdownItemModel = dataset[i]
            
            if (genericDropdownItemModel.getId() == id) {
                currentlySelectedItemIndex = i
                
                break
            }
        }
    }
}
