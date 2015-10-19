//
//  BonusItem.swift
//  Astronaut
//
//  Created by Yannik Lauenstein on 16/10/15.
//  Copyright © 2015 YaLu. All rights reserved.
//

import SpriteKit

class BonusItem: SKSpriteNode {

    var itemType:String!
    var spawned:Bool!
    var spawnHeight:CGFloat!
    var alive:Bool!
    var moving:Bool!
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        
        self.spawned = false
        self.spawnHeight = 9999
        self.alive = false
        self.moving = false
        
        super.init(texture: texture, color: color, size: size)
    }

    convenience init(spawned: Bool = false, spawnHeight: CGFloat = 9999, alive: Bool = false, moving: Bool = false) {
    
        let size = CGSize(width: SKSpriteNode(imageNamed: "Oxygen15").size.width, height: SKSpriteNode(imageNamed: "Oxygen15").size.height)
        let color:SKColor = SKColor.clearColor()
        self.init(texture:nil, color: color, size: size)
        
        self.spawned = spawned
        self.spawnHeight = spawnHeight
        self.alive = alive
        self.moving = moving
    
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}