//
//  UIRaytracerView.swift
//  Feuerlib
//
//  Created by Jannik Feuerhahn on 19.03.21.
//
import UIKit

public protocol UIRaytracerViewSceneDelegate {
    func getScene() -> Scene
    func setScene(_ scene:Scene) -> Void
}

public protocol UIRaytracerViewInteractionDelegate {
    func didTapSphere(_ sphere:Sphere?)
}

///Raytracer canvas view with gestures to change camera and quality streaming
public class UIRaytracerView: UIView {
    
    ///Canvas ImageView
    private lazy var ivImage:UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private lazy var aiLoading:UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView()
        ai.translatesAutoresizingMaskIntoConstraints = false
        return ai
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
    private var scene:Scene {
        get {
            guard let delegate = sceneDelegate else {
                return debugScene
            }
            return delegate.getScene()
        }
        
        set {
            guard let delegate = sceneDelegate else {
                debugScene = newValue
                return
            }
            delegate.setScene(newValue)
        }
    }
    
    private var debugScene = Scene.testScene
    
    public var sceneDelegate:UIRaytracerViewSceneDelegate?
    public var interactionDelegate:UIRaytracerViewInteractionDelegate?
    
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
        addSubview(aiLoading)
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
            ivImage.bottomAnchor.constraint(equalTo: aiLoading.bottomAnchor, constant: 8),
            ivImage.trailingAnchor.constraint(equalTo: aiLoading.trailingAnchor, constant: 8)
        ])
    }
    
    /// Starts the draw queue
    private func draw(_ scene:Scene) {
        aiLoading.startAnimating()
        fastQueue.async {
            self.slowTracers.forEach { $0.cancel() }
            self.slowestTracers.forEach { $0.cancel() }
            self.fastTracer = Raytracer()
            self.fastTracer!.draw(scene: scene, width: self.width, height: self.height, quality: .low) { img in
                DispatchQueue.main.async {
                    self.ivImage.image = UIImage(cgImage: img)
                }
                self.slowQueue.async {
                    self.slowTracers.forEach { $0.cancel() }
                    self.slowestTracers.forEach { $0.cancel() }
                    let slowTracer = Raytracer()
                    self.slowTracers = [slowTracer]
                    slowTracer.draw(scene: scene, width: self.width, height: self.height, quality: .medium) { img in
                        DispatchQueue.main.async {
                            self.ivImage.image = UIImage(cgImage: img)
                        }
                        self.slowestQueue.async {
                            self.slowTracers.forEach { $0.cancel() }
                            self.slowestTracers.forEach { $0.cancel() }
                            let slowestTracer = Raytracer()
                            self.slowestTracers = [slowestTracer]
                            slowestTracer.draw(scene: scene, width: self.width, height: self.height, quality: .high) { img in
                                DispatchQueue.main.async {
                                    self.ivImage.image = UIImage(cgImage: img)
                                    self.aiLoading.stopAnimating()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    @objc private func didTap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: ivImage)
        let tracer = Raytracer()
        let shape = tracer.hitTest(scene, width: self.width, height:self.height, Int(location.x), Int(location.y))
        self.interactionDelegate?.didTapSphere(shape)
    }
    
    @objc private func didDoubleTap(_ sender: UITapGestureRecognizer) {
        if zoomed {
            scene.camera.viewportSize = 1
        } else {
            scene.camera.viewportSize = 0.5
        }
        zoomed = !zoomed
        
        draw(scene)
    }
    
    @objc private func didRotate(_ sender: UIRotationGestureRecognizer) {
        self.scene.camera.yaw += Float(sender.velocity/20)
        draw(scene)
    }
    
    @objc private func didPinch(_ sender: UIPinchGestureRecognizer) {
        let vector = .init(0, 0, (Float(sender.velocity)/15)) * scene.camera.matrix
        scene.camera.position = scene.camera.position + vector
        draw(scene)
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
        draw(scene)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.width = Int(frame.width)
        self.height = Int(frame.height)        
        guard width > 0, height > 0 else {
            return
        }
        
        draw(scene)
    }
}

