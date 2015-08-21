//
//  PlayScene.swift
//  Astronaut
//
//  Created by Yannik Lauenstein on 20/08/15.
//  Copyright (c) 2015 YaLu. All rights reserved.
//

import SpriteKit

class PlayScene: SKScene, SKPhysicsContactDelegate {
	var hero:Hero!
	var touchLocation = CGFloat()
	var gameOver = true
	var gameStarted = false
	var enemys:[Enemy] = []
	var endOfScreenRight = CGFloat()
	var endOfScreenLeft = CGFloat()
	var gamePaused = false
    
    var playSceneActive = false
    
	var highScore:Int = 0
	
	var gameSpeed:Float = 1.3
	var gameProgress:Int = 0
	var totalSpeedenemyAsteroid:CGFloat = 1.0
	var totalSpeedenemySatellite:CGFloat = 1.5
	var totalSpeedenemyRocket:CGFloat = 3.0
	var normalSpeedenemyAsteroid:CGFloat = 0.5
	var normalSpeedenemySatellite:CGFloat = 1
	var normalSpeedenemyRocket:CGFloat = 2
	
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
    var timerPause = NSTimer()
	var countDown = 3
	var countDownText = SKLabelNode(text: "3")
	enum ColliderType:UInt32 {
		
		case Hero = 1
		case Enemy = 2
		
	}
	
