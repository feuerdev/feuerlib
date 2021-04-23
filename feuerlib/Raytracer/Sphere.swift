//
//  Sphere.swift
//  Feuerlib
//
//  Created by Jannik Feuerhahn on 03.03.21.
//
public struct Sphere: Hashable {
    
    private static var index = 1
    
    public var id:Int
    public var name: String
    public var center:Vector3
    public var radius:Float
    public var color: RGBColor
    public var specular: Int
    public var reflectivity: Float
    
    public init(center:Vector3, radius:Float, color:RGBColor, specular:Int = -1, reflectivity:Float = 0) {
        self.id = Sphere.index
        self.name = "Sphere \(Sphere.index)"
        self.center = center
        self.radius = radius
        self.color = color
        self.specular = specular
        self.reflectivity = reflectivity
        Sphere.index += 1
    }
    
    public static func createRandom() -> Sphere {
        let sphere = Sphere(center: .init(Float.random(in: -5...5), Float.random(in: 0...5), Float.random(in: -5...5)), radius: Float.random(in: 0.2...2.2), color: .init(Int.random(in: 0...255), Int.random(in: 0...255), Int.random(in: 0...255)), specular: Int.random(in: -1...500), reflectivity: Float.random(in: 0...1))
        return sphere
    }
}
