//
//  Hero.swift
//  Astronaut
//
//  Created by Yannik Lauenstein on 20/08/15.
//  Copyright (c) 2015 YaLu. All rights reserved.
//

import SpriteKit

class Hero {
	
	var guy:SKSpriteNode
	var speed: CGFloat = 75
	var pace = 0.1
	var emit = false
	var emitFrameCount = 0
	var maxEmitFrameCount = 20
	var particles:SKEmitterNode
	//var heroAtlas = SKTextureAtlas(named: "hero.atlas")
	
	init(guy:SKSpriteNode, particles:SKEmitterNode){
		self.guy = guy
		self.particles = particles
		
	}
	
	
}
