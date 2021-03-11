//
//  Vector3.swift
//  Feuerlib
//
//  Created by Jannik Feuerhahn on 03.03.21.
//
public struct Vector3 {
    public var x:Float
    public var y:Float
    public var z:Float
    
    public init(_ x:Float, _ y:Float, _ z:Float) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    public func length() -> Float {
        return (x*x+y*y+z*z).squareRoot()
    }
    
    public func normalize() -> Vector3 {
        return self / self.length()
    }
    
    static public func + (_ v1:Vector3, _ number:Float) -> Vector3 {
        return .init(v1.x+number, v1.y+number, v1.z+number)
    }
    
    static public func + (_ v1:Vector3, _ v2:Vector3) -> Vector3 {
        return Vector3(v1.x+v2.x, v1.y+v2.y, v1.z+v2.z)
    }
    
    static public func - (_ v1:Vector3, _ v2:Vector3) -> Vector3 {
        return Vector3(v1.x-v2.x, v1.y-v2.y, v1.z-v2.z)
    }
    
    static public func * (_ v1:Vector3, _ number:Float) -> Vector3 {
        return .init(v1.x*number, v1.y*number, v1.z*number)
    }
    
    static public func * (_ v1:Vector3, _ v2:Vector3) -> Vector3 {
        return Vector3(v1.x*v2.x, v1.y*v2.y, v1.z*v2.z)
    }    
    
    static public func / (_ v1:Vector3, _ number:Float) -> Vector3 {
        return .init(v1.x/number, v1.y/number, v1.z/number)
    }
    
    static public func / (_ v1:Vector3, _ v2:Vector3) -> Vector3 {
        return Vector3(v1.x/v2.x, v1.y/v2.y, v1.z/v2.z)
    }
    
    static public func dot(_ v1:Vector3, _ v2:Vector3) -> Float {
        return v1.x*v2.x + v1.y*v2.y + v1.z*v2.z
    }
}
