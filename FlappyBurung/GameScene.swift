//
//  GameScene.swift
//  FlappyBurung
//
//  Created by Yuda on 12/28/17.
//  Copyright © 2017 Yuda. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import Alamofire

struct PhysicsCategory {
    static let Burung : UInt32 = 0x1 << 1
    static let Ground : UInt32 = 0x1 << 2
    static let Wall : UInt32 = 0x1 << 3
    static let Sky : UInt32 = 0x1 << 4
    static let Score : UInt32 = 0x1 << 5
}

class GameScene: SKScene , SKPhysicsContactDelegate, UITextFieldDelegate{
    
    var Ground = SKSpriteNode()
    var Sky = SKSpriteNode()
    var Burung = SKSpriteNode()
    var wallpair = SKNode()
    var MoveAndRemove = SKAction()
    var gameStarted = Bool()
    var blockDistance = CGFloat(0.01)
    var score = Int()
    var scoreLabel = SKLabelNode()
    var dead = Bool()
    var restartBtn = SKSpriteNode()
    var logoutBtn = SKSpriteNode()
    var frameRestart = SKSpriteNode()
    var background = SKSpriteNode()
    var isLogin = Bool()
    var highScore = UITextField()
    var id = Int()
    var user = String()
    var fullname = String()
    
    override func sceneDidLoad() {
        
        self.removeAllActions()
        self.removeAllChildren()
        dead = false
        gameStarted = false
        score = 0
        
        createScene()
        id = UserDefaults.standard.integer(forKey: "id")
        user = UserDefaults.standard.string(forKey: "user")!
        fullname = UserDefaults.standard.string(forKey: "fullname")!
        print("isi local storage : \(id)\(String(describing: user))\(String(describing: fullname))")
    }
    
    func createScene(){
        
        self.physicsWorld.contactDelegate = self
        
        for i in 0..<2{
            background = SKSpriteNode(imageNamed: "Background")
            background.anchorPoint = CGPoint.zero
            background.position = CGPoint(x: CGFloat(i) * self.frame.width, y: 0)
            background.name = "Background"
            background.zPosition = -4
            background.size = (self.scene?.size)!
            self.addChild(background)
            
        }
        
        scoreLabel.position = CGPoint(x: self.frame.width / 2 , y: self.frame.height / 2 + self.frame.height / 3)
        scoreLabel.text = "\(score)"
        scoreLabel.fontName = "04b_19"
        scoreLabel.fontSize = 60
        scoreLabel.zPosition = 5
        self.addChild(scoreLabel)
        
        Ground = SKSpriteNode(imageNamed: "Ground")
        Ground.setScale(0.7)
        Ground.position = CGPoint(x: self.frame.width / 2, y: 0 + Ground.frame.height/2)
        Ground.zPosition = 1
        Ground.physicsBody = SKPhysicsBody(rectangleOf: Ground.size)
        Ground.physicsBody?.categoryBitMask = PhysicsCategory.Ground
        Ground.physicsBody?.collisionBitMask = PhysicsCategory.Burung
        Ground.physicsBody?.contactTestBitMask = PhysicsCategory.Burung
        Ground.physicsBody?.affectedByGravity = false
        Ground.physicsBody?.isDynamic = false
        
        Sky = SKSpriteNode(imageNamed: "Ground")
        Sky.setScale(0.7)
        Sky.position = CGPoint(x: self.frame.width / 2, y: self.frame.height + Sky.frame.height/2)
        Sky.zPosition = 1
        Sky.physicsBody = SKPhysicsBody(rectangleOf: Sky.size)
        Sky.physicsBody?.categoryBitMask = PhysicsCategory.Sky
        Sky.physicsBody?.collisionBitMask = PhysicsCategory.Burung
        Sky.physicsBody?.contactTestBitMask = PhysicsCategory.Burung
        Sky.physicsBody?.affectedByGravity = false
        Sky.physicsBody?.isDynamic = false
        
        
        self.addChild(Ground)
        self.addChild(Sky)
        
        
        Burung = SKSpriteNode(imageNamed: "Ghost")
        Burung.setScale(0.3)
        Burung.zRotation = CGFloat(-1.575)
        Burung.position = CGPoint(x: self.frame.width / 4, y: self.frame.height / 2 + Burung.frame.height / 2)
        Burung.physicsBody = SKPhysicsBody(circleOfRadius: Burung.frame.height / 2 )
        Burung.physicsBody?.categoryBitMask = PhysicsCategory.Burung
        Burung.physicsBody?.collisionBitMask = PhysicsCategory.Ground | PhysicsCategory.Wall | PhysicsCategory.Sky
        Burung.physicsBody?.contactTestBitMask = PhysicsCategory.Ground | PhysicsCategory.Wall | PhysicsCategory.Score | PhysicsCategory.Sky
        Burung.physicsBody?.affectedByGravity = false
        Burung.physicsBody?.isDynamic = true
        
        self.addChild(Burung)
    }
    
    func restartScene(){
        self.removeAllActions()
        self.removeAllChildren()
        dead = false
        gameStarted = false
        score = 0
        createScene()
    }
    
