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
    let buttonPressLight = SKAction.colorizeWithColor(UIColor.whiteColor(), colorBlendFactor: 0.2, duration: 0.2)
    var optionSceneActive = false
    var red:Float = 0
    var green:Float = 0
    var blue:Float = 0
    
    override func didMoveToView(view: SKView) {
        addChild(bg)
        
        redSlider = UISlider(frame: CGRectMake(self.size.width / 2 - 140, self.size.height / 6, 280, 20))
        redSlider.minimumValue = 0
        redSlider.maximumValue = 100
        redSlider.continuous = true
        redSlider.tintColor = UIColor.redColor()
        redSlider.value = 50
        redSlider.addTarget(self, action: "sliderValueDidChange", forControlEvents: .ValueChanged)
        self.view?.addSubview(redSlider)
        
        greenSlider = UISlider(frame: CGRectMake(self.size.width / 2 - 140, self.size.height / 3, 280, 20))
        greenSlider.minimumValue = 0
        greenSlider.maximumValue = 100
        greenSlider.continuous = true
        greenSlider.tintColor = UIColor.greenColor()
        greenSlider.value = 50
        greenSlider.addTarget(self, action: "sliderValueDidChange", forControlEvents: .ValueChanged)
        self.view?.addSubview(greenSlider)
        
        blueSlider = UISlider(frame: CGRectMake(self.size.width / 2 - 140, self.size.height / 2 , 280, 20))
        blueSlider.minimumValue = 0
        blueSlider.maximumValue = 100
        blueSlider.continuous = true
        blueSlider.tintColor = UIColor.blueColor()
        blueSlider.value = 50
        blueSlider.addTarget(self, action: "sliderValueDidChange", forControlEvents: .ValueChanged)
        self.view?.addSubview(blueSlider)
        
        coloredSprite.position.x = 0
        coloredSprite.position.y = -(self.size.height / 4)
        addChild(coloredSprite)
        
        backSprite.position.x = -(self.size.width / 4)
        backSprite.position.y = -(self.size.height / 4)
        addChild(backSprite)
        
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            if self.nodeAtPoint(location) == self.backSprite {
                self.backSprite.runAction(buttonPressDark)
            }
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            if self.nodeAtPoint(location) == self.backSprite {
                self.backSprite.runAction(buttonPressLight){
                    self.showMenu()
                }
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
            println("Red value: \(redSlider.value)")
            println("Green value: \(greenSlider.value)")
            println("Blue value: \(blueSlider.value)")
        
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

