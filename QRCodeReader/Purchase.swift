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
    
    var iid: String
    var items: [JSON]
    
    init(iid: String) {
        <#statements#>
    }
    
    init() {
        self.iid = "123"
    }
    
    func add(ean: String) {
        items.append(getData(ean: ean))
    }
    
    func write() {
        
        
    }
    
    private func getData(ean: String) -> JSON {
        return JSON(string: "{'item': 'Milch', 'ean': " + ean + "}")
    }
    
}
