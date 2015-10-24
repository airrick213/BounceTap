import Foundation

enum GameState {
    case Title, Ready, Playing, GameOver
}

class MainScene: CCNode, CCPhysicsCollisionDelegate{
    
    weak var background: CCNodeColor!
    weak var startButton: CCButton!
    weak var scoreLabel: CCLabelTTF!
    weak var circle: Circle!
    weak var tapTheCircle: CCLabelTTF!
    weak var gamePhysicsNode: CCPhysicsNode!
    
    var gameState: GameState = .Title
    
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
        
        self.animationManager.runAnimationsForSequenceNamed("Ready")
        
        circle.totalVelocity = 150
        
        circle.physicsBody.velocity.x = CGFloat(arc4random_uniform(UInt32(circle.totalVelocity)))
        circle.physicsBody.velocity.y = circle.findComponentVelocity(circle.physicsBody.velocity.x)
    }
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, circle: CCNode!, verticalWall: CCNode!) -> Bool {
        circle.physicsBody.velocity.x = -circle.physicsBody.velocity.x
        
        return true
    }
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, circle: CCNode!, horizontalWall: CCNode!) -> Bool {
        circle.physicsBody.velocity.y = -circle.physicsBody.velocity.y
        
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
        }
        else {
            triggerGameOver()
        }
    }
    
    func triggerGameOver() {
        gameState = .GameOver
        
        circle.totalVelocity = 0
        circle.physicsBody.velocity.x = 0
        circle.physicsBody.velocity.y = 0
    }
    
}
