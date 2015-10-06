//
//  GameViewController.swift
//  Astronaut
//
//  Created by Yannik Lauenstein on 20/08/15.
//  Copyright (c) 2015 YaLu. All rights reserved.
//

import UIKit
import SpriteKit
import MediaPlayer
import iAd

class GameViewController: UIViewController, ADBannerViewDelegate, EasyGameCenterDelegate {
    
    var UIiAd: ADBannerView = ADBannerView()
    var gotScore:Bool = false
    var gcScore:Int = -1
    
	override func viewDidLoad() {
		super.viewDidLoad()
        
        UIiAd.translatesAutoresizingMaskIntoConstraints = false
        self.view!.addSubview(UIiAd)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "hideBannerAd", name: "hideadsID", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showBannerAd", name: "showadsID", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showFsAd", name: "showFSAd", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "hideFullScreenAd", name: "hideFSAd", object: nil)
        
        UIiAd.delegate = self
        
        self.UIiAd.hidden = true
        self.UIiAd.alpha = 0
        
		// Init Easy Game Center
		EasyGameCenter.sharedInstance(self)
		
		let scene = GameScene()
        
		let skView = self.originalContentView as! SKView
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
    
    func easyGameCenterAuthentified() {
        loadHighScore()
    }
    
    func loadHighScore() {
        EasyGameCenter.getHighScore(leaderboardIdentifier: "astronautgame_leaderboard") {
            (tupleHighScore) -> Void in
            if self.gotScore == false {
                if let tupleIsOk = tupleHighScore {
                self.gcScore = tupleIsOk.score
                NSUserDefaults.standardUserDefaults().setInteger(self.gcScore, forKey: "highScore")
                NSUserDefaults.standardUserDefaults().synchronize()
                self.gotScore = true
                }
            }
        }
    }
    
    func addAdConstraints() {
        let viewsDictionary = ["bannerView":UIiAd]
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[bannerView]|", options: [], metrics: nil, views: viewsDictionary))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[bannerView]|", options: [], metrics: nil, views: viewsDictionary))
    
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
        addAdConstraints()
    }
    
    override func viewWillDisappear(animated: Bool) {
        UIiAd.delegate = nil
        UIiAd.removeFromSuperview()
    }
    
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        //var BV = UIiAd.bounds.height
        self.view.addSubview(UIiAd)
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
    
    func showFsAd() {
        self.interstitialPresentationPolicy = ADInterstitialPresentationPolicy.Manual
        self.requestInterstitialAdPresentation()
    }
    
}
