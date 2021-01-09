//
//  UITableView.swift
//  Feuerlib
//
//  Created by Jannik Feuerhahn on 09.01.21.
//

import UIKit

extension UITableView {
    
    /**
     Hide the additional dividers on the bottom of the UITableView by adding an empty footer view.
     */
    public func hideAdditionalDividers() {
        guard self.tableFooterView == nil else {
            //footerView is already set, there should be no additional dividers
            return
        }
        
        self.tableFooterView = UIView()
    }
}
