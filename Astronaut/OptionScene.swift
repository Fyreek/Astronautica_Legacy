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
    let buttonPressDark = SKAction.colorizeWithColor(UIColor.blackColor(), colorBlendFactor: 0.2, duration: 0.2)
    let buttonPressLight = SKAction.colorizeWithColor(UIColor.clearColor(), colorBlendFactor: 0, duration: 0.2)
    var optionSceneActive = false
    var red:Float = 0
    var green:Float = 0
    var blue:Float = 0
    var lastSpriteName:String = ""
    
    override func didMoveToView(view: SKView) {
        addChild(bg)
        
        backSprite.name = "backSprite"
        
        redSlider = UISlider(frame: CGRectMake(self.size.width / 2 - 140, self.size.height / 6, 280, 20))
        redSlider.minimumValue = 0
        redSlider.maximumValue = 1
        redSlider.continuous = true
        redSlider.tintColor = UIColor.redColor()
        if NSUserDefaults.standardUserDefaults().floatForKey("heroColorRed") != 0.0 {
            redSlider.value = NSUserDefaults.standardUserDefaults().floatForKey("heroColorRed")
        } else {
            redSlider.value = 1
        }
        redSlider.addTarget(self, action: "sliderValueDidChange", forControlEvents: .ValueChanged)
        self.view?.addSubview(redSlider)
        
        greenSlider = UISlider(frame: CGRectMake(self.size.width / 2 - 140, self.size.height / 3, 280, 20))
        greenSlider.minimumValue = 0
        greenSlider.maximumValue = 1
        greenSlider.continuous = true
        greenSlider.tintColor = UIColor.greenColor()
        if NSUserDefaults.standardUserDefaults().floatForKey("heroColorGreen") != 0.0 {
            greenSlider.value = NSUserDefaults.standardUserDefaults().floatForKey("heroColorGreen")
        } else {
            greenSlider.value = 1
        }
        greenSlider.addTarget(self, action: "sliderValueDidChange", forControlEvents: .ValueChanged)
        self.view?.addSubview(greenSlider)
        
        blueSlider = UISlider(frame: CGRectMake(self.size.width / 2 - 140, self.size.height / 2 , 280, 20))
        blueSlider.minimumValue = 0
        blueSlider.maximumValue = 1
        blueSlider.continuous = true
        blueSlider.tintColor = UIColor.blueColor()
        if NSUserDefaults.standardUserDefaults().floatForKey("heroColorBlue") != 0.0 {
            blueSlider.value = NSUserDefaults.standardUserDefaults().floatForKey("heroColorBlue")
        } else {
            blueSlider.value = 1
        }
        blueSlider.addTarget(self, action: "sliderValueDidChange", forControlEvents: .ValueChanged)
        self.view?.addSubview(blueSlider)
        
        coloredSprite.position.x = 0
        coloredSprite.position.y = -(self.size.height / 4)
        addChild(coloredSprite)
        
        backSprite.position.x = -(self.size.width / 4)
        backSprite.position.y = -(self.size.height / 4)
        addChild(backSprite)
        
        sliderValueDidChange()
    }
    
    func removeButtonAnim() {
    
        if lastSpriteName == self.backSprite.name  {
        
            backSprite.removeAllActions()
            backSprite.runAction(buttonPressLight)
        
        }
    
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            if self.nodeAtPoint(location) == self.backSprite {
                lastSpriteName = self.backSprite.name!
                self.backSprite.runAction(buttonPressDark)
            }
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            if self.nodeAtPoint(location) == self.backSprite {
                removeButtonAnim()
                if lastSpriteName == self.backSprite.name {
                    self.backSprite.runAction(buttonPressLight){
                        self.showMenu()
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
        
        redSlider.hidden = true
        redSlider.removeFromSuperview()
        greenSlider.hidden = true
        greenSlider.removeFromSuperview()
        blueSlider.hidden = true
        blueSlider.removeFromSuperview()
        
        let transition = SKTransition.fadeWithDuration(1)
            
        var scene = GameScene(size: self.size)
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