    func createWalls(){
        let scoreNode = SKSpriteNode()
        scoreNode.size = CGSize(width: 1,height: 200)
        scoreNode.position = CGPoint(x: self.frame.width, y: self.frame.height / 2)
        scoreNode.physicsBody = SKPhysicsBody(rectangleOf: scoreNode.size)
        scoreNode.physicsBody?.affectedByGravity = false
        scoreNode.physicsBody?.isDynamic = false
        scoreNode.physicsBody?.categoryBitMask = PhysicsCategory.Score
        scoreNode.physicsBody?.collisionBitMask = 0
        scoreNode.physicsBody?.contactTestBitMask = PhysicsCategory.Burung
//        scoreNode.color = SKColor.blue
        
        wallpair = SKNode()
        wallpair.name = "wallPair"
        let topWall = SKSpriteNode(imageNamed: "Wall")
        let btmWall = SKSpriteNode(imageNamed: "Wall")
    
        topWall.setScale(0.5)
        btmWall.setScale(0.5)
        
        topWall.position = CGPoint(x: self.frame.width , y: self.frame.height / 2 + 340)
        btmWall.position = CGPoint(x: self.frame.width , y: self.frame.height / 2 - 340)
        
        topWall.physicsBody = SKPhysicsBody(rectangleOf: topWall.size)
        topWall.physicsBody?.categoryBitMask = PhysicsCategory.Wall
        topWall.physicsBody?.collisionBitMask = PhysicsCategory.Burung
        topWall.physicsBody?.contactTestBitMask = PhysicsCategory.Burung
        topWall.physicsBody?.affectedByGravity = false
        topWall.physicsBody?.isDynamic = false
        
        btmWall.physicsBody = SKPhysicsBody(rectangleOf: btmWall.size)
        btmWall.physicsBody?.categoryBitMask = PhysicsCategory.Wall
        btmWall.physicsBody?.collisionBitMask = PhysicsCategory.Burung
        btmWall.physicsBody?.contactTestBitMask = PhysicsCategory.Burung
        btmWall.physicsBody?.affectedByGravity = false
        btmWall.physicsBody?.isDynamic = false
        
        
        wallpair.addChild(topWall)
        wallpair.addChild(btmWall)
        wallpair.addChild(scoreNode)
        let randomPosition = CGFloat.random(min: -self.frame.height / 5 , max: self.frame.height / 5 )
        wallpair.position.y = wallpair.position.y + randomPosition
        wallpair.run(MoveAndRemove )
        self.addChild(wallpair)
        
    }
    
