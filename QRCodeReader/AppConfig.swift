//
//  AppConfig.swift
//  QRCodeReader
//
//  Created by Steffo Weber on 05.05.17.
//  Copyright © 2017 zimt.io. All rights reserved.
//

import Foundation


struct AppConfig {
    
    static var bundlePath = Bundle.main.path(forResource: "EmmaCfg", ofType: "plist")!
    static let initialFileURL = URL(fileURLWithPath: Bundle.main.path(forResource: "EmmaCfg", ofType: "plist")!)
    static var documentDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
    static var writableFileURL = documentDirectoryURL.appendingPathComponent("Data.plist", isDirectory: false)
    static var emmaCfg = NSMutableDictionary(contentsOf: copyBundle())!
    
    private static var _port = ""
    private static var _host = ""
    private static var _appName = ""
    private static var _username = ""
    private static var _password = ""
    private static var _oauthClientId = ""
    private static var _userURL = ""
    private static var _didChange = false
    
    static func copyBundle() -> URL {
        if !FileManager.default.fileExists(atPath: writableFileURL.path) {
            do {
                try FileManager.default.copyItem(at: initialFileURL, to: writableFileURL)
            } catch {
                print("Copying file failed with error : \(error)")
            }
        }
        return writableFileURL
    }
    static var oauthClientId: String {
        set {
            AppConfig._oauthClientId = newValue;
            // we don't store this value somewhere. It's fixed per app
        }
        get { return _oauthClientId }
    }
    
    static var port: String {
        set {
            _port = newValue;
            AppConfig.emmaCfg.setValue(_port, forKey: "openAMPort")
            AppConfig.emmaCfg.write(to: AppConfig.writableFileURL, atomically: false)
            
        }
        get { return _port }
    }
    static var host: String {
        set {
            AppConfig._host = newValue;
            AppConfig.emmaCfg.setValue(AppConfig.host, forKey: "openAMHost")
            AppConfig.emmaCfg.write(to: AppConfig.writableFileURL, atomically: false)
            
        }
        get { return _host }
    }
    static var appName: String {
        set {
            _appName = newValue;
            AppConfig.emmaCfg.setValue(_appName, forKey: "openAMAppName")
            AppConfig.emmaCfg.write(to: AppConfig.writableFileURL, atomically: false)
            
        }
        get { return _appName }
    }
    static var username: String {
        set {
            AppConfig._username = newValue;
            AppConfig.emmaCfg.setValue(_username, forKey: "openAMUsername")
            AppConfig.emmaCfg.write(to: AppConfig.writableFileURL, atomically: false)
            
        }
        get { return _username }
    }
    static var password: String {
        set {
            AppConfig._password = newValue;
            AppConfig.emmaCfg.setValue(_password, forKey: "openAMPassword")
            AppConfig.emmaCfg.write(to: AppConfig.writableFileURL, atomically: false)
            
        }
        get { return AppConfig._password }
    }
    
    static var userURL: String {
        set {
            AppConfig._userURL = newValue;
            AppConfig.emmaCfg.setValue(_userURL, forKey: "openAMUserURL")
            AppConfig.emmaCfg.write(to: AppConfig.writableFileURL, atomically: false)
        }
        get { return AppConfig._userURL }
    }
    
    static var didChange: Bool {
        set {
            AppConfig._didChange = newValue;
        }
        get { return AppConfig._didChange }
    }
    
    static func printAll() {
        print("openAMHost: " + _host)
        print("openAMPort: " + _port)
        print("openAMUsername: " + _username)
        print("openAMUserURL: " + _userURL)
    }
    
    init() {
        if let p = AppConfig.emmaCfg.object(forKey: "openAMPort") as? String, p != "" {
            AppConfig._port = p
        } else {
            AppConfig._port = "443"
        }
        if let h = AppConfig.emmaCfg.object(forKey: "openAMHost") as? String, h != "" {
            AppConfig._host = h
        } else {
            AppConfig._host = "identity.zimt.io"
        }
        if let a = AppConfig.emmaCfg.object(forKey: "openAMAppName") as? String, a != "" {
            AppConfig._appName = a
        } else {
            AppConfig._appName = "openam"
        }
        if let u = AppConfig.emmaCfg.object(forKey: "openAMUsername") as? String, u != "" {
            AppConfig._username = u
            NSLog("Init AppConfig w host:" + u + ":")
        } else {
            AppConfig._username = "fred"
        }
        if let p = AppConfig.emmaCfg.object(forKey: "openAMPassword") as? String, p != "" {
            AppConfig._password = p
        } else {
            AppConfig._password = "password"
        }
        if let u = AppConfig.emmaCfg.object(forKey: "openAMUserURL") as? String {
            AppConfig._userURL = u
        }
        
    }
    
}
