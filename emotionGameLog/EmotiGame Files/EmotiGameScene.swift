//
//  EmotiGameScene.swift
//  emotionGameLog
//
//  Created by Benjamin Liu on 6/9/20.
//  Copyright © 2020 Benjamin Liu. All rights reserved.
//
//  Class implementing the EmotiGame built on SpriteKit Framework

import SpriteKit
import SwiftUI

class EmotiGameScene: SKScene, ObservableObject {
    @Published var playingGame: Bool
    var gameColors: Array<UIColor>
    var gameEmojis: Array<String>
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("main init not implemented")
    }
    
    init(playingGame: Bool, gameColors: Array<UIColor>, gameEmojis: Array<String>, size: CGSize) {
        self.playingGame = playingGame
        self.gameColors = gameColors
        self.gameEmojis = gameEmojis
        super.init(size: size)
    }
    
    struct PhysicsCategory {
        static let fallUnit       : UInt32 = 0x1 << 1 //Fall proj
        static let catcher        : UInt32 = 0x1 << 2 //Basket Obj
        static let helper         : UInt32 = 0x1 << 3 //Side Proj
        static let helperContact  : UInt32 = 0x1 << 4 //Hit by side proj
        static let mainContact    : UInt32 = 0x1 << 5 //Hit by regular proj
    }
    
    var score: Int = 0 {
        didSet {
            scoreDisplay.text = "Score: \(self.score) | -\(self.losePointTracker)"
            if self.score == 100 { //Track winning game
                self.stopFallUnits = true
                run(SKAction.wait(forDuration: 3))
                self.runRiseObjectAction(text: "🌟") {
                    self.objectWillChange.send()
                    self.playingGame = false
                }
            }
        }
    }
    
    var losePointTracker = 0 {
        didSet {
            scoreDisplay.text = "Score: \(self.score) | -\(self.losePointTracker)"
            if self.losePointTracker >= 10 { //Track losing game
                self.stopFallUnits = true
                run(SKAction.wait(forDuration: 3))
                self.runRiseObjectAction(text: "☠️") {
                    self.objectWillChange.send()
                    self.playingGame = false
                }
            }
        }
    }
    
    
    // MARK: - Initialize Variables
    let player = SKLabelNode(text: "📥")
    var background = SKSpriteNode()
    var scoreDisplay = SKLabelNode()
    var scoreFrame = SKShapeNode(rect: CGRect(x: 0, y: 0, width: 110, height: 50))
    var backgroundTracker = 0
    var colorTracker = 0
    var draggingCatcher = false
    var selectedNode = SKLabelNode()
    var fallUnitBufferPos: Int = 0
    var helperUnitBufferPos: Int = 0
    var helperCount: Int = 10
    var stopFallUnits: Bool = false
    var itemsCaught: Int = 0
    typealias completionHandler = () -> Void
    
    //Executed when schene loads
    override func didMove(to view: SKView) {
        //Add scoreFrame and player children
        self.score = 0
        self.removeAllChildren()
        self.initPlayer()
        self.initScoreDisplay()
        self.addChild(scoreDisplay)
        self.initScoreFrame()
        scoreDisplay.addChild(scoreFrame)
        
        //Install drag gesture recognizers
        let dragGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleDragGesture))
        self.view!.addGestureRecognizer(dragGestureRecognizer)
        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubleTapHandler))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        self.view!.addGestureRecognizer(doubleTapGestureRecognizer)
        
        //Complete adding children
        self.addChild(background)
        self.addChild(player)
        physicsWorld.contactDelegate = self
        
        //Fall unit action initialization
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run(enlistFallUnit),
                SKAction.wait(forDuration: 1),
                SKAction.run {
                    if self.colorTracker == (self.gameEmojis.count - 1) {
                        self.colorTracker = 0
                    } else {
                        self.colorTracker += 1
                    }
                    if (self.stopFallUnits) {
                        self.removeAction(forKey: "Fall thread")
                    }
                }
            ])
        ), withKey: "Fall thread")
        
        //Background color change init
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run(changeBackground),
                SKAction.wait(forDuration: 5.0),
            ])
        ))
    }
    
    //Create player (Collection Basket)
    func initPlayer() {
        player.position = CGPoint(x: size.width * 0.5, y: size.height * 0.1)
        player.fontSize = 50
        player.zPosition = 1
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.frame.width / 2)
        player.physicsBody!.categoryBitMask = PhysicsCategory.catcher
        player.physicsBody!.contactTestBitMask = PhysicsCategory.fallUnit
        player.name = "Catcher"
        player.physicsBody!.isDynamic = false
    }
    
    //Create score display
    func initScoreDisplay() {
        scoreDisplay = SKLabelNode(text: "Score: \(self.score) | -\(self.losePointTracker)")
        scoreDisplay.fontSize = 15
        scoreDisplay.name = "Score Display"
        scoreDisplay.fontColor = UIColor.white
        scoreDisplay.position = CGPoint(x: scoreDisplay.frame.width / 2 + 10, y: scoreDisplay.frame.height)
        scoreDisplay.zPosition = 1
    }
    
    //Create score frame
    func initScoreFrame() {
        scoreFrame.position = CGPoint(x: (-1) * scoreDisplay.frame.width / 2, y: -20)
        scoreFrame.name = "Score Frame"
        scoreFrame.fillColor = UIColor.black
    }
    
    func changeBackground() {
        var colorize: SKAction
        colorize = SKAction.colorize(with: self.gameColors[self.colorTracker], colorBlendFactor: 1, duration: 3)
        run(colorize)
    }
    
    //Run fall unit through SK Action sequence
    func enlistFallUnit() {
        let fallUnit = addFallUnit()
        addChild(fallUnit)
        
        //Set up fall SK Action
        let fallDuration: CGFloat = 2.5
        let fallAction = SKAction.move(to: CGPoint(x: self.fallUnitBufferPos, y: Int(-fallUnit.frame.height)/3), duration: TimeInterval(fallDuration))
        let fallCompletionAction = SKAction.removeFromParent()
        fallUnit.run(SKAction.sequence([fallAction, fallCompletionAction,
            SKAction.run {
                self.score -= 1
                self.losePointTracker += 1
            }
        ]))
    }
    
    //Init physics and positioning for fall unit
    func addFallUnit() -> SKLabelNode {
        print(self.gameEmojis)
        let emojiText = self.gameEmojis[Int.random(in: 0..<self.gameEmojis.count)]
        let fallUnit = SKLabelNode(text: emojiText)
        
        //Physics
        fallUnit.physicsBody = SKPhysicsBody(circleOfRadius: fallUnit.frame.width / 2)
        fallUnit.physicsBody!.isDynamic = true //Subject to gravity
        fallUnit.physicsBody!.categoryBitMask = PhysicsCategory.fallUnit
        fallUnit.physicsBody!.contactTestBitMask = PhysicsCategory.helperContact | PhysicsCategory.mainContact
        
        //Positioning
        fallUnit.zPosition = 1
        let fallStarterX = Int.random(in: Int(fallUnit.frame.width)...Int(size.width))
        self.fallUnitBufferPos = fallStarterX
        fallUnit.position = CGPoint(x: fallStarterX, y: Int(size.height + fallUnit.frame.height))
        fallUnit.name = "FallUnit"
        return fallUnit
    }
    
    //Enlist the heart helper and run the SK Action helper sequence
    func enlistHelper(text: String) {
        let helper = self.addHelper(text: text)
        addChild(helper)
        
        //Set up SK Sequence
        let riseDuration: CGFloat = 1.5
        let riseAction = SKAction.move(to: CGPoint(x: self.helperUnitBufferPos, y: Int(size.height + helper.frame.height / 3)), duration: TimeInterval(riseDuration))
        let riseCompletionAction = SKAction.removeFromParent()
        helper.run(SKAction.sequence([riseAction, riseCompletionAction]))
    }
    
    //Add heart helper child, set up helper physics
    func addHelper(text: String) -> SKLabelNode {
        let helper = SKLabelNode(text: text)
        
        //Physics
        helper.physicsBody = SKPhysicsBody(circleOfRadius: helper.frame.width / 2)
        helper.physicsBody!.isDynamic = false
        helper.physicsBody!.categoryBitMask = PhysicsCategory.helper
        helper.physicsBody!.contactTestBitMask = PhysicsCategory.fallUnit
        
        //Positioning
        helper.zPosition = 1
        let starterX = Int.random(in: Int(helper.frame.width)...Int(size.width))
        self.helperUnitBufferPos = starterX
        helper.position = CGPoint(x: starterX, y: Int((-1) * helper.frame.height))
        helper.name = "Helper"
        return helper
    }
    
    //Select the basket
    func selectCatcher(_ location: CGPoint) {
        let selectedNode = self.atPoint(location)
        if selectedNode is SKLabelNode, selectedNode.name == "Catcher" {
            self.selectedNode = selectedNode as! SKLabelNode
        }
    }
    
    //Draf the basket
    func moveCatcher(_ translation: CGPoint) {
        let nodePos = self.selectedNode.position
        self.selectedNode.position = CGPoint(x: nodePos.x + translation.x, y: nodePos.y)
    }
    
    //Enlist helpers by double tapping
    @objc func doubleTapHandler(dragRecognizer: UITapGestureRecognizer) {
        print("hello There")
        if self.helperCount > 0 {
            print("Helo")
            run(SKAction.playSoundFileNamed("Bubble_AudioCut.mp3", waitForCompletion: false))
            self.runRiseObjectAction(text: "💖") {}
        }
    }
    
    //Run general rise action sequence (fall unit and helpers)
    func runRiseObjectAction(text: String, function: @escaping completionHandler) {
        run(SKAction.sequence([SKAction.repeat(
            SKAction.sequence([
                SKAction.run{self.enlistHelper(text: text)},
                SKAction.wait(forDuration: 0.2),
            ]), count: 10
            ), SKAction.run {
                self.helperCount -= 1
            }]
        ), completion: function)
    }
    
    //Handler drag gestures (for basket)
    @objc func handleDragGesture(dragRecognizer: UIPanGestureRecognizer) {
        if dragRecognizer.state == .began {
            var location = dragRecognizer.location(in: dragRecognizer.view)
            location = self.convertPoint(fromView: location)
            self.selectCatcher(location)
        } else if dragRecognizer.state == .changed {
            var offset = dragRecognizer.translation(in: dragRecognizer.view!)
            offset = CGPoint(x: offset.x, y: 0)
            self.moveCatcher(offset)
            dragRecognizer.setTranslation(CGPoint(x: 0, y: 0), in: dragRecognizer.view)
        }
    }
    
    //SKAction for catching
    func caughtFallUnit(catcher: SKLabelNode, fallUnit: SKLabelNode) {
        run(SKAction.playSoundFileNamed("Bell_AudioCut.mp3", waitForCompletion: false))
        fallUnit.removeFromParent()
        self.score += 1
    }
    
    //SKAction for helper eliminating fall unit
    func shotFallUnit(helper: SKLabelNode, fallUnit: SKLabelNode) {
        run(SKAction.playSoundFileNamed("Bell_AudioCut.mp3", waitForCompletion: false))
        fallUnit.removeFromParent()
        helper.removeFromParent()
        score += 1
    }
}

