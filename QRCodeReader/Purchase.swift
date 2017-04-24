//
//  Purchase.swift
//  QRCodeReader
//
//  Created by Steffo Weber on 18.04.17.
//  Copyright © 2017 Steffo Weber. All rights reserved.
//

import Foundation
import AudioToolbox
import Alamofire
import SwiftyJSON

class Purchase {
    
    var uid: String
    var items: [JSON]
    
    init(uid: String) {
        self.uid = uid
        self.items = []
    }
    
    init() {
        self.uid = "123"
        self.items = []
    }
    
    func add(ean: String) {
        getData(ean: ean, completion: write)
    }
    
    private func beep() {
        AudioServicesPlayAlertSound(SystemSoundID(1003))
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
    
    func write(jsonResponse: JSON) {
        if jsonResponse[0].description != "null" {
            // the != "null" should be replaced w proper error code
            beep()
            if let topController = UIApplication.topViewController() as? QRScannerController {
                topController.displayLabel(msg: jsonResponse[0]["item"].description)
            }
            print("Saving Data")
            let url = "http://node.zimt.io:4001/scanner/api/v1/" + uid
            let purchase = [
                "item": jsonResponse["item"],
                "code": jsonResponse["code"],
                "price": jsonResponse["price"],
                "identity": uid
                ] as [String : Any]
            let headers: HTTPHeaders = [:]
            let iPlanetDirectoryPro = [
                HTTPCookiePropertyKey.name: "iPlanetDirectoryPro",
                HTTPCookiePropertyKey.value: Identity.tokenId,
                HTTPCookiePropertyKey.domain: ".zimt.io",
                HTTPCookiePropertyKey.path: "/"
            ]
            let iPlanetDirectoryProCookie = HTTPCookie.init(properties: iPlanetDirectoryPro as Any as! [HTTPCookiePropertyKey : Any])
            Alamofire.SessionManager.default.session.configuration.httpCookieStorage?.setCookie(iPlanetDirectoryProCookie!)
            
            let parameters: Parameters = [:]
            
            Alamofire.request(url, method: .post, parameters: purchase, encoding: URLEncoding.httpBody)
                .responseJSON { response in
                    switch response.result {
                    case .success:
                        //print("Success")
                        let jsonAuthResp = response.result.value
                        //print(response.result.value.debugDescription)
                        let resp = JSON(jsonAuthResp!)
                        //completion(resp)
                    //print(resp.description)
                    case .failure(let error):
                        NSLog("GET Error: \(error)")
                    }
            }
            
        }

        
    }
    
    private func getData(ean: String, completion: @escaping (JSON) -> ())  {
        let url = "http://brand.zimt.io:4002/emma/api/v1/products"
        let headers: HTTPHeaders = [:]
        
        let parameters: Parameters = [
            "code": "\"" + ean + "\""
            ]
        
        Alamofire.request(url, method: .get, parameters: parameters, headers: headers)
            .responseJSON { response in
                switch response.result {
                case .success:
                    //print("Success")
                    let jsonAuthResp = response.result.value
                    //print(response.result.value.debugDescription)
                    let resp = JSON(jsonAuthResp!)
                    completion(resp)
                    //print(resp.description)
                case .failure(let error):
                    NSLog("GET Error: \(error)")
                }
        }

    }
    
}
