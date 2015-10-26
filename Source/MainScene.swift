import Foundation
import GameKit

enum GameState {
    case Title, Ready, Playing, GameOver
}

enum GameMode {
    case Normal, TimeAttack
}

class MainScene: CCNode, CCPhysicsCollisionDelegate {
    
    weak var background: CCNodeColor!
    weak var scoreLabel: CCLabelTTF!
    weak var circle: Circle!
    weak var tapTheCircle: CCLabelTTF!
    weak var gamePhysicsNode: CCPhysicsNode!
    weak var gameOverScoreLabel: CCLabelTTF!
    weak var highScoreLabel: CCLabelTTF!
    weak var newHighScoreLabel: CCLabelTTF!
    weak var ring: CCSprite!
    weak var volumeButton: CCButton!
    
    var gameState: GameState = .Title
    var gameMode: GameMode = .Normal
    var currentColor: CCColor = CCColor(red: 0, green: 0, blue: 1)
    var volume: Float = 1.0
    var timeIntoTrack: CCTime = 0
    
    var timeLeft: Float = 5 {
        didSet {
            timeLeft = max(min(timeLeft, 5), 0)
            background.opacity = CGFloat(timeLeft / 5)
        }
    }
    
    var score: Float = 0 {
        didSet {
            scoreLabel.string = "\(Int(score))"
        }
    }
    
    func didLoadFromCCB() {
        userInteractionEnabled = true
        
        setUpGameCenter()
        
        gamePhysicsNode.collisionDelegate = self
        
        OALSimpleAudio.sharedInstance().preloadEffect("beep-ping.wav")
        OALSimpleAudio.sharedInstance().playBg("BounceTap-soundtrack@75bpm.wav", volume: volume, pan: 0, loop: true)
        
        startCircleDefaultVelocity()
    }
    
    func setUpGameCenter() {
        let gameCenterInteractor = GameCenterInteractor.sharedInstance
        gameCenterInteractor.authenticationCheck()
    }
    
    func ready() {
        gameMode = .Normal
        
        resetSettings()
    }
    
    func timeAttackReady() {
        gameMode = .TimeAttack
        
        resetSettings()
    }
    
    func resetSettings() {
        if gameState != .Title {
            circle.position.x = 0.5
            circle.position.y = 0.5
            
            startCircleDefaultVelocity()
            
            OALSimpleAudio.sharedInstance().playBg("BounceTap-soundtrack@75bpm.wav", volume: volume, pan: 0, loop: true)
            timeIntoTrack = 0
        }
        
        gameState = .Ready
        self.animationManager.runAnimationsForSequenceNamed("Ready")
        
        score = 0
        timeLeft = 10
        newHighScoreLabel.visible = false
        
        background.opacity = 1
        currentColor = CCColor(red: 0, green: 0, blue: 1)
        transitionBackgroundColorToCurrentColor(duration: 0.2)
        
        circle.physicsBody.affectedByGravity = false
    }
    
    func startCircleDefaultVelocity() {
        circle.totalVelocity = 150
        
        circle.physicsBody.velocity.x = CGFloat(arc4random_uniform(UInt32(circle.totalVelocity)))
        circle.physicsBody.velocity.y = circle.findComponentVelocity(circle.physicsBody.velocity.x)
    }
    
