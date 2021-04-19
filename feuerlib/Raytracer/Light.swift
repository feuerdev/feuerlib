//
//  Light.swift
//  Feuerlib
//
//  Created by Jannik Feuerhahn on 03.03.21.
//
public enum LightType:Int,CaseIterable {
    case ambient, point, directional
}

public struct Light: Hashable {
    private static var index: Int = 1
    public let id = index
    public let name: String
    public let type: LightType
    public let intensity: Float
    public var position: Vector3 = Vector3(0,0,0)
    public var direction: Vector3 = Vector3(0,0,0)
    
    public init(type: LightType, intensity:Float, position:Vector3 = Vector3(0,0,0), direction:Vector3 = Vector3(0,0,0)) {
        self.name = "Light \(Light.index)"
        self.type = type
        self.intensity = intensity
        self.position = position
        self.direction = direction
        Light.index += 1
    }
}
