//
//  UIRaytracerView.swift
//  Feuerlib
//
//  Created by Jannik Feuerhahn on 19.03.21.
//
import UIKit

///Raytracer canvas view with gestures to change camera and quality streaming
public class UIRaytracerView: UIView {
    
    ///Canvas ImageView
    private lazy var ivImage:UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    ///Fastest dispatch queue for quick feedback
    private let fastQueue = DispatchQueue(label: "fast", qos: .userInteractive)
    
    ///Lower priority queue for quick image fidelity
    private let slowQueue = DispatchQueue(label: "better", qos: .userInitiated)
    
    ///Lower priority queue for clear images
    private let slowestQueue = DispatchQueue(label: "best", qos: .userInitiated)
    
    ///List of currently running tracers tasks
    private var fastTracer: Raytracer?
    ///List of currently running tracers tasks
    private var slowTracers = [Raytracer]()
    ///List of currently running tracers tasks
    private var slowestTracers = [Raytracer]()
    
    ///current 100% quality width
    private var width = 0
    
    ///current 100% quality height
    private var height = 0
    
    ///Is view zoomed in
    private var zoomed = false
    
    ///Scene to be drawn
    public var scene:Scene = Scene.testScene
    
    /// Constructor
    /// - Parameter scene: `Scene` or default test scene
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    /// Constructor
    /// - Parameter coder: NSCoder
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        addSubview(ivImage)
        isUserInteractionEnabled = true
        
        let grPan = UIPanGestureRecognizer(target: self, action: #selector(didPan(_:)))
        let grRotation = UIRotationGestureRecognizer(target: self, action: #selector(didRotate(_:)))
        let grPinch = UIPinchGestureRecognizer(target: self, action: #selector(didPinch(_:)))
        let grTap = UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))
        let grDoubleTap = UITapGestureRecognizer(target: self, action: #selector(didDoubleTap(_:)))
        grTap.numberOfTapsRequired = 1
        grDoubleTap.numberOfTapsRequired = 2
        grTap.require(toFail: grDoubleTap)
        addGestureRecognizer(grPan)
        addGestureRecognizer(grRotation)
        addGestureRecognizer(grPinch)
        addGestureRecognizer(grTap)
        addGestureRecognizer(grDoubleTap)
        NSLayoutConstraint.activate([
            ivImage.leadingAnchor.constraint(equalTo: leadingAnchor),
            ivImage.trailingAnchor.constraint(equalTo: trailingAnchor),
            ivImage.topAnchor.constraint(equalTo: topAnchor),
            ivImage.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    /// Starts the draw queue
    private func redraw() {
        fastQueue.async {
            self.slowTracers.forEach { $0.cancel() }
            self.slowestTracers.forEach { $0.cancel() }
            self.fastTracer = Raytracer()
            self.fastTracer!.draw(scene: self.scene, width: self.width/10 & ~1, height: self.height/10 & ~1) { img in
                DispatchQueue.main.async {
                    self.ivImage.image = UIImage(cgImage: img)
                }
                self.slowQueue.async {
                    self.slowTracers.forEach { $0.cancel() }
                    self.slowestTracers.forEach { $0.cancel() }
                    let slowTracer = Raytracer()
                    self.slowTracers = [slowTracer]
                    slowTracer.draw(scene: self.scene, width: self.width/4 & ~1, height: self.height/4 & ~1) { img in
                        DispatchQueue.main.async {
                            self.ivImage.image = UIImage(cgImage: img)
                        }
                        self.slowestQueue.async {
                            self.slowTracers.forEach { $0.cancel() }
                            self.slowestTracers.forEach { $0.cancel() }
                            let slowestTracer = Raytracer()
                            self.slowestTracers = [slowestTracer]
                            slowestTracer.draw(scene: self.scene, width:self.width & ~1, height: self.height & ~1) { img in
                                DispatchQueue.main.async {
                                    self.ivImage.image = UIImage(cgImage: img)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    @objc private func didTap(_ sender: UITapGestureRecognizer) {
        print("tapped")
        let location = sender.location(in: ivImage)
        guard let tracer = fastTracer else {
            return
        }
        let shape = tracer.trace(scene, Int(location.x/10), Int(location.y/10))
        print(shape?.color)
        redraw()
    }
    
    @objc private func didDoubleTap(_ sender: UITapGestureRecognizer) {
        print("double tapped")
        if zoomed {
            scene.camera.viewportSize = 1
        } else {
            scene.camera.viewportSize = 0.5
        }
        zoomed = !zoomed
        
        redraw()
    }
    
    @objc private func didRotate(_ sender: UIRotationGestureRecognizer) {
        self.scene.camera.yaw += Float(sender.velocity/20)
        redraw()
    }
    
    @objc private func didPinch(_ sender: UIPinchGestureRecognizer) {
        let vector = .init(0, 0, Float(sender.velocity)) * scene.camera.matrix
        scene.camera.position = scene.camera.position + vector
        redraw()
    }
    
    @objc private func didPan(_ sender: UIPanGestureRecognizer) {
        let x = sender.velocity(in: ivImage).x
        let y = sender.velocity(in: ivImage).y
        
        if sender.numberOfTouches == 1 {
            scene.camera.pitch -= Float(x/10000)
            scene.camera.roll -= Float(y/10000)
        } else {
            let vector = .init(Float(x/1000), Float(y/1000), 0) * scene.camera.matrix
            scene.camera.position = scene.camera.position + vector
        }
        redraw()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.width = Int(frame.width)
        self.height = Int(frame.height)        
        guard width > 0, height > 0 else {
            return
        }
        
        redraw()
    }
}

