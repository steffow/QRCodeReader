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
    var notifyCompletion: ((Bool, JSON) -> ())?
    
    init(uid: String) {
        self.uid = uid
        self.items = []
    }
    
    init() {
        self.uid = "123"
        self.items = []
    }
    
    func add(ean: String, completion: @escaping (Bool, JSON) -> ()) {
        // global param is ugly, but now idea on how use escaping closure as param
        notifyCompletion = completion
        getData(ean: ean, writeCompletion: write, notifyCompletion: completion)
        
        
    }
    
    func writeDryRun (jsonResponse: JSON) {
        
        if (jsonResponse.null != nil) {
            // the != "null" should be replaced w proper error code
            gotCodeBeep()
            if let topController = UIApplication.topViewController() as? QRScannerController {
                topController.displayLabel(msg: jsonResponse[0]["item"].description)
            }
            print("Simulating Saving Data: " + jsonResponse[0]["item"].description)
            notifyCompletion!(true, JSON({}))
        }
    }
    
    
    private func gotCodeBeep() {
        // signals that we scanned some EAN-128 code
        AudioServicesPlayAlertSound(SystemSoundID(1003))
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
    
    func write(jsonResponse: JSON) {
        //print("Writing... " + jsonResponse.description)
        if (jsonResponse.null != nil) {
            // the != "null" should be replaced w proper error code
            notifyCompletion!(false, jsonResponse)
            print("Product Record is NULL")
            return
        }
        
        
        gotCodeBeep()
        if let topController = UIApplication.topViewController() as? QRScannerController {
            topController.displayLabel(msg: jsonResponse[0]["item"].description)
        }
        print("Saving Data")
        let url = "http://node.zimt.io:8080/scanner/api/v1/" + uid
        let purchase: [String: Any]  = [
            "item": jsonResponse[0]["item"].stringValue,
            "code": jsonResponse[0]["code"].stringValue,
            "price": jsonResponse[0]["price"].stringValue,
            "identity": uid
        ]
        

            let headers: HTTPHeaders = [
                "Authorization": "Bearer " + Identity.accessToken!,
                //"Accept": "application/json",
                "Content-Type": "application/json"
            ]
        
        Alamofire.request(url, method: .post, parameters: purchase, encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                switch response.result {
                case .success:
                    //print("Success")
                    let jsonAuthResp = response.result.value
                    //print(response.result.value.debugDescription)
                    let resp = JSON(jsonAuthResp!)
                    self.notifyCompletion!(true, resp)
                //print(resp.description)
                case .failure(let error):
                    NSLog("POST Error: \(error)")
                }
        }
        
        
        
    }
    
    private func getData(ean: String, writeCompletion: @escaping (JSON) -> (), notifyCompletion: @escaping(Bool, JSON) -> ())  {
        let url = "http://brand.zimt.io:4002/emma/api/v1/products"
        let headers: HTTPHeaders = [:]
        
        let parameters: Parameters = [
            "code": "\"" + ean + "\""
        ]
        print("Getting product name for: " + ean)
        Alamofire.request(url, method: .get, parameters: parameters, headers: headers)
            .responseJSON { response in
                switch response.result {
                case .success:
                    print("Got Product Name")
                    let jsonAuthResp = response.result.value
                    
                    let resp = JSON(jsonAuthResp!)
                    //print("Data from EAN Backend" + resp[0].description)
                    writeCompletion(resp)
                //print(resp.description)
                case .failure(let error):
                    NSLog("GET Error: \(error)")
                }
        }
        
    }
    
}
