//
//  OptionScene.swift
//  Astronaut
//
//  Created by Yannik Lauenstein on 24.08.15.
//  Copyright (c) 2015 YaLu. All rights reserved.
//

import SpriteKit


class OptionScene: SKScene {
    
    var mySampleColorButton: UIButton!
    var mySampleColorLabel: UILabel!
    var redSlider: UISlider! = UISlider(frame: CGRectMake(20, 260, 280, 20))
    var greenSlider: UISlider! = UISlider(frame: CGRectMake(20, 260, 280, 20))
    var blueSlider: UISlider! = UISlider(frame: CGRectMake(20, 260, 280, 20))
    let bg = SKSpriteNode(imageNamed: "Background188")
    let coloredSprite = SKSpriteNode(imageNamed: "Astronaut25")
    let backSprite = SKSpriteNode(imageNamed: "BackButton32")
    let resetSprite = SKSpriteNode(imageNamed: "BackButton32")
    let buttonPressDark = SKAction.colorizeWithColor(UIColor.blackColor(), colorBlendFactor: 0.2, duration: 0.2)
    let buttonPressLight = SKAction.colorizeWithColor(UIColor.clearColor(), colorBlendFactor: 0, duration: 0.2)
    var optionSceneActive = false
    var red:Float = 0
    var green:Float = 0
    var blue:Float = 0
    var lastSpriteName:String = ""
    var scalingFactor:CGFloat = 1
    
    override func didMoveToView(view: SKView) {
        
        scalingFactor = (self.size.height * 2) / 640 //iPhone 5 Height, so iPhone 5 has original scaled sprites.

        bg.zPosition = 0.9
        bg.setScale(scalingFactor)
        addChild(bg)
        
        backSprite.name = "backSprite"
        resetSprite.name = "resetSprite"
        
        redSlider = UISlider(frame: CGRectMake(self.size.width / 2 - 140, self.size.height / 6, 280, 20))
        redSlider.minimumValue = 0
        redSlider.maximumValue = 1
        redSlider.value = 1.0
        redSlider.continuous = true
        redSlider.tintColor = UIColor.redColor()
        if NSUserDefaults.standardUserDefaults().floatForKey("heroColorRed") != 1.0 {
            redSlider.value = NSUserDefaults.standardUserDefaults().floatForKey("heroColorRed")
        }
        redSlider.addTarget(self, action: "sliderValueDidChange", forControlEvents: .ValueChanged)
        redSlider.alpha = 0
        self.view?.addSubview(redSlider)
        
        greenSlider = UISlider(frame: CGRectMake(self.size.width / 2 - 140, self.size.height / 3, 280, 20))
        greenSlider.minimumValue = 0
        greenSlider.maximumValue = 1
        greenSlider.value = 1.0
        greenSlider.continuous = true
        greenSlider.tintColor = UIColor.greenColor()
        if NSUserDefaults.standardUserDefaults().floatForKey("heroColorGreen") != 1.0 {
            self.greenSlider.value = NSUserDefaults.standardUserDefaults().floatForKey("heroColorGreen")
        }
        greenSlider.addTarget(self, action: "sliderValueDidChange", forControlEvents: .ValueChanged)
        greenSlider.alpha = 0
        self.view?.addSubview(greenSlider)
        
        blueSlider = UISlider(frame: CGRectMake(self.size.width / 2 - 140, self.size.height / 2 , 280, 20))
        blueSlider.minimumValue = 0
        blueSlider.maximumValue = 1
        blueSlider.value = 1.0
        blueSlider.continuous = true
        blueSlider.tintColor = UIColor.blueColor()
        if NSUserDefaults.standardUserDefaults().floatForKey("heroColorBlue") != 1.0 {
           self.blueSlider.value = NSUserDefaults.standardUserDefaults().floatForKey("heroColorBlue")
        }
        blueSlider.addTarget(self, action: "sliderValueDidChange", forControlEvents: .ValueChanged)
        blueSlider.alpha = 0
        self.view?.addSubview(blueSlider)
        
        UIView.animateWithDuration(1.0, animations: {
        
            self.redSlider.alpha = 1.0
            self.greenSlider.alpha = 1.0
            self.blueSlider.alpha = 1.0
        })
        
        coloredSprite.setScale(scalingFactor)
        coloredSprite.position.x = 0
        coloredSprite.position.y = -(self.size.height / 4)
        coloredSprite.zPosition = 1.2
        addChild(coloredSprite)
        
        backSprite.setScale(scalingFactor)
        backSprite.position.x = -(self.size.width / 4)
        backSprite.position.y = -(self.size.height / 4)
        backSprite.zPosition = 1.2
        addChild(backSprite)
        
        resetSprite.setScale(scalingFactor)
        resetSprite.position.x = (self.size.width / 4)
        resetSprite.position.y = -(self.size.height / 4)
        resetSprite.zPosition = 1.2
        resetSprite.alpha = 0
        addChild(resetSprite)
        
        sliderValueDidChange()
    }
    
