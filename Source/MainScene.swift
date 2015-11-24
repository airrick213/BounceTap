import Foundation
import GameKit
import AudioToolbox

enum GameState {
    case Title, Ready, Playing, GameOver
}

enum GameMode {
    case Normal, TwoPlayer
}

class MainScene: CCNode, CCPhysicsCollisionDelegate {
    
    weak var background: CCNodeColor!
    weak var scoreLabel: CCLabelTTF!
    weak var circle: Circle!
    weak var gamePhysicsNode: CCPhysicsNode!
    weak var gameOverScoreLabel: CCLabelTTF!
    weak var highScoreLabel: CCLabelTTF!
    weak var newHighScoreLabel: CCLabelTTF!
    weak var ring: CCSprite!
    weak var volumeButton: CCButton!
    weak var firstPlayerScoreLabel: CCLabelTTF!
    weak var secondPlayerScoreLabel: CCLabelTTF!
    weak var twoPlayerResultLabel: CCLabelTTF!
    weak var topGoal: CCNodeColor!
    weak var bottomGoal: CCNodeColor!
    weak var topGoalInstructions: CCLabelTTF!
    weak var instructions: CCLabelTTF!
    
    var gameState: GameState = .Title
    var gameMode: GameMode = .Normal
    var volume: Float = 1.0
    var timeIntoTrack: CCTime = 0
    var maxSpeed = false
    
    var timeLeft: Float = 5 {
        didSet {
            timeLeft = max(timeLeft, 0)
            background.opacity = CGFloat(timeLeft / 5)
        }
    }
    
    var score: Int = 0 {
        didSet {
            scoreLabel.string = "\(score)"
        }
    }
    
    var firstPlayerScore: Int = 0 {
        didSet {
            firstPlayerScoreLabel.string = "\(firstPlayerScore)"
            
            if firstPlayerScore == 7 {
                triggerGameOver()
            }
        }
    }
    
    var secondPlayerScore: Int = 0 {
        didSet {
            secondPlayerScoreLabel.string = "\(secondPlayerScore)"
            
            if secondPlayerScore == 7 {
                triggerGameOver()
            }
        }
    }
    
    var currentColorIndex: Int = 0 {
        didSet {
            currentColorIndex %= colorPalette.count
            
            changeColorScheme()
        }
    }
    
//    var adCounter: Int = 0 {
//        didSet {
////            if adCounter == 5 {
////                if adCounter >= 10 {
//                    iAdHandler.sharedInstance.loadInterstitialAd()
//                    iAdHandler.sharedInstance.displayInterstitialAd()
//                    
//                    adCounter = 0
////                }
////            }
//        }
//    }
    
    let colorPalette: [CCColor] = [
        CCColor(red: 155.0 / 255.0, green: 89.0 / 255.0, blue: 182.0 / 255.0), //amethyst
        CCColor(red: 52.0 / 255.0, green: 152.0 / 255.0, blue: 219.0 / 255.0), //peter river (blue)
        CCColor(red: 46.0 / 255.0, green: 204.0 / 255.0, blue: 113.0 / 255.0), //emerald
        CCColor(red: 26.0 / 255.0, green: 188.0 / 255.0, blue: 156.0 / 255.0), //turquoise
        CCColor(red: 241.0 / 255.0, green: 196.0 / 255.0, blue: 15.0 / 255.0), //sun flower
        CCColor(red: 243.0 / 255.0, green: 156.0 / 255.0, blue: 18.0 / 255.0), //orange
        CCColor(red: 231.0 / 255.0, green: 76.0 / 255.0, blue: 60.0 / 255.0)
    ]
    
    func didLoadFromCCB() {
        userInteractionEnabled = true
        
        setUpGameCenter()
        
        gamePhysicsNode.collisionDelegate = self
        
        OALSimpleAudio.sharedInstance().preloadEffect("beep-ping.wav")
//        OALSimpleAudio.sharedInstance().preloadEffect("glass-ping.wav")
        
        OALSimpleAudio.sharedInstance().playBg("BounceTap-soundtrack@75bpm.wav", volume: volume, pan: 0, loop: true)
        
        startCircleDefaultVelocity()
    }
    
