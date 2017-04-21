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
    static let openAMauthNURL = "https://identity.zimt.io:443/openam/json/authenticate"
    
    static var tokenId: String?
    

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
            case .failure(let error):
                NSLog("GET Error: \(error)")
            }
        }
    }
    
    func getOAuthToken() {
        // try to get OAuth2 token with tokenId
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
