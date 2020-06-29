//
//  WebServices.swift
//  GoGetter
//
//  Created by OSX on 05/10/17.
//  Copyright © 2017 Batth. All rights reserved.
//

import Foundation
import UIKit

public let baseUrl = "http://slindirapp.com/web-services/index.php"
public let mediaUrl = "http://slindirapp.com/web-services/media/"

//public let baseUrl = "http://98.176.82.131/web-services/index.php"
//public let mediaUrl = "http://98.176.82.131/web-services/media/"
//public let baseUrl = "http://18.236.52.178/web-services/index.php"
//public let mediaUrl = "http://18.236.52.178/web-services/media/"

enum Model: String{
    
    case user = "user"
    
    case quiz = "quiz"
    
    case match = "match"
    
    case friend = "friend"
    
    case chat = "chat"
    
    case report = "report"
    
    case dislike = "dislike"
    
    case clientlog = "clientlog"
    
    case conversation = "conversation"
}

enum ServiceType: String {
    case post = "POST"
    case get = "GET"
}

enum Services: String {

    // Client Log api
    case log                                = "log"

    //Login and Save User Details API's
    case login                              = "login"
    
    case updateProfile                      = "update-profile"
    
    case updateViewCount                    = "updateViewCount"
    
    case queryViewCount                     = "queryViewCount"
    
    case userDetails                        = "get-user-details"
    
    case saveUserInterests                  = "save-user-activities"
    
//Quiz API's
    case fetchQuizQuestions                 = "fetch-quiz-questions"
    case saveUserQuiz                       = "save-user-quiz"
    case fetchUserQuiz                      = "fetch-user-quiz"
    
//Match API	
    case fetchMatchedProfile                = "fetch-matched-profiles"
    
//Set User Location API
    case setLocation                        = "set-user-location"
    
//Friends API's
    case sendFriendRequest                  = "send-friend-request"
    
    case dislikeUser                          = "dislike-user"
    
/// This enum is used for accept friends Request with action "accept" moreover same enum is used for decline or Unfriend Request. Use action as "decline"
    case acceptFriendRequest                = "accept-decline-friend-request"
    
    case fetchFriendList                    = "fetch-friends-list"
    
    case uploadFile                         = "upload-file"
    
    case blockUser                          = "block-user"
    
    case reportUser                         = "report-user"
    
    case logout                             = "logout"
    
    case deleteAccount                      = "delete-account"
    
    case chatMessage                        = "new-message-received"

    case deviceToken                        = "save-device-token"
    
    case moveUserToPermanentList            = "move-users-to-permanent-list"
    
    case requestNewActivities               = "request-new-activities"

    case endUserDetail                      = "get-end-user-details"
    
    case uploadVideoAndThumbnail            = "upload-profile-video"
    
    case checkPhone                         = "checkPhone"
    
    case sendPhoneCode                      = "sendPhoneCode"
    
    case registernewuser                    = "registernewuser"
    
    case requestMailCode                    = "requestMailCode"
    
    case loginPhone                         = "loginPhone"
    
    case checkEmailCode                     = "checkEmailCode"
    
    case changePassword                     = "changePassword"
    
    case doQueryConversation                = "doQueryConversation"

    case doQueryConversationForPurchase                = "doQueryConversationForPurchase"

    case doGetProducts                      = "doGetProducts"

    case inAppPurchaseComplete              = "inAppPurchaseComplete"
    
    case doPurchaseConversation             = "doPurchaseConversation"
    
    case doQueryConvoStats             = "doQueryConvoStats"
    
    case sendConvoAllPaid               = "send-convo-all-paid";

}

class CommError {
    static let global = CommError()
    static var alertController: Optional<UIAlertController> = nil;
    
    private init() { }
    
    func ShowMessage(msg : String) {
        if(CommError.alertController == nil){
            CommError.alertController = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) {
                (action) in
                CommError.alertController = nil;
            }
            CommError.alertController!.addAction(okAction)
            CommError.alertController!.show()
        }
    }
}

class WebServices: NSObject {

    static let service = WebServices()
    
