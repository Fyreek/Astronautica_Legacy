//
//  Hero.swift
//  Astronaut
//
//  Created by Yannik Lauenstein on 20/08/15.
//  Copyright (c) 2015 YaLu. All rights reserved.
//

import SpriteKit

class Hero: SKSpriteNode {
	
	var movementSpeed:CGFloat!
	var pace:Double!
	var emit:Bool!
	
	override init(texture: SKTexture?, color: UIColor, size: CGSize) {
		self.movementSpeed = 125
		self.pace = 0.1
		self.emit = false
		
		super.init(texture: texture, color: color, size: size)
	}
	
	convenience init(color: SKColor, movementSpeed: CGFloat = 75, pace: Double = 0.1, emit: Bool = false){
	
		let size = CGSize(width: SKSpriteNode(imageNamed: "Astronaut25").size.width, height: SKSpriteNode(imageNamed: "Astronaut25").size.height)
		self.init(texture:nil, color: color, size: size)
		self.movementSpeed = movementSpeed
		self.pace = pace
		self.emit = emit.boolValue
	}

	required init?(coder aDecoder: NSCoder) {
		
		super.init(coder: aDecoder)
		
	    fatalError("init(coder:) has not been implemented")
	}
}
