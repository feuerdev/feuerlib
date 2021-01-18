//
//  UIViewController.swift
//  Feuerlib
//
//  Created by Jannik Feuerhahn on 28.12.20.
//

import UIKit

extension UIViewController {
    
    public func showSimpleError(title:String?, message:String?, popViewController:Bool) {        
        let alert = UIAlertController(title: title ?? "Oops", message: message ?? "It looks like we encountered an error :(", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Go Back", style: .cancel, handler: {_ in
            if popViewController {
                self.navigationController?.popViewController(animated: true)
            }
        }))
        self.present(alert, animated: true)
    }
    
    public func showToast(message:String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        self.present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            alert.dismiss(animated: true, completion: nil)
        }
    }
}
