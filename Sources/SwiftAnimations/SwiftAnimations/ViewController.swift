//
//  ViewController.swift
//  ConfettiAnimation
//
//  Created by Ishika Gupta on 16/06/20.
//  Copyright © 2020 Ishika Gupta. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLoad() {
        
    }
    
    @IBAction func animationBegins(_ sender: Any) {
        //how to use
        let confettiAnimation = ConfettiAnimation()
            
        confettiAnimation.confettiBurstRadius = 50.0
        confettiAnimation.birthAnimationDuration = 1.0
        confettiAnimation.initialForce = 700.0
        
        //increase the counter to increase the particle counts
        confettiAnimation.birthRateOfConfettiParticles = 1
        confettiAnimation.initialEmitterPosition = CGPoint(x: self.view.bounds.midX, y: 20)
            
        confettiAnimation.addToView(view: self.view)
        confettiAnimation.blastConfetti()
    }
}

