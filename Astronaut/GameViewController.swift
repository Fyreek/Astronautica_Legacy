//
//  GameViewController.swift
//  Astronaut
//
//  Created by Yannik Lauenstein on 20/08/15.
//  Copyright (c) 2015 YaLu. All rights reserved.
//

import UIKit
import SpriteKit
import iAd

class GameViewController: UIViewController, EasyGameCenterDelegate, ADBannerViewDelegate {
	
    var SH = UIScreen.mainScreen().bounds.height
    let transition = SKTransition.fadeWithDuration(1)
    var UIiAd: ADBannerView = ADBannerView()
    
	override func viewDidLoad() {
		super.viewDidLoad()
		
        UIiAd.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view!.addSubview(UIiAd)
        let viewsDictionary = ["bannerView":UIiAd]
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[bannerView]|", options: .allZeros, metrics: nil, views: viewsDictionary))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[bannerView]|", options: .allZeros, metrics: nil, views: viewsDictionary))
        
        self.UIiAd.hidden = true
        self.UIiAd.alpha = 0
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "hideBannerAd", name: "hideadsID", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showBannerAd", name: "showadsID", object: nil)
        
		// Init Easy Game Center
		EasyGameCenter.sharedInstance(self)
		
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
		
		//self.canDisplayBannerAds = true
        
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
    
    override func viewWillAppear(animated: Bool) {
            var BV = UIiAd.bounds.height
            UIiAd.delegate = self
            //UIiAd.frame = CGRectMake(0, SH + BV, 0, 0)
            UIiAd.frame = CGRectMake(-UIScreen.mainScreen().bounds.width / 2, SH - BV, UIScreen.mainScreen().bounds.width, 0)
            self.view.addSubview(UIiAd)
    }
    
    override func viewWillDisappear(animated: Bool) {
            UIiAd.delegate = nil
            UIiAd.removeFromSuperview()
    }
    
    func bannerViewDidLoadAd(banner: ADBannerView!) {
            var BV = UIiAd.bounds.height
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(1) // Time it takes the animation to complete
            UIiAd.alpha = 1 // Fade in the animation
            UIView.commitAnimations()
    }
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(1)
            UIiAd.alpha = 0
            UIView.commitAnimations()
    }
    
    func showBannerAd() {
            UIiAd.hidden = false
            var BV = UIiAd.bounds.height
            
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(1) // Time it takes the animation to complete
            //UIiAd.frame = CGRectMake(0, SH - BV, 0, 0) // End position of the animation
            UIiAd.frame = CGRectMake(-UIScreen.mainScreen().bounds.width / 2, SH - BV, UIScreen.mainScreen().bounds.width, 0)
            UIView.commitAnimations()
    }
    
    func hideBannerAd() {
            UIiAd.hidden = true
            var BV = UIiAd.bounds.height
            
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(1) // Time it takes the animation to complete
            //UIiAd.frame = CGRectMake(0, SH + BV, 0, 0) // End position of the animation
            UIiAd.frame = CGRectMake(0, 0, 0, 0)
            UIView.commitAnimations()
    }
    
}
