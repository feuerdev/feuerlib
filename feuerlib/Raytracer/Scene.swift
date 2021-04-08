//
//  Scene.swift
//  Feuerlib
//
//  Created by Jannik Feuerhahn on 03.03.21.
//
public struct Scene: Hashable {
    
    
    public var spheres:[Sphere]
    public var lights:[Light]
    public var background:RGBColor
    
    public init(spheres:[Sphere],
                lights:[Light],
                background:RGBColor = .black,
        self.spheres = spheres
        self.lights = lights
        self.background = background
    }
    
    public static let testScene:Scene = {
        let testSpheres = [
            Sphere(center:Vector3(0, -1, 3), radius: 1, color: .white, specular: 1000, reflectivity: 0.2),
            Sphere(center:Vector3(0, 3, 3), radius: 2, color: .red, specular: 10000, reflectivity: 0.4),
            Sphere(center: Vector3(2, 0, 4), radius: 1, color: .blue, specular: 500, reflectivity: 0.3),
            Sphere(center: Vector3(-2, 0, 4), radius: 1, color: .green, specular: 10, reflectivity: 0.4),
            Sphere(center: Vector3(0, -5001, 0), radius: 5000, color: .yellow, specular: 1000, reflectivity: 0)
        ]
        let testLights = [
            Light(type: .ambient, intensity: 0.4),
            Light(type: .point, intensity: 0.2, position: .init(2, 3, 3)),
            Light(type: .point, intensity: 0.6, position: .init(2, 3, -1)),
            Light(type: .directional, intensity: 0.2, direction: .init(1, 4, 4))
        ]
        let scene = Scene(spheres: testSpheres, lights: testLights, cameraPosition: .init(0, 0, -10))
        return scene
    }()
}
