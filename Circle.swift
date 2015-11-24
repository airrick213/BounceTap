//
//  Circle.swift
//  BounceTap
//
//  Created by Eric Kim on 10/24/15.
//  Copyright © 2015 Apportable. All rights reserved.
//

import Foundation

class Circle: CCSprite {
    
    var totalVelocity: CGFloat = 0
    
    let kRadius: CGFloat = 40
    let kStartingVelocity: CGFloat = 150
    let kMaxVelocity: CGFloat = 950
    let kVelocityIncrement: CGFloat = 100
    
    func findComponentVelocity(component1: CGFloat) -> CGFloat {
        return sqrt(totalVelocity * totalVelocity - component1 * component1)
    }
    
    func tapped(tapLocation: CGPoint) -> Bool {
        let xCoord = position.x * CCDirector.sharedDirector().viewSize().width
        let yCoord = position.y * CCDirector.sharedDirector().viewSize().height
        
        return xCoord - kRadius < tapLocation.x && xCoord + kRadius > tapLocation.x && yCoord - kRadius < tapLocation.y && yCoord + kRadius > tapLocation.y
    }
    
    func bounceTap() {
        if totalVelocity < kMaxVelocity {
            totalVelocity += kVelocityIncrement
        }
        
        let xVelocity = physicsBody.velocity.x
        let yVelocity = physicsBody.velocity.y
        
        physicsBody.velocity.x = CGFloat(arc4random_uniform(UInt32(totalVelocity)))
        physicsBody.velocity.y = findComponentVelocity(physicsBody.velocity.x)
            
        if xVelocity > 0 {
            physicsBody.velocity.x *= -1
        }
        if yVelocity > 0 {
            physicsBody.velocity.y *= -1
        }
    }
    
}