    func setUpGameCenter() {
        let gameCenterInteractor = GameCenterInteractor.sharedInstance
        gameCenterInteractor.authenticationCheck()
    }
    
    func ready() {
        gameMode = .Normal
        
        score = 0
        resetSettings()
        
        scoreLabel.visible = true
        firstPlayerScoreLabel.visible = false
        secondPlayerScoreLabel.visible = false
        
        topGoal.visible = false
    }
    
    func twoPlayerReady() {
        gameMode = .TwoPlayer
        
        firstPlayerScore = 0
        secondPlayerScore = 0
        resetSettings()
        
        scoreLabel.visible = false
        firstPlayerScoreLabel.visible = true
        secondPlayerScoreLabel.visible = true
        
        topGoal.visible = true
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
        
        timeLeft = 5
        newHighScoreLabel.visible = false
        
        topGoalInstructions.visible = (gameMode == .TwoPlayer)
        instructions.visible = (gameMode == .Normal)
        
        background.opacity = 1
        currentColorIndex = 0
        
        circle.physicsBody.affectedByGravity = false
    }
    
    func startCircleDefaultVelocity() {
        circle.totalVelocity = circle.kStartingVelocity
        
        circle.physicsBody.velocity.x = CGFloat(arc4random_uniform(UInt32(circle.totalVelocity)))
        if arc4random_uniform(2) < 1 {
            circle.physicsBody.velocity.x *= -1
        }
        
        circle.physicsBody.velocity.y = circle.findComponentVelocity(circle.physicsBody.velocity.x)
        if arc4random_uniform(2) < 1 {
            circle.physicsBody.velocity.y *= -1
        }
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
            
            if gameState == .Title {
                OALSimpleAudio.sharedInstance().playBg("BounceTap-soundtrack@\(Int((circle.totalVelocity - circle.kStartingVelocity) / (circle.kVelocityIncrement / 5)) + 75)bpm.wav", volume: volume, pan: 0, loop: true)
                timeIntoTrack = 0
            }
        }
    }
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, circle: CCNode!, verticalWall: CCNode!) -> Bool {
        if gameState != .GameOver {
            circle.physicsBody.velocity.x = -circle.physicsBody.velocity.x
        }
        
        return true
    }
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, circle: CCNode!, bottomGoal: CCNode!) -> Bool {
        if gameState == .GameOver {
            return true
        }
        
        if gameState == .Playing {
            if gameMode == .Normal {
                triggerGameOver()
            }
            else { //if gameMode == .TwoPlayer
                secondPlayerScore++
                twoPlayerRoundOver()
            }
        }
        else {
            circle.physicsBody.velocity.y = -circle.physicsBody.velocity.y
        }
        
        return true
    }
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, circle: CCNode!, topGoal: CCNode!) -> Bool {
        if gameState == .GameOver {
            return true
        }
        
        if gameState == .Playing {
            if gameMode == .TwoPlayer {
                firstPlayerScore++
                twoPlayerRoundOver()
            }
            else {
                circle.physicsBody.velocity.y = -circle.physicsBody.velocity.y
            }
        }
        else {
            circle.physicsBody.velocity.y = -circle.physicsBody.velocity.y
        }
        
        return true
    }
    
    func twoPlayerRoundOver() {
        if firstPlayerScore < 7 && secondPlayerScore < 7 {
            resetSettings()
        }
        else {
            triggerGameOver()
        }
    }
    
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        if gameState == .GameOver || gameState == .Title {
            return
        }
        else if gameState == .Ready {
            gameState = .Playing
            
            self.animationManager.runAnimationsForSequenceNamed("Playing")
            topGoalInstructions.visible = false
            instructions.visible = false
        }
        
        if circle.tapped(touch.locationInWorld()) {
            if gameMode == .Normal {
                score++
                timeLeft = 5
            }
            
            circle.bounceTap()
            animateRing()
            
            currentColorIndex++
            
            self.animationManager.runAnimationsForSequenceNamed("Spin")
            OALSimpleAudio.sharedInstance().playEffect("beep-ping.wav", volume: volume * Float(circle.totalVelocity / circle.kMaxVelocity), pitch: 0.8, pan: 0, loop: false)
            
            if !maxSpeed {
                speedUpTrack()
                
                if (circle.totalVelocity == circle.kMaxVelocity) {
                    maxSpeed = true
                }
            }
        }
        else {
            if gameMode == .Normal {
                triggerGameOver()
            }
            else {
                if touch.locationInWorld().y < CCDirector.sharedDirector().viewSize().height / 2 {
                    secondPlayerScore++
                }
                else {
                    firstPlayerScore++
                }
                
                twoPlayerRoundOver()
            }
        }
    }
    
    func speedUpTrack() {
        let newBpm: Double = Double((circle.totalVelocity - circle.kStartingVelocity) / (circle.kVelocityIncrement / 5) + 75)
        let oldBpm = newBpm - 5
        let beatsIntoTrack = (Double(timeIntoTrack) / 60 * oldBpm) % 32.0 //64 beats total
        timeIntoTrack = beatsIntoTrack / newBpm * 60
        
        OALSimpleAudio.sharedInstance().preloadBg("BounceTap-soundtrack@\(Int(newBpm))bpm.wav", seekTime: Double(timeIntoTrack))
        OALSimpleAudio.sharedInstance().playBgWithLoop(true)
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
        
        OALSimpleAudio.sharedInstance().stopEverything()
        
        circle.physicsBody.velocity.x = 0
        circle.physicsBody.velocity.y = 0
        maxSpeed = false
        
        NSThread.sleepForTimeInterval(0.5)
       
        AudioServicesPlayAlertSound(UInt32(kSystemSoundID_Vibrate))
        
        circle.physicsBody.affectedByGravity = true
        
        scoreLabel.visible = false
        firstPlayerScoreLabel.visible = false
        secondPlayerScoreLabel.visible = false
                
//        adCounter++
        
        if gameMode == .Normal {
            self.animationManager.runAnimationsForSequenceNamed("NormalGameOver")
        
            gameOverScoreLabel.string = "Score: \(score)"
            
            let highScore: Int = NSUserDefaults().integerForKey("highScore")
        
            if score <= highScore {
                highScoreLabel.string = "High Score: \(highScore)"
            }
            else {
                highScoreLabel.string = "High Score: \(score)"
                NSUserDefaults().setInteger(score, forKey: "highScore")
            
                reportHighScoreToGameCenter()
            
                newHighScoreLabel.visible = true
            }
        }
        else { //if gameMode == .TwoPlayer
            self.animationManager.runAnimationsForSequenceNamed("TwoPlayerGameOver")
            
            if firstPlayerScore >= 7 {
                twoPlayerResultLabel.string = "First Player\nWon!"
            }
            else {
                twoPlayerResultLabel.string = "Second Player\nWon!"
            }
        }
    }
    
    func changeColorScheme() {
        background.runAction(CCActionTintTo(duration: 0.5, color: colorPalette[currentColorIndex]))
        
        bottomGoal.runAction(CCActionTintTo(duration: 0.5, color: colorPalette[(currentColorIndex + 3) % colorPalette.count]))
        topGoal.runAction(CCActionTintTo(duration: 0.5, color: colorPalette[(currentColorIndex + 3) % colorPalette.count]))
    }
    
    override func update(delta: CCTime) {
        if gameState == .Playing {
            timeIntoTrack += delta
            
            if gameMode == .Normal {
                timeLeft -= Float(delta)
            
                if timeLeft == 0 {
                    triggerGameOver()
                }
            }
        }
    }
    
    //MARK: Game Center
    
    func leaderboard() {
        let viewController = CCDirector.sharedDirector().parentViewController!
        let gameCenterViewController = GKGameCenterViewController()
        gameCenterViewController.gameCenterDelegate = self
        
        viewController.presentViewController(gameCenterViewController, animated: true, completion: nil)
    }
    
    func reportHighScoreToGameCenter() {
        let scoreReporter = GKScore(leaderboardIdentifier: "BounceTapNormalModeLeaderboard")
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
