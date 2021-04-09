//
//  Scene.swift
//  Feuerlib
//
//  Created by Jannik Feuerhahn on 03.03.21.
//
public struct Scene: Hashable {
    public var spheres:[Sphere]
    public var lights:[Light]
    public var camera:Camera
    
    ///Background color
    public var background:RGBColor
    
    ///Reflection Recursion Depth
    public var reflections:Int
    
    public init(spheres:[Sphere],
                lights:[Light],
                background:RGBColor = .black,
                reflections:Int = 3,
                camera:Camera = Camera()) {
        self.spheres = spheres
        self.lights = lights
        self.background = background
        self.reflections = reflections
        self.camera = camera
    }
    
    ///Manually defined Scene for testing purposes
    public static let testScene:Scene = {
        let testSpheres = [
            Sphere(center:Vector3(0.3, 0.5, 0), radius: 0.5, color: .black, specular: 1000, reflectivity: 0.2),
            Sphere(center:Vector3(0, 3, 2), radius: 2, color: .red, specular: 100000, reflectivity: 0.05),
            Sphere(center: Vector3(1, 0, 3), radius: 1, color: .blue, specular: 500, reflectivity: 0.08),
            Sphere(center: Vector3(-2, 0, 3), radius: 1, color: .green, specular: 10, reflectivity: 0.06),
            Sphere(center: Vector3(0, -5001, 0), radius: 5000, color: .white, specular: 1000, reflectivity: 0.02)
        ]
        let testLights = [
            Light(type: .ambient, intensity: 0.3),
            Light(type: .point, intensity: 0.9, position: .init(2, 3, -1)),
//            Light(type: .directional, intensity: 0.7, direction: .init(1, 4, 4))
        ]
        let scene = Scene(spheres: testSpheres, lights: testLights, background: .init(107,159,227), camera: Camera(position: .init(4.5, 2.9, -3), pitch: -0.7, roll: 0, yaw: 0.08))
        return scene
    }()
}
