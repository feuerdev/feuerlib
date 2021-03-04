//
//  Intersection.swift
//  Feuerlib
//
//  Created by Jannik Feuerhahn on 03.03.21.
//
public func intersects(ray:Ray, sphere:Sphere) -> (Float, Float) {
    let oc = ray.origin - sphere.center
    
    let a = Vector3.dot(ray.direction, ray.direction)
    let b = 2 * Vector3.dot(oc, ray.direction)
    let c = Vector3.dot(oc, oc) - sphere.radius*sphere.radius
    
    let discriminant = b*b - 4*a*c
    if discriminant < 0 {
        return (Float.greatestFiniteMagnitude, Float.greatestFiniteMagnitude)
    }
    
    let t1 = (-b + discriminant.squareRoot()) / (2*a)
    let t2 = (-b - discriminant.squareRoot()) / (2*a)
    return (t1, t2)
}
