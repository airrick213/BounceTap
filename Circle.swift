//
//  Circle.swift
//  BounceTap
//
//  Created by Eric Kim on 10/24/15.
//  Copyright © 2015 Apportable. All rights reserved.
//

import Foundation

class Circle: CCSprite {
    
    var totalVelocity: CGFloat = 0 {
        didSet {
            OALSimpleAudio.sharedInstance().playBg("BounceTap-soundtrack@\((Int(totalVelocity) - 150) / 10 + 75)bpm.wav", loop: true)
        }
    }
    
    let kRadius: CGFloat = 60
    
    func findComponentVelocity(component1: CGFloat) -> CGFloat {
        return sqrt(totalVelocity * totalVelocity - component1 * component1)
    }
    
    func tapped(tapLocation: CGPoint) -> Bool {
        let xCoord = position.x * CCDirector.sharedDirector().viewSize().width
        let yCoord = position.y * CCDirector.sharedDirector().viewSize().height
        
        return xCoord - kRadius / 2 < tapLocation.x && xCoord + kRadius / 2 > tapLocation.x && yCoord - kRadius / 2 < tapLocation.y && yCoord + kRadius / 2 > tapLocation.y
    }
    
    func bounceTap() {
        if totalVelocity < 600 {
            totalVelocity += 50
        }
        
        let xVelocity = physicsBody.velocity.x
        let yVelocity = physicsBody.velocity.y
        
        physicsBody.velocity.x = CGFloat(arc4random_uniform(UInt32(totalVelocity)))
        physicsBody.velocity.y = findComponentVelocity(physicsBody.velocity.x)
            
        if xVelocity > 0 {
            physicsBody.velocity.x *= -1
            
            if yVelocity > 0 {
                physicsBody.velocity.y *= -1
            }
        }
    }
    
}
