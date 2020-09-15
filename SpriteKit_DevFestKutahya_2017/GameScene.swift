//
//  GameScene.swift
//  SpriteKit_DevFestKutahya_2017
//
//  Created by Macbook Pro on 29.09.2017.
//  Copyright © 2017 Burak ERARSLAN. All rights reserved.
//

import SpriteKit
import GameplayKit

struct PhysicsCatagory{
    static let bee : UInt32 = 0x1 << 1
    static let trap : UInt32 = 0x1 << 2
    static let Score : UInt32 = 0x1 << 3
    static let topViewBoard : UInt32 = 0x1 << 4
    static let bottomViewBoard : UInt32 = 0x1 << 5
}


class GameScene: SKScene,SKPhysicsContactDelegate {
    
    var scoreNode = SKNode()
    var bee = SKSpriteNode()
    var flower = SKSpriteNode()
    var gameOverNode = SKSpriteNode()
    var trap = SKSpriteNode()
    let scoreLabel = SKLabelNode()
    let healtLabel = SKLabelNode()
    var topViewBoard = SKSpriteNode()
    var bottomViewBoard = SKSpriteNode()
    var moveAndRemove = SKAction()
    
    var gameStarted = Bool()
    var died = Bool()
    var score = Int()
    var healt = 3
    var timer = 3
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        
        // scoreLabel
        scoreLabel.position = CGPoint(x: self.frame.width/2, y: self.frame.height - 100)
        scoreLabel.text = "\(score)"
        scoreLabel.fontName = "Marker Felt Wide"
        scoreLabel.fontSize = 45
        scoreLabel.zPosition = 5
        scoreLabel.fontColor = UIColor.white
        self.addChild(scoreLabel)
        
        // healtLabel
        healtLabel.position = CGPoint(x: self.frame.width/2 + 130, y: self.frame.height - 50)
        healtLabel.text = "Healt: \(healt)"
        healtLabel.fontName = "Marker Felt Wide"
        healtLabel.fontSize = 30
        healtLabel.zPosition = 4
        healtLabel.fontColor = UIColor.green
        self.addChild(healtLabel)
        
        // bee
        bee = SKSpriteNode(imageNamed: "bee")
        bee.size = CGSize(width: 50, height: 50)
        bee.position = CGPoint(x: self.frame.width/2 - bee.frame.width, y: self.frame.height/2)
        bee.physicsBody = SKPhysicsBody(rectangleOf: bee.size)
        bee.physicsBody?.categoryBitMask = PhysicsCatagory.bee
        bee.physicsBody?.collisionBitMask = 0
        bee.physicsBody?.contactTestBitMask = PhysicsCatagory.Score
        bee.physicsBody?.affectedByGravity = false
        bee.physicsBody?.isDynamic = true
        bee.zPosition = 3
        self.addChild(bee)
        
        // trap
        trap = SKSpriteNode(color: UIColor.black, size: CGSize(width: 5, height: self.frame.height))
        trap.position = CGPoint(x: self.frame.width/2 - 220, y: self.frame.height/2)
        trap.physicsBody = SKPhysicsBody(rectangleOf: trap.size)
        trap.physicsBody?.categoryBitMask = PhysicsCatagory.trap
        trap.physicsBody?.collisionBitMask = 0
        trap.physicsBody?.contactTestBitMask = PhysicsCatagory.Score
        trap.physicsBody?.affectedByGravity = false
        trap.physicsBody?.isDynamic = true
        self.addChild(trap)
        
        //topView
        topViewBoard = SKSpriteNode(color: UIColor.clear, size: CGSize(width: self.frame.width, height: 5))
        topViewBoard.position = CGPoint(x: self.frame.width/2, y: self.frame.height - topViewBoard.frame.height / 2)
        
        topViewBoard.physicsBody = SKPhysicsBody(rectangleOf: topViewBoard.size)
        topViewBoard.physicsBody?.categoryBitMask = PhysicsCatagory.topViewBoard
        topViewBoard.physicsBody?.collisionBitMask = 0
        topViewBoard.physicsBody?.contactTestBitMask = PhysicsCatagory.bee
        topViewBoard.physicsBody?.affectedByGravity = false
        topViewBoard.physicsBody?.isDynamic = false
        self.addChild(topViewBoard)
        
        //bottomView
        bottomViewBoard = SKSpriteNode(color: UIColor.clear, size: CGSize(width: self.frame.width, height: 5))
        bottomViewBoard.position = CGPoint(x: self.frame.width/2, y: bottomViewBoard.frame.height / 2)
        
