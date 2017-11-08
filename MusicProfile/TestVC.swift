//
//  TestVC.swift
//  MusicProfile
//
//  Created by Tal Cohen on 07/11/2017.
//  Copyright © 2017 Tal Cohen. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer

class TestVC : UIViewController {
    
    let authManager = AuthorizationManager()
    let player = MPMusicPlayerController.applicationMusicPlayer()
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func requestCloudServicePermission(_ sender: Any) {
        AuthorizationManager.requestCloudServiceAuthorization(success: {
            print("CLOUD SERVICE AUTHORIZED")
        }) {
            print("CLOUD SERVICE FAILED")
        }
    }
    @IBAction func requestUserToken() {
        self.authManager.requestUserToken(success: { (userToken) in
            print("FINALLY!")
        }) { (error) in
            print("SOB!!")
        }
    }
    
    @IBAction func requestStorefront() {
        self.authManager.requestStorefrontCountryCode(success: { (countryCode) in
            print("requestStorefront SUCCESS - \(countryCode)")
            MusicAPI().searchSong("november rain", artist: "Guns and roses", limit: 3, success: { (songs) in
                let ids = songs.map{$0.id}
                self.player.setQueueWithStoreIDs(ids)
                self.player.play()

            }, failure: { (error) in
                print("error = \(error)")
            })

        }) { (error) in
            print("ERROR -> \(error)")
        }
    }
    
    @IBAction func checkPlaybackCapability() {
        self.authManager.checkForPlaybackCapability(success: {
            print("YOU HAVE PLAYBACK CAPABILITIES")
        }, failure: {
            print("YOU HAVE NO PLAYBACK CAPABILITIES, CHECKING FOR SUBSCRIBTION IN YOUR REGION")
            self.authManager.checkIfSubscriptionPossible(success: {
                print("YOU CAN SUBSCRIBE TO APPLE MUSIC")
            }, failure: {
                print("YOU CANNOT SUBSCRIBE TO APPLE MUSIC")
            })
        })
    }
    
    @IBAction func getAlbum() {
        MusicAPI().searchSong("24K", artist: "Bruno Mars", limit: 5, success: { (songs) in
            print("🤣")
        }) { (error) in
            print("search Song error -> \(error)")
        }
    }
}
