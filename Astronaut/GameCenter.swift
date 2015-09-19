//
//  GameCenter.swift
//
//  Created by Yannick Stephan DaRk-_-D0G on 19/12/2014.
//
//  The MIT License (MIT)
//  Copyright (c) 2015 Red Wolf Studio & Yannick Stephan
//  Version 3.1
//
//  Updated by Luca Friedrich

import Foundation
import GameKit
import SystemConfiguration

/**
*    Protocol Easy Game Center
*/
@objc protocol EasyGameCenterDelegate:NSObjectProtocol {
	/**
	Authentified, Delegate Easy Game Center
	*/
	optional func easyGameCenterAuthentified()
	/**
	Not Authentified, Delegate Easy Game Center
	*/
	optional func easyGameCenterNotAuthentified()
	/**
	Achievementes in cache, Delegate Easy Game Center
	*/
	optional func easyGameCenterInCache()
	
	optional func easyGameCenterMatchStarted()
	optional func easyGameCenterMatchRecept(match: GKMatch, didReceiveData: NSData, fromPlayer: String)
	optional func easyGameCenterMatchEnded()
	optional func easyGameCenterMatchCancel()
}
/**
*    Extension of UIViewController, UIVC respect protocol
*/
extension UIViewController : EasyGameCenterDelegate {}
/**
*   Easy Game Center Swift
*/
class EasyGameCenter: NSObject, GKGameCenterControllerDelegate, GKMatchmakerViewControllerDelegate, GKMatchDelegate, GKLocalPlayerListener {
	
	/// Achievements GKAchievement Cache
	private var achievementsCache:[String:GKAchievement] = [String:GKAchievement]()
	
	/// Achievements GKAchievementDescription Cache
	private var achievementsDescriptionCache = [String:GKAchievementDescription]()
	
	/// Save for report late when network working
	private var achievementsCacheShowAfter = [String:String]()
	
	/// When is load
	private var loginIsLoading: Bool = false
	
	/// When is caching
	private var inCacheIsLoading: Bool = false
	
	/// Checkup net and login to GameCenter when have Network
	private var timerNetAndPlayer:NSTimer?
	
