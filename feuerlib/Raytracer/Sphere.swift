//
//  Sphere.swift
//  Feuerlib
//
//  Created by Jannik Feuerhahn on 03.03.21.
//
public struct Sphere {
    var center:Vector3
    var radius:Float
    var color: RGBColor
    var specular: Int
    var reflectivity: Float
    
    public init(center:Vector3, radius:Float, color:RGBColor, specular:Int = -1, reflectivity:Float = 0) {
        self.center = center
        self.radius = radius
        self.color = color
        self.specular = specular
        self.reflectivity = reflectivity
    }
}
