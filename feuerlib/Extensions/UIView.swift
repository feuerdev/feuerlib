//
//  UIView.swift
//  Feuerlib
//
//  Created by Jannik Feuerhahn on 12.01.21.
//

import UIKit

extension UIView {
    
    /**
     Loads nib statically from Custom Class
     */
    public class func fromNib() -> Self {
        return Bundle.main.loadNibNamed(String(describing: self), owner: nil, options: nil)![0] as! Self
    }
}