	/// Delegate UIViewController repect protocol EasyGameCenterDelegate
	private var delegateGetSetVC:EasyGameCenterDelegate?
	class var delegate: EasyGameCenterDelegate? {
		get {
		if let delegateVCIsOk = EasyGameCenter.sharedInstance()?.delegateGetSetVC {
		return delegateVCIsOk
		}
		return nil
		}
		set {
			EasyGameCenter.debug("\n[Easy Game Center] Delegate UIViewController is \(_stdlib_getDemangledTypeName(newValue!))\n")
			/* If EasyGameCenter is start instance (for not instance Here) */
			if newValue != nil {
				if let instance = EasyGameCenter.sharedInstance() {
					let delegateVC = EasyGameCenter.delegate as UIViewController
					let newDelegateVC = newValue as UIViewController
					if newDelegateVC != delegateVC {
						instance.delegateGetSetVC = newValue
					}
				}
			}
		}
	}
	/// Debug mode for see message
	private var debugModeGetSet:Bool = false
	class var debugMode:Bool {
		get {
		return EasyGameCenter.sharedInstance()!.debugModeGetSet
		}
		set {
			EasyGameCenter.sharedInstance()!.debugModeGetSet = newValue
		}
	}
	/*####################################################################################################*/
	/*                                    Singleton    Instance                                           */
	/*####################################################################################################*/
	/**
	Static EasyGameCenter
	
	*/
	struct Static {
		/// Async EGC
		static var onceToken: dispatch_once_t = 0
		/// instance of EGC
		static var instance: EasyGameCenter? = nil
	}
	/**
	Start Singleton GameCenter Instance
	
	*/
	class func sharedInstance(delegate:EasyGameCenterDelegate)-> EasyGameCenter {
		if Static.instance == nil {
			dispatch_once(&Static.onceToken) {
				Static.instance = EasyGameCenter()
				Static.instance!.delegateGetSetVC = delegate
				Static.instance!.loginPlayerToGameCenter()
			}
		}
		return Static.instance!
	}
	/**
	ShareInstance Private
	
	- returns: EasyGameCenter or Nil
	
	*/
	class private func sharedInstance() -> EasyGameCenter? {
		return EasyGameCenter.Static.instance
	}
	/*####################################################################################################*/
	/*                                            private Start                                           */
	/*####################################################################################################*/
	override init() {
		super.init()
	}
	/**
	Load achievements in cache
	(Is call when you init EasyGameCenter, but if is fail example for cut connection, you can recall)
	And when you get Achievement or all Achievement, it shall automatically cached
	
	*/
	private func cachingAchievements() {
		if !self.inCacheIsLoading {
			self.inCacheIsLoading = true
			let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
			dispatch_async(dispatch_get_global_queue(priority, 0)) {
				if  EasyGameCenter.isConnectedToNetwork() &&
					EasyGameCenter.isPlayerIdentifiedToGameCenter() {
						
						/* For the local player from Game Center */
						GKAchievement.loadAchievementsWithCompletionHandler({
							(var allAchievements:[GKAchievement]?, error:NSError?) -> Void in
							if error != nil {
								self.checkupNetAndPlayer()
								EasyGameCenter.debug("\n[Easy Game Center] Couldn't load achievements, error: \(error)\n")
							}
							/* Load Achievement with value pourcent */
							for anAchievement in allAchievements!  {
								if let oneAchievement = anAchievement as GKAchievement {
									self.achievementsCache[oneAchievement.identifier!] = oneAchievement
								}
							}
							
							/* Get Description cache */
							GKAchievementDescription.loadAchievementDescriptionsWithCompletionHandler {
								(var achievementsDescription:[GKAchievement]?, error:NSError?) -> Void in
								
								if error != nil {
									self.checkupNetAndPlayer()
									EasyGameCenter.debug("\n[Easy Game Center] Couldn't load achievementInformation, error: \(error)\n")
								}
								
								if let achievementsIsArrayGKAchievementDescription = achievementsDescription as? [GKAchievementDescription] {
									for gkAchievementDes in achievementsIsArrayGKAchievementDescription {
										
										/* Not reset Achievements with value pourcent */
										if self.achievementsCache[gkAchievementDes.identifier] == nil {
											
											/* get by GKAchievement for fixe bug boucle */
											if let gkAchievement = GKAchievement(identifier: gkAchievementDes.identifier) {
												self.achievementsCache[gkAchievement.identifier] = gkAchievement
											}
										}
										self.achievementsDescriptionCache[gkAchievementDes.identifier] = gkAchievementDes
									}
									if  self.achievementsCache.count > 0 &&
										self.achievementsDescriptionCache.count > 0 &&
										self.achievementsCache.count == self.achievementsDescriptionCache.count {
											EasyGameCenter.delegate!.easyGameCenterInCache?()
									} else {
										self.checkupNetAndPlayer()
									}
								} else {
									self.checkupNetAndPlayer()
									
								}
								self.inCacheIsLoading = false
							}
						})
				} else {
					self.inCacheIsLoading = false
					self.checkupNetAndPlayer()
				}
			}
		}
	}
	/**
	Login player to GameCenter With Handler Authentification
	This function is recall When player connect to Game Center
	
	- parameter completion: (Bool) if player login to Game Center
	
	*/
	private func loginPlayerToGameCenter()  {
		if !loginIsLoading {
			self.loginIsLoading = true
			
			let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
			dispatch_async(dispatch_get_global_queue(priority, 0)) {
				let delegate = EasyGameCenter.delegate
				let instanceEGC = EasyGameCenter.sharedInstance()
				
				if (delegate == nil || instanceEGC == nil) {
					EasyGameCenter.debug("\n[Easy Game Center] Error delegate UIViewController not set\n")
					
				} else {
					if !EasyGameCenter.isConnectedToNetwork() {
						instanceEGC!.checkupNetAndPlayer()
						delegate!.easyGameCenterNotAuthentified?()
						
					} else {
						if EasyGameCenter.isPlayerIdentifiedToGameCenter() {
							
							dispatch_async(dispatch_get_main_queue()) {
								instanceEGC!.cachingAchievements()
							}
							delegate!.easyGameCenterAuthentified?()
							
						} else {
							GKLocalPlayer.localPlayer().authenticateHandler = {
								(gameCenterVC:UIViewController?, error:NSError?) -> Void in
								/* If got error / Or player not set value for login */
								if error != nil {
									instanceEGC!.checkupNetAndPlayer()
									delegate!.easyGameCenterNotAuthentified?()
									
									/* Login to game center need Open page */
								} else {
									if gameCenterVC != nil {
										if let delegateController = delegate as? UIViewController {
											dispatch_async(dispatch_get_main_queue()) {
												delegateController.presentViewController(gameCenterVC!, animated: true, completion: nil)
											}
										} else {
											instanceEGC!.checkupNetAndPlayer()
											delegate!.easyGameCenterNotAuthentified?()
											EasyGameCenter.debug("\n[Easy Game Center] Delegate not set\n")
										}
									} else if EasyGameCenter.isPlayerIdentifiedToGameCenter() {
										dispatch_async(dispatch_get_main_queue()) {
											instanceEGC!.cachingAchievements()
										}
										delegate!.easyGameCenterAuthentified?()
										
										
									} else  {
										instanceEGC!.checkupNetAndPlayer()
										delegate!.easyGameCenterNotAuthentified?()
										
									}
								}
							}
						}
					}
				}
				self.loginIsLoading = false
			}
		}
	}
	/*####################################################################################################*/
	/*                              Private Timer checkup                                                 */
	/*####################################################################################################*/
	/**
	Function checkup when he have net work login Game Center
	*/
	func checkupNetAndPlayer() {
		dispatch_async(dispatch_get_main_queue()) {
			if self.timerNetAndPlayer == nil {
				self.timerNetAndPlayer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("checkupNetAndPlayer"), userInfo: nil, repeats: true)
			}
			
			if EasyGameCenter.isConnectedToNetwork() {
				self.timerNetAndPlayer!.invalidate()
				self.timerNetAndPlayer = nil
				
				let instanceEGC = EasyGameCenter.sharedInstance()
				if instanceEGC == nil {
					EasyGameCenter.debug("\n[Easy Game Center] Instance nil\n")
				} else {
					instanceEGC!.loginPlayerToGameCenter()
				}
			}
		}
	}
	/*####################################################################################################*/
	/*                                      Public Func Show                                              */
	/*####################################################################################################*/
	/**
	Show Game Center Player Achievements
	
	- parameter completion: Viod just if open Game Center Achievements
	*/
	class func showGameCenterAchievements(completion: ((isShow:Bool) -> Void)? = nil) {
		let delegateUIVC = EasyGameCenter.delegate as? UIViewController
		let instance = Static.instance
		if (delegate == nil || instance == nil) {
			EasyGameCenter.debug("\n[Easy Game Center] Delegate UIViewController not set")
			if completion != nil { completion!(isShow:false) }
		} else {
			if EasyGameCenter.isConnectedToNetwork() && EasyGameCenter.isPlayerIdentifiedToGameCenter() {
				
				let gc = GKGameCenterViewController()
				gc.gameCenterDelegate = Static.instance!
				gc.viewState = GKGameCenterViewControllerState.Achievements
				
				delegateUIVC!.presentViewController(gc, animated: true, completion: {
					() -> Void in
					
					if completion != nil { completion!(isShow:true) }
				})
				
			} else {
				EasyGameCenter.debug("\n[Easy Game Center] Player not identified or not network\n")
				if completion != nil { completion!(isShow:false) }
			}
		}
	}
	/**
	Show Game Center Leaderboard
	
	- parameter leaderboardIdentifier: Leaderboard Identifier
	- parameter completion:            Viod just if open Game Center Leaderboard
	*/
	class func showGameCenterLeaderboard(leaderboardIdentifier leaderboardIdentifier :String, completion: ((isShow:Bool) -> Void)? = nil) {
		let delegateUIVC = EasyGameCenter.delegate as? UIViewController
		let instance = Static.instance
		if (delegate == nil || instance == nil) {
			EasyGameCenter.debug("\n[Easy Game Center] Delegate UIViewController not set\n")
		} else {
			if leaderboardIdentifier != "" {
				if EasyGameCenter.isConnectedToNetwork() && EasyGameCenter.isPlayerIdentifiedToGameCenter() {
					
					let gc = GKGameCenterViewController()
					gc.gameCenterDelegate = instance!
					gc.leaderboardIdentifier = leaderboardIdentifier
					gc.viewState = GKGameCenterViewControllerState.Leaderboards
					
					delegateUIVC!.presentViewController(gc, animated: true, completion: {
						() -> Void in
						
						if completion != nil { completion!(isShow:true) }
					})
				} else {
					EasyGameCenter.debug("\n[Easy Game Center] Player not identified or not network\n")
					if completion != nil { completion!(isShow:false) }
				}
			}
		}
	}
	/**
	Show Game Center Challenges
	
	- parameter completion: Viod just if open Game Center Challenges
	
	*/
	class func showGameCenterChallenges(completion: ((isShow:Bool) -> Void)? = nil) {
		let delegateUIVC = EasyGameCenter.delegate as? UIViewController
		let instance = Static.instance
		if (delegate == nil || instance == nil) {
			EasyGameCenter.debug("\n[Easy Game Center] Delegate UIViewController not set\n")
		} else {
			if EasyGameCenter.isConnectedToNetwork() && EasyGameCenter.isPlayerIdentifiedToGameCenter() {
				
				let gc = GKGameCenterViewController()
				gc.gameCenterDelegate =  instance!
				gc.viewState = GKGameCenterViewControllerState.Challenges
				
				delegateUIVC!.presentViewController(gc, animated: true, completion: {
					() -> Void in
					
					if completion != nil { completion!(isShow:true) }
				})
			} else {
				EasyGameCenter.debug("\n[Easy Game Center] Player not identified or not network\n")
				if completion != nil { completion!(isShow:false) }
			}
		}
	}
	/**
	Show banner game center
	
	- parameter title:       title
	- parameter description: description
	- parameter completion:  When show message
	
	*/
	class func showCustomBanner(title title:String, description:String,completion: (() -> Void)? = nil) {
		if EasyGameCenter.isPlayerIdentifiedToGameCenter() {
			dispatch_async(dispatch_get_main_queue()) {
				GKNotificationBanner.showBannerWithTitle(title, message: description, completionHandler: {
					() -> Void in
					
					if completion != nil { completion!() }
				})
			}
		} else {
			EasyGameCenter.debug("\n[Easy Game Center] Player not identified\n")
		}
	}
	/**
	Show page Authentication Game Center
	
	- parameter completion: Viod just if open Game Center Authentication
	
	*/
	class func showGameCenterAuthentication(completion: ((result:Bool) -> Void)? = nil) {
		if completion != nil {
			completion!(result: UIApplication.sharedApplication().openURL(NSURL(string: "gamecenter:")!))
		}
	}
	/*####################################################################################################*/
	/*                                      Public Func Ohter                                             */
	/*####################################################################################################*/
	/**
	If player is Identified to Game Center
	
	- returns: Bool is identified
	
	*/
	class func isPlayerIdentifiedToGameCenter() -> Bool { return GKLocalPlayer.localPlayer().authenticated }
	/**
	Get local player (GKLocalPlayer)
	
	- returns: Bool True is identified
	
	*/
	class func getLocalPlayer() -> GKLocalPlayer { return GKLocalPlayer.localPlayer() }
	/**
	Get local player Information (playerID,alias,profilPhoto)
	
	:completion: Tuple of type (playerID:String,alias:String,profilPhoto:UIImage?)
	
	*/
	class func getlocalPlayerInformation(completion completionTuple: (playerInformationTuple:(playerID:String,alias:String,profilPhoto:UIImage?)?) -> ()) {
		
		let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
		dispatch_async(dispatch_get_global_queue(priority, 0)) {
			if EasyGameCenter.isConnectedToNetwork() && EasyGameCenter.isPlayerIdentifiedToGameCenter() {
				
				EasyGameCenter.getLocalPlayer().loadPhotoForSize(GKPhotoSizeNormal, withCompletionHandler: {
					(image, error) -> Void in
					
					var playerInformationTuple:(playerID:String,alias:String,profilPhoto:UIImage?)
					playerInformationTuple.profilPhoto = nil
					
					playerInformationTuple.playerID = EasyGameCenter.getLocalPlayer().playerID!
					playerInformationTuple.alias = EasyGameCenter.getLocalPlayer().alias!
					if error == nil { playerInformationTuple.profilPhoto = image }
					completionTuple(playerInformationTuple: playerInformationTuple)
				})
			} else {
				EasyGameCenter.debug("\n[Easy Game Center] Player not identified or not network\n")
			}
		}
	}
	/*####################################################################################################*/
	/*                                      Public Func LeaderBoard                                       */
	/*####################################################################################################*/
	
	/**
	Get Leaderboards
	
	- parameter completion: return [GKLeaderboard] or nil
	
	*/
	class func getGKLeaderboard(completion completion: ((resultArrayGKLeaderboard:Set<GKLeaderboard>?) -> Void)) {
		let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
		dispatch_async(dispatch_get_global_queue(priority, 0)) {
			let instanceEGC = EasyGameCenter.sharedInstance()
			if (instanceEGC == nil) {
				EasyGameCenter.debug("\n[Easy Game Center] Instance nil\n")
			} else {
				if EasyGameCenter.isPlayerIdentifiedToGameCenter() {
					
					GKLeaderboard.loadLeaderboardsWithCompletionHandler {
						(var leaderboards:[AnyObject]!, error:NSError!) ->
						Void in
						
						if error != nil { print("\n[Easy Game Center] Couldn't loadLeaderboards, error: \(error)\n") }
						
						if let leaderboardsIsArrayGKLeaderboard = leaderboards as? [GKLeaderboard] {
							completion(resultArrayGKLeaderboard: Set(leaderboardsIsArrayGKLeaderboard))
							
						} else {
							completion(resultArrayGKLeaderboard: nil)
						}
					}
				} else {
					EasyGameCenter.debug("\n[Easy Game Center] Player not identified or not network\n")
				}
			}
		}
	}
	/**
	Reports a  score to Game Center
	
	- parameter The: score Int
	- parameter Leaderboard: identifier
	- parameter completion: (bool) when the score is report to game center or Fail
	
	*/
	class func reportScoreLeaderboard(leaderboardIdentifier leaderboardIdentifier:String, score: Int) {
		let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
		dispatch_async(dispatch_get_global_queue(priority, 0)) {
			if EasyGameCenter.isPlayerIdentifiedToGameCenter() {
				
				let gkScore = GKScore(leaderboardIdentifier: leaderboardIdentifier)
				gkScore.value = Int64(score)
				gkScore.shouldSetDefaultLeaderboard = true
				
				GKScore.reportScores([gkScore], withCompletionHandler: ( {
					(error: NSError!) -> Void in
					if ((error) != nil) { /* Game Center Auto Save */ }
				}))
			} else {
				EasyGameCenter.debug("\n[Easy Game Center] Player not identified\n")
			}
		}
	}
	/**
	Get High Score for leaderboard identifier
	
	- parameter leaderboardIdentifier: leaderboard ID
	- parameter completion:            Tuple (playerName: String, score: Int, rank: Int)
	
	*/
	class func getHighScore(leaderboardIdentifier leaderboardIdentifier:String, completion:((playerName:String, score:Int,rank:Int)? -> Void)) {
		EasyGameCenter.getGKScoreLeaderboard(leaderboardIdentifier: leaderboardIdentifier, completion: {
			(resultGKScore) -> Void in
			if resultGKScore != nil {
				
				let rankVal = resultGKScore!.rank
				let nameVal  = EasyGameCenter.getLocalPlayer().alias
				let scoreVal  = Int(resultGKScore!.value)
				completion((playerName: nameVal!, score: scoreVal, rank: rankVal))
				
			} else {
				completion(nil)
			}
		})
	}
	/**
	Get GKScoreOfLeaderboard
	
	- parameter completion: GKScore or nil
	
	*/
	class func  getGKScoreLeaderboard(leaderboardIdentifier leaderboardIdentifier:String, completion:((resultGKScore:GKScore?) -> Void)) {
		let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
		dispatch_async(dispatch_get_global_queue(priority, 0)) {
			if EasyGameCenter.isPlayerIdentifiedToGameCenter() {
				
				let leaderBoardRequest = GKLeaderboard()
				leaderBoardRequest.identifier = leaderboardIdentifier
				
				leaderBoardRequest.loadScoresWithCompletionHandler {
					(resultGKScore, error) ->Void in
					
					if error != nil || resultGKScore == nil {
						completion(resultGKScore: nil)
						
					} else  {
						completion(resultGKScore: leaderBoardRequest.localPlayerScore)
					}
				}
			} else {
				EasyGameCenter.debug("\n[Easy Game Center] Player not identified\n")
				completion(resultGKScore: nil)
			}
		}
	}
	/*####################################################################################################*/
	/*                                      Public Func Achievements                                      */
	/*####################################################################################################*/
	/**
	Get Tuple ( GKAchievement , GKAchievementDescription) for identifier Achievement
	
	- parameter achievementIdentifier: Identifier Achievement
	
	- returns: (gkAchievement:GKAchievement,gkAchievementDescription:GKAchievementDescription)?
	
	*/
	class func getTupleGKAchievementAndDescription(achievementIdentifier achievementIdentifier:String,completion completionTuple: ((tupleGKAchievementAndDescription:(gkAchievement:GKAchievement,gkAchievementDescription:GKAchievementDescription)?) -> Void)
		) {
			let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
			dispatch_async(dispatch_get_global_queue(priority, 0)) {
				let instanceEGC = EasyGameCenter.sharedInstance()
				if instanceEGC == nil {
					completionTuple(tupleGKAchievementAndDescription: nil)
					EasyGameCenter.debug("\n[Easy Game Center] Instance nil\n")
				} else {
					if EasyGameCenter.isPlayerIdentifiedToGameCenter()  {
						let achievementGKScore = instanceEGC!.achievementsCache[achievementIdentifier]
						let achievementGKDes =  instanceEGC!.achievementsDescriptionCache[achievementIdentifier]
						
						if achievementGKScore != nil && achievementGKDes != nil {
							completionTuple(tupleGKAchievementAndDescription: (achievementGKScore!,achievementGKDes!))
						} else {
							if instanceEGC!.achievementsCache.count > 0 {
								EasyGameCenter.debug("\n[EasyGameCenter] Achievements ID not real\n")
							} else {
								EasyGameCenter.debug("\n[EasyGameCenter] Haven't load cache\n")
							}
							completionTuple(tupleGKAchievementAndDescription: nil)
						}
					} else {
						EasyGameCenter.debug("\n[EasyGameCenter] Player not identified\n")
						completionTuple(tupleGKAchievementAndDescription: nil)
					}
				}
			}
	}
	/**
	Get Achievement
	
	- parameter identifierAchievement: Identifier achievement
	
	- returns: GKAchievement Or nil if not exist
	
	*/
	class func getAchievementForIndentifier(identifierAchievement identifierAchievement : NSString) -> GKAchievement? {
		if identifierAchievement != "" {
			let instanceEGC = EasyGameCenter.sharedInstance()
			if instanceEGC == nil {
				EasyGameCenter.debug("\n[Easy Game Center] Instance nil\n")
			} else {
				if EasyGameCenter.isPlayerIdentifiedToGameCenter()  {
					
					if let achievementFind = instanceEGC!.achievementsCache[identifierAchievement as String] {
						return achievementFind
					} else {
						if instanceEGC!.achievementsCache.count == 0 {
							EasyGameCenter.debug("\n[Easy Game Center] Not have cache\n")
						} else {
							EasyGameCenter.debug("\n[Easy Game Center] Achievement ID \(identifierAchievement) is not real \n")
						}
					}
				} else {
					EasyGameCenter.debug("\n[Easy Game Center] Player not identified\n")
				}
			}
		}
		return nil
	}
	/**
	Add progress to an achievement
	
	- parameter progress:               Progress achievement Double (ex: 10% = 10.00)
	- parameter achievementIdentifier:  Achievement Identifier
	- parameter showBannnerIfCompleted: if you want show banner when now or not when is completed
	- parameter completionIsSend:       Completion if is send to Game Center
	
	*/
	class func reportAchievement( progress progress : Double, achievementIdentifier : String, showBannnerIfCompleted : Bool = true ,addToExisting: Bool = false) {
		if achievementIdentifier != "" {
			let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
			dispatch_async(dispatch_get_global_queue(priority, 0)) {
				if !EasyGameCenter.isAchievementCompleted(achievementIdentifier: achievementIdentifier) {
					let instanceEGC = EasyGameCenter.sharedInstance()
					if instanceEGC == nil {
						EasyGameCenter.debug("\n[Easy Game Center] Instance nil\n")
					} else {
						if let achievement = EasyGameCenter.getAchievementForIndentifier(identifierAchievement: achievementIdentifier) {
							
							let currentValue = achievement.percentComplete
							let newProgress: Double = !addToExisting ? progress : progress + currentValue
							
							achievement.percentComplete = newProgress
							
							/* show banner only if achievement is fully granted (progress is 100%) */
							if achievement.completed && showBannnerIfCompleted {
								EasyGameCenter.debug("[Easy Game Center] Achievement \(achievementIdentifier) completed")
								
								if EasyGameCenter.isConnectedToNetwork() {
									achievement.showsCompletionBanner = true
								} else {
									//oneAchievement.showsCompletionBanner = true << Bug For not show two banner
									// Force show Banner when player not have network
									EasyGameCenter.getTupleGKAchievementAndDescription(achievementIdentifier: achievementIdentifier, completion: {
										(tupleGKAchievementAndDescription) -> Void in
										
										if let tupleIsOK = tupleGKAchievementAndDescription {
											let title = tupleIsOK.gkAchievementDescription.title
											let description = tupleIsOK.gkAchievementDescription.achievedDescription
											
											EasyGameCenter.showCustomBanner(title: title, description: description)
										}
									})
								}
							}
							if  achievement.completed && !showBannnerIfCompleted {
								instanceEGC!.achievementsCacheShowAfter[achievementIdentifier] = achievementIdentifier
							}
							instanceEGC!.reportAchievementToGameCenter(achievement: achievement)
						}
					}
				} else {
					EasyGameCenter.debug("[Easy Game Center] Achievement is already completed")
				}
			}
		}
	}
	/**
	Get GKAchievementDescription
	
	- parameter completion: return array [GKAchievementDescription] or nil
	
	*/
	class func getGKAllAchievementDescription(completion completion: ((arrayGKAD:Set<GKAchievementDescription>?) -> Void)){
		let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
		dispatch_async(dispatch_get_global_queue(priority, 0)) {
			let instanceEGC = EasyGameCenter.sharedInstance()
			if instanceEGC == nil {
				EasyGameCenter.debug("\n[Easy Game Center] Instance nil\n")
				completion(arrayGKAD: nil)
			} else {
				if EasyGameCenter.isPlayerIdentifiedToGameCenter() {
					if let gameCenterInstance = EasyGameCenter.sharedInstance() {
						if gameCenterInstance.achievementsDescriptionCache.count > 0 {
							var tempsEnvoi = Set<GKAchievementDescription>()
							for achievementDes in gameCenterInstance.achievementsDescriptionCache {
								tempsEnvoi.insert(achievementDes.1)
							}
							completion(arrayGKAD: tempsEnvoi)
						} else {
							EasyGameCenter.debug("\n[Easy Game Center] Not have cache\n")
						}
					}
				} else {
					EasyGameCenter.debug("\n[Easy Game Center] Player not identified or not network\n")
					completion(arrayGKAD: nil)
				}
			}
		}
	}
	/**
	If achievement is Completed
	
	- parameter Achievement: Identifier
	:return: (Bool) if finished
	
	*/
	class func isAchievementCompleted(achievementIdentifier achievementIdentifier: String) -> Bool{
		if let achievement = EasyGameCenter.getAchievementForIndentifier(identifierAchievement: achievementIdentifier) {
			if achievement.completed || achievement.percentComplete == 100.00 {
				return true
			}
		}
		return false
	}
	/**
	Get Achievements Completes during the game and banner was not showing
	
	- returns: [String : GKAchievement] or nil
	
	*/
	class func getAchievementCompleteAndBannerNotShowing() -> [GKAchievement]? {
		let instanceEGC = EasyGameCenter.sharedInstance()
		if instanceEGC == nil {
			EasyGameCenter.debug("\n[Easy Game Center] Instance nil\n")
		} else {
			let achievements : [String:String] = instanceEGC!.achievementsCacheShowAfter
			var achievementsTemps = [GKAchievement]()
			
			if achievements.count > 0 {
				
				for achievement in achievements  {
					if let achievementExtract = EasyGameCenter.getAchievementForIndentifier(identifierAchievement: achievement.1) {
						if achievementExtract.completed && achievementExtract.showsCompletionBanner == false {
							achievementsTemps.append(achievementExtract)
						}
					}
				}
				return achievementsTemps
			}
		}
		return nil
	}
	/**
	Show all save achievement Complete if you have ( showBannerAchievementWhenComplete = false )
	
	- parameter completion: if is Show Achievement banner
	(Bug Game Center if you show achievement by showsCompletionBanner = true when you report and again you show showsCompletionBanner = false is not show)
	
	*/
	class func showAllBannerAchievementCompleteForBannerNotShowing(completion: ((achievementShow:GKAchievement?) -> Void)? = nil) {
		let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
		dispatch_async(dispatch_get_global_queue(priority, 0)) {
			let instance = EasyGameCenter.sharedInstance()
			if instance == nil {
				EasyGameCenter.debug("\n[Easy Game Center] Instance nil\n")
				completion!(achievementShow: nil)
			} else {
				if !EasyGameCenter.isPlayerIdentifiedToGameCenter() {
					EasyGameCenter.debug("\n[Easy Game Center] Player not identified\n")
					if completion != nil { completion!(achievementShow: nil) }
				} else {
					if let achievementNotShow: [GKAchievement] = EasyGameCenter.getAchievementCompleteAndBannerNotShowing() {
						for achievement in achievementNotShow  {
							
							EasyGameCenter.getTupleGKAchievementAndDescription(achievementIdentifier: achievement.identifier!, completion: {
								(tupleGKAchievementAndDescription) -> Void in
								
								if let tupleOK = tupleGKAchievementAndDescription {
									//oneAchievement.showsCompletionBanner = true
									let title = tupleOK.gkAchievementDescription.title
									let description = tupleOK.gkAchievementDescription.achievedDescription
									
									EasyGameCenter.showCustomBanner(title: title, description: description, completion: { () -> Void in
										if completion != nil { completion!(achievementShow: achievement) }
									})
								} else {
									if completion != nil { completion!(achievementShow: nil) }
								}
							})
						}
						instance!.achievementsCacheShowAfter.removeAll(keepCapacity: false)
					} else {
						if completion != nil { completion!(achievementShow: nil) }
					}
				}
			}
		}
	}
	/**
	Get progress to an achievement
	
	- parameter Achievement: Identifier
	
	- returns: Double or nil (if not find)
	
	*/
	class func getProgressForAchievement(achievementIdentifier achievementIdentifier:String) -> Double? {
		let instanceEGC = EasyGameCenter.sharedInstance()
		if instanceEGC == nil {
			EasyGameCenter.debug("\n[Easy Game Center] Instance nil\n")
		} else {
			if EasyGameCenter.isPlayerIdentifiedToGameCenter() {
				if let achievementInArrayInt = instanceEGC!.achievementsCache[achievementIdentifier]?.percentComplete {
					return achievementInArrayInt
				} else {
					EasyGameCenter.debug("\n[EasyGameCenter] Haven't cache\n")
				}
			} else {
				EasyGameCenter.debug("\n[EasyGameCenter] Player not identified\n")
			}
		}
		return nil
	}
	/**
	Remove All Achievements
	
	completion: return GKAchievement reset or Nil if game center not work
	
	*/
	class func resetAllAchievements( completion:  ((achievementReset:GKAchievement?) -> Void)? = nil)  {
		let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
		dispatch_async(dispatch_get_global_queue(priority, 0)) {
			if EasyGameCenter.isPlayerIdentifiedToGameCenter() {
				GKAchievement.resetAchievementsWithCompletionHandler({
					(error:NSError?) -> Void in
					if error != nil {
						EasyGameCenter.debug("\n[Easy Game Center] Couldn't Reset achievement (Send data error) \n")
					} else {
						let gameCenter = EasyGameCenter.Static.instance!
						for lookupAchievement in gameCenter.achievementsCache {
							let achievementID = lookupAchievement.0
							let achievementGK = lookupAchievement.1
							achievementGK.percentComplete = 0
							achievementGK.showsCompletionBanner = false
							if completion != nil { completion!(achievementReset:achievementGK) }
							EasyGameCenter.debug("\n[Easy Game Center] Reset achievement (\(achievementID))\n")
						}
					}
				})
			} else {
				EasyGameCenter.debug("\n[Easy Game Center] Player not identified\n")
				if completion != nil { completion!(achievementReset: nil) }
			}
		}
	}
	/*####################################################################################################*/
	/*                                      Private Func Achievements                                     */
	/*####################################################################################################*/
	/**
	Report achievement classic
	
	- parameter achievement: GKAchievement
	*/
	private func reportAchievementToGameCenter(achievement achievement:GKAchievement) {
		/* try to report the progress to the Game Center */
		GKAchievement.reportAchievements([achievement], withCompletionHandler:  {
			(error:NSError?) -> Void in
			if error != nil { /* Game Center Save Automatique */ }
		})
	}
	/*####################################################################################################*/
	/*                             Internal Delagate Game Center                                          */
	/*####################################################################################################*/
	/**
	Dismiss Game Center when player open
	- parameter GKGameCenterViewController:
	
	Override of GKGameCenterControllerDelegate
	
	*/
	internal func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController) {
		gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
	}
	
	/*####################################################################################################*/
	/*                                          Mutliplayer                                               */
	/*####################################################################################################*/
	
	/// Actual Match with other players
	var match: GKMatch?
	var playersInMatch = Set<GKPlayer>()
	var invitedPlayer: GKPlayer?
	var invite: GKInvite?
	
	/*####################################################################################################*/
	/*                                          Public Func                                               */
	/*####################################################################################################*/
	/**
	Find player By number
	
	- parameter minPlayers: Int
	- parameter maxPlayers: Max
	*/
	class func findMatchWithMinPlayers(minPlayers: Int, maxPlayers: Int) {
		let instanceEGC = EasyGameCenter.sharedInstance()
		if instanceEGC == nil {
			EasyGameCenter.debug("\n[Easy Game Center] Instance nil\n")
		} else {
			EasyGameCenter.disconnectMatch()
			if let delegateController = EasyGameCenter.delegate! as? UIViewController {
				
				let request = GKMatchRequest()
				request.minPlayers = minPlayers
				request.maxPlayers = maxPlayers
				
				let controlllerGKMatch = GKMatchmakerViewController(matchRequest: request)
				controlllerGKMatch.matchmakerDelegate = instanceEGC!
				delegateController.presentViewController(controlllerGKMatch, animated: true, completion: nil)
			}
		}
	}
	/**
	Get Player in match
	
	- returns: Set<GKPlayer>
	*/
	class func getPlayerInMatch() -> Set<GKPlayer>? {
		let instanceEGC = EasyGameCenter.sharedInstance()
		if instanceEGC == nil {
			EasyGameCenter.debug("\n[Easy Game Center] Instance nil\n")
		} else {
			if instanceEGC!.match == nil {
				EasyGameCenter.debug("\n[Easy Game Center] No Match\n")
			} else {
				if instanceEGC!.playersInMatch.count > 0 {
					return instanceEGC!.playersInMatch
				}
			}
		}
		return nil
	}
	/**
	Deconnect the Match
	*/
	class func disconnectMatch() {
		let instanceEGC = EasyGameCenter.sharedInstance()
		if instanceEGC == nil {
			EasyGameCenter.debug("\n[Easy Game Center] Instance nil\n")
		} else {
			if instanceEGC!.match != nil {
				EasyGameCenter.debug("\n[Easy Game Center] Disconnect from match \n")
				instanceEGC!.match!.disconnect()
				instanceEGC!.match = nil
				EasyGameCenter.delegate!.easyGameCenterMatchEnded?()
			}
		}
	}
	/**
	Get match
	
	- returns: GKMatch or nil if haven't match
	*/
	class func getMatch() -> GKMatch? {
		let instanceEGC = EasyGameCenter.sharedInstance()
		if instanceEGC == nil {
			EasyGameCenter.debug("\n[Easy Game Center] Instance nil\n")
		} else {
			if instanceEGC!.match == nil {
				EasyGameCenter.debug("\n[Easy Game Center] No Match\n")
			} else {
				return EasyGameCenter.sharedInstance()!.match!
			}
		}
		return nil
	}
	/**
	player in net
	*/
	private func lookupPlayers() {
		let instanceEGC = EasyGameCenter.sharedInstance()
		if instanceEGC == nil {
			EasyGameCenter.debug("\n[Easy Game Center] Instance nil\n")
		} else {
			if instanceEGC!.match == nil {
				EasyGameCenter.debug("\n[Easy Game Center] No Match\n")
			} else {
				let playerIDs = match!.players.map { ($0 ).playerID }
				
				/* Load an array of player */
				GKPlayer.loadPlayersForIdentifiers(playerIDs) {
					(players, error) -> Void in
					
					if error != nil {
						EasyGameCenter.debug("[Easy Game Center] Error retrieving player info: \(error.localizedDescription)")
						EasyGameCenter.disconnectMatch()
					} else {
						
						if let arrayPlayers = players as? [GKPlayer] {
							self.playersInMatch = Set(arrayPlayers)
						}
						GKMatchmaker.sharedMatchmaker().finishMatchmakingForMatch(self.match)
						EasyGameCenter.delegate!.easyGameCenterMatchStarted?()
					}
				}
			}
		}
	}
	
	/**
	Transmits data to all players connected to the match.
	
	- parameter data:     NSData
	- parameter modeSend: GKMatchSendDataMode
	
	:GKMatchSendDataMode Reliable: a.s.a.p. but requires fragmentation and reassembly for large messages, may stall if network congestion occurs
	:GKMatchSendDataMode Unreliable: Preferred method. Best effort and immediate, but no guarantees of delivery or order; will not stall.
	*/
	class func sendDataToAllPlayers(data: NSData!, modeSend:GKMatchSendDataMode) {
		let instanceEGC = EasyGameCenter.sharedInstance()
		if instanceEGC == nil {
			EasyGameCenter.debug("\n[Easy Game Center] Instance nil\n")
		} else {
			if instanceEGC!.match == nil {
				EasyGameCenter.debug("\n[Easy Game Center] No Match\n")
			} else {
				var error: NSError?
				let success: Bool
				do {
					try instanceEGC!.match!.sendDataToAllPlayers(data, withDataMode: modeSend)
					success = true
				} catch let error1 as NSError {
					error = error1
					success = false
				}
				if error != nil || !success {
					EasyGameCenter.debug("\n[Easy Game Center] Fail sending data all Player\n")
					EasyGameCenter.disconnectMatch()
					EasyGameCenter.delegate!.easyGameCenterMatchEnded?()
				} else {
					EasyGameCenter.debug("\n[Easy Game Center] Succes sending data all Player \n")
				}
			}
		}
	}
	/*####################################################################################################*/
	/*                                          GKMatchDelegate                                           */
	/*####################################################################################################*/
	/**
	Called when data is received from a player.
	
	- parameter theMatch: GKMatch
	- parameter data:     NSData
	- parameter playerID: String
	*/
	func match(theMatch: GKMatch, didReceiveData data: NSData, fromPlayer playerID: String) {
		if match != theMatch {
			return
		}
		EasyGameCenter.delegate!.easyGameCenterMatchRecept?(theMatch, didReceiveData: data, fromPlayer: playerID)
	}
	/**
	Called when a player connects to or disconnects from the match.
	
	Echange avec autre players
	
	- parameter theMatch: GKMatch
	- parameter playerID: String
	- parameter state:    GKPlayerConnectionState
	*/
	func match(theMatch: GKMatch, player playerID: String, didChangeState state: GKPlayerConnectionState) {
		/* recall when is desconnect match = nil */
		if match != theMatch {
			return
		}
		
		switch state {
			/* Connected */
		case .StateConnected:
			if theMatch.expectedPlayerCount == 0 {
				lookupPlayers()
			}
			
			/* Lost deconnection */
		case .StateDisconnected:
			EasyGameCenter.disconnectMatch()
		default:
			break
		}
	}
	/**
	Called when the match cannot connect to any other players.
	
	- parameter theMatch: GKMatch
	- parameter error:    NSError
	
	*/
	func match(theMatch: GKMatch, didFailWithError error: NSError?) {
		if self.match != theMatch {
			return
		}
		if error != nil {
			EasyGameCenter.debug("[Easy Game Center] Match failed with error: \(error.localizedDescription)")
			EasyGameCenter.disconnectMatch()
		}
	}
	
	/*####################################################################################################*/
	/*                            GKMatchmakerViewControllerDelegate                                      */
	/*####################################################################################################*/
	/**
	Called when a peer-to-peer match is found.
	
	- parameter viewController: GKMatchmakerViewController
	- parameter theMatch:       GKMatch
	*/
	internal func matchmakerViewController(viewController: GKMatchmakerViewController, didFindMatch theMatch: GKMatch) {
		viewController.dismissViewControllerAnimated(true, completion: nil)
		self.match = theMatch
		self.match!.delegate = self
		if match!.expectedPlayerCount == 0 {
			self.lookupPlayers()
		}
	}
	
	
	/*####################################################################################################*/
	/*                             GKLocalPlayerListener                                                  */
	/*####################################################################################################*/
	/**
	Called when another player accepts a match invite from the local player
	
	- parameter player:         GKPlayer
	- parameter inviteToAccept: GKPlayer
	*/
	internal func player(player: GKPlayer, didAcceptInvite inviteToAccept: GKInvite) {
		let gkmv = GKMatchmakerViewController(invite: inviteToAccept)
		gkmv.matchmakerDelegate = self
		
		if let delegatUI = EasyGameCenter.delegate! as? UIViewController {
			delegatUI.presentViewController(gkmv, animated: true, completion: nil)
		}
		
	}
	/**
	Initiates a match from Game Center with the requested players
	
	- parameter player:          The GKPlayer object containing the current player’s information
	- parameter playersToInvite: An array of GKPlayer
	*/
	internal func player(player: GKPlayer, didRequestMatchWithOtherPlayers playersToInvite: [GKPlayer]) {
		
	}
	
	/**
	Called when the local player starts a match with another player from Game Center
	
	- parameter player:            The GKPlayer object containing the current player’s information
	- parameter playerIDsToInvite: An array of GKPlayer
	*/
	internal func player(player: GKPlayer, didRequestMatchWithPlayers playerIDsToInvite: [String]) {
		
	}
	
	/*####################################################################################################*/
	/*                            GKMatchmakerViewController                                              */
	/*####################################################################################################*/
	/**
	Called when the user cancels the matchmaking request (required)
	
	- parameter viewController: GKMatchmakerViewController
	*/
	internal func matchmakerViewControllerWasCancelled(viewController: GKMatchmakerViewController) {
		viewController.dismissViewControllerAnimated(true, completion: nil)
		EasyGameCenter.debug("\n[Easy Game Center] Player cancels the matchmaking request \n")
		EasyGameCenter.delegate!.easyGameCenterMatchCancel?()
	}
	/**
	Called when the view controller encounters an unrecoverable error.
	
	- parameter viewController: GKMatchmakerViewController
	- parameter error:          NSError
	*/
	internal func matchmakerViewController(viewController: GKMatchmakerViewController, didFailWithError error: NSError) {
		viewController.dismissViewControllerAnimated(true, completion: nil)
		EasyGameCenter.debug("\n[Easy Game Center] Error finding match: \(error.localizedDescription)\n")
		EasyGameCenter.delegate!.easyGameCenterMatchCancel?()
	}
	/*####################################################################################################*/
	/*                                      Public Other Func                                             */
	/*####################################################################################################*/
	/**
	CheckUp Connection the new
	
	- returns: Bool Connection Validation
	
	*/
	class func isConnectedToNetwork() -> Bool {
		
		var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
		zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
		zeroAddress.sin_family = sa_family_t(AF_INET)
		
		let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
			SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0)).takeRetainedValue()
		}
		
		var flags: SCNetworkReachabilityFlags = 0
		if SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) == 0 {
			return false
		}
		
		let isReachable = (flags & UInt32(kSCNetworkFlagsReachable)) != 0
		let needsConnection = (flags & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
		
		return (isReachable && !needsConnection) ? true : false
	}
	/**
	Open Dialog for player see he wasn't authentifate to Game Center and can go to login
	
	- parameter titre:                     Title
	- parameter message:                   Message
	- parameter buttonOK:                  Title of button OK
	- parameter buttonOpenGameCenterLogin: Title of button open Game Center
	- parameter completion:                Completion if player open Game Center Authentification
	
	*/
	class func openDialogGameCenterAuthentication(title title:String, message:String,buttonOK:String,buttonOpenGameCenterLogin:String, completion: ((openGameCenterAuthentification:Bool) -> Void)?) {
		
		let delegateUIVC = EasyGameCenter.delegate as? UIViewController
		let instance = Static.instance
		if (delegate == nil || instance == nil) {
			print("\n[Easy Game Center] Delegate UIViewController not set")
		} else {
			/* iOS 8 */
			if ( objc_getClass("UIAlertController") != nil ) {
				
				var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
				
				delegateUIVC!.presentViewController(alert, animated: true, completion: nil)
				
				alert.addAction(UIAlertAction(title: buttonOK, style: .Default, handler: {
					action in
					
					if completion != nil { completion!(openGameCenterAuthentification: false) }
					
				}))
				alert.addAction(UIAlertAction(title: buttonOpenGameCenterLogin, style: .Default, handler: {
					action in
					
					EasyGameCenter.showGameCenterAuthentication({
						(resultOpenGameCenter) -> Void in
						
						if completion != nil { completion!(openGameCenterAuthentification: resultOpenGameCenter) }
					})
					
				}))
				/* iOS 7 */
			} else {
				var alert: UIAlertView = UIAlertView()
				alert.delegate = self
				alert.title = title
				alert.message = message
				alert.addButtonWithTitle(buttonOK)
				alert.addButtonWithTitle(buttonOpenGameCenterLogin)
				alert.show()
			}
		}
	}
	/**
	Class callBack UIAlertView iOS 7
	
	- parameter View:        UIAlertView
	- parameter buttonIndex: ButtonIndex
	
	*/
	class func alertView(View: UIAlertView!, clickedButtonAtIndex buttonIndex: Int){
		
		switch buttonIndex{
			
		case 1:
			EasyGameCenter.showGameCenterAuthentication({
				(resultOpenGameCenter) -> Void in
				EasyGameCenter.debug("\n[Easy Game Center] showGameCenterAuthentication() has been opened\n")
			})
			break;
		case 0:
			EasyGameCenter.debug("Dismiss")
			break;
		default:
			break;
			
		}
	}
	/*####################################################################################################*/
	/*                                      Private Other Func                                            */
	/*####################################################################################################*/
	private class func debug(object: Any) {
		if EasyGameCenter.debugMode {
			dispatch_async(dispatch_get_main_queue()) {
				Swift.print(object)
			}
		}
	}
}