//
//  Circle.swift
//  BounceTap
//
//  Created by Eric Kim on 10/24/15.
//  Copyright © 2015 Apportable. All rights reserved.
//

import Foundation

class Circle: CCSprite {
    
    func findComponentVelocity(totalVelocity: CGFloat, component1: CGFloat) -> CGFloat {
        return sqrt(totalVelocity * totalVelocity - component1 * component1)
    }
    
}
