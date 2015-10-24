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
        
        circle.physicsBody.velocity.x = CGFloat(arc4random_uniform(150))
        circle.physicsBody.velocity.y = circle.findComponentVelocity(150, component1: circle.physicsBody.velocity.x)
    }
    
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        
    }
    
}
