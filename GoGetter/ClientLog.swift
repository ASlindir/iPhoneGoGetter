import UIKit
import CoreData


public class ClientLog: NSObject {

    public static func WriteClientLog( msgType:String, msg:String){
//        return
        let facebookID = LocalStore.store.getFacebookID()

        var parameters = Dictionary<String, Any>()
        parameters["user_fb_id"] = facebookID

        if let device_id =  UIDevice.current.identifierForVendor?.uuidString{
            parameters["device_id"] = device_id
        }
        else {
            parameters["device_id"] = "notknown"
        }
        parameters["msgtype"] = msgType;
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS "
        let nmsg = formatter.string(from: NSDate() as Date) + " : " + msg
        parameters["msg"] = nmsg;

        WebServices.service.webServicePostRequest(.post, .clientlog, .log, parameters, successHandler: { (response) in
        }, errorHandler: { (error) in  })
    }
}

