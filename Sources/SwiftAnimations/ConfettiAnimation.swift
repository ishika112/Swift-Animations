//
//  ConfettiAnimation.swift
//
//  Created by Ishika Gupta on 18/06/20.
//  Copyright © 2020 Ishika Gupta. All rights reserved.
//

import UIKit

public class ConfettiAnimation: CAEmitterLayer {
    
    // configurable public properties with default values
    var emptyView = UIView()
    var confettiColorsArray: [UIColor] = [
                    (r:199,g:1,b:1),(r:199,g:1,b:1), (r:239,g:2,b:30), (r:248,g:231,b:28),(r:199,g:1,b:1),(r:199,g:1,b:1),(r:188, g:157, b:76),(r:255, g:255, b:255),(r:248,g:231,b:28)
                    ].map { UIColor(red: $0.r / 255.0, green: $0.g / 255.0, blue: $0.b / 255.0, alpha: 1) }
    
    var confettiBurstRadius = 50.0
    var birthAnimationDuration = 1.0
    var initialForce = 700.0
    var initialEmitterPosition = CGPoint(x: 0, y: 0)
    var birthRateOfConfettiParticles: CGFloat = 1.0
    
    var rectangularParticleSize = CGRect(x: 0, y: 0, width: 22, height: 8)
    var squareParticleSize = CGRect(x: 0, y: 0, width: 10, height: 10)
    var circularParticleSize = CGRect(x: 0, y: 0, width: 6, height: 6)
    var starParticleSize = CGRect(x: 0, y: 0, width: 8, height: 8)
    
    override init() {
       super.init()
    }
    
