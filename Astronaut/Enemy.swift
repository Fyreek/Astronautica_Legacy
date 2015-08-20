//
//  Enemy.swift
//  Astronaut
//
//  Created by Yannik Lauenstein on 20/08/15.
//  Copyright (c) 2015 YaLu. All rights reserved.
//

import SpriteKit

class BadGuy {
	
	var speed:Float = 0.0
	var guy:SKSpriteNode
	var currentFrame = 0
	var randomFrame = 0
	var moving = false
	var rotationSpeed:CGFloat = 1.0
	var angle = 0.0
	var range = 1.2
	var yPos = CGFloat()
	
	init(speed:Float, guy:SKSpriteNode, rotationSpeed:CGFloat) {
		
		self.speed = speed
		self.guy = guy
		self.rotationSpeed = rotationSpeed
		self.setRandomFrame()
		
		
	}
	
	func setRandomFrame() {
		
		var range = UInt32(5)..<UInt32(100)
		self.randomFrame = Int(range.startIndex + arc4random_uniform(range.endIndex - range.startIndex + 1))
		
	}
	
}
