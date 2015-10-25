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
    
	override func viewDidLoad() {
		super.viewDidLoad()
        
        updateSoundState()
        
        loadAds()
        
        interScene.explosionSound = SKAction.playSoundFileNamed("explosion.caf", waitForCompletion: true)
        interScene.satelliteSound = SKAction.playSoundFileNamed("satellite.caf", waitForCompletion: true)
        interScene.oxygenSound = SKAction.playSoundFileNamed("oxygen.caf", waitForCompletion: true)
        
        playBackgroundMusic("music.aifc")
        
        self.UIiAd.hidden = true
        self.UIiAd.alpha = 0
        
        UIiAd.translatesAutoresizingMaskIntoConstraints = false
        self.view!.addSubview(UIiAd)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "hideBannerAd", name: "hideadsID", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showBannerAd", name: "showadsID", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showFsAd", name: "showFSAd", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "removeAds", name: "removeAds", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "extMusicOn", name: "MusicOn", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "extMusicOff", name: "MusicOff", object: nil)
        
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
        if interScene.musicState == true {
            extMusicOn()
        } else {
            extMusicOff()
        }
        interScene.soundState = NSUserDefaults.standardUserDefaults().boolForKey("soundBool")
        interScene.musicState = NSUserDefaults.standardUserDefaults().boolForKey("musicBool")
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
        addAdConstraints()
        UIiAd.hidden = false
        UIiAd.alpha = 1.0
        
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
    
    func removeAds() {
        InAppPurchase.sharedInstance.buyRemoveAds()
    }
    
    func loadAds() {
        InAppPurchase.sharedInstance.loadAds()
    }
    
}