	override func didMoveToView(view: SKView) {
		//NSUserDefaults.standardUserDefaults().setInteger(0, forKey: "highScore") Reset Highscore on start!
		
		self.physicsWorld.contactDelegate = self
		endOfScreenLeft = (self.size.width / 2) * CGFloat(-1) - (SKSpriteNode(imageNamed: "enemyAsteroid").size.width / 2)
		endOfScreenRight = (self.size.width / 2) + (SKSpriteNode(imageNamed: "enemyAsteroid").size.width / 2)
		
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
		//hero.guy.position.x = -(self.size.width/2)/3
		hero.guy.position.x = 0
		hero.guy.name = "kevin"
		
		refresh.runAction(SKAction.fadeOutWithDuration(1.0))
		menu.runAction(SKAction.fadeOutWithDuration(1.0))
		totalScore.runAction(SKAction.fadeOutWithDuration(1.0))
		score = 0
		scoreLabel.text = "0"
		gameProgress = 0
		gameSpeed = 1
		totalSpeedenemyAsteroid = normalSpeedenemyAsteroid
		totalSpeedenemySatellite = normalSpeedenemySatellite
		totalSpeedenemyRocket = normalSpeedenemyRocket
		
		for enemy in enemys {
			
			resetEnemy(enemy.guy, yPos: enemy.yPos)
			enemy.guy.hidden = true
			
		}
		
		enemys.removeAll(keepCapacity: false)
		addEnemys()
		
		for var i = 1; i < startEnemy; i++ {
			
			self.addEnemys()
			
		}
		
		timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("updateTimer"), userInfo: nil, repeats: true)
		
		
	}
	
	func updateTimer() {
		
		if countDown > 0 {
			
			if hero.guy.position.y != 0 {
				
				hero.guy.position.y = 0
				
			}
			
			countDown--
			countDownText.text = String(countDown)
			
		} else {
			
			countDown = 3
			countDownText.text = String(countDown)
			countDownText.hidden = true
			gameOver = false
			timer.invalidate()
			countDownRunning = false
			gamePause.hidden = false
			gamePause.alpha = 1
			
		}
	}
	
	func addheroPlayer(){
		
		let heroPlayer = SKSpriteNode(imageNamed: "heroPlayer")
		
		heroPlayer.physicsBody = SKPhysicsBody(circleOfRadius: heroPlayer.size.width / 2)
		
		heroPlayer.physicsBody!.affectedByGravity = false
		heroPlayer.physicsBody!.categoryBitMask = ColliderType.Hero.rawValue
		heroPlayer.physicsBody!.contactTestBitMask = ColliderType.Enemy.rawValue
		heroPlayer.physicsBody!.collisionBitMask = ColliderType.Enemy.rawValue
		
		let heroParticles = SKEmitterNode(fileNamed: "HitParticle.sks")
		heroParticles.hidden = true
		hero = Hero(guy: heroPlayer, particles: heroParticles)
		heroPlayer.addChild(heroParticles)
		addChild(heroPlayer)
		
	}
	
	func addEnemys() {
		var number:Int = Int(arc4random_uniform(11))
		var upDown:Int = Int(arc4random_uniform(2))
		var heightNumber:Int = Int((self.size.height / 2) - 15)
		var height:Int = Int(arc4random_uniform(UInt32(heightNumber)))
		var rotationSpeedRandom:CGFloat = CGFloat(arc4random_uniform(2)  + 1)
		//println("Hoehe: " + String(height))
		//println("oben Unten: " + String(upDown))
		//println("number: " + String(number))
		
		//number = 2
		
		println(number)
		
		if number == 0 || number == 1 || number == 2 || number == 3 || number == 4{
			if upDown == 0  {
				addEnemy(named: "enemyAsteroid", speed: Float(normalSpeedenemyAsteroid) * gameSpeed, yPos: CGFloat(-(height)), rotationSpeed: rotationSpeedRandom)
			} else if upDown == 1 {
				addEnemy(named: "enemyAsteroid", speed: Float(normalSpeedenemyAsteroid) * gameSpeed, yPos: CGFloat(height), rotationSpeed: rotationSpeedRandom)
			}
			
			
		} else if number == 5 || number == 6 || number == 7 || number == 8 || number == 9 {
			if upDown == 0 {
				addEnemy(named: "enemySatellite", speed: Float(normalSpeedenemySatellite) * gameSpeed, yPos: CGFloat(-(height)), rotationSpeed: 0)
			} else if upDown == 1 {
				addEnemy(named: "enemySatellite", speed: Float(normalSpeedenemySatellite) * gameSpeed, yPos: CGFloat(height), rotationSpeed: 0)
			}
		} else if number == 10 {
			if upDown == 0 {
				addEnemy(named: "enemyRocket", speed: Float(normalSpeedenemyRocket) * gameSpeed, yPos: CGFloat(-(height)), rotationSpeed: 0)
			} else if upDown == 1 {
				addEnemy(named: "enemyRocket", speed: Float(normalSpeedenemyRocket) * gameSpeed, yPos: CGFloat(height), rotationSpeed: 0)
			}
		}
		
	}
	
	func addEnemy(#named: String, speed:Float, yPos: CGFloat, rotationSpeed:CGFloat) {
		
		var enemyNode = SKSpriteNode(imageNamed: named)
		
		enemyNode.physicsBody = SKPhysicsBody(circleOfRadius: enemyNode.size.width / 2)
		enemyNode.physicsBody!.affectedByGravity = false
		enemyNode.physicsBody!.categoryBitMask = ColliderType.Enemy.rawValue
		enemyNode.physicsBody!.contactTestBitMask = ColliderType.Hero.rawValue
		enemyNode.physicsBody!.collisionBitMask = ColliderType.Hero.rawValue
		
		var enemy = Enemy(speed: speed, guy: enemyNode, rotationSpeed: rotationSpeed)
		enemys.append(enemy)
		enemy.guy.name = named
		resetEnemy(enemyNode, yPos: yPos)
		enemy.yPos = enemyNode.position.y
		addChild(enemyNode)
		
	}
	
	func resetEnemy(enemyNode:SKSpriteNode, yPos: CGFloat) {
		
		enemyNode.position.x = endOfScreenRight
		enemyNode.position.y = yPos
		
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
        self.playSceneActive = false
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
            
            countDownText.hidden = false
            gamePlay.hidden = true
            countDownRunning = true
            timerPause = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("updateTimerPause"), userInfo: nil, repeats: true)
            
            //gamePaused = false
			//gamePlay.hidden = true
			//gamePlay.alpha = 0
			//gamePause.hidden = false
			//hero.guy.paused = false
			
		}
	}
	
    func updateTimerPause() {
    
        if countDown > 0 {
            
            countDown--
            countDownText.text = String(countDown)
            
        } else {
            
            countDown = 3
            countDownText.text = String(countDown)
            countDownText.hidden = true
            timerPause.invalidate()
            countDownRunning = false
            gamePaused = false
            gamePlay.hidden = true
            gamePlay.alpha = 0
            gamePause.hidden = false
            hero.guy.paused = false
            
        }
        
    }
    
	func heroMovement() {
		
		var duration = (abs(hero.guy.position.y - touchLocation)) / hero.speed
		
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
                if !countDownRunning {
                    resumeGame()
                }
			}
		}
	}
	
	override func update(currentTime: CFTimeInterval) {
		/* Called before each frame is rendered */
		if !gamePaused {
			if !gameOver {
				
				updateEnemysPosition()
				
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
	
	func updateEnemysPosition(){
		
		for enemy in enemys {
			
			if !enemy.moving {
				
				enemy.currentFrame++
				if enemy.currentFrame > enemy.randomFrame{
					
					enemy.moving = true
					
				}
			} else {
				
				if enemy.guy.name == "enemySatellite" {
					
					enemy.guy.position.y = CGFloat(Double(enemy.guy.position.y) + sin(enemy.angle / 2) * enemy.range)
					enemy.angle += hero.pace
					
				} else if enemy.guy.name == "enemyRocket" {
                    if enemy.guy.position.x >= hero.guy.position.y {
                        if hero.guy.position.y > enemy.guy.position.y {
						
                            enemy.guy.position.y = CGFloat(Double(enemy.guy.position.y) + 1 )
                            enemy.rotationSpeed = 0
                            
                        } else if hero.guy.position.y < enemy.guy.position.y {
						
                            enemy.guy.position.y = CGFloat(Double(enemy.guy.position.y) - 1)
                            enemy.rotationSpeed = 1
                            
                        }
                    } else {
                        if enemy.rotationSpeed == 0 {
                        
                            enemy.guy.position.y = CGFloat(Double(enemy.guy.position.y) + 1 )
                            
                        } else if enemy.rotationSpeed == 1 {
                        
                            enemy.guy.position.y = CGFloat(Double(enemy.guy.position.y) - 1 )
                            
                        }
                    
                    }
				} else if enemy.guy.name == "enemyAsteroid" {
					
                    var degreeRotation = (CDouble(self.speed) * M_PI / 180) * CDouble(enemy.rotationSpeed)
                    enemy.guy.zRotation -= CGFloat(degreeRotation)
                    
					enemy.angle = 0
					if hero.guy.position.y > enemy.guy.position.y {
						
						enemy.guy.position.y = CGFloat(Double(enemy.guy.position.y) + 0.05 )
						
					} else if hero.guy.position.y < enemy.guy.position.y {
						
						enemy.guy.position.y = CGFloat(Double(enemy.guy.position.y) - 0.05)
						
					}
					
					//enemy.guy.position.y = CGFloat(Double(enemy.guy.position.y) + hero.speed)
					
				}
				
				//enemy.angle += hero.speed
				if enemy.guy.position.x > endOfScreenLeft{
					
					enemy.guy.position.x -= CGFloat(enemy.speed)
					
				} else {
					
					if enemy.guy.name == "enemyAsteroid" {
						enemy.guy.speed = totalSpeedenemyAsteroid
					} else if enemy.guy.name == "enemySatellite" {
						enemy.guy.speed = totalSpeedenemySatellite
					} else if enemy.guy.name == "enemyRocket" {
						enemy.guy.speed = totalSpeedenemyRocket
					}
					
					var upDown:Int = Int(arc4random_uniform(2))
					var heightNumber:Int = Int((self.size.height / 2) - 15)
					var height:Int = Int(arc4random_uniform(UInt32(heightNumber)))
					
					if upDown == 0 {
						enemy.guy.position.y = CGFloat(-(height))
					} else if upDown == 1 {
						enemy.guy.position.y = CGFloat(height)
					}
					if enemy.guy.name == "enemyRocket" {
						
						enemy.guy.removeFromParent()
						enemy.moving = false
						enemy.guy.hidden = true
						enemy.guy.position.x = self.size.width + 200
						
					} else {
						
						enemy.guy.position.x = endOfScreenRight
						enemy.currentFrame = 0
						enemy.setRandomFrame()
						enemy.moving = false
						enemy.range += 0.1
						
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
			
			totalSpeedenemyAsteroid = totalSpeedenemyAsteroid + 0.1
			totalSpeedenemySatellite = totalSpeedenemySatellite + 0.1
			totalSpeedenemyRocket = totalSpeedenemyRocket + 0.1
			
			gameProgress++
			gameSpeed = gameSpeed + 0.1 // vielleicht eigentlich 0.2
			//println(gameProgress)
			
			
		} else if score % 3 == 0 {
			
			addEnemys()
			
		}
	}
}

