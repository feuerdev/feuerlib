//
//  Light.swift
//  Feuerlib
//
//  Created by Jannik Feuerhahn on 03.03.21.
//
public enum LightType {
    case point, ambient, directional
}

public struct Light {
    let type: LightType
    let intensity: Float
    var position: Vector3 = Vector3(0,0,0)
    var direction: Vector3 = Vector3(0,0,0)
    
    public init(type: LightType, intensity:Float, position:Vector3 = Vector3(0,0,0), direction:Vector3 = Vector3(0,0,0)) {
        self.type = type
        self.intensity = intensity
        self.position = position
        self.direction = direction
    }
}
