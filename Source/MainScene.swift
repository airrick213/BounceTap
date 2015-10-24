import Foundation

enum GameState {
    case Title, Ready, Playing, GameOver
}

class MainScene: CCNode {
    
    weak var background: CCNodeColor!
    weak var startButton: CCButton!
    weak var scoreLabel: CCLabelTTF!
    weak var circle: Circle!
    weak var tapTheCircle: CCLabelTTF!
    
    var gameState: GameState = .Title
    
    var score: Int = 0 {
        didSet {
            scoreLabel.string = "\(score)"
        }
    }
    
    func ready() {
        gameState = .Ready
        
        self.animationManager.runAnimationsForSequenceNamed("Ready")
    }
    
}
