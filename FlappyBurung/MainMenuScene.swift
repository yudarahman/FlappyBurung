//
//  MainMenu.swift
//  FlappyBurung
//
//  Created by Yuda on 1/12/18.
//  Copyright © 2018 Yuda. All rights reserved.
//

import SpriteKit
import GameplayKit
import Alamofire
import UIKit

class MainMenuScene: SKScene, UITextFieldDelegate {
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    var username = UITextField()
    var password = UITextField()
    var loginBtn = UIButton(type: .custom)
    var registerBtn = UIButton(type: .custom)
    var background = SKSpriteNode()
    var burung = SKSpriteNode()
    var fullname = UITextField()
    
    
    override func didMove(to view: SKView) {
        self.removeAllChildren()
        self.createBackground()
        let id = UserDefaults.standard.integer(forKey: "id")
        let user = UserDefaults.standard.string(forKey: "user")
        let fullname = UserDefaults.standard.string(forKey: "fullname")
        if(id != 0){
            self.moveToGame(username: user!, fullname: fullname!, id: id)
        }else{
            self.createLoginScreen()
       }
        
    }
    
    
    func createLoginScreen(){
        self.createTextFieldWithKeyboardOn(textField: username, x: Int(self.frame.width / 5), y: Int(self.frame.height / 2) + 50, placeholder: "Username", text: "")
        self.createTextFieldWithKeyboardOn(textField: password, x: Int(self.frame.width / 5), y: Int(self.frame.height / 2), placeholder: "Password", text: "")
        self.password.isSecureTextEntry = true
        self.createButton(button: loginBtn, x : Int(self.frame.width / 5), y : Int(self.frame.height / 4) , text: "Login" , color : UIColor.blue, textColor: UIColor.white)
        self.createButton(button: registerBtn, x : Int(self.frame.width / 5), y : Int(self.frame.height / 4) - 50 , text: "Dont Have Account ?" , color: UIColor(white: 1, alpha: 0), textColor: UIColor.white)
    }
    
    func createSplasScreen(){
        burung = SKSpriteNode(imageNamed: "Ghost")
        burung.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        burung.setScale(0.3)
        burung.zRotation = CGFloat(-1.575)
    }
    
    func createBackground(){
        background = SKSpriteNode(imageNamed: "Background")
        background.anchorPoint = CGPoint.zero
        background.name = "Background"
        background.zPosition = -4
        background.size = (self.scene?.size)!
        self.addChild(background)
    }
    
    func createTextFieldWithKeyboardOn(textField:UITextField, x:Int, y: Int, placeholder: String, text: String) {
        let position = self.convertPoint(toView: CGPoint(x: x, y: y))
        textField.frame = CGRect(x: position.x, y: position.y, width: 200, height: 40)
        textField.textColor = UIColor.white
        textField.backgroundColor = UIColor(white: 0, alpha: 0.5)
        textField.delegate = self
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.attributedPlaceholder = NSAttributedString(string: placeholder,attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        textField.textAlignment = .center
        textField.becomeFirstResponder()
        self.view?.addSubview(textField)
        
    }
    
    func createButton(button:UIButton, x:Int, y: Int, text: String, color: UIColor, textColor: UIColor) {
        let position = self.convertPoint(toView: CGPoint(x: x, y: y))
        button.frame = CGRect(x: position.x, y: position.y, width: 200, height: 40)
        button.backgroundColor = color
        button.setTitle(text, for: .normal)
        button.setTitleColor(textColor, for: .normal)
        self.view?.addSubview(button)
        if(text == "Login"){
            loginBtn.addTarget(self, action: #selector(loginAction(_:)), for: .touchUpInside)
        }else{
            registerBtn.addTarget(self, action: #selector(registerAction(_:)), for: .touchUpInside)
        }
    }
    
    @objc private func loginAction(_ sender: UIButton?) {
        self.login()
    }
    
    @objc private func registerAction(_ sender: UIButton?) {
        self.addRegister()
    }
    
    func login(){
        let parameter: Parameters = [
            "username":self.username.text!,
            "password":self.password.text!
        ]
        Alamofire.request("http://192.168.2.116:8222/api/user/login", method: .post, parameters: parameter).responseJSON{
            response in
            switch response.result {
            case .success(let data):
                let res = data as! NSDictionary
                let stat = res["status"] as! Int
                let message = res["message"] as! String
                let isi = res["data"] as! NSDictionary
                let id = isi["id_user"] as! Int
                let username = isi["username"] as! String
                let nama_lengkap = isi["nama_lengkap"] as! String
                if(stat == 0){
                    self.alert(title: "Flappy Burung", message: message)
                }else{
                    self.moveToGame(username: username, fullname: nama_lengkap, id: id)
                }
                break
            case .failure(let error):
                self.alert(title: "Flappy Burung", message: error.localizedDescription)
                break
            }
        }
    }
    
    func addRegister(){
        self.createTextFieldWithKeyboardOn(textField: fullname, x: Int(self.frame.width / 5), y: Int(self.frame.height / 2) - 50, placeholder: "Full Name", text: "")
        loginBtn.removeFromSuperview()
        registerBtn.removeFromSuperview()
        self.createButton(button: registerBtn, x : Int(self.frame.width / 5), y : Int(self.frame.height / 4) , text: "Register" , color: UIColor.blue, textColor: UIColor.white)
        registerBtn.addTarget(self, action:  #selector(register(_:)), for: .touchUpInside)
    }
    
    @objc private func register(_ sender: UIButton?) {
        let parameter: Parameters = [
            "username":self.username.text!,
            "password":self.password.text!,
            "nama_lengkap":self.fullname.text!
        ]
        Alamofire.request("http://192.168.2.116:8222/api/user", method: .post, parameters : parameter).responseJSON
            {
                response in
                switch response.result {
                case .success(let data):
                    let res = data as! NSDictionary
                    let stat = res["status"] as! Int
                    let message = res["message"] as! String
                    
                    if(stat == 0){
                        self.alert(title: "Flappy Burung", message: message)
                    }else{
                        self.alert(title: "Flappy Burung", message: message)
                        self.username.removeFromSuperview()
                        self.password.removeFromSuperview()
                        self.fullname.removeFromSuperview()
                        self.registerBtn.removeFromSuperview()
                        self.removeAllChildren()
                        self.createBackground()
                        self.createLoginScreen()
                        self.username.text = ""
                        self.password.text = ""
                    }
                    break
                case .failure(let error):
                    self.alert(title: "Flappy Burung", message: error.localizedDescription)
                    break
                }
            }
    }
    
    func alert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default) { action in
            // Handle when button is clicked
        }
        alert.addAction(action)
        if let vc = self.scene?.view?.window?.rootViewController {
            vc.present(alert, animated: true, completion: nil)
        }
    }
    
    func moveToGame(username: String, fullname: String, id: Int){
        self.username.removeFromSuperview()
        self.password.removeFromSuperview()
        loginBtn.removeFromSuperview()
        registerBtn.removeFromSuperview()
        UserDefaults.standard.set(username, forKey: "user")
        UserDefaults.standard.set(fullname, forKey: "fullname")
        UserDefaults.standard.set(id, forKey: "id")
        if let scene = GKScene(fileNamed: "GameScene") {
            
            // Get the SKScene from the loaded GKScene
            if let sceneNode = scene.rootNode as! GameScene? {
                
                // Present the scene
                if let view = self.view  {
                    view.presentScene(sceneNode)
                    
                    view.ignoresSiblingOrder = true
                    view.showsFPS = true
                    view.showsNodeCount = true
                }
            }
        }
    }
    
    func touchDown(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view?.endEditing(true)
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}


