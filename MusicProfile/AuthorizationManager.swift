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
import SwiftyJSON

class AuthorizationManager: NSObject, SKCloudServiceSetupViewControllerDelegate {

    fileprivate let cloudServiceController = SKCloudServiceController()
    static var userToken: String?
    static var storefrontCountryCode: String?
    
    static let developerToken = "eyJhbGciOiJFUzI1NiIsImFsZyI6IkVTMjU2Iiwia2lkIjoiUkI1UkU4OTM5SiJ9.eyJpc3MiOiI5UDYzRFlHSDc1IiwiaWF0IjoxNTA4ODkwMDA2LCJleHAiOjE1MjQ0NDIwMDZ9.pB7O0ET5AI9pR8pHphliGiiPHUL9M0jBNM-p9bUqjlyGMWclrVnNwfyf8JBd7TkyhGtjMzdt-oRuy4MNfMu4xg"
    
    func presentJoinToAppleMusicViewController(presentingViewController: UIViewController) {
        let setupViewController = SKCloudServiceSetupViewController()
        setupViewController.delegate = self
        
        let setupOptions : [SKCloudServiceSetupOptionsKey: Any] = [
            .action : SKCloudServiceSetupAction.subscribe,
            .messageIdentifier : SKCloudServiceSetupMessageIdentifier.playMusic
        ]
        
        setupViewController.load(options: setupOptions) { (succeedLoading, error) in
            if succeedLoading {
                presentingViewController.present(setupViewController, animated: true, completion: nil)
            }
        }
    }
    
    static func requestCloudServiceAuthorization(success: (()->())?, failure: (()->())?) {
        let status = SKCloudServiceController.authorizationStatus()
        switch status {
        case .authorized:
            success?()
        case .notDetermined:
            SKCloudServiceController.requestAuthorization({ (newStatus) in
                AuthorizationManager.requestCloudServiceAuthorization(success: success, failure: failure)
            })
        case .denied, .restricted:
            failure?()
        }
    }
    
    func checkForPlaybackCapability(success: @escaping (()->()), failure: @escaping (()->())) {
        self.cloudServiceController.requestCapabilities { (capabilities, error) in
            guard error == nil else {
                failure()
                return
            }
            let canPlay = capabilities.contains(.musicCatalogPlayback)
            if canPlay {
                success()
            } else {
                failure()
            }
        }
    }
    
    func checkIfSubscriptionPossible(success: @escaping (()->()), failure: @escaping (()->())) {
        self.cloudServiceController.requestCapabilities { (capabilities, error) in
            guard error == nil else {
                failure()
                return
            }
            let subscriptionPossible = capabilities.contains(.musicCatalogSubscriptionEligible)
            if subscriptionPossible {
                success()
            } else {
                failure()
            }
        }
    }
    
    func requestUserToken(success: @escaping (String)->(), failure: @escaping (Error)->()) {
        self.cloudServiceController.requestUserToken(forDeveloperToken: AuthorizationManager.developerToken) { (userToken, error) in
            guard error == nil else {
                failure(error!)
                return
            }
            guard let userToken = userToken else {
                fatalError()
            }
            AuthorizationManager.userToken = userToken
            success(userToken)
        }
    }
    
    //STOREFRONT
    
