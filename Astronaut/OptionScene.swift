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
    let menuColorSprite = SKSpriteNode(imageNamed: "BackButton32")
    let menuSoundSprite = SKSpriteNode(imageNamed: "BackButton32")
    let menuInAppSprite = SKSpriteNode(imageNamed: "BackButton32")
    let noAdSprite = SKSpriteNode(imageNamed: "BackButton32")
    let soundSprite = SKSpriteNode(imageNamed: "SoundOnButton32")
    let musicSprite = SKSpriteNode(imageNamed: "BackButton32")
    let buttonPressDark = SKAction.colorizeWithColor(UIColor.blackColor(), colorBlendFactor: 0.2, duration: 0.2)
    let buttonPressLight = SKAction.colorizeWithColor(UIColor.clearColor(), colorBlendFactor: 0, duration: 0.2)
    var soundOn:Bool = true
    var musicOn:Bool = true
    var adsDisabled:Bool = false
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
        
        soundOn = NSUserDefaults.standardUserDefaults().boolForKey("soundBool")
        musicOn = NSUserDefaults.standardUserDefaults().boolForKey("musicBool")
        
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
        
        coloredSprite.setScale(scalingFactor)
        coloredSprite.position.x = 0
        coloredSprite.position.y = -(self.size.height / 4)
        coloredSprite.zPosition = 1.2
        addChild(coloredSprite)
        coloredSprite.hidden = true
        
        noAdSprite.setScale(scalingFactor)
        noAdSprite.position.x = 0
        noAdSprite.position.y = 0
        noAdSprite.zPosition = 1.2
        noAdSprite.name = "noAdSprite"
        addChild(noAdSprite)
        noAdSprite.hidden = true
        
        musicSprite.setScale(scalingFactor)
        musicSprite.position.x = 0
        musicSprite.position.y = musicSprite.size.height
        musicSprite.zPosition = 1.2
        musicSprite.name = "musicSprite"
        if musicOn == true {
            musicSprite.zRotation = 180
        } else {
            musicSprite.zRotation = 0
        }
        addChild(musicSprite)
        
        soundSprite.setScale(scalingFactor)
        soundSprite.position.x = 0
        soundSprite.position.y = -soundSprite.size.height
        soundSprite.zPosition = 1.2
        soundSprite.name = "soundSprite"
        if soundOn == true {
            soundSprite.texture = SKTexture(imageNamed: "SoundOnButton32")
        } else {
            soundSprite.texture = SKTexture(imageNamed: "SoundOffButton32")
        }
        addChild(soundSprite)
        
        backSprite.setScale(scalingFactor)
        backSprite.position.x = -((self.size.width / 2) - (backSprite.size.width / 2) - 20)
        backSprite.position.y = -(self.size.height / 4)
        backSprite.zPosition = 1.2
        backSprite.name = "backSprite"
        addChild(backSprite)
        
        menuColorSprite.setScale(scalingFactor)
        menuColorSprite.position.x = (self.size.width / 2) - (menuColorSprite.size.width / 2) - 20
        menuColorSprite.position.y = self.size.height / 4
        menuColorSprite.zPosition = 1.2
        menuColorSprite.name = "menuColorSprite"
        addChild(menuColorSprite)
        
        menuSoundSprite.setScale(scalingFactor)
        menuSoundSprite.position.x = (self.size.width / 2) - (menuSoundSprite.size.width / 2) - 20
        menuSoundSprite.position.y = 0
        menuSoundSprite.zPosition = 1.2
        menuSoundSprite.name = "menuSoundSprite"
        addChild(menuSoundSprite)
        
        menuInAppSprite.setScale(scalingFactor)
        menuInAppSprite.position.x = (self.size.width / 2) - (menuInAppSprite.size.width / 2) - 20
        menuInAppSprite.position.y = -(self.size.height / 4)
        menuInAppSprite.zPosition = 1.2
        menuInAppSprite.name = "menuInAppSprite"
        addChild(menuInAppSprite)
        
        sliderValueDidChange()
    }
    
    func showHeroColorMenu() {
    
        soundSprite.runAction(SKAction.fadeOutWithDuration(1.0))
        musicSprite.runAction(SKAction.fadeOutWithDuration(1.0))
        noAdSprite.runAction(SKAction.fadeOutWithDuration(1.0)){
            self.noAdSprite.hidden = true
            self.musicSprite.hidden = true
            self.soundSprite.hidden = true
            
            self.view?.addSubview(self.redSlider)
            self.view?.addSubview(self.greenSlider)
            self.view?.addSubview(self.blueSlider)
            self.coloredSprite.hidden = false
            self.coloredSprite.runAction(SKAction.fadeInWithDuration(1.0))
            
            UIView.animateWithDuration(1.0, animations: {
                self.redSlider.alpha = 1.0
                self.greenSlider.alpha = 1.0
                self.blueSlider.alpha = 1.0
            })
        }
    }
    
    func showSoundMenu() {
    
        coloredSprite.runAction(SKAction.fadeOutWithDuration(1.0))
        noAdSprite.runAction(SKAction.fadeOutWithDuration(1.0)){
            self.coloredSprite.hidden = true
            self.noAdSprite.hidden = true
            
            self.redSlider.removeFromSuperview()
            self.greenSlider.removeFromSuperview()
            self.blueSlider.removeFromSuperview()
            
            self.musicSprite.hidden = false
            self.musicSprite.runAction(SKAction.fadeInWithDuration(1.0))
            self.soundSprite.hidden = false
            self.soundSprite.runAction(SKAction.fadeInWithDuration(1.0))
        }
        UIView.animateWithDuration(1.0, animations: {
            
            self.redSlider.alpha = 0
            self.greenSlider.alpha = 0
            self.blueSlider.alpha = 0
        })
    }
    
    func showAdMenu() {
    
        coloredSprite.runAction(SKAction.fadeOutWithDuration(1.0)){
            self.musicSprite.hidden = true
            self.soundSprite.hidden = true
            self.coloredSprite.hidden = true
            
            UIView.animateWithDuration(1.0, animations: {
                
                self.redSlider.alpha = 0
                self.greenSlider.alpha = 0
                self.blueSlider.alpha = 0
                
                }, completion: {(finished: Bool) -> Void in
                    
                    self.redSlider.removeFromSuperview()
                    self.greenSlider.removeFromSuperview()
                    self.blueSlider.removeFromSuperview()
                    
                    self.noAdSprite.hidden = false
                    self.noAdSprite.runAction(SKAction.fadeInWithDuration(1.0))
            })

            
        }
        musicSprite.runAction(SKAction.fadeOutWithDuration(1.0))
        soundSprite.runAction(SKAction.fadeOutWithDuration(1.0))
    }
    
    func removeButtonAnim() {
    
        if lastSpriteName == self.backSprite.name  {
            backSprite.removeAllActions()
            backSprite.runAction(buttonPressLight)
        } else if lastSpriteName == self.menuColorSprite.name {
            menuColorSprite.removeAllActions()
            menuColorSprite.runAction(buttonPressLight)
        } else if lastSpriteName == menuInAppSprite.name {
            menuInAppSprite.removeAllActions()
            menuInAppSprite.runAction(buttonPressLight)
        } else if lastSpriteName == menuSoundSprite.name {
            menuSoundSprite.removeAllActions()
            menuSoundSprite.runAction(buttonPressLight)
        } else if lastSpriteName == noAdSprite.name {
            noAdSprite.removeAllActions()
            noAdSprite.runAction(buttonPressLight)
        } else if lastSpriteName == soundSprite.name {
            soundSprite.removeAllActions()
            soundSprite.runAction(buttonPressLight)
        } else if lastSpriteName == musicSprite.name {
            musicSprite.removeAllActions()
            musicSprite.runAction(buttonPressLight)
        }
    }
    
    func hideAds() {
    
    }
    
    func soundManagment() {
        if soundOn == true {
            soundOn = false
            soundSprite.texture = SKTexture(imageNamed: "SoundOffButton32")
        } else {
            soundOn = true
            soundSprite.texture = SKTexture(imageNamed: "SoundOnButton32")
        }
        print(soundOn)
        NSUserDefaults.standardUserDefaults().setBool(soundOn, forKey: "soundBool")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func musicManagement() {
        if musicOn == true {
            musicOn = false
            musicSprite.zRotation = 0
        } else {
            musicOn = true
            musicSprite.zRotation = 180
        }
        print(musicOn)
        NSUserDefaults.standardUserDefaults().setBool(musicOn, forKey: "musicBool")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            if self.nodeAtPoint(location) == self.backSprite {
                lastSpriteName = self.backSprite.name!
                self.backSprite.runAction(buttonPressDark)
            } else if self.nodeAtPoint(location) == self.menuColorSprite {
                lastSpriteName = self.menuColorSprite.name!
                self.menuColorSprite.runAction(buttonPressDark)
            } else if self.nodeAtPoint(location) == self.menuSoundSprite {
                lastSpriteName = self.menuSoundSprite.name!
                self.menuSoundSprite.runAction(buttonPressDark)
            } else if self.nodeAtPoint(location) == self.menuInAppSprite {
                lastSpriteName = self.menuInAppSprite.name!
                self.menuInAppSprite.runAction(buttonPressDark)
            } else if self.nodeAtPoint(location) == self.noAdSprite {
                lastSpriteName = self.noAdSprite.name!
                self.noAdSprite.runAction(buttonPressDark)
            } else if self.nodeAtPoint(location) == self.soundSprite {
                lastSpriteName = self.soundSprite.name!
                self.soundSprite.runAction(buttonPressDark)
            } else if self.nodeAtPoint(location) == self.musicSprite {
                lastSpriteName = self.musicSprite.name!
                self.musicSprite.runAction(buttonPressDark)
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
            } else if self.nodeAtPoint(location) == self.menuColorSprite {
                removeButtonAnim()
                if lastSpriteName == self.menuColorSprite.name {
                    self.menuColorSprite.runAction(buttonPressLight){
                        self.showHeroColorMenu()
                    }
                }
            } else if self.nodeAtPoint(location) == self.menuInAppSprite {
                removeButtonAnim()
                if lastSpriteName == self.menuInAppSprite.name {
                    self.menuInAppSprite.runAction(buttonPressLight) {
                        self.showAdMenu()
                    }
                }
            } else if self.nodeAtPoint(location) == self.menuSoundSprite {
                removeButtonAnim()
                if lastSpriteName == self.menuSoundSprite.name {
                    self.menuSoundSprite.runAction(buttonPressLight) {
                        self.showSoundMenu()
                    }
                }
            } else if self.nodeAtPoint(location) == self.noAdSprite {
                removeButtonAnim()
                if lastSpriteName == self.noAdSprite.name {
                    self.noAdSprite.runAction(buttonPressLight){
                        self.hideAds()
                    }
                }
            } else if self.nodeAtPoint(location) == self.soundSprite {
                removeButtonAnim()
                if lastSpriteName == self.soundSprite.name {
                    self.soundSprite.runAction(buttonPressLight){
                        self.soundManagment()
                    }
                }
            } else if self.nodeAtPoint(location) == self.musicSprite {
                removeButtonAnim()
                if lastSpriteName == self.musicSprite.name {
                    self.musicSprite.runAction(buttonPressLight){
                        self.musicManagement()
                    }
                }
            } else {
                backSprite.removeAllActions()
                menuColorSprite.removeAllActions()
                menuInAppSprite.removeAllActions()
                menuSoundSprite.removeAllActions()
                noAdSprite.removeAllActions()
                musicSprite.removeAllActions()
                soundSprite.removeAllActions()
                self.backSprite.runAction(buttonPressLight)
                self.menuColorSprite.runAction(buttonPressLight)
                self.menuInAppSprite.runAction(buttonPressLight)
                self.menuSoundSprite.runAction(buttonPressLight)
                self.noAdSprite.runAction(buttonPressLight)
                self.musicSprite.runAction(buttonPressLight)
                self.soundSprite.runAction(buttonPressLight)
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

