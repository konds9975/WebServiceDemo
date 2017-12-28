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
    func APIResponseArrived(_ Response:AnyObject, error : String)
   
   @objc optional func imageUploadResponse(_ Response:AnyObject, error : String)
}
class WebHandler: NSObject
{
    var reachability : Reachability! = nil
    var delegate:WebHandlerDelegate! = nil
   
    let kMessageNoInternetConnection = "Server cannot be reached. Please, check your internet connection." as NSString
    static let somthingWrongMsg = "Something went wrong. Please try again."
    
    static let mainUrl = "http://103.224.243.154/wordpress/Woocommerce/"
    
    static let projectTitle = "Web Service Demo" as NSString
    
    
    func doRequestGet(urlStr : NSString )
    {
        reachability = Reachability()
        
        if reachability!.isReachable
        {
            print("Internet is Available ")
           
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
        
            request.timeoutInterval = 60.0 // TimeoutInterval in Second
            request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalCacheData
            request.addValue(ContentType_ApplicationJson, forHTTPHeaderField: HTTPHeaderField_ContentType)
            request.httpMethod = HTTPMethod_Get
        
            let dataTask = urlSession.dataTask(with: request)
            { (data,response,error) in
                if error != nil
                {
                    //return
                    self.delegate.APIResponseArrived([] as AnyObject, error: "0")
                }
                do
                {
                    if data != nil
                    {
                        let resultJson = try JSONSerialization.jsonObject(with: data!, options: []) as? [String:AnyObject]
                
                        print("Result",resultJson!)
                        self.delegate.APIResponseArrived(resultJson as AnyObject , error: "1")
                    }
                    else
                    {
                        print("somthing went worng")
                         self.delegate.APIResponseArrived([] as AnyObject, error: "0")
                        //self.delegate.somthingWentWorng(error:"Somthing Went Worng")
                    }
                }
                catch
                {
                    print("Error -> \(error)")
                    self.delegate.APIResponseArrived([] as AnyObject , error: "0")
                }
            }
        
            dataTask.resume()
        }
        else
        {
            print("Internet is NOT Available")
             WebHandler.showAlertWithTilte(title: WebHandler.projectTitle , message:kMessageNoInternetConnection)
        }
    }
    
    func doRequestPost(parameters : AnyObject, urlStr : NSString)
    {
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
                self.delegate.APIResponseArrived([] as AnyObject, error: "0")
                return

            }
            
            guard let data = data else
            {
                self.delegate.APIResponseArrived([] as AnyObject, error: "0")
                return

            }
            
            do
            {
                //create json object from data
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]
                {
                    print(json)
                    // handle json...
                    self.delegate.APIResponseArrived(json as AnyObject, error: "1")
                    //  self.delegate.API(jsonDic: json as NSDictionary)
                }
                
            }
            catch let error
            {
                print(error.localizedDescription)
                self.delegate.APIResponseArrived([] as AnyObject, error: "0")

            }
            })
            task.resume()
            
        }
        else
        {
            print("Internet is NOT Available")
            WebHandler.showAlertWithTilte(title: WebHandler.projectTitle , message:kMessageNoInternetConnection)
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
        
        
        for (key, value) in parameters {
            
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
