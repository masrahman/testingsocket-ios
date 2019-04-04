//
//  ViewController.swift
//  TestingSocket
//
//  Created by Maas Rahman on 4/4/19.
//  Copyright © 2019 Maas Rahman. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
class ViewController: UIViewController {
    @IBOutlet weak var etUsername: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func login(_ sender: UIButton) {
        if etUsername.text != "" {
            let param: Parameters = [
                "name" : etUsername.text!
            ]
            AF.request("\(BASE_URL)api/search", method: .post, parameters: param, encoding:  URLEncoding.default).responseString(completionHandler: {response in
                print(response)
                let data = response.data
                do{
                    let jsonData = try JSON(data: data!)
                    let dataResponse = DataResponse.init(json: jsonData)
                    DispatchQueue.main.async {
                        if dataResponse.data != nil {
                            //print("CEK USERNAME RESPONSE \(dataResponse.data?.name)")
                            self.toMain(model: dataResponse.data!)
                        }else{
                            self.createUser()
                        }
                    }
                }catch{
                    print(error)
                }
            })
        }
    }
    
    func createUser(){
        let param: Parameters = [
            "name" : etUsername.text!
        ]
        AF.request("\(BASE_URL)api/user", method: .post, parameters: param, encoding:  URLEncoding.default).responseString(completionHandler: {response in
            let data = response.data
            do{
                let jsonData = try JSON(data: data!)
                let dataResponse = DataResponse.init(json: jsonData)
                DispatchQueue.main.async {
                    if dataResponse.data != nil {
                        self.toMain(model: dataResponse.data!)
                    }else{
                        let alert = UIAlertController(title: "Error", message: "Gagal Insert User", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }catch{
                print(error)
            }
        })
    }
    
    func toMain(model:DataModel){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainController") as! MainController
        vc.userModel = model
        self.present(vc, animated: true, completion: nil)
    }
}

