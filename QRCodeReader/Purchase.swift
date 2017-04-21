//
//  Purchase.swift
//  QRCodeReader
//
//  Created by Steffo Weber on 18.04.17.
//  Copyright © 2017 Steffo Weber. All rights reserved.
//

import Foundation
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
    
    func write(jsonResponse: JSON) {
        if let topController = UIApplication.topViewController() as? QRScannerController {
            topController.displayLabel(msg: jsonResponse[0]["item"].description)
        }
        let url = "http://node.zimt.io:4001/emma/api/v1/" + uid
        let headers: HTTPHeaders = [:]
        
        let parameters: Parameters = [:]
        
        Alamofire.request(url, method: .get, parameters: parameters, headers: headers)
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
