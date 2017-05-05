//
//  Identity.swift
//  QRCodeReader
//
//  Created by Steffo Weber on 21.04.17.
//  Copyright © 2017 zimt.io. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class Identity {
    
    //static let username = "scanner"
    static var username: String?
    static let password = "password"
    //static let OAuthClientId = "scannerOA2Client"
    static let OAuthClientId = "oidc"
    static let OAuthClientSecret = "password"
    static let openAMBaseURL =  "https://identity.zimt.io:443/openam"
    static let openAMauthNURL = "https://identity.zimt.io:443/openam/json/authenticate"
    static let openAMOauth2AccesstokenURL = openAMBaseURL + "/oauth2/access_token"
    static let openAMPushAuthURL = openAMBaseURL + "/json/authenticate?authIndexType=service&authIndexValue=pushAuth"
    
    static var tokenId: String?
    static var accessToken: String?
    
    private static var timer: Timer?
    
    static func setUsername(name: String) {
        username = name
    }
    static func getTokenID() {
        let headers: HTTPHeaders = [
            "X-OpenAM-Username": username!,
            "X-OpenAM-Password": password,
            "Content-Type": "application/json",
            "Accept-API-Version": "resource=2.0, protocol=1.0"
        ]
        
        Alamofire.request(openAMauthNURL, method: .post, headers: headers).responseJSON { response in
            switch response.result {
            case .success:
                let jsonAuthResp = response.result.value
                let resp = JSON(jsonAuthResp!)
                tokenId = resp["tokenId"].stringValue
                TokenStore.tokenIdScanner = tokenId!
            case .failure(let error):
                NSLog("GET Error: \(error)")
            }
        }
    }
    
    
    // ------------------------------
    //
    // Some stuff for PushAuth
    //
    // ------------------------------
    
    static func sendPollRequest(response: JSON, refreshOAuthAccessTkn: Bool) {
        let params = response.dictionaryObject
        
        let headers: HTTPHeaders = [
            "X-OpenAM-Username": username!,
            "Content-Type": "application/json",
            "Accept-API-Version": "resource=2.0, protocol=1.0"
        ]
        
        Alamofire.request(openAMPushAuthURL, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success:
                let jsonAuthResp = response.result.value
                let resp = JSON(jsonAuthResp!)
                if let _ = resp["tokenId"].string {
                    tokenId = resp["tokenId"].stringValue
                    TokenStore.tokenIdScanner = tokenId!
                    self.timer?.invalidate()
                    if refreshOAuthAccessTkn {
                        self.getOAuthToken()
                    }
                } else {
                    //self.pushPoll(response: resp, duration: 4)
                    print("Next Poll round: " + (self.timer?.timeInterval.debugDescription)!)
                }
            case .failure(let error):
                NSLog("GET Error: \(error)")
            }
        }
    }
    
    static func pushPoll(response: JSON, duration: Int) {
        print("Dispatching")
        self.timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { timer in
            Identity.sendPollRequest(response: response, refreshOAuthAccessTkn: true)
        }
    }
    
    static func pushLogin(username: String) {
        let headers: HTTPHeaders = [
            "X-OpenAM-Username": username,
            "Content-Type": "application/json",
            "Accept-API-Version": "resource=2.0, protocol=1.0"
        ]
        
        Alamofire.request(openAMPushAuthURL, method: .post, headers: headers).responseJSON { response in
            switch response.result {
            case .success:
                let jsonAuthResp = response.result.value
                let resp = JSON(jsonAuthResp!)
                self.pushPoll(response: resp, duration: 3)
            case .failure(let error):
                NSLog("GET Error: \(error)")
            }
        }

    }
    
    // ------------------------------
    //
    // OAuth2 Section
    //
    // ------------------------------
    
    static func getOAuthToken(){
            var headers: HTTPHeaders = [:]
            
            let parameters: Parameters = [
                "scope": "uid",
                "grant_type": "password",
                "response_type": "token",
                "username": Identity.username,
                "password": Identity.password,
                ]
            
            if let authorizationHeader = Request.authorizationHeader(user: Identity.OAuthClientId, password: Identity.OAuthClientSecret) {
                headers[authorizationHeader.key] = authorizationHeader.value
                print("Headers: " + headers.description)
            }
            
            Alamofire.request(Identity.openAMOauth2AccesstokenURL, method: .post, parameters: parameters, headers: headers)
                .responseJSON { response in
                    switch response.result {
                    case .success:
                        let jsonAuthResp = response.result.value
                        let resp = JSON(jsonAuthResp!)
                        let token = resp["access_token"].stringValue
                        Identity.accessToken = token
                        print("AccTkn: " + token)
                    case .failure(let error):
                        NSLog("GET Error: \(error)")
                    }
            }
            
        
    }
    
    // ------------------------------
    //
    // Let's check if there is an active user 
    // with that QR code URL
    //
    // ------------------------------

    func checkUserQR(scannedQR: String, completion: @escaping (Bool, JSON) -> ()) {
        let url = scannedQR
        let headers: HTTPHeaders = [:]
        let iPlanetDirectoryPro = [
            HTTPCookiePropertyKey.name: "iPlanetDirectoryPro",
            HTTPCookiePropertyKey.value: Identity.tokenId,
            HTTPCookiePropertyKey.domain: ".zimt.io",
            HTTPCookiePropertyKey.path: "/"
        ]
        let iPlanetDirectoryProCookie = HTTPCookie.init(properties: iPlanetDirectoryPro)
        Alamofire.SessionManager.default.session.configuration.httpCookieStorage?.setCookie(iPlanetDirectoryProCookie!)
        
        let parameters: Parameters = [:]
        
        Alamofire.request(url, method: .get, parameters: parameters, headers: headers)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                switch response.result {
                case .success:
                    let jsonAuthResp = response.result.value
                    let resp = JSON(jsonAuthResp!)
                    //print("Validating User " + resp.stringValue)
                    completion(true, resp)
                case .failure(let error):
                    NSLog("GET Error: \(error)")
                    completion(false, JSON(response.result.value))
                }
        }

    }
}
