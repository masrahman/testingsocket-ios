//
//  DataResponse.swift
//  Test Socket IO
//
//  Created by Maas Rahman on 4/4/19.
//  Copyright © 2019 Maas Rahman. All rights reserved.
//

import Foundation
import SwiftyJSON

class DataResponse : NSObject {
    var status:String
    var data:DataModel? = nil
    
    init(json: JSON){
        self.status = json["message"].stringValue
        let cekData = json["data"]
        if cekData.stringValue != "null" {
            self.data = DataModel.init(json: cekData)
        }
    }
}

class DataModel : NSObject {
    var id: String
    var name: String
    var sessionId: String
    var v: String
    
    init(json: JSON){
        print("CEK DATA MODEL \(json)")
        self.id = json["_id"].stringValue
        self.name = json["name"].stringValue
        self.sessionId = json["sessionId"].stringValue
        self.v = json["__v"].stringValue
    }
}

var BASE_URL = "http://localhost:3000/"
