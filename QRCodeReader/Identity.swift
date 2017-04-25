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
    
    static let username = "scanner"
    static let password = "password"
    static let OAuthClientId = "scannerOA2Client"
    static let OAuthClientSecret = "password"
    static let openAMBaseURL =  "https://identity.zimt.io:443/openam"
    static let openAMauthNURL = "https://identity.zimt.io:443/openam/json/authenticate"
    static let openAMOauth2AccesstokenURL = openAMBaseURL + "/oauth2/access_token"
    
    static var tokenId: String?
    static var accessToken: String?
    

    static func getTokenID() {
        let headers: HTTPHeaders = [
            "X-OpenAM-Username": username,
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
    
    static func getOAuthToken(){
            var headers: HTTPHeaders = [:]
            
            let parameters: Parameters = [
                "scope": "uid mail givenName",
                "grant_type": "password",
                "response_type": "token",
                "username": Identity.username,
                "password": Identity.password,
                ]
            
            if let authorizationHeader = Request.authorizationHeader(user: Identity.OAuthClientId, password: Identity.OAuthClientSecret) {
                headers[authorizationHeader.key] = authorizationHeader.value
            }
            
            Alamofire.request(Identity.openAMOauth2AccesstokenURL, method: .post, parameters: parameters)
                .responseJSON { response in
                    switch response.result {
                    case .success:
                        let jsonAuthResp = response.result.value
                        let resp = JSON(jsonAuthResp!)
                        let token = resp["access_token"].stringValue
                        //print("In Code Sender:" + resp["access_token"].stringValue);
                        Identity.accessToken = token
                    case .failure(let error):
                        NSLog("GET Error: \(error)")
                    }
            }
            
        
    }

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
                    completion(true, resp)
                case .failure(let error):
                    NSLog("GET Error: \(error)")
                    completion(false, JSON(response.result.value))
                }
        }

    }
}
