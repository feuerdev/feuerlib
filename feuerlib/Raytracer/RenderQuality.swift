//
//  RenderQuality.swift
//  Feuerlib
//
//  Created by Jannik Feuerhahn on 09.04.21.
//

public struct RenderQuality: Hashable {
    public let low:Float
    public let medium:Float
    public let high:Float
    
    public init(low:Float, medium:Float, high:Float) {
        self.low = low
        self.medium = medium
        self.high = high
    }
}
