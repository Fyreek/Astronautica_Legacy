//
//  PlayScene.swift
//  Astronaut
//
//  Created by Luca Friedrich on 20/08/15.
//  Copyright (c) 2015 YaLu. All rights reserved.
//

import SpriteKit

class PlayScene: SKScene, SKPhysicsContactDelegate {
	var hero:Hero!
	var touchLocation = CGFloat()
	var gameOver = true
	var gameStarted = false
	var badGuys:[BadGuy] = []
	var endOfScreenRight = CGFloat()
	var endOfScreenLeft = CGFloat()
	var gamePaused = false
	
	var highScore:Int = 0
	
	var gameSpeed:Float = 1.3
	var gameProgress:Int = 0
	var totalSpeedEnemy1:CGFloat = 1.0
	var totalSpeedEnemy2:CGFloat = 1.5
	var totalSpeedEnemy3:CGFloat = 3.0
	var normalSpeedEnemy1:CGFloat = 0.5
	var normalSpeedEnemy2:CGFloat = 1
	var normalSpeedEnemy3:CGFloat = 2
	
	var countDownRunning = false
	
	let bg = SKSpriteNode(imageNamed: "bg")
	let bg2 = SKSpriteNode(imageNamed: "bg")
	
	var score = 0
	var scoreLabel = SKLabelNode()
	var refresh = SKSpriteNode(imageNamed: "refresh")
	var totalScore = SKLabelNode(text: "0")
	var menu = SKSpriteNode(imageNamed: "menu")
	
	var gamePause = SKSpriteNode(imageNamed: "gamePause")
	var gamePlay = SKSpriteNode(imageNamed: "gamePlay")
	
	var startEnemy:Int = 3
	
	var timer = NSTimer()
	var countDown = 3
	var countDownText = SKLabelNode(text: "3")
	enum ColliderType:UInt32 {
		
		case Hero = 1
		case BadGuy = 2
		
	}
	
	override func didMoveToView(view: SKView) {
		//NSUserDefaults.standardUserDefaults().setInteger(0, forKey: "highScore") Reset Highscore on start!
		
		self.physicsWorld.contactDelegate = self
		endOfScreenLeft = (self.size.width / 2) * CGFloat(-1) - (SKSpriteNode(imageNamed: "enemy1").size.width / 2)
		endOfScreenRight = (self.size.width / 2) + (SKSpriteNode(imageNamed: "enemy1").size.width / 2)
		
		addChild(bg)
		addheroPlayer()
		
		highScore = NSUserDefaults.standardUserDefaults().integerForKey("highScore")
		
		scoreLabel = SKLabelNode(text: "0")
		scoreLabel.fontColor = UIColor.blackColor()
		scoreLabel.position.y = (self.size.height / 2) - 40
		scoreLabel.position.x = -(self.size.width / 2) + 40
		
		countDownText.fontColor = UIColor.blackColor()
		countDownText.setScale(2.0)
		countDownText.position.y = (self.size.height / 8)
		
		refresh.position.y = 0
		refresh.position.x = -(self.size.width / 8) // - 400
		
		menu.position.y = 0
		menu.position.x = (self.size.width / 8) // + 400
		
		gamePause.position.y = -(self.size.height / 2) + 40
		gamePause.position.x = -(self.size.width / 2) + 40
		
		gamePlay.position.y = 0
		gamePlay.position.x = 0
		
		totalScore.position.x = 0
		totalScore.position.y = self.size.height / 8
		
		addChild(totalScore)
		addChild(scoreLabel)
		addChild(refresh)
		addChild(menu)
		addChild(gamePause)
		addChild(gamePlay)
		addChild(countDownText)
		
		countDownText.hidden = true
		refresh.name = "refresh"
		refresh.hidden = true
		refresh.zPosition = 1.1
		refresh.alpha = 0
		
		gamePlay.name = "gamePlay"
		gamePlay.hidden = true
		gamePlay.zPosition = 1.1
		gamePlay.alpha = 0
		
		gamePause.name = "gamePause"
		gamePause.hidden = true
		gamePause.zPosition = 1.1
		gamePause.alpha = 0
		
		totalScore.name = "totaScore"
		totalScore.fontColor = UIColor.blackColor()
		totalScore.hidden = true
		totalScore.zPosition = 1.1
		totalScore.alpha = 0
		
		menu.name = "menu"
		menu.hidden = true
		menu.zPosition = 1.1
		menu.alpha = 0
		
		startGameNormal()
		
	}
	
