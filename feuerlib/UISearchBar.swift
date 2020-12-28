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
}