    func removeButtonAnim() {
    
        if lastSpriteName == self.backSprite.name  {
        
            backSprite.removeAllActions()
            backSprite.runAction(buttonPressLight)
        
        } else if lastSpriteName == self.resetSprite.name {
        
            resetSprite.removeAllActions()
            resetSprite.runAction(buttonPressLight)
            
        }
    
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            if self.nodeAtPoint(location) == self.backSprite {
                lastSpriteName = self.backSprite.name!
                self.backSprite.runAction(buttonPressDark)
            } else if resetSprite.containsPoint(location) {
                lastSpriteName = self.resetSprite.name!
                self.resetSprite.runAction(buttonPressDark)
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            if self.nodeAtPoint(location) == self.backSprite {
                removeButtonAnim()
                if lastSpriteName == self.backSprite.name {
                    self.backSprite.runAction(buttonPressLight){
                        self.showMenu()
                    }
                }
            } else if resetSprite.containsPoint(location) {
                removeButtonAnim()
                if lastSpriteName == self.resetSprite.name {
                    self.resetSprite.runAction(buttonPressLight){
                        NSUserDefaults.standardUserDefaults().setInteger(0, forKey: "highScore")
                    }
                }
            } else {
                backSprite.removeAllActions()
                self.backSprite.runAction(buttonPressLight)
            }
        }
    }
    
    func showMenu() {
        
        optionSceneActive = false
        
        UIView.animateWithDuration(1.0, animations: {
        
            self.redSlider.alpha = 0
            self.greenSlider.alpha = 0
            self.blueSlider.alpha = 0
            
        }, completion: {(finished: Bool) -> Void in
        
            self.redSlider.removeFromSuperview()
            self.greenSlider.removeFromSuperview()
            self.blueSlider.removeFromSuperview()
            
        
        })
        
        let transition = SKTransition.fadeWithDuration(1)
            
        let scene = GameScene(size: self.size)
        let skView = self.view as SKView!
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .ResizeFill
        scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        scene.size = skView.bounds.size
        skView.presentScene(scene, transition: transition)

    }
    
    func sliderValueDidChange() {
        if optionSceneActive {

            red = Float(redSlider.value)
            green = Float(greenSlider.value)
            blue = Float(blueSlider.value)
            let color = UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: 1.0)
        
            NSUserDefaults.standardUserDefaults().setFloat(red, forKey: "heroColorRed")
            NSUserDefaults.standardUserDefaults().setFloat(green, forKey: "heroColorGreen")
            NSUserDefaults.standardUserDefaults().setFloat(blue, forKey: "heroColorBlue")
            NSUserDefaults.standardUserDefaults().synchronize()
        
            coloredSprite.color = color
            coloredSprite.colorBlendFactor = 0.4
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
            /* Called before each frame is rendered */
    }
    
}