    func webServicePostRequest(_ servcieType: ServiceType,_ model: Model, _ methods:Services ,_ parameters: Dictionary<String, Any>?, successHandler success:@escaping (_ response: Dictionary<String, Any>?) -> Void, errorHandler serviceError:@escaping (_ error: Error?) -> Void){
        
        let fullUrlString = "\(baseUrl)?model=\(model)&type=\(methods.rawValue)"
        
        let url = URL(string: fullUrlString)
        var request = URLRequest(url: url!)
        request.httpMethod = servcieType.rawValue
        
        // add token to each request as json parameter
        var params: Dictionary<String, Any> = [:]
        
        if parameters != nil {
            params = parameters!
        }
        
        if let ggToken = UserDefaults.standard.string(forKey: "ggToken") {
            if !ggToken.isEmpty {
                params["ggToken"] = ggToken
            }
        }
        
        do{
            if params.count > 0 {
                request.httpBody = try JSONSerialization.data(withJSONObject: params, 	options: .prettyPrinted)
            }
        }catch let err{
            print(err)
        }
        
        let urlSessionConfiguration = URLSessionConfiguration.default
        let urlSession = URLSession(configuration: urlSessionConfiguration, delegate: nil, delegateQueue: OperationQueue.main)
        let urlSessionData = urlSession.dataTask(with: request) { (data, response, error) in
            if error == nil{
                do{
                    // check for exceptions that happened on the server... comes work but server app threw exeption
                    let dictionary = ProcessInfo.processInfo.environment
                    var isOutResponse = true
                    
                    if let _value = dictionary["OUT_RESPONSE_FROM_SERVER"] {
                        if _value == "0" {
                            isOutResponse = false
                        }
                    }
                    
                    if isOutResponse {
                        print(String.init(data: data!, encoding: .utf8)!)
                        print(response!)
                    }
                    
            	        if let jsonData = data{
                        if (jsonData.count > 0){
                            let json = try JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as! Dictionary<String, 	Any>
                            let status = json["status"] as? String
                            if (status == "syserror"){
                                if let emsg = json["message"] as? String{
                                    CommError.global.ShowMessage(msg:emsg)
                                }
                                else{
                                    CommError.global.ShowMessage(msg:"Oops the gogetter server is having issues right now, please try again later or contact us at support@slindir.com");
                                }
                            }
                            else{
                                if let ggToken = json["ggToken"] as? String {
                                    UserDefaults.standard.set(ggToken, forKey: "ggToken")
                                }
                                
                                success(json)
                            }
                        }
                        else{
                            CommError.global.ShowMessage(msg:"Oops the gogetter server is having issues right now, please try again later or contact us at support@slindir.com");
                        }
                    }else{
                        success(nil)		
                    }
                }catch let err{
                    print(err.localizedDescription)
                    serviceError(err)
                }
            }else{
                // real comm errors come here... use built in IOS default NSUrl domain messsages
                print(error?.localizedDescription)
                serviceError(error)
            }
        }
        urlSessionData.resume()
    }
    
    func webServicePostFileRequest(_ servcieType: ServiceType,_ model: Model, _ methods:Services,_ type:String,_ fileData:Data,_ parameters: Dictionary<String, Any>?, successHandler success:@escaping (_ response: Dictionary<String, Any>?) -> Void, errorHandler serviceError:@escaping (_ error: Error?) -> Void){
        
        let fullUrlString = "\(baseUrl)?model=\(model)&type=\(methods.rawValue)"
        
        let url = URL(string: fullUrlString)
        var request = URLRequest(url: url!)
        request.httpMethod = servcieType.rawValue
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var fileName = String(format:"image%d.jpg",Int(NSTimeIntervalSince1970))
        var mimeType:String = "image/jpg"
        
        if type == "video" {
            mimeType = "application/octet-stream"
            fileName = String(format:"video%d.mp4",Int(NSTimeIntervalSince1970))
        }
        
        // add token to each request as json parameter
        var params: Dictionary<String, Any> = [:]
        
        if parameters != nil {
            params = parameters!
        }
        
        if let ggToken = UserDefaults.standard.string(forKey: "ggToken") {
            if !ggToken.isEmpty {
                params["ggToken"] = ggToken
            }
        }
        
        request.httpBody = createBody(parameters: params as! [String : String],
                                boundary: boundary,
                                data: fileData,
                                mimeType: mimeType,
                                filename: fileName)
        
        let urlSessionConfiguration = URLSessionConfiguration.default
        let urlSession = URLSession(configuration: urlSessionConfiguration, delegate: nil, delegateQueue: OperationQueue.main)
        let urlSessionData = urlSession.dataTask(with: request) { (data, response, error) in
            if error == nil{
                do{
                    if let jsonData = data{
                        let json = try JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as! Dictionary<String, Any>
                        success(json)
                    }else{
                        success(nil)
                    }
                }catch let err{
                    serviceError(err)
                }
            }else{
                serviceError(error)
            }
        }
        urlSessionData.resume()
    }
    