//Physics Extensions, Reference code format inspired by Ray WenderLich but written independently with completely separate logic
//Cite: https://www.raywenderlich.com/71-spritekit-tutorial-for-beginners
extension EmotiGameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        //Process category bitmasks
        let toggleCategory: Bool = contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask
        let objectOne: SKPhysicsBody = toggleCategory ? contact.bodyA : contact.bodyB
        let objectTwo: SKPhysicsBody = toggleCategory ? contact.bodyB : contact.bodyA
        
        //Contact interactions
        fallCatcherInteraction(objectOne: objectOne, objectTwo: objectTwo)
        fallHelperInteraction(objectOne: objectOne, objectTwo: objectTwo)
    }
    
    //Fall Unit and Catcher Contact
    func fallCatcherInteraction(objectOne: SKPhysicsBody, objectTwo: SKPhysicsBody) {
        let fallCatcherContact: Bool = (objectOne.categoryBitMask & PhysicsCategory.fallUnit != 0) && (objectTwo.categoryBitMask & PhysicsCategory.catcher != 0)
        if fallCatcherContact {
            if let fallUnit = objectOne.node as? SKLabelNode,
                let catcher = objectTwo.node as? SKLabelNode {
                self.caughtFallUnit(catcher: catcher, fallUnit: fallUnit)
            }
        }
    }
    
    //Fall Unit and Helper Contact
    func fallHelperInteraction(objectOne: SKPhysicsBody, objectTwo: SKPhysicsBody) {
        let fallHelperContact: Bool = (objectOne.categoryBitMask & PhysicsCategory.fallUnit != 0) && (objectTwo.categoryBitMask & PhysicsCategory.helper != 0)
        if fallHelperContact {
            if let fallUnit = objectOne.node as? SKLabelNode,
                let helper = objectTwo.node as? SKLabelNode {
                self.shotFallUnit(helper: helper, fallUnit: fallUnit)
            }
        }
    }
}


