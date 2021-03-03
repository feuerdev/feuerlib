//
//  FeuerShareViewController.swift
//  Feuerlib
//
//  Created by Jannik Feuerhahn on 15.02.21.
//

import UIKit

open class FeuerShareViewController: UIViewController {
    
    /// openURL is usually not allowed in Extension Contexts, this goes up the responder chain and calls the openURL function on the application object instead
    @objc
    public func openURL(_ url:URL) -> Bool {
        var responder: UIResponder? = self
        while responder != nil {
            if let application = responder as? UIApplication {
                return application.perform(#selector(openURL(_:)), with: url) != nil
            }
            responder = responder?.next
        }
        return false
    }
}
