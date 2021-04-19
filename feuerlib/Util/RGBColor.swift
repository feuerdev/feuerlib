//
//  RGBColor.swift
//  Feuerlib
//
//  Created by Jannik Feuerhahn on 10.03.21.
//
import UIKit

///RGB color representation without alpha component
public struct RGBColor: Hashable {
    public var red:Int
    public var green:Int
    public var blue:Int
    
    public init(_ red:Int,_ green:Int,_ blue:Int) {
        self.red = max(min(red, 255), 0)
        self.green = max(min(green, 255), 0)
        self.blue = max(min(blue, 255), 0)
    }
    
    ///Converts UInt32 hex integer of format 0xFF000000 (alpha, r, g, b) to RGBColor
    public init(with hex:UInt32) {
        let comps = hex.toRGBAIntComponents()
        self.init(comps[0], comps[1], comps[2])
    }
    
    ///Converts RGBColor to UIColor
    public func toUIColor() -> UIColor {
        return UIColor(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: 1)
    }
    
    ///Converts RGBColor to UInt32 hex integer of format 0xFF000000 (alpha, r, g, b)
    public func toUInt32() -> UInt32 {
        return UInt32((255 << 24) | (red << 16) | (green << 8) | blue)
    }
    
    public static func + (_ c1:RGBColor, _ c2:RGBColor) -> RGBColor {
        return .init(c1.red + c2.red, c1.green + c2.green, c1.blue + c2.blue)
    }
    
    public static func * (_ c1:RGBColor, _ c2:RGBColor) -> RGBColor {
        return .init(c1.red * c2.red / 255, c1.green * c2.green / 255, c1.blue * c2.blue / 255)
    }
    
    public static func * (_ c1:RGBColor, _ factor:Float) -> RGBColor {
        return .init(Int(Float(c1.red) * factor), Int(Float(c1.green) * factor), Int(Float(c1.blue) * factor))
    }
}

extension RGBColor {
    public static let red = RGBColor(255, 0, 0)
    public static let green = RGBColor(0, 255, 0)
    public static let blue = RGBColor(0, 0, 255)
    public static let yellow = RGBColor(255, 255, 0)
    public static let black = RGBColor(0, 0, 0)
    public static let white = RGBColor(255, 255, 255)
}