    func changeVolume() {
        if volumeButton.selected != true {
            volumeButton.selected = true
            volume = 0
            OALSimpleAudio.sharedInstance().stopEverything()
        }
        else {
            volumeButton.selected = false
            volume = 1
            
            OALSimpleAudio.sharedInstance().playBg("BounceTap-soundtrack@\((Int(circle.totalVelocity) - 150) / 10 + 75)bpm.wav", volume: volume, pan: 0, loop: true)
            timeIntoTrack = 0
        }
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
            if gameMode == .Normal {
                score++
            }
            
            circle.bounceTap()
            animateRing()
            changeBackgroundColor()
            
            self.animationManager.runAnimationsForSequenceNamed("Spin")
            OALSimpleAudio.sharedInstance().playEffect("beep-ping.wav", volume: volume, pitch: Float(circle.totalVelocity / 500), pan: 0, loop: false)
            
            let newBpm: Double = Double((circle.totalVelocity - 150) / 10 + 75)
            let oldBpm = newBpm - 5
            let beatsIntoTrack = (Double(timeIntoTrack) / 60 * oldBpm) % 32.0 //64 beats total
            timeIntoTrack = beatsIntoTrack / newBpm * 60
            
            OALSimpleAudio.sharedInstance().preloadBg("BounceTap-soundtrack@\(Int(newBpm))bpm.wav", seekTime: Double(timeIntoTrack))
            OALSimpleAudio.sharedInstance().playBgWithLoop(true)
            
            if gameMode == .TimeAttack {
                timeLeft++
            }
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
        
        circle.physicsBody.velocity.x = 0
        circle.physicsBody.velocity.y = 0
        
        NSThread.sleepForTimeInterval(0.5)
       
        circle.physicsBody.affectedByGravity = true
        
        self.animationManager.runAnimationsForSequenceNamed("GameOver")
        
        gameOverScoreLabel.string = "Score: \(Int(score))"
        
        var highScore: Int
        if gameMode == .Normal {
            highScore = NSUserDefaults().integerForKey("high_score")
        }
        else {
            highScore = NSUserDefaults().integerForKey("time_attack_high_score")
        }
        
        if Int(score) <= highScore {
            highScoreLabel.string = "High Score: \(highScore)"
        }
        else {
            highScoreLabel.string = "High Score: \(Int(score))"
            
            if gameMode == .Normal {
                NSUserDefaults().setInteger(Int(score), forKey: "high_score")
            }
            else {
                NSUserDefaults().setInteger(Int(score), forKey: "time_attack_high_score")
            }
            reportHighScoreToGameCenter()
            
            newHighScoreLabel.visible = true
        }
    }
    
    func changeBackgroundColor() {
        let blue = currentColor.blue
        let green = currentColor.green
        let red = currentColor.red
        
        let transitionTime: Double = 0.5
        
        if gameMode == .TimeAttack {
            background.opacity = 1
        }
        
        if blue == 1 {
            if green < 1 {
                if red == 0 {
                    currentColor = CCColor(red: red, green: green + 0.25, blue: blue)
                    
                    transitionBackgroundColorToCurrentColor(duration: transitionTime)
                }
                else {
                    currentColor = CCColor(red: red - 0.25, green: green, blue: blue)
                    
                    transitionBackgroundColorToCurrentColor(duration: transitionTime)
                }
            }
        }
        
        if green == 1 {
            if red < 1 {
                if blue == 0 {
                    currentColor = CCColor(red: red + 0.25, green: green, blue: blue)
                    
                    transitionBackgroundColorToCurrentColor(duration: transitionTime)
                }
                else {
                    currentColor = CCColor(red: red, green: green, blue: blue - 0.25)
                    
                    transitionBackgroundColorToCurrentColor(duration: transitionTime)
                }
            }
        }
        
        if red == 1 {
            if blue < 1 {
                if green == 0 {
                    currentColor = CCColor(red: red, green: green, blue: blue + 0.25)
                    
                    transitionBackgroundColorToCurrentColor(duration: transitionTime)
                }
                else {
                    currentColor = CCColor(red: red, green: green - 0.25, blue: blue)
                    
                    transitionBackgroundColorToCurrentColor(duration: transitionTime)
                }
            }
        }
    }
    
    func transitionBackgroundColorToCurrentColor(duration duration: Double) {
        background.runAction(CCActionTintTo(duration: duration, color: currentColor))
    }
    
    override func update(delta: CCTime) {
        if gameMode == .TimeAttack && gameState == .Playing {
            timeLeft -= Float(delta)
            score += Float(delta)
            
            if timeLeft == 0 {
                triggerGameOver()
            }
        }
        
        timeIntoTrack += delta
    }
    
    //MARK: Game Center
    
    func leaderboard() {
        let viewController = CCDirector.sharedDirector().parentViewController!
        let gameCenterViewController = GKGameCenterViewController()
        gameCenterViewController.gameCenterDelegate = self
        
        viewController.presentViewController(gameCenterViewController, animated: true, completion: nil)
    }
    
    func reportHighScoreToGameCenter() {
        var identifier: String
        if gameMode == .Normal {
            identifier = "BounceTapNormalModeLeaderboard"
        }
        else {
            identifier = "BounceTapTimeAttackLeaderboard"
        }
        
        let scoreReporter = GKScore(leaderboardIdentifier: identifier)
        scoreReporter.value = Int64(score)
        
        let scoreArray: [GKScore] = [scoreReporter]
        
        GKScore.reportScores(scoreArray, withCompletionHandler: {(error: NSError?) -> Void in
            if error != nil {
                print("Game Center: Score Submission Error")
            }
        })
    }
    
}

extension MainScene: GKGameCenterControllerDelegate {
    
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
