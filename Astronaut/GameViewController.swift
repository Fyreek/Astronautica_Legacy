//
//  GameViewController.swift
//  Astronaut
//
//  Created by Luca Friedrich on 20/08/15.
//  Copyright (c) 2015 YaLu. All rights reserved.
//

import UIKit
import SpriteKit



class GameViewController: UIViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		
		let scene = GameScene()
		
		
		let skView = self.view as! SKView
		skView.showsFPS = false
		skView.showsNodeCount = false
		
		/* Sprite Kit applies additional optimizations to improve rendering performance */
		skView.ignoresSiblingOrder = true
		
		/* Set the scale mode to scale to fit the window */
		scene.scaleMode = .ResizeFill
		scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
		scene.size = skView.bounds.size
		
		skView.presentScene(scene)
		
	}
	
	override func shouldAutorotate() -> Bool {
		return true
	}
	
	override func supportedInterfaceOrientations() -> Int {
		if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
			return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
		} else {
			return Int(UIInterfaceOrientationMask.All.rawValue)
		}
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Release any cached data, images, etc that aren't in use.
	}
	
	override func prefersStatusBarHidden() -> Bool {
		return true
	}
}
