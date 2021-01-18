//
//  UISearchBar.swift
//  Feuerlib
//
//  Created by Jannik Feuerhahn on 28.12.20.
//

import UIKit

extension UISearchBar {
    public func getTextField() -> UITextField? { return value(forKey: "searchField") as? UITextField }
    
    public func setTextField(color: UIColor) {
        guard let textField = getTextField() else { return }
        switch searchBarStyle {
        case .minimal:
            textField.layer.backgroundColor = color.cgColor
            textField.layer.cornerRadius = 6
        case .prominent, .default: textField.backgroundColor = color
        @unknown default: break
        }
    }
    
    public func setSearchIconColor(_ color:UIColor) {
        if let icon = getTextField()?.leftView as? UIImageView { //Magnifying glass
            icon.image = icon.image?.withRenderingMode(.alwaysTemplate)
            icon.tintColor = color
        }
    }
    
    public func setTextColor(_ color:UIColor) {
        getTextField()?.textColor = color
    }
    
    public func setPlaceholderTextColor(_ color:UIColor) {
       getTextField()?.attributedPlaceholder = NSAttributedString(string: getTextField()?.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor : color])
        
    }
    
}
