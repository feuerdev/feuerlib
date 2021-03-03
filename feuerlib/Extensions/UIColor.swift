//
//  UIColor.swift
//  Feuerlib
//
//  Created by Jannik Feuerhahn on 01.12.20.
//

import UIKit

extension UIColor {
    
    ///Initialises color by hex string e.g. FA341D
    public convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
    
    ///Slightly faded version of the default label color
    @available(iOS 13.0, *)
    public static let highlightedLabel = UIColor.label.withAlphaComponent(0.8)
    
    ///Slightly faded version of the current color
    public var highlighted: UIColor { withAlphaComponent(0.8) }
    
    ///UIImage of current color
    public var image: UIImage {
        let pixel = CGSize(width: 1, height: 1)
        return UIGraphicsImageRenderer(size: pixel).image { context in
            self.setFill()
            context.fill(CGRect(origin: .zero, size: pixel))
        }
    }
    
}
