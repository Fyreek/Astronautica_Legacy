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

class GameViewController: UIViewController, ADBannerViewDelegate, EGCDelegate {
    
    var UIiAd: ADBannerView = ADBannerView()
    var gotScore:Bool = false
    var gcScore:Int = -1
    var loadedAd:Bool = false
    
	override func viewDidLoad() {
		super.viewDidLoad()

        updateSoundState()

        loadAds()
        
        if (NSUserDefaults.standardUserDefaults().objectForKey("highScore") != nil) {
            interScene.highScore = NSUserDefaults.standardUserDefaults().integerForKey("highScore")
        }
        
        playBackgroundMusic("music.caf")
        
        interScene.explosionSound = SKAction.playSoundFileNamed("explosion.caf", waitForCompletion: true)
        interScene.oxygenSound = SKAction.playSoundFileNamed("oxygen.caf", waitForCompletion: true)
        
        self.UIiAd.hidden = true
        self.UIiAd.alpha = 0
        self.UIiAd.backgroundColor = UIColor(rgba: "#1E2124")
        UIiAd.translatesAutoresizingMaskIntoConstraints = false
        self.view!.addSubview(UIiAd)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "hideBannerAd", name: "hideadsID", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showBannerAd", name: "showadsID", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showFsAd", name: "showFSAd", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "extMusicOn", name: "MusicOn", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "extMusicOff", name: "MusicOff", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "displayAdAlert", name: "displayAdAlert", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showShareMenu", name: "ShareMenu", object: nil)
        
        UIiAd.delegate = self
		EGC.sharedInstance(self)
		
		let scene = GameScene()
		let skView = self.originalContentView as! SKView
		skView.showsFPS = false
		skView.showsNodeCount = false
        skView.showsPhysics = false
		skView.ignoresSiblingOrder = true
		scene.scaleMode = .ResizeFill
		scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
		scene.size = skView.bounds.size
        
		skView.presentScene(scene)
	}
    
    func updateSoundState() {
        let hint = AVAudioSession.sharedInstance().secondaryAudioShouldBeSilencedHint
        if hint == true {
            if let _ = NSUserDefaults.standardUserDefaults().objectForKey("soundBool") {
                interScene.soundState = NSUserDefaults.standardUserDefaults().boolForKey("soundBool")
            } else {
                interScene.soundState = true
            }
            interScene.musicState = false
        } else {
            if let _ = NSUserDefaults.standardUserDefaults().objectForKey("soundBool") {
                interScene.soundState = NSUserDefaults.standardUserDefaults().boolForKey("soundBool")
            } else {
                interScene.soundState = true
            }
            if let _ = NSUserDefaults.standardUserDefaults().objectForKey("musicBool") {
                interScene.musicState = NSUserDefaults.standardUserDefaults().boolForKey("musicBool")
            } else {
                interScene.musicState = true
            }
        }
        if interScene.musicState == true {
            extMusicOn()
        } else {
            extMusicOff()
        }
    }
    
    func EGCAuthentified(authentified:Bool) {
        if authentified {
            interScene.connectedToGC = true
            loadHighScore()
            NSNotificationCenter.defaultCenter().postNotificationName("switchLbButton", object: nil)
        }
    }
    
    func playBackgroundMusic(filename: String) {
        let url = NSBundle.mainBundle().URLForResource(
            filename, withExtension: nil)
        if (url == nil) {
            print("Could not find file: \(filename)")
            return
        }
        
        do {
            
            interScene.backgroundMusicP = try AVAudioPlayer(contentsOfURL: url!)
        } catch {
            
        }
        if interScene.backgroundMusicP == nil {
            print("Could not create audio player!")
            return
        }
        if interScene.musicState == true {
            interScene.backgroundMusicP.numberOfLoops = -1
            interScene.backgroundMusicP.prepareToPlay()
            interScene.backgroundMusicP.volume = 1
            interScene.backgroundMusicP.play()
        }
    }
    