    func createBody(parameters: [String: String],
                    boundary: String,
                    data: Data,
                    mimeType: String,
                    filename: String) -> Data {
        let body = NSMutableData()
        
        let boundaryPrefix = "--\(boundary)\r\n"
        
        for (key, value) in parameters {
            body.appendString(boundaryPrefix)
            body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.appendString(String(format:"%@\r\n",value ))
        }
        
        body.appendString(boundaryPrefix)
        body.appendString("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Type: \(mimeType)\r\n\r\n")
        body.append(data)
        body.appendString("\r\n")
        body.appendString("--".appending(boundary.appending("--")))
        
        return body as Data
    }
    
    func webServicePostVideoFileAndThumbnailRequest(_ servcieType: ServiceType,_ model: Model, _ methods:Services,_ fileData:Data,_ imageData:Data,_ parameters: Dictionary<String, Any>?, successHandler success:@escaping (_ response: Dictionary<String, Any>?) -> Void, errorHandler serviceError:@escaping (_ error: Error?) -> Void){
        
        let fullUrlString = "\(baseUrl)?model=\(model)&type=\(methods.rawValue)"
        
        let url = URL(string: fullUrlString)
        var request = URLRequest(url: url!)
        request.httpMethod = servcieType.rawValue
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let fileName = String(format:"image%d.jpg",Int(NSTimeIntervalSince1970))
        
        let body = NSMutableData()
        
        let boundaryPrefix = "--\(boundary)\r\n"
        
        for (key, value) in parameters! {
            body.appendString(boundaryPrefix)
            body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.appendString(String(format:"%@\r\n",value as! String))
        }
        
        body.appendString(boundaryPrefix)
        body.appendString("Content-Disposition: form-data; name=\"profileVideoThumbnail\"; filename=\"\(fileName)\"\r\n")
        body.appendString("Content-Type: image/jpg\r\n\r\n")
        body.append(imageData)
        body.appendString("\r\n")

        let videoFileName = String(format:"video%d.mp4",Int(NSTimeIntervalSince1970))

        body.appendString(boundaryPrefix)
        body.appendString("Content-Disposition: form-data; name=\"profileVideo\"; filename=\"\(videoFileName)\"\r\n")
        body.appendString("Content-Type: application/octet-stream\r\n\r\n")
        body.append(fileData)
        body.appendString("\r\n")
        body.appendString("--".appending(boundary.appending("--")))
        
        request.httpBody = body as Data
        
        let urlSessionConfiguration = URLSessionConfiguration.default
        let urlSession = URLSession(configuration: urlSessionConfiguration, delegate: nil, delegateQueue: OperationQueue.main)
        let urlSessionData = urlSession.dataTask(with: request) { (data, response, error) in
            if error == nil{
                do{
                    if let jsonData = data{
                        print(String(data: jsonData, encoding: String.Encoding.utf8) ?? "")

                        let json = try JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as! Dictionary<String, Any>
                        success(json)
                    }else{
                        success(nil)
                    }
                }catch let err{
                    serviceError(err)
                }
            }else{
                serviceError(error)
            }
        }
        urlSessionData.resume()
    }

}

public extension UIAlertController {
    func show() {
        let win = UIWindow(frame: UIScreen.main.bounds)
        let vc = UIViewController()
        vc.view.backgroundColor = .clear
        win.rootViewController = vc
        win.windowLevel = UIWindow.Level.alert + 1
        win.makeKeyAndVisible()
        vc.present(self, animated: true, completion: nil)
    }
}

extension NSMutableData {
    func appendString(_ string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: false)
        append(data!)
    }
}
