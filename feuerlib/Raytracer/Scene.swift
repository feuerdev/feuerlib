//
//  Scene.swift
//  Feuerlib
//
//  Created by Jannik Feuerhahn on 03.03.21.
//
public struct Scene: Hashable {
    
    
    public var spheres:[Sphere]
    public var lights:[Light]
    public var cameraPosition:Vector3
    public var cameraRotation:[[Float]]
    
    public init(spheres:[Sphere],
                lights:[Light],
                cameraPosition:Vector3 = Vector3(0,0,0),
                cameraRotation:[[Float]] = [[1, 0, 0],
                                            [0, 1, 0],
                                            [0, 0, 1]]) {
        self.spheres = spheres
        self.lights = lights
        self.cameraPosition = cameraPosition
        self.cameraRotation = cameraRotation
    }
}
