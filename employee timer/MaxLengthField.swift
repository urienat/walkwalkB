//
//  MaxLengthField.swift
//  employee timer
//
//  Created by אורי עינת on 27.12.2016.
//  Copyright © 2016 אורי עינת. All rights reserved.
//

import Foundation
import UIKit

import UIKit

class MaxLengthTextField: UITextField, UITextFieldDelegate {
    
    //keyboard hide
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        let field = textField
        field.resignFirstResponder()
        
        return true
    } //end of keyboard hide

    
    private var characterLimit: Int?
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        delegate = self
    }
    
    @IBInspectable var maxLength: Int {
        get {
            guard let length = characterLimit else {
                return Int.max
            }
            return length
        }
        set {
            characterLimit = newValue
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard string.characters.count > 0 else {
            return true
        }
        
        let currentText = textField.text ?? ""
        let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        // 1. Here's the first change...
        return allowedIntoTextField(text: prospectiveText)
    }
    
    // 2. ...and here's the second!
    func allowedIntoTextField(text: String) -> Bool {
        return text.characters.count <= maxLength
    }
    
    
        
}