    func createBtn(){
        
        frameRestart = SKSpriteNode(color: SKColor.white, size: CGSize(width: 200, height: 300))
        frameRestart.position = CGPoint(x: self.frame.width / 2,y: self.frame.height / 2)
        frameRestart.zPosition = 4
//        frameRestart.setScale(0)
        self.addChild(frameRestart)
//        frameRestart.run(SKAction.scale(to: 1.0, duration: 0.3))
        
        restartBtn.size = CGSize(width: 200, height: 50)
        restartBtn.position = CGPoint(x: self.frame.width / 2,y: self.frame.height / 3.3)
        restartBtn.zPosition = 5
        self.addChild(restartBtn)
        
        let restartLbl = SKLabelNode()
        restartLbl.text = "Restart"
        restartLbl.fontName = "04b_19"
        restartLbl.fontSize = 20
        restartLbl.fontColor = SKColor.black
        restartLbl.zPosition = 5
        restartLbl.position = CGPoint(x: 0 , y: -frameRestart.position.y / 2.3)
        frameRestart.addChild(restartLbl)
        
        logoutBtn.size = CGSize(width: 150, height: 50)
        logoutBtn.position = CGPoint(x: self.frame.width / 2 , y: self.frame.height / 2 + self.frame.height / 3)
        logoutBtn.zPosition = 5
        self.addChild(logoutBtn)
        
        let logoutLbl = SKLabelNode()
        logoutLbl.text = "Logout"
        logoutLbl.fontName = "04b_19"
        logoutLbl.fontSize = 20
        logoutLbl.fontColor = SKColor.black
        logoutLbl.zPosition = 5
        logoutLbl.position = CGPoint(x: self.frame.width / 2 , y: self.frame.height / 2 + self.frame.height / 3)
        self.addChild(logoutLbl)
        
        Alamofire.request("http://192.168.2.116:8222/api/user/point?_limit=6").responseJSON{
            response in
            switch response.result {
            case .success(let data):
                let res = data as! NSDictionary
                let stat = res["status"] as! Int
                let isi = res["data"] as! [NSDictionary]
                if(stat == 1){
                    var i = 0
                    for item in isi{
                        let highscoreLbl1 = SKLabelNode()
                        highscoreLbl1.text = "\(item["username"] as! String)"
                        highscoreLbl1.fontName = "04b_19"
                        highscoreLbl1.fontSize = 20
                        highscoreLbl1.horizontalAlignmentMode = .left
                        highscoreLbl1.fontColor = SKColor.black
                        highscoreLbl1.zPosition = 5
                        highscoreLbl1.position = CGPoint(x: -self.frameRestart.frame.width / 2.5  , y:  (self.frameRestart.position.y / 2.5) - CGFloat( (i) * 30))
                        self.frameRestart.addChild(highscoreLbl1)
                        
                        let highscoreLbl2 = SKLabelNode()
                        highscoreLbl2.text = "\(item["point"] as! Int)"
                        highscoreLbl2.fontName = "04b_19"
                        highscoreLbl2.fontSize = 20
                        highscoreLbl2.horizontalAlignmentMode = .right
                        highscoreLbl2.fontColor = SKColor.black
                        highscoreLbl2.zPosition = 5
                        highscoreLbl2.position = CGPoint(x: self.frameRestart.frame.width / 2.5 , y:  (self.frameRestart.position.y / 2.5) - CGFloat( (i) * 30))
                        self.frameRestart.addChild(highscoreLbl2)
                        
                        i = i + 1
                        
                    }
                }
                break
            case .failure(let error):
                print(error)
                break
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        if( firstBody.categoryBitMask == PhysicsCategory.Score && secondBody.categoryBitMask == PhysicsCategory.Burung || firstBody.categoryBitMask == PhysicsCategory.Burung && secondBody.categoryBitMask == PhysicsCategory.Score ){
            
            score += 1
//            print(score)
            scoreLabel.text = "\(score)"
        }
        
        if( firstBody.categoryBitMask == PhysicsCategory.Burung && secondBody.categoryBitMask == PhysicsCategory.Wall || firstBody.categoryBitMask == PhysicsCategory.Wall && secondBody.categoryBitMask == PhysicsCategory.Burung ||
            firstBody.categoryBitMask == PhysicsCategory.Burung && secondBody.categoryBitMask == PhysicsCategory.Ground || firstBody.categoryBitMask == PhysicsCategory.Ground && secondBody.categoryBitMask == PhysicsCategory.Burung
            ){
            
            enumerateChildNodes(withName: "wallPair", using: ({ (node, error) in
                node.speed = 0
                self.removeAllActions()
            }))
            
            if dead == false{
            
                dead = true
                let parameter : Parameters = [
                    "id_user" : id,
                    "point" : score
                ]
                Alamofire.request("http://192.168.2.116:8222/api/user/point", method: .post, parameters: parameter).responseJSON{
                    response in
                    switch response.result {
                    case .success(let data):
                        print(data)
                        self.createBtn()
                        break
                    case .failure(let error):
                        print(error)
                        break
                    }
                }
                let dimPanel = SKSpriteNode(color: SKColor.black, size: self.size)
                dimPanel.alpha = 0.75
                dimPanel.zPosition = 3
                dimPanel.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
                self.addChild(dimPanel)
                dimPanel.run(SKAction.fadeAlpha(to: 0.75, duration: 3))
                
            }
        }
    }
    func touchDown(atPoint pos : CGPoint) {

    }
    
    func touchMoved(toPoint pos : CGPoint) {

    }
    
    func touchUp(atPoint pos : CGPoint) {
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
//        for i in touches {
//            print(i.location(in: self))
//            print(i.location(in: self.view))
//        }
        
        print("a a a a")
        
        if gameStarted == false{
            
            gameStarted = true;
            
            Burung.physicsBody?.affectedByGravity = true
            let spawn = SKAction.run( {
                () in
                
                self.createWalls()
                
            })
            
            let delay = SKAction.wait(forDuration: 2.5)
            let spawnDelay = SKAction.sequence([spawn,delay])
            let spawnDelayForeever = SKAction.repeatForever(spawnDelay)
            self.run(spawnDelayForeever)
            
            let distance = CGFloat(self.frame.width + wallpair.frame.width)
            let movePipes = SKAction.moveBy(x: -distance, y: 0, duration: TimeInterval(blockDistance * distance))
            let removePipes = SKAction.removeFromParent()
            MoveAndRemove = SKAction.sequence([movePipes,removePipes])
            
            Burung.physicsBody?.velocity = CGVector(dx : 0,dy: 0)
            Burung.physicsBody?.applyImpulse(CGVector(dx: 0,dy: 40))
            
        }else{
            if dead == true {
                
            }else{
                Burung.physicsBody?.velocity = CGVector(dx : 0,dy: 0)
                Burung.physicsBody?.applyImpulse(CGVector(dx: 0,dy: 40))
            }
        }
        
        for touch in touches {
            let location = touch.location(in: self)
            if dead == true{
                if restartBtn.contains(location){
                    print("touched")
                     restartScene()
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
  
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
  
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    
    override func update(_ currentTime: TimeInterval) {
    
        if gameStarted == true{
            if dead == false{
                enumerateChildNodes(withName: "Background", using: ({(node,error) in
                    let bg = node as! SKSpriteNode
                    bg.position = CGPoint(x:bg.position.x - 1,y:bg.position.y)
                    
                    if bg.position.x <= -bg.size.width{
                        bg.position = CGPoint(x: bg.position.x + bg.size.width * 2, y: bg.position.y)
                    }
                }))
            }
        }
    }
}