        bottomViewBoard.physicsBody = SKPhysicsBody(rectangleOf: bottomViewBoard.size)
        bottomViewBoard.physicsBody?.categoryBitMask = PhysicsCatagory.bottomViewBoard
        bottomViewBoard.physicsBody?.collisionBitMask = 0
        bottomViewBoard.physicsBody?.contactTestBitMask = PhysicsCatagory.bee
        bottomViewBoard.physicsBody?.affectedByGravity = false
        bottomViewBoard.physicsBody?.isDynamic = false
        self.addChild(bottomViewBoard)
    }
    
    public func random(min : CGFloat, max : CGFloat) -> CGFloat{
        
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF) * (max - min) + min
    }
    func createFlower(){
        
        scoreNode = SKNode()
        scoreNode.name = "flower"
        flower = SKSpriteNode(imageNamed: "flower")
        flower.size = CGSize(width: 40, height: 40)
        flower.position = CGPoint(x: self.frame.width, y: self.frame.height/2)
        flower.physicsBody = SKPhysicsBody(rectangleOf: flower.size)
        flower.physicsBody?.affectedByGravity = false
        flower.physicsBody?.isDynamic = false
        flower.physicsBody?.categoryBitMask = PhysicsCatagory.Score
        flower.physicsBody?.collisionBitMask = 0
        flower.physicsBody?.contactTestBitMask = PhysicsCatagory.bee | PhysicsCatagory.trap
        
        let randomPosition = random(min: -(self.frame.height/2 - 300), max: self.frame.height/2-150)
        
        scoreNode.position.y = scoreNode.position.y +  randomPosition
        scoreNode.addChild(flower)
        
        scoreNode.run(moveAndRemove)
        scoreNode.zPosition = 2
        self.addChild(scoreNode)
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        let isFirstTop = firstBody.categoryBitMask == PhysicsCatagory.topViewBoard && secondBody.categoryBitMask == PhysicsCatagory.bee
        let isSecondTop = firstBody.categoryBitMask == PhysicsCatagory.bee && secondBody.categoryBitMask == PhysicsCatagory.topViewBoard
        
        let isFirstBottom = firstBody.categoryBitMask == PhysicsCatagory.bottomViewBoard && secondBody.categoryBitMask == PhysicsCatagory.bee
        let isSecondBottom = firstBody.categoryBitMask == PhysicsCatagory.bee && secondBody.categoryBitMask == PhysicsCatagory.bottomViewBoard
        
        
        if firstBody.categoryBitMask == PhysicsCatagory.Score && secondBody.categoryBitMask == PhysicsCatagory.bee{
            point()
            firstBody.node?.removeFromParent()
        } else if firstBody.categoryBitMask == PhysicsCatagory.bee && secondBody.categoryBitMask == PhysicsCatagory.Score
        {
            point()
            secondBody.node?.removeFromParent()
        } else if (firstBody.categoryBitMask == PhysicsCatagory.trap && secondBody.categoryBitMask == PhysicsCatagory.Score) || firstBody.categoryBitMask == PhysicsCatagory.Score && secondBody.categoryBitMask == PhysicsCatagory.trap {

            if firstBody.categoryBitMask == PhysicsCatagory.Score
            {
                firstBody.node?.removeFromParent()
            }
            else
            {
                secondBody.node?.removeFromParent()
                
            }
            healt = healt - 1
            healtLabel.text = "Healt: \(healt)"
            
            if healt <= 0 && !died {
                gameOver()
            }
        } else if (isFirstTop || isSecondTop || isFirstBottom || isSecondBottom) && !died {
            gameOver()
        }
    }
    
    func point() {
        score += 1
        if score % 10 == 0 && timer >= 0
        {
            timer -= 1
            returnFlowers()
        }
        
        scoreLabel.text = "\(score)"
    }
    
    func gameOver() {
        enumerateChildNodes(withName: "flower", using: ({
            (node , error) in
            
            node.speed = 0
            
            self.healtLabel.text = ""
            
            self.createGameOver()
            self.removeAllActions()

        })
        )
        if died == false{
            died = true
        }
    }
    
    func createGameOver(){
        gameOverNode = SKSpriteNode(imageNamed: "gameOver")
        gameOverNode.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
        gameOverNode.size = CGSize(width: 200, height: 200)
        gameOverNode.zPosition = 6
        gameOverNode.setScale(0)
        self.addChild(gameOverNode)
        gameOverNode.run(SKAction.scale(to: 1.0, duration: 0.3))
    }
    
    func returnFlowers(){
        let spawn = SKAction.run({
            () in
            self.createFlower()
        })
        let delay = SKAction.wait(forDuration: 2.5)
        let SpawnDelay = SKAction.sequence([spawn, delay])
        let SpawnDelayForever = SKAction.repeatForever(SpawnDelay)
        self.run(SpawnDelayForever)
    }
    

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
  
        if gameStarted == false{
            
            gameStarted =  true
            
            bee.physicsBody?.affectedByGravity = true
            
            returnFlowers()
            
            let distance = CGFloat(self.frame.width + scoreNode.frame.width)
            let movePipes = SKAction.moveBy(x: -distance - 50, y: 0, duration: TimeInterval(0.008 * distance))
            let removePipes = SKAction.removeFromParent()
            
            moveAndRemove = SKAction.sequence([movePipes, removePipes])
            
            bee.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            bee.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 60))
        }
        else
        {
            if !died
            {
                bee.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                bee.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 60))
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
