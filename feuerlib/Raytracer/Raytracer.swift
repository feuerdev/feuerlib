import CoreGraphics

///Basic Raytracing implemented in Swift based on CoreGraphics Bitmap Context
public class Raytracer {

    ///Width of Canvas
    let width:Int
    
    ///Height of Canvas
    let height:Int
    
    //Aspect Ratio
    let aspect:Float
    
    ///Scene Data
    public var scene:Scene
    
    ///Background color
    let background:RGBColor
    
    ///Reflection Recursion Depth
    let rDepth:Int
    
    ///Pixel buffer
    var pixels: [UInt32]
    
    //Very small number
    let epsilon: Float = 0.01

    /// Constructor
    /// - Parameters:
    ///   - width: width of Canvas
    ///   - height: height of Canvas
    ///   - background: default pixel background color
    ///   - rDepth: reflection recursion depth
    public init(width:Int, height:Int, scene:Scene, background:RGBColor = .black, rDepth:Int = 2) {
        self.width = width
        self.height = height
        self.aspect = Float(height)/Float(width)
        self.scene = scene
        self.background = background
        self.pixels = [UInt32](repeating: background.toUInt32(), count: width*height)
        self.rDepth = rDepth
    }

    /// Render the scene
    /// - Returns: Image or nil
    public func draw() -> CGImage? {
        fillBuffer()
        return createContext()?.makeImage()
    }

    /// Base API to set a pixel to a color. Converts from cartesian system (origin in center) to graphics system (origin top left)
    /// - Parameters:
    ///   - x: Cartesian X coordinate
    ///   - y: Cartesian Y coordinate
    ///   - color: Color of pixel
    private func putPixel(_ x:Int, _ y:Int, _ color: RGBColor) {
        let sX = (width/2)+x
        let sY = (height/2)-y-1
        let index = (width*sY)+(sX)
        pixels[index] = color.toUInt32()
    }

    /// Main work function iterates through each pixel on the canvas and calculates its pixel color
    private func fillBuffer() {
        for x in -width/2..<width/2 {
            for y in -height/2..<height/2 {
                let direction = canvasToViewport(x,y) * scene.cameraRotation
                let ray = Ray(origin: scene.cameraPosition, direction: direction)
                let color = traceRay(ray, tMin:scene.projectionPlane, tMax:Float.greatestFiniteMagnitude, rDepth: self.rDepth)
                putPixel(x,y,color)
            }
        }
    }

    /// Calculates the viewport coordinate for a given canvas pixel
    /// - Parameters:
    ///   - x: Cartesian X coordinate
    ///   - y: Cartesian Y coordinate
    /// - Returns: Vector3 of given pixel on the viewport
    private func canvasToViewport(_ x:Int, _ y:Int) -> Vector3 {
        return Vector3(
            Float(x)*scene.viewportSize/Float(width),
            Float(y)*(scene.viewportSize * aspect)/Float(height),
            scene.projectionPlane)
    }
    
    ///Calculate light level for a given ray
    private func computeLighting(_ point:Vector3, _ normal:Vector3, _ view:Vector3, _ specular:Int) -> Float {
        var intensity:Float = 0.0
        var L:Vector3? = nil
        var tMax:Float = 0
        for light in scene.lights {
            if light.type == .ambient {
                intensity += light.intensity
            } else {
                if light.type == .point {
                    L = light.position - point
                    tMax = 1
                } else {
                    L = light.direction
                    tMax = Float.greatestFiniteMagnitude
                }
                
                guard let L = L else {
                    return 0
                }
                
                // Shadow check
                let (shadowSphere, _) = closestIntersection(Ray(origin: point, direction: L), tMin: epsilon, tMax: tMax)
                if shadowSphere != nil {
                    continue
                }
                
                //Diffuse
                let n_dot_1 = Vector3.dot(normal, L)
                if n_dot_1 > 0 {
                    intensity += light.intensity * n_dot_1 / (normal.length() * L.length())
                }
                
                //Specular
                if specular != -1 {
                    let R = (normal * (2 * Vector3.dot(normal, L))) - L
                    let r_dot_v = Vector3.dot(R, view)
                    if r_dot_v > 0 {
                        intensity += light.intensity * powf(r_dot_v / (R.length() * view.length()), Float(specular))
                    }
                }
            }
        }
        return intensity
    }
    
    private func closestIntersection(_ ray:Ray, tMin:Float, tMax:Float) -> (Sphere?, Float) {
        var tClosest = Float.greatestFiniteMagnitude
        var sClosest:Sphere? = nil
        for sphere in scene.spheres {
            let (t1, t2) = intersects(ray: ray, sphere: sphere)
            if t1 < tMax && t1 > tMin && t1 < tClosest {
                tClosest = t1
                sClosest = sphere
            }
            if t2 < tMax && t2 > tMin && t2 < tClosest {
                tClosest = t2
                sClosest = sphere
            }
        }
        return (sClosest, tClosest)
    }
    
    private func reflectRay(_ R:Vector3, _ N:Vector3) -> Vector3 {
        return ((N * 2) * Vector3.dot(N, R)) - R
    }

    /// Calculates the target color of a given ray
    /// - Parameters:
    ///   - from: Vector3 of camera origin
    ///   - to: Vector3 of viewport coordinate
    ///   - tMin: Position on ray to start tracing
    ///   - tMax: Position on ray to end tracing
    /// - Returns: RGBColor of target color
    private func traceRay(_ ray:Ray, tMin:Float, tMax:Float, rDepth:Int) -> RGBColor {
        let (sClosest, tClosest) = closestIntersection(ray, tMin: tMin, tMax: tMax)
        
        guard let sphere = sClosest else {
            return background
        }
        
        let intersection:Vector3 = ray.origin + (ray.direction * tClosest)
        let normal = (intersection - sphere.center).normalize()
        let view = ray.direction * -1
        let factor = computeLighting(intersection, normal, view, sphere.specular)
        
        let color = sphere.color * factor
        
        let reflectivity = sphere.reflectivity
        if rDepth <= 0 || reflectivity <= 0 {
            return color
        }

        let reflectedRay = reflectRay(view, normal)
        let reflectedColor = traceRay(Ray(origin: intersection, direction: reflectedRay), tMin: epsilon, tMax: Float.greatestFiniteMagnitude, rDepth: rDepth-1)
        
        let combinedColor = (color * (1 - reflectivity)) + (reflectedColor * reflectivity)
        return combinedColor
    }

    /// Sets up the rendering context using CoreGraphics
    /// - Returns: CGContext or nil
    private func createContext() -> CGContext? {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo.byteOrder32Little.rawValue |
                         CGImageAlphaInfo.premultipliedFirst.rawValue &
                         CGBitmapInfo.alphaInfoMask.rawValue
        let height = pixels.count / width
        let bytesPerRow = width * 4
        let context = pixels.withUnsafeMutableBufferPointer { (ptr) -> CGContext? in
            let context = CGContext(data: ptr.baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo)
            return context
        }
        return context
    }
}
