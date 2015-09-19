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

class GameViewController: UIViewController, ADBannerViewDelegate, EasyGameCenterDelegate {
    
    var UIiAd: ADBannerView = ADBannerView()
    
	override func viewDidLoad() {
		super.viewDidLoad()
        
        UIiAd.translatesAutoresizingMaskIntoConstraints = false
        self.view!.addSubview(UIiAd)
        let viewsDictionary = ["bannerView":UIiAd]
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[bannerView]|", options: [], metrics: nil, views: viewsDictionary))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[bannerView]|", options: [], metrics: nil, views: viewsDictionary))
        
        self.UIiAd.hidden = true
        self.UIiAd.alpha = 0
        
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
        
	}
    
	override func shouldAutorotate() -> Bool {
		return true
	}
	
	override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
		if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
			return UIInterfaceOrientationMask.AllButUpsideDown
		} else {
			return UIInterfaceOrientationMask.All
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
        UIiAd.delegate = self
        self.view.addSubview(UIiAd)
    }
    
    override func viewWillDisappear(animated: Bool) {
        UIiAd.delegate = nil
        UIiAd.removeFromSuperview()
    }
    
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        //var BV = UIiAd.bounds.height
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(1) // Time it takes the animation to complete
        UIiAd.alpha = 1 // Fade in the animation
        UIView.commitAnimations()
    }
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        UIiAd.alpha = 0
    }
    
    func showBannerAd() {
        UIiAd.hidden = false
        
        UIView.animateWithDuration(0.25, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
        
            self.UIiAd.alpha = 1.0
            
        }, completion: nil)
    }
    
    func hideBannerAd() {
        
        UIView.animateWithDuration(0.25, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {

            self.UIiAd.alpha = 0.0
        
            }, completion: { finished in
        
          self.UIiAd.hidden = true
        
        })
    }
    
}
