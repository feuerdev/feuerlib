//
//  Vector3.swift
//  Feuerlib
//
//  Created by Jannik Feuerhahn on 03.03.21.
//
public struct Vector3: Hashable {
    public var x:Float
    public var y:Float
    public var z:Float
    
    public init(_ x:Float, _ y:Float, _ z:Float) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    public init() {
        self.init(0, 0, 0)
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
    
    static public func * (_ v1:Vector3, _ matrix:[[Float]]) -> Vector3 {
        var result = Vector3()
        for i in 0..<3 {
            for j in 0..<3 {
                result[i] += v1[j]*matrix[i][j]
            }
        }
        return result
    }
    
    static public func multiply(_ m1:[[Float]], _ m2:[[Float]]) -> [[Float]] {
        var result = m1
        for i in 0..<3 {
            for j in 0..<3 {
                result[i][j] *= m2[i][j]
            }
        }
        return result
    }
    
    static public func add(_ m1:[[Float]], _ m2:[[Float]]) -> [[Float]] {
        var result = m1
        for i in 0..<3 {
            for j in 0..<3 {
                result[i][j] += m2[i][j]
            }
        }
        return result
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
    
    subscript(index: Int) -> Float {
        get {
            switch index {
            case 0: return self.x
            case 1: return self.y
            case 2: return self.z
            default: return 0
            }
        }
        
        set {
            switch index {
            case 0: self.x = newValue
            case 1: self.y = newValue
            case 2: self.z = newValue
            default: break
            }
        }
    }
}