    //MARK: - iOS 11
    func requestStorefrontCountryCode(success: @escaping (String)->(), failure: @escaping (Error)->()) {
        guard SKCloudServiceController.authorizationStatus() == .authorized else {
            self.determineRegionWithDeviceLocale(success: success, failure: failure)
            return
        }
        if #available(iOS 11.0, *) {
            self.cloudServiceController.requestStorefrontCountryCode(completionHandler: { (countryCode, error) in
                guard error == nil else {
                    failure(error!)
                    return
                }
                guard countryCode != nil else {
                    fatalError()
                }
                AuthorizationManager.storefrontCountryCode = countryCode
                success(countryCode!)
            })
        } else {
            self.performAppleMusicGetUserStorefront(userToken: AuthorizationManager.userToken, success: { (countryCode) in
                AuthorizationManager.storefrontCountryCode = countryCode
                success(countryCode)
            }, failure: failure)
        }
    }
    
    //MARK: - iOS 10 and below
    func determineRegionWithDeviceLocale(success: @escaping (String)->(), failure: @escaping (Error)->()) {
        let currentRegionCode = Locale.current.regionCode?.lowercased() ?? "us"
        self.performAppleMusicStorefrontsLookup(regionCode: currentRegionCode, success: success, failure: failure)
    }
    
    func performAppleMusicStorefrontsLookup(regionCode: String, success: @escaping (String)->(), failure: @escaping (Error)->()) {
        let developerToken = AuthorizationManager.developerToken
        
        let urlSession = URLSession(configuration: .default)
        
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = MusicAPI.host
        urlComponents.path = "/v1/storefronts/\(regionCode)"
        
        var urlRequest = URLRequest(url: urlComponents.url!)
        urlRequest.httpMethod = "GET"
        
        urlRequest.addValue("Bearer \(developerToken)", forHTTPHeaderField: "Authorization")
        let task = urlSession.dataTask(with: urlRequest) { (data, response, error) in
            guard error == nil, let data = data else {
                failure(error!)
                return
            }
            let json = JSON(data: data)
            if let regionCode = json["id"].string {
                success(regionCode)
            } else {
                let error = NSError(domain: "regionCodeNotFound", code: -9000, userInfo: nil)
                failure(error)
            }
        }
        
        task.resume()
    }
    
    func performAppleMusicGetUserStorefront(userToken: String?, success: @escaping (String)->(), failure: @escaping (Error)->()) {
        guard let userToken = userToken else {
            let error = NSError(domain: "userTokenNotFound", code: -9000, userInfo: nil)
            failure(error)
            return
        }
        let developerToken = AuthorizationManager.developerToken
        
        let urlSession = URLSession(configuration: .default)
        
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = MusicAPI.host
        urlComponents.path = MusicAPI.userStorefrontPath
        
        var urlRequest = URLRequest(url: urlComponents.url!)
        urlRequest.httpMethod = "GET"
        
        urlRequest.addValue("Bearer \(developerToken)", forHTTPHeaderField: "Authorization")
        urlRequest.addValue(userToken, forHTTPHeaderField: "Music-User-Token")
        
        let task = urlSession.dataTask(with: urlRequest) { (data, response, error) in
            guard error == nil, let data = data else {
                let error = NSError(domain: "AppleMusicManagerErrorDomain", code: -9000, userInfo: [NSUnderlyingErrorKey: error!])
                failure(error)
                return
            }
            let json = JSON(data: data)
            if let regionCode = json["id"].string {
                success(regionCode)
            } else {
                let error = NSError(domain: "regionCodeNotFound", code: -9000, userInfo: nil)
                failure(error)
            }
        }
        task.resume()
    }
    
}

class MusicAPI {
    
    public static let host = "api.music.apple.com"
    
    //PATHS
    public static let userStorefrontPath = "/v1/me/storefront"
    private let recentlyPlayedPath = "/v1/me/recent/played"
    private var searchPath : String {
        get {
            return "/v1/catalog/" + AuthorizationManager.storefrontCountryCode! + "/search"
        }
    }
    
    func searchSong(_ name: String, artist: String, limit: Int = 0, success: @escaping (_ songs: [Song])->(), failure: @escaping ((Error)->())) {
        let developerToken = AuthorizationManager.developerToken

        let urlSession = URLSession(configuration: .default)
        
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = MusicAPI.host
        urlComponents.path = self.searchPath
        var queryItems : [URLQueryItem] = [
            URLQueryItem(name: "term", value: name + " - " + artist),
            URLQueryItem(name: "types", value: "songs")
        ]
        if limit > 0 {
            queryItems += [URLQueryItem(name: "limit", value: "\(limit)")]
        }
        urlComponents.queryItems = queryItems
        
        var urlRequest = URLRequest(url: urlComponents.url!)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("Bearer \(developerToken)", forHTTPHeaderField: "Authorization")

        let task = urlSession.dataTask(with: urlRequest) { (data, response, error) in
            guard error == nil, let data = data else {
                let error = NSError(domain: "AppleMusicManagerErrorDomain", code: -9000, userInfo: [NSUnderlyingErrorKey: error!])
                failure(error)
                return
            }
            let songs = JSON(data: data)["results"]["songs"]["data"]
            if songs.count == 0 {
                let error = NSError(domain: "NoResults", code: 0, userInfo: nil)
                failure(error)
                return
            }
            let results = songs.flatMap {
                Song(id: $0.1["attributes"]["playParams"]["id"].stringValue,
                     songName: $0.1["attributes"]["name"].stringValue,
                     artistName: $0.1["attributes"]["artistName"].stringValue,
                     genre: $0.1["attributes"]["genreNames"][0].stringValue,
                     url: $0.1["attributes"]["previews"][0]["url"].stringValue)
            }
            success(results)
        }
        task.resume()
    }
    
}
