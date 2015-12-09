//
//  Structs.swift
//  Astronaut
//
//  Created by Yannik Lauenstein on 09/12/15.
//  Copyright © 2015 YaLu. All rights reserved.
//

import SpriteKit
import AVFoundation

struct interScene {
    static var playSceneDidLoad:Bool = false
    static var soundState:Bool = true
    static var musicState:Bool = true
    static var adState:Bool = true
    static var smallAdLoad:Bool = false
    static var connectedToGC:Bool = false
    static var explosionSound = SKAction.playSoundFileNamed("explosion.caf", waitForCompletion: true)
    static var oxygenSound = SKAction.playSoundFileNamed("oxygen.caf", waitForCompletion: true)
    static var backgroundMusicP: AVAudioPlayer!
    static var tickTime:Int = 200
    static var adPrice:String = ""
    static var scalingfactoriPad:CGFloat = 1
    static var scalingfactoriPhone:CGFloat = 1
    static var scalingfactorSpeed:CGFloat = 1
    static var deviceType = UIDevice.currentDevice().deviceType
    static var firstStart:Bool = true
    static var introDisplayed:Bool = false
    static var highScore:Int = 0
    static var highScoreBefore:Int = 0
    static var oxygenFail:Int = 0
    static var deaths:Int = 0
    static var coins:Int = 0
}

struct price {
    static var boost:Int = 200
    static var heart:Int = 2000
}

struct items {
    static var boostCount:Int = 0
    static var heartCount:Int = 0
}

struct secretUnlock {
    static var secretStep1:Bool = false
    static var secretStep2:Bool = false
    static var secretStep3:Bool = false
    static var secretStep4:Bool = false
    static var secretStep5:Bool = false
    static var secretStep6:Bool = false
    static var secretUnlocked:Bool = false
}

struct achievementNoob {
    static var Noob1:Bool = false
    static var Noob2:Bool = false
    static var Noob3:Bool = false
    static var Noob4:Bool = false
    static var trigger:Bool = false
}

struct heroColor {
    static var heroColorRed:Float = 1.0
    static var heroColorGreen:Float = 1.0
    static var heroColorBlue:Float = 1.0
}
