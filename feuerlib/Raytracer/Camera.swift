//
//  Camera.swift
//  Feuerlib
//
//  Created by Jannik Feuerhahn on 21.03.21.
//

import Foundation

public struct Camera:Hashable {
    
    public var position:Vector3
    public var pitch:Float {
        didSet {
            self.matrix = Camera.calculate(pitch:pitch, roll:roll, yaw:yaw)
        }
    }
    public var roll:Float {
        didSet {
            self.matrix = Camera.calculate(pitch:pitch, roll:roll, yaw:yaw)
        }
    }
    public var yaw:Float {
        didSet {
            self.matrix = Camera.calculate(pitch:pitch, roll:roll, yaw:yaw)
        }
    }
    ///Size of the viewport determines fov
    public var viewportSize:Float = 1
    
    ///Distance of camera to viewport
    public var projectionPlane:Float = 1
    
    public var matrix:[[Float]]
    
    public init(position: Vector3 = .init(0,0,0),
        pitch:Float = 0,
        roll:Float = 0,
        yaw:Float = 0) {
        self.position = position
        self.pitch = pitch
        self.roll = roll
        self.yaw = yaw
        self.matrix = Camera.calculate(pitch:pitch, roll:roll, yaw:yaw)
    }
    
    private static func calculate(pitch:Float, roll:Float, yaw:Float) -> [[Float]] {
        let cosa = cos(yaw)
        let sina = sin(yaw)

        let cosb = cos(pitch)
        let sinb = sin(pitch)

        let cosc = cos(roll)
        let sinc = sin(roll)

        let axx = cosa*cosb
        let axy = cosa*sinb*sinc - sina*cosc
        let axz = cosa*sinb*cosc + sina*sinc

        let ayx = sina*cosb
        let ayy = sina*sinb*sinc + cosa*cosc
        let ayz = sina*sinb*cosc - cosa*sinc

        let azx = -sinb
        let azy = cosb*sinc
        let azz = cosb*cosc
        
        let mtx = [
            [axx, axy, axz],
            [ayx, ayy, ayz],
            [azx, azy, azz]
        ]
        return mtx
    }
}
