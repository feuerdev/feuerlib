//
//  RenderQuality.swift
//  Feuerlib
//
//  Created by Jannik Feuerhahn on 09.04.21.
//

public enum EnumRenderQuality {
    case low, medium, high
}

public struct RenderQuality: Hashable {
    public var low:Float
    public var medium:Float
    public var high:Float
    
    public init(low:Float, medium:Float, high:Float) {
        self.low = low
        self.medium = medium
        self.high = high
    }
}
