//
//  AuthorizationManager.swift
//  MusicProfile
//
//  Created by Tal Cohen on 25/10/2017.
//  Copyright © 2017 Tal Cohen. All rights reserved.
//

import Foundation
import StoreKit
import MediaPlayer

class AuthorizationManager {

    let cloudServiceController = SKCloudServiceController()
    var userToken: String?
    var storefrontCountryCode: String?
    
    static let developerToken = "eyJhbGciOiJFUzI1NiIsImFsZyI6IkVTMjU2Iiwia2lkIjoiUkI1UkU4OTM5SiJ9.eyJpc3MiOiI5UDYzRFlHSDc1IiwiaWF0IjoxNTA4ODkwMDA2LCJleHAiOjE1MjQ0NDIwMDZ9.pB7O0ET5AI9pR8pHphliGiiPHUL9M0jBNM-p9bUqjlyGMWclrVnNwfyf8JBd7TkyhGtjMzdt-oRuy4MNfMu4xg"
    
    static func requestMediaLibraryAuthorization(success: (()->())?, failure: (()->())?) {
        let status = MPMediaLibrary.authorizationStatus()
        switch status {
        case .authorized:
            success?()
        case .notDetermined:
            MPMediaLibrary.requestAuthorization({ (newStatus) in
                AuthorizationManager.requestMediaLibraryAuthorization(success: success, failure: failure)
            })
        case .denied, .restricted:
            failure?()
        }

    }
    
    func requestUserToken() {
        self.cloudServiceController.requestUserToken(forDeveloperToken: AuthorizationManager.developerToken) { [weak self] (userToken, error) in
            guard error == nil,
                let userToken = userToken else { return }
            self?.userToken = userToken
        }
    }
    
    func requestStorefrontCountryCode() {
        let completionHandler: (String?, Error?) -> Void = { [weak self] (countryCode, error) in
            guard error == nil else {
                print("An error occurred when requesting storefront country code: \(error!.localizedDescription)")
                return
            }
            
            guard let countryCode = countryCode else {
                print("Unexpected value from SKCloudServiceController for storefront country code.")
                return
            }
            
            self?.storefrontCountryCode = countryCode
        }
        
        if SKCloudServiceController.authorizationStatus() == .authorized {
            if #available(iOS 11.0, *) {
                cloudServiceController.requestStorefrontCountryCode(completionHandler: completionHandler)
            } else {
//                appleMusicManager.performAppleMusicGetUserStorefront(userToken: userToken, completion: completionHandler)
            }
        } else {
            determineRegionWithDeviceLocale(completion: completionHandler)
        }
    }
    
    func determineRegionWithDeviceLocale(completion: @escaping (String?, Error?) -> Void) {
        let currentRegionCode = Locale.current.regionCode?.lowercased() ?? "us"
        
//        appleMusicManager.performAppleMusicStorefrontsLookup(regionCode: currentRegionCode, completion: completion)

    
}

class MusicAPI {
    
    private let host = "http://api.music.apple.com/v1/"
    
    
    
}


