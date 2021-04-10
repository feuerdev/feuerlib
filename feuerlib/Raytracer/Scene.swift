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
    
    ///Show point light as small sphere
    public var showLights:Bool
    
    public var quality:RenderQuality
    
    public init(spheres:[Sphere],
                lights:[Light],
                background:RGBColor = .black,
                reflections:Int = 3,
                showLights:Bool = false,
                quality: RenderQuality = RenderQuality(low: 0.1, medium: 0.25, high: 1),
                camera:Camera = Camera()) {
        self.spheres = spheres
        self.lights = lights
        self.background = background
        self.showLights = showLights
        self.reflections = reflections
        self.quality = quality
        self.camera = camera
    }
    
    ///Manually defined Scene for testing purposes
    public static let testScene:Scene = {
        let testSpheres:[Sphere] = [
            Sphere(center:Vector3(-1, 0.3, 2), radius: 1.3, color: .red, specular: 5, reflectivity: 0.12),
            Sphere(center: Vector3(1, 0, 2.5), radius: 1, color: .blue, specular: 1000, reflectivity: 0.38),
            Sphere(center: Vector3(-0.5, 0, 0), radius: 0.7, color: .green, specular: 500, reflectivity: 0.2),
            Sphere(center:Vector3(1, -0.5, 0), radius: 0.5, color: .white, specular: 1000, reflectivity: 0.6),
            Sphere(center: Vector3(0, -5001, 0), radius: 5000, color: .white, specular: 2, reflectivity: 0.02)
                    ]
        let testLights = [
            Light(type: .ambient, intensity: 0.5),
            Light(type: .directional, intensity: 0.5, direction: .init(0.5, 1, 0.2))
        ]
        let scene = Scene(
            spheres: testSpheres,
            lights: testLights,
            background: .init(107,159,227),
            reflections: 3,
            showLights: false,
            camera: Camera(position: .init(4.5, 2.9, -3), pitch: -0.8, roll: 0.34, yaw: 0.08))
        return scene
    }()
}
