//
//  WebHandler.swift
//  TripGroupTrack
//
//  Created by Geetanjali on 14/01/17.
//  Copyright © 2017 Geetanjali. All rights reserved.
//

import UIKit
import Foundation

@objc protocol WebHandlerDelegate
{
    func APIResponseArrived(_ Response:AnyObject, error : String , number : String)
   
   @objc optional func imageUploadResponse(_ Response:AnyObject, error : String)
}
class WebHandler: NSObject
{
    var reachability : Reachability! = nil
    var delegate:WebHandlerDelegate! = nil
   
    static let kMessageNoInternetConnection = "Please check your internet connection" as NSString
    static let somthingWrongMsg = "Network error"
    //"Something went wrong. Please try again."
    
    //static let mainUrl = "http://103.224.243.154/magento/marginfresh/soapapi/core/"
    
    static let mainUrl = "https://marginfresh.com/staging/soapapi/core/"
    static let mainUrl1 = "https://marginfresh.com/staging/soapapi/shopcart/"
    static let mainUrl2 = "https://marginfresh.com/staging/soapapi/deviceid/"
     static let mainUrl3 = "https://marginfresh.com/staging/soapapi/referafriend/"
    
 
    
    static let projectTitle = "Margin Fresh" as NSString
    
    
    func doRequestGet(urlStr : NSString ,number : String)
    {
        DispatchQueue.global(qos: .background).async {
        
        
        let urlStr = urlStr.replacingOccurrences(of: " ", with: "%20")
        self.reachability = Reachability()
        
        if self.reachability!.isReachable
        {
           // print("Internet is Available ")
           
               // Show MBProgressHUD Here
            var config:URLSessionConfiguration!
            var urlSession:URLSession!
        
            config = URLSessionConfiguration.default
            urlSession = URLSession(configuration: config)
        
            // MARK:- HeaderField
            let HTTPHeaderField_ContentType = "Content-Type"
        
            // MARK:- ContentType
            let ContentType_ApplicationJson = "application/json"
        
            //MARK: HTTPMethod
            let HTTPMethod_Get = "GET"
            
            let callURL = URL.init(string: urlStr as String)
        
            var request = URLRequest.init(url: callURL!)
        
            request.timeoutInterval = 120.0 // TimeoutInterval in Second
            request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalCacheData
            request.addValue(ContentType_ApplicationJson, forHTTPHeaderField: HTTPHeaderField_ContentType)
            request.httpMethod = HTTPMethod_Get
        
            let dataTask = urlSession.dataTask(with: request)
            { (data,response,error) in
                if error != nil
                {
                    //return
                    self.delegate.APIResponseArrived([] as AnyObject, error: "0" ,number : number)
                }
                do
                {
                    if data != nil
                    {
                        let resultJson = try JSONSerialization.jsonObject(with: data!, options: []) as? [String:AnyObject]
                
                       // print("Result",resultJson!)
                        self.delegate.APIResponseArrived(resultJson as AnyObject , error: "1",number : number)
                    }
                    else
                    {
                       // print("somthing went worng")
                         self.delegate.APIResponseArrived([] as AnyObject, error: "0",number : number)
                        //self.delegate.somthingWentWorng(error:"Somthing Went Worng")
                    }
                }
                catch
                {
                    print("Error -> \(error)")
                    self.delegate.APIResponseArrived([] as AnyObject , error: "0",number : number)
                }
            }
        
            dataTask.resume()
        }
        else
        {
           // print("Internet is NOT Available")
             WebHandler.showAlertWithTilte(title: WebHandler.projectTitle , message:WebHandler.kMessageNoInternetConnection)
        }
            
        }

    }
    
