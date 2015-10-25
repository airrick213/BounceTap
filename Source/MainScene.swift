import Foundation

enum GameState {
    case Title, Ready, Playing, GameOver
}

enum GameMode {
    case Normal, TimeAttack
}

class MainScene: CCNode, CCPhysicsCollisionDelegate{
    
    weak var background: CCNodeColor!
    weak var startButton: CCButton!
    weak var scoreLabel: CCLabelTTF!
    weak var circle: Circle!
    weak var tapTheCircle: CCLabelTTF!
    weak var gamePhysicsNode: CCPhysicsNode!
    weak var gameOverScoreLabel: CCLabelTTF!
    weak var highScoreLabel: CCLabelTTF!
    weak var newHighScoreLabel: CCLabelTTF!
    weak var ring: CCSprite!
    
    var gameState: GameState = .Title
    var gameMode: GameMode = .Normal
    
    var score: Int = 0 {
        didSet {
            scoreLabel.string = "\(score)"
        }
    }
    
    func didLoadFromCCB() {
        userInteractionEnabled = true
        
        gamePhysicsNode.collisionDelegate = self
    }
    
    func ready() {
        gameState = .Ready
        gameMode = .Normal
        
        resetSettings()
    }
    
    func timeAttackReady() {
        gameState = .Ready
        gameMode = .TimeAttack
        
        resetSettings()
    }
    
    func resetSettings() {
        self.animationManager.runAnimationsForSequenceNamed("Ready")
        
        score = 0
        newHighScoreLabel.visible = false
        
        transitionBackgroundColor(duration: 0.2, red: 0, green: 0, blue: 1)
        
        circle.physicsBody.affectedByGravity = false
        
        circle.position.x = 0.5
        circle.position.y = 0.5
        
        circle.totalVelocity = 150
        
        circle.physicsBody.velocity.x = CGFloat(arc4random_uniform(UInt32(circle.totalVelocity)))
        circle.physicsBody.velocity.y = circle.findComponentVelocity(circle.physicsBody.velocity.x)
 
    }
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, circle: CCNode!, verticalWall: CCNode!) -> Bool {
        if gameState != .GameOver {
            circle.physicsBody.velocity.x = -circle.physicsBody.velocity.x
        }
        
        return true
    }
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, circle: CCNode!, horizontalWall: CCNode!) -> Bool {
        if gameState != .GameOver {
            circle.physicsBody.velocity.y = -circle.physicsBody.velocity.y
        }
        
        return true
    }
    
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        if gameState == .GameOver || gameState == .Title {
            return
        }
        else if gameState == .Ready {
            gameState = .Playing
            
            self.animationManager.runAnimationsForSequenceNamed("Playing")
        }
        
        if circle.tapped(touch.locationInWorld()) {
            score++
            
            circle.bounceTap()
            animateRing()
            changeBackgroundColor()
            
            self.animationManager.runAnimationsForSequenceNamed("Spin")
        }
        else {
            triggerGameOver()
        }
    }
    
    func animateRing() {
        ring.opacity = 1
        ring.scale = 0
        
        ring.position.x = circle.position.x
        ring.position.y = circle.position.y
        
        ring.runAction(CCActionScaleTo(duration: 0.5, scale: 1))
        ring.runAction(CCActionFadeOut(duration: 0.5))
    }
    
    func triggerGameOver() {
        gameState = .GameOver
        
        circle.totalVelocity = 0
        circle.physicsBody.velocity.x = 0
        circle.physicsBody.velocity.y = 0
        
        NSThread.sleepForTimeInterval(0.5)
       
        circle.physicsBody.affectedByGravity = true
        
        self.animationManager.runAnimationsForSequenceNamed("GameOver")
        
        gameOverScoreLabel.string = "Score: \(score)"
        
        let highScore = NSUserDefaults().integerForKey("high_score")
        
        if score <= highScore {
            highScoreLabel.string = "High Score: \(highScore)"
        }
        else {
            highScoreLabel.string = "High Score: \(score)"
            NSUserDefaults().setInteger(score, forKey: "high_score")
            
            newHighScoreLabel.visible = true
        }
    }
    
    func changeBackgroundColor() {
        let blue = background.color.blue
        let green = background.color.green
        let red = background.color.red
        
        let transitionTime: Double = 0.5
        
        if blue == 1 {
            if green < 1 {
                if red == 0 {
                    transitionBackgroundColor(duration: transitionTime, red: red, green: green + 0.25, blue: blue)
                }
                else {
                    transitionBackgroundColor(duration: transitionTime, red: red - 0.25, green: green, blue: blue)
                }
            }
        }
        
        if green == 1 {
            if red < 1 {
                if blue == 0 {
                    transitionBackgroundColor(duration: transitionTime, red: red + 0.25, green: green, blue: blue)
                }
                else {
                    transitionBackgroundColor(duration: transitionTime, red: red, green: green, blue: blue - 0.25)
                }
            }
        }
        
        if red == 1 {
            if blue < 1 {
                if green == 0 {
                    transitionBackgroundColor(duration: transitionTime, red: red, green: green, blue: blue + 0.25)
                }
                else {
                    transitionBackgroundColor(duration: transitionTime, red: red, green: green - 0.25, blue: blue)
                }
            }
        }
    }
    
    func transitionBackgroundColor(duration duration: Double, red: Float, green: Float, blue: Float) {
        background.runAction(CCActionTintTo(duration: duration, color: CCColor(red: red, green: green, blue: blue)))
    }
    
}