    required init(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
    
    func addToView(view: UIView) {
        emptyView = view
    }
    
    private class ConfettiType {
        
        let color: UIColor
        let shape: ConfettiShape
        let position: ConfettiPosition
        
        var rectangularParticleSize = CGRect(x: 0, y: 0, width: 20, height: 8)
        var squareParticleSize = CGRect(x: 0, y: 0, width: 10, height: 10)
        var circularParticleSize = CGRect(x: 0, y: 0, width: 6, height: 6)
        var starParticleSize = CGRect(x: 0, y: 0, width: 8, height: 8)
        
        init(color: UIColor, shape: ConfettiShape, position: ConfettiPosition) {
            self.color = color
            self.shape = shape
            self.position = position
        }
        
        lazy var name = UUID().uuidString
        
        lazy var image: UIImage = {
            let imageRect: CGRect = {
                switch shape {
                case .rectangle:
                    return rectangularParticleSize
                case .circle:
                    return circularParticleSize
                case .square:
                    return squareParticleSize
                case .star:
                    return circularParticleSize
                }
            }()
            
            UIGraphicsBeginImageContext(imageRect.size)
            let context = UIGraphicsGetCurrentContext()!
            context.setFillColor(color.cgColor)
            
            switch shape {
            case .rectangle:
                context.fill(imageRect)
            case .circle:
                context.fillEllipse(in: imageRect)
            case .square:
                context.fill(imageRect)
            case .star:
                let star = RoundedStar(frame: imageRect)
                star.backgroundColor = .clear
                star.fillColor = color
                star.cornerRadius = 0.1
                return star.asImage()
            }
            
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image!
        }()
    }
    
    private enum ConfettiShape {
        case rectangle
        case circle
        case square
        case star
    }
    
    private enum ConfettiPosition {
        case foreground
        case background
    }
    
    private lazy var confettiTypes: [ConfettiType] = {
        
        // For each position x shape x color, construct an image
        return [ConfettiPosition.foreground, ConfettiPosition.background].flatMap { position in
            return [ConfettiShape.rectangle, ConfettiShape.circle, ConfettiShape.square, ConfettiShape.star].flatMap { shape in
                return confettiColorsArray.map { color in
                    let confettiType = ConfettiType(color: color, shape: shape, position: position)
                    confettiType.squareParticleSize = squareParticleSize
                    confettiType.rectangularParticleSize = rectangularParticleSize
                    confettiType.circularParticleSize = circularParticleSize
                    confettiType.starParticleSize = starParticleSize
                    return confettiType
                }
            }
        }
    }()
    
    private lazy var confettiCells: [CAEmitterCell] = {
        
        return confettiTypes.map { confettiType in
            let cell = CAEmitterCell()
            cell.name = confettiType.name
            
            cell.beginTime = 0.1
            //Increases the confetti counts
            cell.birthRate = Float(birthRateOfConfettiParticles)
            cell.contents = confettiType.image.cgImage
            cell.emissionRange = CGFloat(Double.pi)
            cell.lifetime = 10
            cell.spin = 4
            cell.spinRange = 8
            cell.velocityRange = 0
            cell.yAcceleration = 0
                        
            cell.setValue("plane", forKey: "particleType")
            cell.setValue(Double.pi, forKey: "orientationRange")
            cell.setValue(Double.pi / 2, forKey: "orientationLongitude")
            cell.setValue(Double.pi / 2, forKey: "orientationLatitude")
            
            return cell
        }
    }()
    
    private lazy var confettiLayer: CAEmitterLayer = {
        let emitterLayer = CAEmitterLayer()

        emitterLayer.birthRate = 0
        emitterLayer.emitterCells = confettiCells
        emitterLayer.emitterPosition = initialEmitterPosition
        emitterLayer.emitterSize = CGSize(width: confettiBurstRadius, height: confettiBurstRadius)
        emitterLayer.emitterShape = .sphere
        emitterLayer.frame = emptyView.bounds
        
        emitterLayer.beginTime = CACurrentMediaTime()
        return emitterLayer
    }()
        
    private func createBehavior(type: String) -> NSObject {
        let behaviorClass = NSClassFromString("CAEmitterBehavior") as! NSObject.Type
        let behaviorWithType = behaviorClass.method(for: NSSelectorFromString("behaviorWithType:"))!
        let castedBehaviorWithType = unsafeBitCast(behaviorWithType, to:(@convention(c)(Any?, Selector, Any?) -> NSObject).self)
        return castedBehaviorWithType(behaviorClass, NSSelectorFromString("behaviorWithType:"), type)
    }
    
    private func horizontalWaveBehavior() -> Any {
        let behavior = createBehavior(type: "wave")
        //Increase the value increase the force
        behavior.setValue([50, 0, 0], forKeyPath: "force")
        behavior.setValue(0.5, forKeyPath: "frequency")
        return behavior
    }
    
    private func verticalWaveBehavior() -> Any {
        let behavior = createBehavior(type: "wave")
        behavior.setValue([0, 300, 0], forKeyPath: "force")
        behavior.setValue(5, forKeyPath: "frequency")
        return behavior
    }
    
    private func attractorBehavior(for emitterLayer: CAEmitterLayer) -> Any {
        let behavior = createBehavior(type: "attractor")
        behavior.setValue("attractor", forKeyPath: "name")
        
        // Attractiveness
        behavior.setValue(-290, forKeyPath: "falloff")
        behavior.setValue(200, forKeyPath: "radius")
        behavior.setValue(10, forKeyPath: "stiffness")
        
        // Position
        behavior.setValue(CGPoint(x: emitterLayer.emitterPosition.x,
                                  y: emitterLayer.emitterPosition.y),
                          forKeyPath: "position")
        behavior.setValue(-70, forKeyPath: "zPosition")
        
        return behavior
    }
    
    private func addAttractorAnimation(to layer: CALayer) {
        let animation = CAKeyframeAnimation()
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animation.duration = birthAnimationDuration + 2
        animation.keyTimes = [0, 0.4]
        animation.values = [20, 5]
        
        layer.add(animation, forKey: "emitterBehaviors.attractor.stiffness")
    }
    
    private func addBirthrateAnimation(to layer: CALayer) {
        let animation = CABasicAnimation()
        animation.duration = birthAnimationDuration
        animation.fromValue = birthAnimationDuration
        animation.toValue = 0
        
        layer.add(animation, forKey: "birthRate")
    }
    
    private func addGravityAnimation(to layer: CALayer) {
        let animation = CAKeyframeAnimation()
        animation.duration = birthAnimationDuration + 3
        animation.keyTimes = [0.05, 0.25, 0.5, 1]
        animation.values = [10, 250, 500, 1000]
        for image in confettiTypes {
            layer.add(animation, forKey: "emitterCells.\(image.name).yAcceleration")
        }
    }
    
    private func addAnimations() {
        addAttractorAnimation(to: confettiLayer)
        addBirthrateAnimation(to: confettiLayer)
        addGravityAnimation(to: confettiLayer)
    }
    
    private func addBehaviors() {
        confettiLayer.setValue([
            horizontalWaveBehavior(),
            verticalWaveBehavior(),
            attractorBehavior(for: confettiLayer)
        ], forKey: "emitterBehaviors")
    }
    
    func blastConfetti() {
        emptyView.layer.addSublayer(confettiLayer)
        addBehaviors()
        addAnimations()
    }
}

class RoundedStar : UIView {
    
    var cornerRadius: CGFloat = 10 { didSet { setNeedsDisplay() } }
    var rotation: CGFloat = 54     { didSet { setNeedsDisplay() } }
    var fillColor = UIColor.red    { didSet { setNeedsDisplay() } }

    override func draw(_ rect: CGRect) {
        
        let path = UIBezierPath()
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        let r = rect.width / 2
        let rc = cornerRadius
        let rn = r * 0.95 - rc

        var cangle = rotation
        for i in 1 ... 5 {

            let cc = CGPoint(x: center.x + rn * cos(cangle * .pi / 180), y: center.y + rn * sin(cangle * .pi / 180))
            let p = CGPoint(x: cc.x + rc * cos((cangle - 72) * .pi / 180), y: cc.y + rc * sin((cangle - 72) * .pi / 180))

            if i == 1 {
                path.move(to: p)
            } else {
                path.addLine(to: p)
            }

            path.addArc(withCenter: cc, radius: rc, startAngle: (cangle - 72) * .pi / 180, endAngle: (cangle + 72) * .pi / 180, clockwise: true)

            cangle += 144
        }

        path.close()
        fillColor.setFill()
        path.fill()
    }
}

extension UIView {
    
    func asImage() -> UIImage {
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(bounds: bounds)
            return renderer.image { rendererContext in
                layer.render(in: rendererContext.cgContext)
            }
        } else {
            UIGraphicsBeginImageContext(self.frame.size)
            self.layer.render(in:UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return UIImage(cgImage: image!.cgImage!)
        }
    }
}
