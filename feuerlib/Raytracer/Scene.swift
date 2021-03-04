//
//  Scene.swift
//  Feuerlib
//
//  Created by Jannik Feuerhahn on 03.03.21.
//
public struct Scene {
    let spheres:[Sphere]
    let lights:[Light]
    var viewportSize:Float = 1
    var projectionPlane:Float = 1
    
    public var cameraPosition:Vector3 = Vector3(0, 0, 0)
    
    public init(spheres:[Sphere], lights:[Light], cameraPosition:Vector3 = Vector3(0,0,0), viewportSize:Float = 1, projectionPlane:Float = 1) {
        self.spheres = spheres
        self.lights = lights
        self.cameraPosition = cameraPosition
        self.viewportSize = viewportSize
        self.projectionPlane = projectionPlane
    }
}
