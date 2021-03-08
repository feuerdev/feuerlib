import CoreGraphics

///Basic Raytracing implemented in Swift based on CoreGraphics Bitmap Context
public class Raytracer {

    ///Width of Canvas
    let width:Int
    
    ///Height of Canvas
    let height:Int
    
    ///Scene Data
    public var scene:Scene
    
    ///Background color
    let background:UInt32
    
    ///Pixel buffer
    var pixels: [UInt32]

    /// Constructor
    /// - Parameters:
    ///   - width: width of Canvas
    ///   - height: height of Canvas
    ///   - background: default pixel background color
    public init(width:Int, height:Int, scene:Scene, background:UInt32 = 0xff000000) {
        self.width = width
        self.height = height
        self.scene = scene
        self.background = background
        self.pixels = [UInt32](repeating: background, count: width*height)
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
    private func putPixel(_ x:Int, _ y:Int, _ color: UInt32) {
        let sX = (width/2)+x
        let sY = (height/2)-y-1
        let index = (width*sY)+(sX)
        pixels[index] = color
    }

    /// Main work function iterates through each pixel on the canvas and calculates its pixel
    private func fillBuffer() {
        for x in -width/2..<width/2 {
            for y in -height/2..<height/2 {
                let direction = canvasToViewport(x,y)
                let ray = Ray(origin: scene.cameraPosition, direction: direction)
                let color = traceRay(ray, tMin:scene.projectionPlane, tMax:Float.greatestFiniteMagnitude)
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
            Float(y)*scene.viewportSize/Float(height),
            scene.projectionPlane)
    }
    
    ///Calculate light level for a given ray
    private func computeLighting(_ point:Vector3, _ normal:Vector3) -> Float {
        var intensity:Float = 0.0
        var L:Vector3? = nil
        for light in scene.lights {
            if light.type == .ambient {
                intensity += light.intensity
            } else {
                if light.type == .point {
                    L = light.position - point
                } else {
                    L = light.direction
                }
                let n_dot_1 = Vector3.dot(normal, L!)
                if n_dot_1 > 0 {
                    intensity += light.intensity * n_dot_1 / (normal.length() * L!.length())
                }
            }
        }
        return intensity
    }

    /// Calculates the target color of a given ray
    /// - Parameters:
    ///   - from: Vector3 of camera origin
    ///   - to: Vector3 of viewport coordinate
    ///   - tMin: Position on ray to start tracing
    ///   - tMax: Position on ray to end tracing
    /// - Returns: UInt32 of target color
    private func traceRay(_ ray:Ray, tMin:Float, tMax:Float) -> UInt32 {
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
        
        guard let sphere = sClosest else {
            return background
        }
        
        let intersection: Vector3 = (ray.origin + tClosest) * ray.direction
        let normal = (intersection - sphere.center).normalize()
        let factor = computeLighting(intersection, normal)
        
        //Get r,g,b,a values -> drop alpha -> multiply with light factor -> clamp to reasonable value
        let comps: [Int] = sphere.color.toRGBAIntComponents().prefix(3).map {
            let color = Float($0)*factor
            let clamped = max(min(color, 255), 0)
            let asInt = Int(clamped)
            return asInt
        }

        return UInt32(a: 255, r: comps[0], g: comps[1], b: comps[2])
    }

    /// Sets up the rendering context using CoreGraphics
    /// - Returns: CGContext or nil
    private func createContext() -> CGContext? {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo.byteOrder32Little.rawValue |
                         CGImageAlphaInfo.premultipliedFirst.rawValue &
                         CGBitmapInfo.alphaInfoMask.rawValue

        let mutatablePointer = UnsafeMutableRawBufferPointer(start: &pixels, count: pixels.count).baseAddress
        let height = pixels.count / width
        let bytesPerRow = width * 4

        let context = CGContext(data: mutatablePointer, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo)
        return context
        
    }
}