    func loadHighScore() {
        EGC.getHighScore(leaderboardIdentifier: "astronautgame_leaderboard") {
            (tupleHighScore) -> Void in
            if self.gotScore == false {
                if let tupleIsOk = tupleHighScore {
                    self.gcScore = tupleIsOk.score
                    
                    if let _ = NSUserDefaults.standardUserDefaults().objectForKey("highScore") {
                        
                        if self.gcScore > NSUserDefaults.standardUserDefaults().integerForKey("highScore") {
                            
                            NSUserDefaults.standardUserDefaults().setInteger(self.gcScore, forKey: "highScore")
                            NSUserDefaults.standardUserDefaults().synchronize()
                            interScene.highScore = self.gcScore
                            
                        } else if self.gcScore < NSUserDefaults.standardUserDefaults().integerForKey("highScore") {
                            
                            interScene.highScore = NSUserDefaults.standardUserDefaults().integerForKey("highScore")
                            EGC.reportScoreLeaderboard(leaderboardIdentifier: "astronautgame_leaderboard", score: NSUserDefaults.standardUserDefaults().integerForKey("highScore"))
                            
                        }
                        
                    } else {
                        
                        NSUserDefaults.standardUserDefaults().setInteger(self.gcScore, forKey: "highScore")
                        NSUserDefaults.standardUserDefaults().synchronize()
                        interScene.highScore = self.gcScore

                    }
                    
                    self.gotScore = true
                }
            }
        }
    }
    
    func addAdConstraints() {
        let viewsDictionary = ["bannerView":UIiAd]
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[bannerView]|", options: [], metrics: nil, views: viewsDictionary))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[bannerView]|", options: [], metrics: nil, views: viewsDictionary))    }
    
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
	}
	
	override func prefersStatusBarHidden() -> Bool {
		return true
	}
    
    override func viewWillAppear(animated: Bool) {
        self.view!.addSubview(UIiAd)
        if interScene.smallAdLoad == true {
                if interScene.adState == true {
                showBannerAd()
                addAdConstraints()
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        UIiAd.delegate = nil
        UIiAd.removeFromSuperview()
    }
    
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        if interScene.playSceneDidLoad == false {
            if interScene.adState == true {
                loadedAd = true
                showBannerAd()
                self.view.addSubview(UIiAd)
                UIView.beginAnimations(nil, context: nil)
                UIView.setAnimationDuration(1)
                UIiAd.alpha = 1
                UIView.commitAnimations()
            }
        }
    }
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        UIiAd.alpha = 0
    }
    
    func extMusicOn() {
        let sess = AVAudioSession.sharedInstance()
        if sess.otherAudioPlaying {
            _ = try? sess.setCategory(AVAudioSessionCategorySoloAmbient)
            _ = try? sess.setActive(true, withOptions: [])
        }
    }
    
    func extMusicOff() {
        let sess = AVAudioSession.sharedInstance()
        if sess.otherAudioPlaying {
            _ = try? sess.setCategory(AVAudioSessionCategoryAmbient)
            _ = try? sess.setActive(true, withOptions: [])
        }
    }
    
    func showBannerAd() {
        if loadedAd == true {
            addAdConstraints()
            UIiAd.hidden = false
            UIiAd.alpha = 1.0
            
            UIView.animateWithDuration(0.25, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            
                self.UIiAd.alpha = 1.0
                
            }, completion: nil)
        }
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
    
    func loadAds() {
        InAppPurchase.sharedInstance.loadAds()
    }
    
    func showShareMenu() {
        let firstActivityItem = "I scored \(interScene.highScore) points in Astronautica. Check it out:\nhttp://bit.ly/1koZQ4e"
        
        let activityViewController : UIActivityViewController = UIActivityViewController(activityItems: [firstActivityItem], applicationActivities: nil)
        
        self.presentViewController(activityViewController, animated: true, completion: nil)

    }
    
    func displayAdAlert() {
        let alert = UIAlertController(title: "Remove Ads", message: "Do you want to remove the ads?", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "Purchase \(interScene.adPrice)", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) in
                InAppPurchase.sharedInstance.buyRemoveAds()
            }))
            
        alert.addAction(UIAlertAction(title: "Restore Purchase", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) in
                InAppPurchase.sharedInstance.restoreTransactions()
            }))
            
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
