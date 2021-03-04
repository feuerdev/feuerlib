//
//  Sphere.swift
//  Feuerlib
//
//  Created by Jannik Feuerhahn on 03.03.21.
//
public struct Sphere {
    var center:Vector3
    var radius:Float
    var color: UInt32
    
    public init(center:Vector3, radius:Float, color:UInt32) {
        self.center = center
        self.radius = radius
        self.color = color
    }
}