    func doRequestPost(parameters : AnyObject, urlStr : NSString ,number : String)
    {
         let urlStr = urlStr.replacingOccurrences(of: " ", with: "%20")
        reachability = Reachability()
        
        if reachability!.isReachable
        {
            print("HTTPURL   " + (urlStr as String))
            //declare parameter as a dictionary which contains string as key and value combination. considering inputs are valid
        
            //        let parameters = ["email": "manojrkhole@gmail.com", "password": "qwerty"] as Dictionary<String, String>
        
            //create the url with URL
            let url = URL(string: urlStr as String)! //change the url
        
            //create the session object
            let session = URLSession.shared
        
                //now create the URLRequest object using the url object
            var request = URLRequest(url: url)
        
            request.httpMethod = "POST" //set http method as POST
            request.timeoutInterval = 120.0
            do
            {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
            
            }
            catch let error
            {
                print(error.localizedDescription)
            }
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
        
            //create dataTask using the session object to send data to the server
            let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            guard error == nil else
            {
                self.delegate.APIResponseArrived([] as AnyObject, error: "0",number:  number)
                return

            }
            
            guard let data = data else
            {
                self.delegate.APIResponseArrived([] as AnyObject, error: "0",number: number)
                return

            }
            
            do
            {
                //create json object from data
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]
                {
                   // print(json)
                    // handle json...
                    self.delegate.APIResponseArrived(json as AnyObject, error: "1",number:  number)
                    //  self.delegate.API(jsonDic: json as NSDictionary)
                }
                
            }
            catch let error
            {
                print(error.localizedDescription)
                self.delegate.APIResponseArrived([] as AnyObject, error: "0",number: number)

            }
            })
            task.resume()
            
        }
        else
        {
           // print("Internet is NOT Available")
            WebHandler.showAlertWithTilte(title: WebHandler.projectTitle , message:WebHandler.kMessageNoInternetConnection)
        }
      
    }
    
   
    
    func UploadRequest(parameters:Dictionary<String, String>,urlStr : String ,imageName : String , actualImage : UIImage)
    {
        let url = URL(string: urlStr)
        
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "POST"
        
        let boundary = generateBoundaryString()
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        
        
        let image_data = UIImageJPEGRepresentation(actualImage, 0.0) //UIImagePNGRepresentation(profileImage.image!)
        
        
        
        if(image_data == nil)
        {
            return
        }
        
        
        let body = NSMutableData()
        
        let fname = "test.png"
        let mimetype = "image/png"
        
        
        for (key, value) in parameters
        {
            
            body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n\(value)".data(using: String.Encoding.utf8)!)
            body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
            
        }
        
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition:form-data; name=\"test\"\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append("hi\r\n".data(using: String.Encoding.utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition:form-data; name=\"\(imageName)\"; filename=\"\(fname)\"\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append(image_data!)
        body.append("\r\n".data(using: String.Encoding.utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
        //        print("Body:-", body)
        request.httpBody = body as Data
        _ = URLSession.shared
        
        let task = URLSession.shared.dataTask(with: request as URLRequest)
        {            (
            data, response, error) in
            
            guard let _:Data = data, let _:URLResponse = response  , error == nil else
            {
               // print("error")
                 self.delegate.imageUploadResponse!(error! as AnyObject, error: "0")
                return
            }
            
            let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            self.delegate.imageUploadResponse!(dataString!, error: "1")
            //print(dataString ?? "nothing")
        }
        task.resume()
    }
    func generateBoundaryString() -> String
    {
        return "Boundary-\(UUID().uuidString)"
    }
    
    
    
    
    
   static func showAlertWithTilte(title : NSString , message : NSString)
    {
        DispatchQueue.main.async(execute: {() -> Void in
            let alertController = UIAlertController(title: title as String, message: message as String, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: {(_ action: UIAlertAction) -> Void in
                
                
            }))
            UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: {() -> Void in
            })
        })
    }

    
    
}

















////////////////////
//@IBAction func uploadImage(_ sender: Any)
//{
//    print("Up")
//    //UploadRequest()
//    let temp = WebHandler()
//    temp.delegate=self
//    let data = ["user_id" : "22"]
//    // "http://74.208.12.101/snsapi/save_image.php"
//    
//    temp.UploadRequest(parameters: data, urlStr: "http://74.208.12.101/snsapi/save_image.php", imageName: "photo_pics", actualImage: image.image!)
//    
//    
//}
//func imageUploadResponse(_ Response:AnyObject, error : String)
//{
//    print(Response)
//}
//@IBAction func getServiceCallBtnClicked(_ sender: Any)
//{
//    //Show Indicator
//    myActivityIndicator.startAnimating()
//    //MARK: - Get Request
//    let temp = WebHandler()
//    temp.delegate=self
//    
//    let name = "pqr" as NSString
//    let pass = "pass123" as NSString
//    
//    let url = WebHandler.mainUrl + "user-login?user_name=\(name)&user_password=\(pass)" as NSString
//    
//    print(url)
//    temp.doRequestGet(urlStr:url)
//    
//}
//
//@IBAction func postServiceCallBtnClicked(_ sender: Any)
//{
//    //Show Indicato
//    myActivityIndicator.startAnimating()
//    //MARK: - Get Request
//    let temp = WebHandler()
//    temp.delegate=self
//    
//    let name = "pqr" as String
//    let pass = "pass123" as String
//    
//    let url = WebHandler.mainUrl+"user-login" as NSString
//    
//    print(url)
//    
//    let parameter = ["user_name":name , "user_password":pass]
//    temp.doRequestPost(parameters: parameter as AnyObject, urlStr: url)
//    
//    
//}
////MARK:- Get Request Service Resopnse
//func APIResponseArrived(_ Response:AnyObject, error : String)
//{
//    if error != "0"
//    {
//        if Response is Dictionary<String, AnyObject>
//        {
//            print(Response)
//            let Message = Response["Message"] as! NSString
//            
//            if "success" == Response["Status"] as! String
//            {
//                print(Response)
//                //Hide Indicator
//                myActivityIndicator.isHidden = true
//                myActivityIndicator.stopAnimating()
//                myActivityIndicator.isHidden = true
//                WebHandler.showAlertWithTilte(title: WebHandler.projectTitle , message: Message)
//            }
//            else
//            {
//                //Hide Indicator
//                myActivityIndicator.isHidden = true
//                myActivityIndicator.stopAnimating()
//                WebHandler.showAlertWithTilte(title: WebHandler.projectTitle , message: Message)
//            }
//        }
//    }
//    else
//    {
//        //Hide Indicator
//        myActivityIndicator.isHidden = true
//        myActivityIndicator.stopAnimating()
//        WebHandler.showAlertWithTilte(title: WebHandler.projectTitle , message: WebHandler.somthingWrongMsg as NSString)
//    }
//}

