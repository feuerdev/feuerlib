//
//  UInt32.swift
//  Feuerlib
//
//  Created by Jannik Feuerhahn on 04.03.21.
//

extension UInt32 {
    
    ///Creates a UInt32 based on argb channels
    public init(a:Int, r:Int, g:Int, b:Int) {
        self = UInt32((a << 24) | (r << 16) | (g << 8) | b)
    }
    
    ///Returns an array containing the red, green, blue, alpha components as Float between 0 and 1
    func toRGBAFloatComponents() -> [Float] {
        let components = self.toRGBAIntComponents()
        return components.map { (value) -> Float in
            return Float(value)/255.0
        }
    }
    
    ///Returns an array containing the red, green, blue, alpha components as Ints between 0 and 255
    func toRGBAIntComponents() -> [Int] {
        var result = [Int]()
        result.append(Int((self & 0x00FF0000) >> 16))
        result.append(Int((self & 0x0000FF00) >> 8))
        result.append(Int(self & 0x000000FF))
        result.append(Int((self & 0xFF000000) >> 24))
        return result
    }
    
}
