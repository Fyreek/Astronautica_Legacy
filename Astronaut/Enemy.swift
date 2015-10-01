//
//  Enemy.swift
//  Astronaut
//
//  Created by Yannik Lauenstein on 20/08/15.
//  Copyright (c) 2015 YaLu. All rights reserved.
//

import SpriteKit

class Enemy : SKSpriteNode {
	
	var movementSpeed:Float!
	var currentFrame:Int!
	var randomFrame:Int!
	var moving:Bool!
	var rotationSpeed:CGFloat!
	var angle:Float!
	var range:Float!
	var yPos:CGFloat!
    var rotationDirection:Int!
    var preLocation:CGFloat!
    var health:Int!
	var uniqueIndetifier:Int!
    var scored:Bool!
	
	override init(texture: SKTexture?, color: UIColor, size: CGSize) {
		self.movementSpeed = 0.0
		self.currentFrame = 0
		self.randomFrame = 0
		self.moving = false
		self.rotationSpeed = 1.0
		self.angle = 0.0
		self.range = 1.2
		self.yPos = 0
		self.rotationDirection = 0
		self.preLocation = 0
		self.health = 0
		self.uniqueIndetifier = 0
        self.scored = false
		
		super.init(texture: texture, color: color, size: size)
	}
	
    convenience init(movementSpeed: Float = 0.0, currentFrame: Int = 0, randomFrame: Int = 0, moving: Bool = false, rotationSpeed: CGFloat = 1.0, angle: Float = 0.0, range: Float = 1.2, yPos: CGFloat = 0, rotationDirection: Int = 0, preLocation: CGFloat = 0, health: Int = 0, uniqueIdentifier: Int = 0, scored: Bool = false){
	
		let size = CGSize(width: SKSpriteNode(imageNamed: "Asteroid16").size.width, height: SKSpriteNode(imageNamed: "Asteroid16").size.height)
		
		let color:SKColor = SKColor.clearColor()
		
		self.init(texture:nil, color: color, size: size)
		self.movementSpeed = movementSpeed
		self.currentFrame = currentFrame
		self.randomFrame = randomFrame
		self.moving = moving.boolValue
		self.rotationSpeed = rotationSpeed
		self.angle = angle
		self.range = range
		self.yPos = yPos
		self.rotationDirection = rotationDirection
		self.preLocation = preLocation
		self.health = health
		self.uniqueIndetifier = uniqueIdentifier
        self.scored = scored
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	func setRandomFrame() {
		
		let range = UInt32(5)..<UInt32(200)
		self.randomFrame = Int(range.startIndex + arc4random_uniform(range.endIndex - range.startIndex + 1))
	}
	
}
