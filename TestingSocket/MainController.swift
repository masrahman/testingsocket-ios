//
//  MainController.swift
//  TestingSocket
//
//  Created by Maas Rahman on 4/4/19.
//  Copyright © 2019 Maas Rahman. All rights reserved.
//

import UIKit
import SocketIO
import Alamofire
import SwiftyJSON
import UserNotifications
class MainController: UIViewController, UNUserNotificationCenterDelegate {
    @IBOutlet weak var lblMain: UILabel!
    @IBOutlet weak var lblResult: UILabel!
    let manager = SocketManager(socketURL: URL(string: BASE_URL)!, config: [.log(true), .compress])
    
    var userModel : DataModel? = nil
    var textResult = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("Notifications permission granted.")
            }
            else {
                print("Notifications permission denied because: \(error!.localizedDescription).")
            }
        }
        
        let socket = manager.defaultSocket
        socket.on(clientEvent: .connect) {data, ack in
            self.updateSocketId(id: socket.sid)
        }
        
        socket.on("maasrahman") {data, ack in
            guard let cur = data[0] as? [String: String] else { return }
            self.sendNotif(message: cur["message"]!)
            if self.textResult == "" {
                self.textResult = "Message : \(cur["message"]!)"
            }else{
                self.textResult = "\(self.textResult)<br/>Message : \(cur["message"]!)"
            }
            self.lblResult.attributedText = self.textResult.htmlToAttributedString
        }
        socket.connect()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.alert, .badge, .sound])
    }
    
    private func updateSocketId(id:String){
        let params : Parameters = [
            "session" : id
        ]
        let userId = userModel?.id
        AF.request("\(BASE_URL)api/user/\(userId!)", method: .post, parameters: params, encoding:  URLEncoding.default).responseString(completionHandler: {response in
            let data = response.data
            do{
                let jsonData = try JSON(data: data!)
                let dataResponse = DataResponse.init(json: jsonData)
                DispatchQueue.main.async {
                    if dataResponse.data != nil {
                        self.lblMain.text = "Update Session Berhasil"
                        UIView.animate(withDuration: 3.0, animations: {
                            self.lblMain.alpha = 0.0
                        })
                    }else{
                        self.lblMain.text = "Gagal Update Session"
                    }
                }
            }catch{
                print(error)
            }
        })
    }
    
    private func sendNotif(message: String){
        print("")
        let content = UNMutableNotificationContent()
        
        //adding title, subtitle, body and badge
        content.title = "Testing Socket IO"
        content.subtitle = ""
        content.body = message
        content.badge = 1
        
        //getting the notification trigger
        //it will be called after 5 seconds
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        //getting the notification request
        let request = UNNotificationRequest(identifier: "SimplifiedIOSNotification", content: content, trigger: trigger)
        
        //adding the notification to notification center
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}


extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}
