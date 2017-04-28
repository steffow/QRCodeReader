//
//  TokenStore.swift
//  QRCodeReader
//
//  Created by Steffo Weber on 23.04.17.
//  Copyright © 2017 zimt.io. All rights reserved.
//

import Foundation

class TokenStore {
    
    private static var _tokenIdScanner: String? // iPlanetDirPro of scanner (operator)
    static var OauthAccessToken: String?
    static var OAuthRefreshToken: String?
    
    static var tokenIdScanner: String {
        set {
            TokenStore._tokenIdScanner = newValue;

        }
        get { return TokenStore._tokenIdScanner! }
    }
    
}
