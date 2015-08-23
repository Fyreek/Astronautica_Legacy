//
//  Enemy.swift
//  Astronaut
//
//  Created by Yannik Lauenstein on 20/08/15.
//  Copyright (c) 2015 YaLu. All rights reserved.
//

import SpriteKit

class Enemy {
	
	var speed:Float = 0.0
	var guy:SKSpriteNode
	var currentFrame = 0
	var randomFrame = 0
	var moving = false
	var rotationSpeed:CGFloat = 1.0
	var angle = 0.0
	var range = 1.2
	var yPos = CGFloat()
    var rotationDirection:Int = 0
    var preLocation:CGFloat = 0
    var health:Int = 0
	
    init(speed:Float, guy:SKSpriteNode, rotationSpeed:CGFloat, rotationDirection:Int, preLocation:CGFloat, health:Int) {
		
		self.speed = speed
		self.guy = guy
		self.rotationSpeed = rotationSpeed
        self.rotationDirection = rotationDirection
        self.preLocation = preLocation
        self.health = health
		self.setRandomFrame()
		
		
	}
	
	func setRandomFrame() {
		
		var range = UInt32(5)..<UInt32(100)
		self.randomFrame = Int(range.startIndex + arc4random_uniform(range.endIndex - range.startIndex + 1))
		
	}
	
}
