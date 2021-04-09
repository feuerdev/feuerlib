import CoreGraphics

///Basic Raytracing implemented in Swift based on CoreGraphics Bitmap Context
public class Raytracer {
    
    ///Width of Canvas
    private var width:Int = 0
    
    ///Height of Canvas
    private var height:Int = 0
    
    //Aspect Ratio
    private var aspect:Float = 0
    
    ///Pixel buffer
    private var pixels: [UInt32] = []
    
    //Very small number
    private let epsilon: Float = 0.04
    
    //Cancel tracing
    private var cancelled = false
    
    public init() {
        //
    }

    /// Render the scene
    /// - Returns: Image or nil
    public func draw(scene:Scene,
                     width:Int,
                     height:Int,
                     quality: EnumRenderQuality = .high,
                     updateHandler:(CGImage) -> Void = { _ in },
                     completionHandler:(CGImage) -> Void) {
        var qualityPercent:Float = 0
        switch quality {
        case .low:
            qualityPercent = scene.quality.low
        case .medium:
            qualityPercent = scene.quality.medium
        case .high:
            qualityPercent = scene.quality.high
        }
        
        self.width = Int(Float(width) * qualityPercent) & ~1
        self.height = Int(Float(height) * qualityPercent) & ~1
        
        self.aspect = Float(height)/Float(width)
        self.pixels = [UInt32](repeating: scene.background.toUInt32(), count: self.width*self.height)
        
        self.fillBuffer(scene: scene, completionHandler: updateHandler)
        guard !cancelled else {
            return
        }
        if let img = createContext()?.makeImage() {
            completionHandler(img)
        }
        
    }
    
    public func trace(_ scene:Scene, _ x:Int, _ y:Int) -> Sphere? {
        let direction = canvasToViewport(scene, x, y) * scene.camera.matrix
        let ray = Ray(origin: scene.camera.position, direction: direction)
        let (sphere, _) = closestIntersection(scene: scene, ray, tMin: epsilon, tMax: .greatestFiniteMagnitude)
        return sphere
    }
    
    /// Cancells the current rendering. Will take effect on the next ray cast. It will then abort and not call the completionHandler
    public func cancel() {
        self.cancelled = true
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
        self.pixels[index] = color.toUInt32()
    }

    /// Main work function iterates through each pixel on the canvas and calculates its pixel color
    private func fillBuffer(scene:Scene, completionHandler:(CGImage) -> Void) {
        for x in -self.width/2..<self.width/2 {
            for y in -self.height/2..<self.height/2 {
                guard !cancelled else {
                    return
                }
                
                let direction = canvasToViewport(scene, x, y) * scene.camera.matrix
                let ray = Ray(origin: scene.camera.position, direction: direction)
                let color = traceRay(scene:scene, ray, tMin:scene.camera.projectionPlane, tMax:Float.greatestFiniteMagnitude, rDepth: scene.reflections)
                putPixel(x,y,color)
                
            }
            if let img = createContext()?.makeImage() {
                completionHandler(img)
            }
        }
    }

    /// Calculates the viewport coordinate for a given canvas pixel
    /// - Parameters:
    ///   - scene: Scene
    ///   - x: Cartesian X coordinate
    ///   - y: Cartesian Y coordinate
    /// - Returns: Vector3 of given pixel on the viewport
    private func canvasToViewport(_ scene:Scene, _ x:Int, _ y:Int) -> Vector3 {
        return Vector3(
            Float(x)*scene.camera.viewportSize/Float(width),
            Float(y)*(scene.camera.viewportSize * aspect)/Float(height),
            scene.camera.projectionPlane)
    }
    
    ///Calculate light level for a given ray
    private func computeLighting(scene:Scene, _ point:Vector3, _ normal:Vector3, _ view:Vector3, _ specular:Int) -> Float {
        var intensity:Float = 0.0
        var lightRay:Vector3? = nil
        var tMax:Float = 0
        for light in scene.lights {
            if light.type == .ambient {
                intensity += light.intensity
            } else {
                if light.type == .point {
                    lightRay = light.position - point
                    tMax = 1
                } else {
                    lightRay = light.direction
                    tMax = Float.greatestFiniteMagnitude
                }
                
                guard let lightRay = lightRay else {
                    return 0
                }
                
                // Shadow check
                let (shadowSphere, _) = closestIntersection(scene:scene, Ray(origin: point, direction: lightRay), tMin: epsilon, tMax: tMax)
                if shadowSphere != nil {
                    continue
                }
                
                //Diffuse
                let n_dot_1 = Vector3.dot(normal, lightRay)
                if n_dot_1 > 0 {
                    intensity += light.intensity * n_dot_1 / (normal.length() * lightRay.length())
                }
                
                //Specular
                if specular != -1 {
                    let R = (normal * (2 * Vector3.dot(normal, lightRay))) - lightRay
                    let r_dot_v = Vector3.dot(R, view)
                    if r_dot_v > 0 {
                        intensity += light.intensity * powf(r_dot_v / (R.length() * view.length()), Float(specular))
                    }
                }
            }
        }
        return intensity
    }
    
    private func closestIntersection(scene:Scene, _ ray:Ray, tMin:Float, tMax:Float) -> (Sphere?, Float) {
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
    
    private func reflectRay(_ ray:Vector3, _ normal:Vector3) -> Vector3 {
        return ((normal * 2) * Vector3.dot(normal, ray)) - ray
    }

    /// Calculates the target color of a given ray
    /// - Parameters:
    ///   - from: Vector3 of camera origin
    ///   - to: Vector3 of viewport coordinate
    ///   - tMin: Position on ray to start tracing
    ///   - tMax: Position on ray to end tracing
    /// - Returns: RGBColor of target color
    private func traceRay(scene:Scene, _ ray:Ray, tMin:Float, tMax:Float, rDepth:Int) -> RGBColor {
        let (sClosest, tClosest) = closestIntersection(scene:scene, ray, tMin: tMin, tMax: tMax)
        
        guard let sphere = sClosest else {
            return scene.background
        }
        
        let intersection:Vector3 = ray.origin + (ray.direction * tClosest)
        let normal = (intersection - sphere.center).normalize()
        let view = ray.direction * -1
        let factor = computeLighting(scene:scene, intersection, normal, view, sphere.specular)
        
        let color = sphere.color * factor
        
        let reflectivity = sphere.reflectivity
        if rDepth <= 0 || reflectivity <= 0 {
            return color
        }

        let reflectedRay = reflectRay(view, normal)
        let reflectedColor = traceRay(scene:scene, Ray(origin: intersection, direction: reflectedRay), tMin: epsilon, tMax: Float.greatestFiniteMagnitude, rDepth: rDepth-1)
        
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