	func didBeginContact(contact: SKPhysicsContact) {
		
		gameOver = true
		gamePause.hidden = true
		hero.guy.removeAllActions()
		
		hero.emit = true
		refresh.hidden = false
		refresh.runAction(SKAction.fadeInWithDuration(1.0))
		menu.hidden = false
		menu.runAction(SKAction.fadeInWithDuration(1.0))
		
		if score > NSUserDefaults.standardUserDefaults().integerForKey("highScore") {
			
			NSUserDefaults.standardUserDefaults().setInteger(score, forKey: "highScore")
			NSUserDefaults.standardUserDefaults().synchronize()
			
			totalScore.hidden = false
			totalScore.text = ("New Highscore: ") + String(score) + (" points!")
			totalScore.runAction(SKAction.fadeInWithDuration(1.0))
			
		} else {
			
			totalScore.hidden = false
			totalScore.text = ("You reached ") + String(score) + (" points!")
			totalScore.runAction(SKAction.fadeInWithDuration(1.0))
			
		}
		
	}
	
	func reloadGame() {
		
		countDownText.hidden = false
		hero.guy.removeAllActions()
		
		hero.guy.position.y = 0
		hero.guy.position.x = 0
		hero.guy.name = "kevin"
		
		refresh.runAction(SKAction.fadeOutWithDuration(1.0))
		menu.runAction(SKAction.fadeOutWithDuration(1.0))
		totalScore.runAction(SKAction.fadeOutWithDuration(1.0))
		score = 0
		scoreLabel.text = "0"
		gameProgress = 0
		gameSpeed = 1
		totalSpeedEnemy1 = normalSpeedEnemy1
		totalSpeedEnemy2 = normalSpeedEnemy2
		totalSpeedEnemy3 = normalSpeedEnemy3
		
		for badGuy in badGuys {
			
			resetBadGuy(badGuy.guy, yPos: badGuy.yPos)
			badGuy.guy.hidden = true
			
		}
		
		badGuys.removeAll(keepCapacity: false)
		addBadGuys()
		
		for var i = 1; i < startEnemy; i++ {
			
			self.addBadGuys()
			
		}
		
		timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("updateTimer"), userInfo: nil, repeats: true)
		
		
	}
	
	func updateTimer() {
		
		hero.guy.removeActionForKey("movingA")
		
		if countDown > 0 {
			
			if hero.guy.position.y != 0 {
				
				hero.guy.position.y = 0
				
			}
			
			countDown--
			countDownText.text = String(countDown)
			
			
		} else {
			
			//hero.guy.hidden = false
			countDown = 3
			countDownText.text = String(countDown)
			countDownText.hidden = true
			gameOver = false
			timer.invalidate()
			countDownRunning = false
			gamePause.hidden = false
			gamePause.alpha = 0.5
			
		}
	}
	
	func addheroPlayer(){
		
		let heroPlayer = SKSpriteNode(imageNamed: "heroPlayer")
		
		heroPlayer.physicsBody = SKPhysicsBody(circleOfRadius: heroPlayer.size.width / 2)
		
		heroPlayer.physicsBody!.affectedByGravity = false
		heroPlayer.physicsBody!.categoryBitMask = ColliderType.Hero.rawValue
		heroPlayer.physicsBody!.contactTestBitMask = ColliderType.BadGuy.rawValue
		heroPlayer.physicsBody!.collisionBitMask = ColliderType.BadGuy.rawValue
		
		let heroParticles = SKEmitterNode(fileNamed: "HitParticle.sks")
		heroParticles.hidden = true
		hero = Hero(guy: heroPlayer, particles: heroParticles)
		heroPlayer.addChild(heroParticles)
		addChild(heroPlayer)
		
	}
	
	func addBadGuys() {
		var number:Int = Int(arc4random_uniform(11))
		var upDown:Int = Int(arc4random_uniform(2))
		var heightNumber:Int = Int((self.size.height / 2) - 15)
		var height:Int = Int(arc4random_uniform(UInt32(heightNumber)))
		var rotationSpeedRandom:CGFloat = CGFloat(arc4random_uniform(2)  + 1)
		//println("Hoehe: " + String(height))
		//println("oben Unten: " + String(upDown))
		//println("number: " + String(number))
		
		//number = 0
		
		println(number)
		
		if number == 0 || number == 1 || number == 2 || number == 3 || number == 4{
			if upDown == 0  {
				addBadGuy(named: "enemy1", speed: Float(normalSpeedEnemy1) * gameSpeed, yPos: CGFloat(-(height)), rotationSpeed: rotationSpeedRandom)
			} else if upDown == 1 {
				addBadGuy(named: "enemy1", speed: Float(normalSpeedEnemy1) * gameSpeed, yPos: CGFloat(height), rotationSpeed: rotationSpeedRandom)
			}
			
			
		} else if number == 5 || number == 6 || number == 7 || number == 8 || number == 9 {
			if upDown == 0 {
				addBadGuy(named: "enemy2", speed: Float(normalSpeedEnemy2) * gameSpeed, yPos: CGFloat(-(height)), rotationSpeed: 0)
			} else if upDown == 1 {
				addBadGuy(named: "enemy2", speed: Float(normalSpeedEnemy2) * gameSpeed, yPos: CGFloat(height), rotationSpeed: 0)
			}
		} else if number == 10 {
			if upDown == 0 {
				addBadGuy(named: "enemy3", speed: Float(normalSpeedEnemy3) * gameSpeed, yPos: CGFloat(-(height)), rotationSpeed: 0)
			} else if upDown == 1 {
				addBadGuy(named: "enemy3", speed: Float(normalSpeedEnemy3) * gameSpeed, yPos: CGFloat(height), rotationSpeed: 0)
			}
		}
		
	}
	
	func addBadGuy(#named: String, speed:Float, yPos: CGFloat, rotationSpeed:CGFloat) {
		
		var badGuyNode = SKSpriteNode(imageNamed: named)
		
		badGuyNode.physicsBody = SKPhysicsBody(circleOfRadius: badGuyNode.size.width / 2)
		badGuyNode.physicsBody!.affectedByGravity = false
		badGuyNode.physicsBody!.categoryBitMask = ColliderType.BadGuy.rawValue
		badGuyNode.physicsBody!.contactTestBitMask = ColliderType.Hero.rawValue
		badGuyNode.physicsBody!.collisionBitMask = ColliderType.Hero.rawValue
		
		var badGuy = BadGuy(speed: speed, guy: badGuyNode, rotationSpeed: rotationSpeed)
		badGuys.append(badGuy)
		badGuy.guy.name = named
		resetBadGuy(badGuyNode, yPos: yPos)
		badGuy.yPos = badGuyNode.position.y
		addChild(badGuyNode)
		
	}
	
	func resetBadGuy(badGuyNode:SKSpriteNode, yPos: CGFloat) {
		
		badGuyNode.position.x = endOfScreenRight
		badGuyNode.position.y = yPos
		
	}
	
	func startGameNormal() {
		
		gameStarted = true
		reloadGame()
		
	}
	
	func startGameItems() {
		
		//Spiel mit Items starten.
		
	}
	
	func showMenu() {
		
		var scene = GameScene(size: self.size)
		let skView = self.view as SKView!
		skView.ignoresSiblingOrder = true
		scene.scaleMode = .ResizeFill
		scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
		scene.size = skView.bounds.size
		skView.presentScene(scene)
		
		highScore = NSUserDefaults.standardUserDefaults().integerForKey("highScore")
		scene.highScoreLabel.text = "Highscore: " + String(highScore)
		
	}
	
	func pauseGame() {
		
		//Spiel pausieren.
		
		if !gameOver {
			
			gamePaused = true
			gamePlay.hidden = false
			gamePlay.alpha = 1
			gamePause.hidden = true
			hero.guy.paused = true
			
		}
	}
	
	func resumeGame() {
		
		//Spiel fortsetzen.
		
		if !gameOver {
			
			gamePaused = false
			gamePlay.hidden = true
			gamePlay.alpha = 0
			gamePause.hidden = false
			hero.guy.paused = false
			
		}
	}
	
	func heroMovement() {
		
		var duration = (abs(hero.guy.position.y - touchLocation)) / 100
		
		//println(duration)
		
		let moveAction = SKAction.moveToY(touchLocation, duration: NSTimeInterval(duration))
		
		moveAction.timingMode = SKActionTimingMode.EaseOut
		hero.guy.runAction(moveAction, withKey: "movingA")
	}
	
	override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
		/* Called when a touch begins */
		
		for touch: AnyObject in touches {
			touchLocation = touch.locationInNode(self).y
			let location = touch.locationInNode(self)
			if !gamePaused {
				if gameOver {
					
					if self.nodeAtPoint(location) == self.refresh {
						if gameOver {
							
							reloadGame()
							countDownRunning = true
							//println("restart")
							
						}
					} else if self.nodeAtPoint(location) == self.menu {
						if gameOver {
							
							showMenu()
							gameStarted = false
							
						}
						
					}
					
					
				} else if !gameOver {
					
					if self.nodeAtPoint(location) == self.gamePause {
						
						pauseGame()
						
					} else {
						
						heroMovement()
						//println("hero movement")
						
					}
					
				}
				
			} else if self.nodeAtPoint(location) == self.gamePlay {
				
				resumeGame()
				
			}
		}
	}
	
	override func update(currentTime: CFTimeInterval) {
		/* Called before each frame is rendered */
		if !gamePaused {
			if !gameOver {
				
				updateBadGuysPosition()
				
			}
			
			updateHeroEmitter()
		}
	}
	
	func updateHeroEmitter(){
		
		if hero.emit && hero.emitFrameCount < hero.maxEmitFrameCount {
			
			hero.emitFrameCount++
			hero.particles.hidden = false
			
		} else {
			
			hero.emit = false
			hero.particles.hidden = true
			hero.emitFrameCount = 0
			
		}
		
	}
	
	func updateBadGuysPosition(){
		
		for badGuy in badGuys {
			
			if !badGuy.moving {
				
				badGuy.currentFrame++
				if badGuy.currentFrame > badGuy.randomFrame{
					
					badGuy.moving = true
					
				}
			} else {
				
				
				//rotate enemy
				var degreeRotation = (CDouble(self.speed) * M_PI / 180) * CDouble(badGuy.rotationSpeed)
				badGuy.guy.zRotation -= CGFloat(degreeRotation)
				if badGuy.guy.name == "enemy2" {
					
					badGuy.guy.position.y = CGFloat(Double(badGuy.guy.position.y) + sin(badGuy.angle / 2) * badGuy.range)
					badGuy.angle += hero.speed
					
				} else if badGuy.guy.name == "enemy3" {
					
					if hero.guy.position.y > badGuy.guy.position.y {
						
						badGuy.guy.position.y = CGFloat(Double(badGuy.guy.position.y) + 1 )
						
					} else if hero.guy.position.y < badGuy.guy.position.y {
						
						badGuy.guy.position.y = CGFloat(Double(badGuy.guy.position.y) - 1)
						
					}
					
				} else if badGuy.guy.name == "enemy1" {
					
					badGuy.angle = 0
					if hero.guy.position.y > badGuy.guy.position.y {
						
						badGuy.guy.position.y = CGFloat(Double(badGuy.guy.position.y) + 0.05 )
						
					} else if hero.guy.position.y < badGuy.guy.position.y {
						
						badGuy.guy.position.y = CGFloat(Double(badGuy.guy.position.y) - 0.05)
						
					}
					
					//badGuy.guy.position.y = CGFloat(Double(badGuy.guy.position.y) + hero.speed)
					
				}
				
				//badGuy.angle += hero.speed
				if badGuy.guy.position.x > endOfScreenLeft{
					
					badGuy.guy.position.x -= CGFloat(badGuy.speed)
					
				} else {
					
					if badGuy.guy.name == "enemy1" {
						badGuy.guy.speed = totalSpeedEnemy1
					} else if badGuy.guy.name == "enemy2" {
						badGuy.guy.speed = totalSpeedEnemy2
					} else if badGuy.guy.name == "enemy3" {
						badGuy.guy.speed = totalSpeedEnemy3
					}
					
					var upDown:Int = Int(arc4random_uniform(2))
					var heightNumber:Int = Int((self.size.height / 2) - 15)
					var height:Int = Int(arc4random_uniform(UInt32(heightNumber)))
					
					if upDown == 0 {
						badGuy.guy.position.y = CGFloat(-(height))
					} else if upDown == 1 {
						badGuy.guy.position.y = CGFloat(height)
					}
					if badGuy.guy.name == "enemy3" {
						
						badGuy.guy.removeFromParent()
						badGuy.moving = false
						badGuy.guy.hidden = true
						badGuy.guy.position.x = self.size.width + 200
						
					} else {
						
						badGuy.guy.position.x = endOfScreenRight
						badGuy.currentFrame = 0
						badGuy.setRandomFrame()
						badGuy.moving = false
						badGuy.range += 0.1
						
					}
					
					updateScore()
					
				}
			}
			
		}
		
	}
	
	func updateScore(){
		
		score++
		scoreLabel.text = String(score)
		
		if score % 5 == 0 {
			
			totalSpeedEnemy1 = totalSpeedEnemy1 + 0.1
			totalSpeedEnemy2 = totalSpeedEnemy2 + 0.1
			totalSpeedEnemy3 = totalSpeedEnemy3 + 0.1
			
			gameProgress++
			gameSpeed = gameSpeed + 0.1 // vielleicht eigentlich 0.2
			//println(gameProgress)
			
			
		} else if score % 3 == 0 {
			
			addBadGuys()
			
		}
	}
}

